from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, EmailStr
from typing import List
from security import get_api_key
from app.api.routes.kb import get_current_admin_user as require_admin  # reuse admin guard
from app.services.email_service import send_email

router = APIRouter(prefix="/api/v1/email", tags=["Email"], dependencies=[Depends(get_api_key), Depends(require_admin)])


class SendEmailRequest(BaseModel):
    to: List[EmailStr] | EmailStr
    subject: str
    body: str
    is_html: bool = False


@router.post('/send')
def email_send(req: SendEmailRequest):
    try:
        send_email(req.to, req.subject, req.body, req.is_html)
        return {"ok": True}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


