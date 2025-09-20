"""
Add auth columns to users table

Revision ID: 0006_add_user_auth_columns
Revises: 0005_add_user_subscription_table
Create Date: 2025-08-31
"""

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '0006_add_user_auth_columns'
down_revision = '0005'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Add columns if not exists pattern via try/except is not supported directly; rely on Alembic to apply once
    with op.batch_alter_table('users') as batch_op:
        batch_op.add_column(sa.Column('password_hash', sa.String(), nullable=True))
        batch_op.add_column(sa.Column('is_active', sa.Boolean(), nullable=False, server_default=sa.text('false')))
        batch_op.add_column(sa.Column('email_verification_token', sa.String(), nullable=True))
        batch_op.add_column(sa.Column('email_verified_at', sa.DateTime(), nullable=True))

    # Create index for verification token lookups
    op.create_index('ix_users_email_verification_token', 'users', ['email_verification_token'], unique=False)

    # Remove server_default to keep app-level defaults going forward
    with op.batch_alter_table('users') as batch_op:
        batch_op.alter_column('is_active', server_default=None)


def downgrade() -> None:
    # Drop index then columns
    op.drop_index('ix_users_email_verification_token', table_name='users')
    with op.batch_alter_table('users') as batch_op:
        batch_op.drop_column('email_verified_at')
        batch_op.drop_column('email_verification_token')
        batch_op.drop_column('is_active')
        batch_op.drop_column('password_hash')


