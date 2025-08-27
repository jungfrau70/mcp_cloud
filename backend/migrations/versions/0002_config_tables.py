"""config tables

Revision ID: 0002_config_tables
Revises: 0001_initial
Create Date: 2025-08-26

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = '0002_config_tables'
down_revision: Union[str, None] = '0001_initial'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'config_items',
        sa.Column('id', sa.BigInteger(), primary_key=True),
        sa.Column('scope_env', sa.Text(), nullable=True),
        sa.Column('scope_service', sa.Text(), nullable=True),
        sa.Column('scope_tenant', sa.Text(), nullable=True),
        sa.Column('key', sa.Text(), nullable=False),
        sa.Column('value_plain', sa.Text(), nullable=True),
        sa.Column('value_json', sa.JSON(), nullable=True),
        sa.Column('is_secret', sa.Boolean(), nullable=False, server_default=sa.text('false')),
        sa.Column('secret_ciphertext', sa.LargeBinary(), nullable=True),
        sa.Column('secret_key_id', sa.Text(), nullable=True),
        sa.Column('version', sa.Integer(), nullable=False, server_default=sa.text('1')),
        sa.Column('enabled', sa.Boolean(), nullable=False, server_default=sa.text('true')),
        sa.Column('updated_by', sa.Text(), nullable=True),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()')),
    )

    op.create_index(
        'ix_config_items_scope_key_enabled',
        'config_items',
        ['scope_env', 'scope_service', 'scope_tenant', 'key', 'enabled']
    )

    op.create_table(
        'config_audit',
        sa.Column('id', sa.BigInteger(), primary_key=True),
        sa.Column('item_id', sa.BigInteger(), sa.ForeignKey('config_items.id', ondelete='CASCADE'), nullable=False),
        sa.Column('action', sa.Text(), nullable=False),
        sa.Column('diff', sa.JSON(), nullable=True),
        sa.Column('actor', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()')),
    )


def downgrade() -> None:
    op.drop_table('config_audit')
    op.drop_index('ix_config_items_scope_key_enabled', table_name='config_items')
    op.drop_table('config_items')


