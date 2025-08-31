from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import secrets
import smtplib
from email.mime.text import MIMEText
import os
import jwt
from passlib.context import CryptContext
from app.api.deps import get_db
from app.models import User

router = APIRouter(prefix="/api/v1/auth", tags=["Auth"])

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
JWT_SECRET = os.getenv("JWT_SECRET", "dev_secret_change_me")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
JWT_EXPIRES_MIN = int(os.getenv("JWT_EXPIRES_MIN", "60"))


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    full_name: str | None = None


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


def _hash_password(raw: str) -> str:
    return pwd_context.hash(raw)


def _verify_password(raw: str, hashed: str | None) -> bool:
    if not hashed:
        return False
    return pwd_context.verify(raw, hashed)


def _create_access_token(subject: str) -> str:
    now = datetime.utcnow()
    payload = {
        "sub": subject,
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(minutes=JWT_EXPIRES_MIN)).timestamp()),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def _send_verification_email(to_email: str, token: str):
    verify_base = os.getenv("FRONTEND_BASE_URL", "http://localhost:3000")
    verify_link = f"{verify_base}/verify-email?token={token}"
    subject = "Verify your account"
    body = f"Please click the link to verify your email: {verify_link}"

    smtp_host = os.getenv("SMTP_HOST")
    smtp_port = int(os.getenv("SMTP_PORT", "587"))
    smtp_user = os.getenv("SMTP_USER")
    smtp_pass = os.getenv("SMTP_PASS")
    smtp_from = os.getenv("SMTP_FROM", smtp_user or "no-reply@example.com")

    if not smtp_host:
        # Fallback to log for development
        print(f"[DEV] Verification email to {to_email}: {verify_link}")
        return

    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = smtp_from
    msg['To'] = to_email

    with smtplib.SMTP(smtp_host, smtp_port) as server:
        server.starttls()
        if smtp_user and smtp_pass:
            server.login(smtp_user, smtp_pass)
        server.sendmail(smtp_from, [to_email], msg.as_string())


@router.post("/register", response_model=TokenResponse)
def register(payload: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == payload.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    verify_token = secrets.token_urlsafe(32)
    user = User(
        email=str(payload.email),
        full_name=payload.full_name,
        role="student",
        password_hash=_hash_password(payload.password),
        is_active=False,
        email_verification_token=verify_token,
        last_login_at=datetime.utcnow(),
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    try:
        _send_verification_email(user.email, verify_token)
    except Exception as e:
        print(f"[WARN] Failed to send verification email: {e}")

    token = _create_access_token(user.email)
    return TokenResponse(access_token=token)


@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == str(payload.email)).first()
    if not user or not _verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not user.is_active:
        raise HTTPException(status_code=403, detail="Email not verified")

    user.last_login_at = datetime.utcnow()
    db.add(user)
    db.commit()

    token = _create_access_token(user.email)
    return TokenResponse(access_token=token)


@router.post("/logout")
def logout():
    # Stateless JWT logout is client-side token discard. Endpoint exists for symmetry.
    return {"ok": True}


class VerifyEmailRequest(BaseModel):
    token: str


@router.post("/verify-email")
def verify_email(payload: VerifyEmailRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email_verification_token == payload.token).first()
    if not user:
        raise HTTPException(status_code=400, detail="Invalid or expired token")
    user.is_active = True
    user.email_verified_at = datetime.utcnow()
    user.email_verification_token = None
    db.add(user)
    db.commit()
    return {"ok": True}


def get_user_from_bearer(request: Request, db: Session) -> User | None:
    auth = request.headers.get("Authorization", "")
    if not auth.lower().startswith("bearer "):
        return None
    token = auth.split(" ", 1)[1].strip()
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        email = payload.get("sub")
        if not email:
            return None
        return db.query(User).filter(User.email == email).first()
    except Exception:
        return None


