# backend/app/api/routes/datasources.py
from fastapi import APIRouter, Depends, HTTPException
from typing import List, Optional
from pydantic import BaseModel
from sqlalchemy.orm import Session
from security import get_api_key
from ..deps import get_db
from app.models import DataSource

router = APIRouter(prefix="/api/v1/datasources", tags=["Data Sources"], dependencies=[Depends(get_api_key)])


class DataSourceCreate(BaseModel):
    name: str
    provider: str
    data_type: str
    config: dict


class DataSourceUpdate(BaseModel):
    name: Optional[str] = None
    provider: Optional[str] = None
    data_type: Optional[str] = None
    config: Optional[dict] = None


class DataSourceInDB(BaseModel):
    id: int
    name: str
    provider: str
    data_type: str
    config: dict

    class Config:
        from_attributes = True


@router.post("/", response_model=DataSourceInDB)
def create_datasource(payload: DataSourceCreate, db: Session = Depends(get_db)):
    ds = DataSource(name=payload.name, provider=payload.provider, data_type=payload.data_type, config=payload.config)
    db.add(ds)
    db.commit()
    db.refresh(ds)
    return DataSourceInDB.from_orm(ds)


@router.get("/", response_model=List[DataSourceInDB])
def list_datasources(db: Session = Depends(get_db)):
    items = db.query(DataSource).all()
    return [DataSourceInDB.from_orm(x) for x in items]


@router.get("/{datasource_id}", response_model=DataSourceInDB)
def get_datasource(datasource_id: int, db: Session = Depends(get_db)):
    ds = db.query(DataSource).get(datasource_id)
    if not ds:
        raise HTTPException(status_code=404, detail="Not found")
    return DataSourceInDB.from_orm(ds)


@router.put("/{datasource_id}", response_model=DataSourceInDB)
def update_datasource(datasource_id: int, payload: DataSourceUpdate, db: Session = Depends(get_db)):
    ds = db.query(DataSource).get(datasource_id)
    if not ds:
        raise HTTPException(status_code=404, detail="Not found")
    if payload.name is not None:
        ds.name = payload.name
    if payload.provider is not None:
        ds.provider = payload.provider
    if payload.data_type is not None:
        ds.data_type = payload.data_type
    if payload.config is not None:
        ds.config = payload.config
    db.add(ds)
    db.commit()
    db.refresh(ds)
    return DataSourceInDB.from_orm(ds)


@router.delete("/{datasource_id}", response_model=DataSourceInDB)
def delete_datasource(datasource_id: int, db: Session = Depends(get_db)):
    ds = db.query(DataSource).get(datasource_id)
    if not ds:
        raise HTTPException(status_code=404, detail="Not found")
    db.delete(ds)
    db.commit()
    return DataSourceInDB.from_orm(ds)


