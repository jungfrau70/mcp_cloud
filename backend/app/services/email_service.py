import os
import smtplib
from email.mime.text import MIMEText
from typing import List, Dict, Any
from jinja2 import Template


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


def render_template(template_str: str, context: Dict[str, Any]) -> str:
    tpl = Template(template_str)
    return tpl.render(**context)


def send_email(to: List[str] | str, subject: str, body: str, is_html: bool = False) -> None:
    """Send email via SMTP if configured; else log to console."""
    to_list = [to] if isinstance(to, str) else list(to)
    smtp_host = os.getenv("SMTP_HOST")

    if smtp_host:
        _send_via_smtp(to_list, subject, body, is_html)
        return
    print(f"[DEV] Email to={to_list} subject={subject} body={(body[:200] + '...') if len(body) > 200 else body}")

