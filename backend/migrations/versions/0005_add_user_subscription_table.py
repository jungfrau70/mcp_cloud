"""Add user subscription table

Revision ID: 0005
Revises: 0004
Create Date: 2025-08-30 16:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '0005'
down_revision = '0004'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table('user_subscriptions',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('user_id', sa.Integer(), nullable=False),
    sa.Column('stripe_customer_id', sa.String(), nullable=True),
    sa.Column('stripe_subscription_id', sa.String(), nullable=True),
    sa.Column('plan_id', sa.String(), nullable=True),
    sa.Column('status', sa.String(), nullable=True),
    sa.Column('current_period_start', sa.DateTime(), nullable=True),
    sa.Column('current_period_end', sa.DateTime(), nullable=True),
    sa.Column('cancel_at_period_end', sa.Boolean(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('user_id')
    )
    op.create_index(op.f('ix_user_subscriptions_stripe_customer_id'), 'user_subscriptions', ['stripe_customer_id'], unique=True)
    op.create_index(op.f('ix_user_subscriptions_stripe_subscription_id'), 'user_subscriptions', ['stripe_subscription_id'], unique=True)


def downgrade() -> None:
    op.drop_index(op.f('ix_user_subscriptions_stripe_subscription_id'), table_name='user_subscriptions')
    op.drop_index(op.f('ix_user_subscriptions_stripe_customer_id'), table_name='user_subscriptions')
    op.drop_table('user_subscriptions')
