from sqlalchemy.orm import declarative_base

# Single SQLAlchemy Base for new modular models
Base = declarative_base()

__all__ = ["Base"]


