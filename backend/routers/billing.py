# backend/routers/billing.py
import os
import stripe
from fastapi import APIRouter, Depends, HTTPException, Request, Header
from sqlalchemy.orm import Session

from backend import models
from backend.dependencies import get_db, get_current_user

# --- Stripe Configuration ---
# Make sure to set these in your .env file for production
STRIPE_API_KEY = os.getenv("STRIPE_API_KEY", "sk_test_...your_test_secret_key")
STRIPE_WEBHOOK_SECRET = os.getenv("STRIPE_WEBHOOK_SECRET", "whsec_...your_webhook_secret")

# These would be the IDs of the Products/Prices you create in your Stripe Dashboard
STRIPE_PRO_PLAN_PRICE_ID = os.getenv("STRIPE_PRO_PLAN_PRICE_ID", "price_1Pb...pro_plan_id")

stripe.api_key = STRIPE_API_KEY

# --- Router Definition ---
router = APIRouter(
    prefix="/api/v1/billing",
    tags=["Billing"],
)

# --- Helper function to manage user subscription ---
def manage_user_subscription(db: Session, user: models.User, customer_id: str, subscription: stripe.Subscription):
    sub, created = get_or_create_subscription(db, user.id)
    
    sub.stripe_customer_id = customer_id
    sub.stripe_subscription_id = subscription.id
    sub.plan_id = subscription.items.data[0].price.id
    sub.status = subscription.status
    sub.current_period_start = subscription.current_period_start
    sub.current_period_end = subscription.current_period_end
    sub.cancel_at_period_end = subscription.cancel_at_period_end

    db.add(sub)
    db.commit()

def get_or_create_subscription(db: Session, user_id: int):
    sub = db.query(models.UserSubscription).filter_by(user_id=user_id).first()
    if sub:
        return sub, False
    else:
        new_sub = models.UserSubscription(user_id=user_id)
        return new_sub, True

# --- API Endpoints ---

@router.post("/checkout-session")
def create_checkout_session(current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Create a Stripe Checkout session for the user to subscribe to the Pro plan."""
    # Check if user already has a subscription
    sub = db.query(models.UserSubscription).filter_by(user_id=current_user.id).first()
    customer_id = sub.stripe_customer_id if sub else None

    if not customer_id:
        customer = stripe.Customer.create(email=current_user.email, name=current_user.full_name)
        customer_id = customer.id

    try:
        checkout_session = stripe.checkout.Session.create(
            customer=customer_id,
            payment_method_types=['card'],
            line_items=[
                {'price': STRIPE_PRO_PLAN_PRICE_ID, 'quantity': 1},
            ],
            mode='subscription',
            success_url=f"https://app.gostock.us/profile?payment_success=true", # Replace with your frontend URL
            cancel_url=f"https://app.gostock.us/profile?payment_canceled=true", # Replace with your frontend URL
        )
        return {"sessionId": checkout_session.id, "url": checkout_session.url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/portal-session")
def create_portal_session(current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Create a Stripe Customer Portal session for the user to manage their subscription."""
    sub = db.query(models.UserSubscription).filter_by(user_id=current_user.id).first()
    if not sub or not sub.stripe_customer_id:
        raise HTTPException(status_code=404, detail="User has no subscription to manage.")

    try:
        portal_session = stripe.billing_portal.Session.create(
            customer=sub.stripe_customer_id,
            return_url=f"https://app.gostock.us/profile", # Replace with your frontend URL
        )
        return {"url": portal_session.url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/webhook")
async def stripe_webhook(request: Request, db: Session = Depends(get_db)):
    """Handle incoming webhooks from Stripe to sync subscription status."""
    payload = await request.body()
    sig_header = request.headers.get('stripe-signature')

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, STRIPE_WEBHOOK_SECRET
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail="Invalid payload")
    except stripe.error.SignatureVerificationError as e:
        raise HTTPException(status_code=400, detail="Invalid signature")

    # Handle the event
    if event['type'] == 'checkout.session.completed':
        session = event['data']['object']
        customer_id = session.get('customer')
        subscription_id = session.get('subscription')
        
        subscription = stripe.Subscription.retrieve(subscription_id)
        user = db.query(models.User).filter(models.User.email == session['customer_details']['email']).first()
        if user:
            manage_user_subscription(db, user, customer_id, subscription)

    elif event['type'] in ['customer.subscription.updated', 'customer.subscription.deleted', 'customer.subscription.created']:
        subscription = event['data']['object']
        customer_id = subscription.get('customer')
        sub_record = db.query(models.UserSubscription).filter_by(stripe_customer_id=customer_id).first()
        if sub_record:
            manage_user_subscription(db, sub_record.user, customer_id, subscription)

    return {"status": "success"}
