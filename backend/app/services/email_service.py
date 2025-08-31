import os
import smtplib
from email.mime.text import MIMEText
from typing import List
import requests


def _send_via_smtp(to_emails: List[str], subject: str, body: str, is_html: bool = False) -> None:
    smtp_host = os.getenv("SMTP_HOST")
    smtp_port = int(os.getenv("SMTP_PORT", "587"))
    smtp_user = os.getenv("SMTP_USER")
    smtp_pass = os.getenv("SMTP_PASS")
    smtp_from = os.getenv("SMTP_FROM", smtp_user or "no-reply@example.com")

    msg = MIMEText(body, "html" if is_html else "plain", _charset="utf-8")
    msg['Subject'] = subject
    msg['From'] = smtp_from
    msg['To'] = ", ".join(to_emails)

    with smtplib.SMTP(smtp_host, smtp_port) as server:
        server.starttls()
        if smtp_user and smtp_pass:
            server.login(smtp_user, smtp_pass)
        server.sendmail(smtp_from, to_emails, msg.as_string())


def _send_via_sendgrid(to_emails: List[str], subject: str, body: str, is_html: bool = False) -> None:
    api_key = os.getenv("SENDGRID_API_KEY")
    sender = os.getenv("SMTP_FROM", "no-reply@example.com")
    content_type = "text/html" if is_html else "text/plain"
    data = {
        "personalizations": [{
            "to": [{"email": e} for e in to_emails],
            "subject": subject
        }],
        "from": {"email": sender},
        "content": [{"type": content_type, "value": body}]
    }
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
    r = requests.post("https://api.sendgrid.com/v3/mail/send", json=data, headers=headers, timeout=10)
    if r.status_code >= 400:
        raise RuntimeError(f"SendGrid error: {r.status_code} {r.text}")


def send_email(to: List[str] | str, subject: str, body: str, is_html: bool = False) -> None:
    """Send email via SMTP if configured; else via SendGrid if API key provided; else log to console."""
    to_list = [to] if isinstance(to, str) else list(to)
    smtp_host = os.getenv("SMTP_HOST")
    sendgrid_key = os.getenv("SENDGRID_API_KEY")

    if smtp_host:
        _send_via_smtp(to_list, subject, body, is_html)
        return
    if sendgrid_key:
        _send_via_sendgrid(to_list, subject, body, is_html)
        return
    print(f"[DEV] Email to={to_list} subject={subject} body={(body[:200] + '...') if len(body) > 200 else body}")

