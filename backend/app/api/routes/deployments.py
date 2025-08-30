# backend/app/api/routes/deployments.py
from fastapi import APIRouter, Depends, HTTPException
from typing import Optional
from pydantic import BaseModel
from sqlalchemy.orm import Session
from security import get_api_key
from ..deps import get_db
from app.models import Deployment, DeploymentStatus

router = APIRouter(prefix="/api/v1/deployments", tags=["Deployments"], dependencies=[Depends(get_api_key)])


class DeploymentRequest(BaseModel):
    name: str
    cloud: str
    module: str
    vars: dict


class DeploymentResponse(BaseModel):
    id: int
    name: str
    cloud: str
    module: str
    vars: dict
    status: DeploymentStatus

    class Config:
        from_attributes = True


@router.post("/", response_model=DeploymentResponse)
def create_deployment(payload: DeploymentRequest, db: Session = Depends(get_db)):
    d = Deployment(name=payload.name, cloud=payload.cloud, module=payload.module, vars=payload.vars, status=DeploymentStatus.CREATED)
    db.add(d)
    db.commit()
    db.refresh(d)
    return DeploymentResponse.from_orm(d)


@router.get("/{deployment_id}", response_model=DeploymentResponse)
def get_deployment(deployment_id: int, db: Session = Depends(get_db)):
    d = db.query(Deployment).get(deployment_id)
    if not d:
        raise HTTPException(status_code=404, detail="Not found")
    return DeploymentResponse.from_orm(d)


@router.post("/{deployment_id}/plan", response_model=DeploymentResponse)
def plan_deployment(deployment_id: int, db: Session = Depends(get_db)):
    d = db.query(Deployment).get(deployment_id)
    if not d:
        raise HTTPException(status_code=404, detail="Not found")
    d.status = DeploymentStatus.PLANNED
    db.add(d)
    db.commit()
    db.refresh(d)
    return DeploymentResponse.from_orm(d)


@router.post("/{deployment_id}/apply", response_model=DeploymentResponse)
def apply_deployment(deployment_id: int, db: Session = Depends(get_db)):
    d = db.query(Deployment).get(deployment_id)
    if not d:
        raise HTTPException(status_code=404, detail="Not found")
    d.status = DeploymentStatus.APPLIED
    db.add(d)
    db.commit()
    db.refresh(d)
    return DeploymentResponse.from_orm(d)


@router.post("/{deployment_id}/approve", response_model=DeploymentResponse)
def approve_deployment(deployment_id: int, db: Session = Depends(get_db)):
    d = db.query(Deployment).get(deployment_id)
    if not d:
        raise HTTPException(status_code=404, detail="Not found")
    d.status = DeploymentStatus.AWAITING_APPROVAL
    db.add(d)
    db.commit()
    db.refresh(d)
    return DeploymentResponse.from_orm(d)


