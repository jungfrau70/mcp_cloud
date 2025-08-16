"""initial schema

Revision ID: 0001_initial
Revises: 
Create Date: 2025-08-13

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = '0001_initial'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'deployments',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('name', sa.String(), nullable=True),
        sa.Column('cloud', sa.String(), nullable=True),
        sa.Column('module', sa.String(), nullable=True),
        sa.Column('vars', sa.JSON(), nullable=True),
        sa.Column('status', sa.Enum('created','planned','awaiting_approval','applying','applied','failed','destroying','destroyed', name='deploymentstatus'), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.Column('terraform_plan_output', sa.Text(), nullable=True),
        sa.Column('terraform_apply_log', sa.Text(), nullable=True),
        sa.Column('gemini_review_summary', sa.Text(), nullable=True),
        sa.Column('gemini_review_issues', sa.JSON(), nullable=True),
    )


def downgrade() -> None:
    op.drop_table('deployments')


