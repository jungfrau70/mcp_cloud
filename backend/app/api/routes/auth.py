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
from app.services.email_service import render_template, send_email
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
    subject = os.getenv("EMAIL_SUBJECT_VERIFY", "Verify your account")
    # load inline template or external file
    try:
        template_path = os.getenv("EMAIL_TEMPLATE_VERIFY", "/app/app/templates/email/verify_email.html")
        if os.path.exists(template_path):
            with open(template_path, 'r', encoding='utf-8') as f:
                template_str = f.read()
        else:
            template_str = """
            <p>Hello {{ email }},</p>
            <p>Please click the link to verify your email:</p>
            <p><a href='{{ verify_link }}'>{{ verify_link }}</a></p>
            """
        body = render_template(template_str, { 'email': to_email, 'verify_link': verify_link })
        is_html = True
    except Exception:
        body = f"Please click the link to verify your email: {verify_link}"
        is_html = False

    smtp_host = os.getenv("SMTP_HOST")
    smtp_port = int(os.getenv("SMTP_PORT", "587"))
    smtp_user = os.getenv("SMTP_USER")
    smtp_pass = os.getenv("SMTP_PASS")
    smtp_from = os.getenv("SMTP_FROM", smtp_user or "no-reply@example.com")

    if not smtp_host:
        # Fallback to dev log
        print(f"[DEV] Verification email to {to_email}: {verify_link}")
        return

    msg = MIMEText(body, 'html' if is_html else 'plain', _charset='utf-8')
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
    print(f"[DEBUG] Register request received: email={payload.email}, full_name={payload.full_name}")
    existing = db.query(User).filter(User.email == payload.email).first()
    if existing:
        print(f"[DEBUG] Email already exists: {payload.email}")
        raise HTTPException(
            status_code=400, 
            detail={
                "message": "이미 등록된 이메일입니다. 로그인을 시도해보세요.",
                "code": "EMAIL_ALREADY_EXISTS",
                "redirect_to": "/login"
            }
        )

    # Check for test mode to bypass email verification
    is_test_mode = os.getenv("TEST_MODE", "false").lower() == "true"

    verify_token = secrets.token_urlsafe(32) if not is_test_mode else None
    # Determine role: first user becomes admin
    users_count = db.query(User).count()
    default_role = "admin" if users_count == 0 else "student"
    try:
        user = User(
            email=str(payload.email),
            full_name=payload.full_name,
            role=default_role,
            password_hash=_hash_password(payload.password),
            is_active=is_test_mode,  # Activate immediately in test mode
            email_verification_token=verify_token,
            last_login_at=datetime.utcnow(),
        )
        print(f"[DEBUG] Creating user: {user.email}")
        db.add(user)
        db.commit()
        db.refresh(user)
        print(f"[DEBUG] User created successfully: {user.id}")
    except Exception as e:
        print(f"[ERROR] Failed to create user: {str(e)}")
        db.rollback()
        raise HTTPException(status_code=400, detail=f"Failed to create user: {str(e)}")

    if not is_test_mode:
        try:
            _send_verification_email(user.email, verify_token)
        except Exception as e:
            print(f"[WARN] Failed to send verification email: {e}")

    token = _create_access_token(user.email)
    return TokenResponse(access_token=token)


@router.options("/login")
def login_options():
    """Handle CORS preflight request for login"""
    return {"message": "OK"}

@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == str(payload.email)).first()
    if not user or not _verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not user.is_active:
        # Return a structured error so clients can offer resend verification
        raise HTTPException(status_code=403, detail={"code": "EMAIL_NOT_VERIFIED", "message": "Email not verified"})

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


class ResendVerificationRequest(BaseModel):
    email: EmailStr


@router.post("/resend-verification")
def resend_verification(payload: ResendVerificationRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == str(payload.email)).first()
    if not user:
        # Do not leak if user exists
        return {"ok": True}
    if user.is_active:
        return {"ok": True}
    verify_token = user.email_verification_token or secrets.token_urlsafe(32)
    user.email_verification_token = verify_token
    db.add(user)
    db.commit()
    try:
        _send_verification_email(user.email, verify_token)
    except Exception as e:
        print(f"[WARN] Resend verification failed: {e}")
    return {"ok": True}


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str


def _send_password_reset_email(to_email: str, token: str):
    reset_base = os.getenv("FRONTEND_BASE_URL", "http://localhost:3000")
    reset_link = f"{reset_base}/reset-password?token={token}"
    subject = "비밀번호 재설정 요청"
    
    body = f"""
    <html>
    <body>
        <h2>비밀번호 재설정 요청</h2>
        <p>안녕하세요,</p>
        <p>비밀번호 재설정을 요청하셨습니다. 아래 링크를 클릭하여 새 비밀번호를 설정해주세요.</p>
        <p><a href="{reset_link}" style="background-color: #4F46E5; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">비밀번호 재설정</a></p>
        <p>링크가 작동하지 않는 경우, 아래 URL을 복사하여 브라우저에 붙여넣으세요:</p>
        <p>{reset_link}</p>
        <p><strong>주의사항:</strong></p>
        <ul>
            <li>이 링크는 1시간 후에 만료됩니다.</li>
            <li>비밀번호 재설정을 요청하지 않으셨다면 이 이메일을 무시하세요.</li>
        </ul>
        <p>감사합니다.</p>
    </body>
    </html>
    """
    
    smtp_host = os.getenv("SMTP_HOST")
    smtp_port = int(os.getenv("SMTP_PORT", "587"))
    smtp_user = os.getenv("SMTP_USER")
    smtp_pass = os.getenv("SMTP_PASS")
    smtp_from = os.getenv("SMTP_FROM", smtp_user or "no-reply@example.com")

    if not smtp_host:
        # Fallback to dev log
        print(f"[DEV] Password reset email to {to_email}: {reset_link}")
        return

    msg = MIMEText(body, 'html', _charset='utf-8')
    msg['Subject'] = subject
    msg['From'] = smtp_from
    msg['To'] = to_email

    with smtplib.SMTP(smtp_host, smtp_port) as server:
        server.starttls()
        if smtp_user and smtp_pass:
            server.login(smtp_user, smtp_pass)
        server.sendmail(smtp_from, [to_email], msg.as_string())


@router.post("/forgot-password")
def forgot_password(payload: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == str(payload.email)).first()
    if not user:
        # Do not leak if user exists
        return {"ok": True}
    
    # Generate password reset token
    reset_token = secrets.token_urlsafe(32)
    user.password_reset_token = reset_token
    user.password_reset_expires = datetime.utcnow() + timedelta(hours=1)  # 1시간 후 만료
    db.add(user)
    db.commit()
    
    try:
        _send_password_reset_email(user.email, reset_token)
    except Exception as e:
        print(f"[WARN] Password reset email failed: {e}")
    
    return {"ok": True}


@router.post("/reset-password")
def reset_password(payload: ResetPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(
        User.password_reset_token == payload.token,
        User.password_reset_expires > datetime.utcnow()
    ).first()
    
    if not user:
        raise HTTPException(status_code=400, detail="Invalid or expired token")
    
    # Update password
    user.password_hash = _hash_password(payload.new_password)
    user.password_reset_token = None
    user.password_reset_expires = None
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


