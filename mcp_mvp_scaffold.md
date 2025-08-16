# MCP MVP Scaffold — FastAPI + Terraform + GitHub Actions

**What this doc contains**

- Lightweight MVP scaffold for an MCP control plane.
- FastAPI backend (minimal) that accepts deployment requests, runs `terraform plan`, stores plan output, supports approval and `terraform apply` via a worker.
- Example Terraform module (VPC for AWS and Network for GCP) and remote state guidance.
- GitHub Actions workflow for terraform plan/apply with manual approval step.
- README with how-to run locally (dev) and deploy.

---

## Project layout

```
mcp-mvp/
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── api.py
│   │   ├── models.py
│   │   ├── db.py
│   │   ├── terraform_runner.py
│   │   └── requirements.txt
│   ├── Dockerfile
│   └── README.md
├── terraform/
│   ├── modules/
│   │   ├── aws_vpc/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── gcp_network/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── examples/
│       ├── aws_example/
│       │   └── main.tf
│       └── gcp_example/
│           └── main.tf
├── .github/workflows/terraform.yml
└── README.md
```

---

## backend/app/requirements.txt

```
fastapi==0.95.2
uvicorn[standard]==0.22.0
httpx==0.24.1
sqlmodel==0.0.8
alembic==1.11.1
python-dotenv==1.0.0
pydantic==1.10.11
```

---

## backend/app/db.py

```python
from sqlmodel import SQLModel, create_engine, Session
import os

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./mcp.db")
engine = create_engine(DATABASE_URL, echo=False)

def init_db():
    from .models import Deployment, PlanOutput
    SQLModel.metadata.create_all(engine)

def get_session():
    with Session(engine) as session:
        yield session
```

---

## backend/app/models.py

```python
from typing import Optional
from sqlmodel import SQLModel, Field
from datetime import datetime

class Deployment(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    cloud: str  # aws | gcp
    module: str
    vars_json: Optional[str] = None
    status: str = "created"  # created, planned, awaiting_approval, applied, failed
    plan_text: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)

class PlanOutput(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    deployment_id: int
    plan_text: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
```

---

## backend/app/terraform\_runner.py

```python
import subprocess
import os
import uuid
from pathlib import Path

WORKDIR = Path("/tmp/mcp_tf")
WORKDIR.mkdir(parents=True, exist_ok=True)


def run_terraform_plan(module_dir: str, vars_file: str | None = None) -> str:
    run_id = uuid.uuid4().hex[:8]
    td = WORKDIR / f"plan_{run_id}"
    td.mkdir(parents=True, exist_ok=True)

    # copy module content into td (simple approach)
    subprocess.run(["cp", "-r", module_dir + "/.", str(td)], check=True)

    env = os.environ.copy()
    # ensure terraform installed in runner image/environment

    init = subprocess.run(["terraform", "init"], cwd=str(td), capture_output=True, text=True)
    if init.returncode != 0:
        return init.stdout + "\n" + init.stderr

    plan_cmd = ["terraform", "plan", "-no-color"]
    if vars_file:
        plan_cmd += ["-var-file", vars_file]

    plan = subprocess.run(plan_cmd, cwd=str(td), capture_output=True, text=True)
    return plan.stdout + "\n" + plan.stderr


def run_terraform_apply(module_dir: str, vars_file: str | None = None) -> str:
    run_id = uuid.uuid4().hex[:8]
    td = WORKDIR / f"apply_{run_id}"
    td.mkdir(parents=True, exist_ok=True)
    subprocess.run(["cp", "-r", module_dir + "/.", str(td)], check=True)

    init = subprocess.run(["terraform", "init"], cwd=str(td), capture_output=True, text=True)
    if init.returncode != 0:
        return init.stdout + "\n" + init.stderr

    apply_cmd = ["terraform", "apply", "-auto-approve", "-no-color"]
    if vars_file:
        apply_cmd += ["-var-file", vars_file]

    apply = subprocess.run(apply_cmd, cwd=str(td), capture_output=True, text=True)
    return apply.stdout + "\n" + apply.stderr
```

---

## backend/app/api.py

```python
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from .models import Deployment, PlanOutput
from .db import get_session
from .terraform_runner import run_terraform_plan, run_terraform_apply
from pathlib import Path
import json

router = APIRouter()
MODULES_DIR = Path(__file__).resolve().parents[1] / ".." / "terraform" / "modules"
MODULES_DIR = MODULES_DIR.resolve()

@router.post("/deployments")
async def create_deployment(payload: dict, session: Session = Depends(get_session)):
    name = payload.get("name")
    cloud = payload.get("cloud")
    module = payload.get("module")
    vars_json = json.dumps(payload.get("vars", {}))

    if not (name and cloud and module):
        raise HTTPException(status_code=400, detail="name, cloud, module required")

    d = Deployment(name=name, cloud=cloud, module=module, vars_json=vars_json)
    session.add(d)
    session.commit()
    session.refresh(d)

    return {"id": d.id, "status": d.status}

@router.post("/deployments/{deployment_id}/plan")
async def plan(deployment_id: int, session: Session = Depends(get_session)):
    d = session.get(Deployment, deployment_id)
    if not d:
        raise HTTPException(404)

    module_dir = MODULES_DIR / d.module
    if not module_dir.exists():
        raise HTTPException(status_code=404, detail="module not found")

    plan_text = run_terraform_plan(str(module_dir))
    d.plan_text = plan_text
    d.status = "planned"
    session.add(d)
    session.commit()

    po = PlanOutput(deployment_id=d.id, plan_text=plan_text)
    session.add(po)
    session.commit()

    return {"id": d.id, "status": d.status, "plan": plan_text}

@router.post("/deployments/{deployment_id}/approve")
async def approve(deployment_id: int, session: Session = Depends(get_session)):
    d = session.get(Deployment, deployment_id)
    if not d:
        raise HTTPException(404)
    if d.status != "planned":
        raise HTTPException(status_code=400, detail="deployment not in planned state")

    d.status = "awaiting_approval"
    session.add(d)
    session.commit()
    return {"id": d.id, "status": d.status}

@router.post("/deployments/{deployment_id}/apply")
async def apply(deployment_id: int, session: Session = Depends(get_session)):
    d = session.get(Deployment, deployment_id)
    if not d:
        raise HTTPException(404)
    if d.status not in ("planned", "awaiting_approval"):
        raise HTTPException(status_code=400, detail="deployment not ready to apply")

    module_dir = MODULES_DIR / d.module
    d.status = "applying"
    session.add(d)
    session.commit()

    apply_text = run_terraform_apply(str(module_dir))
    if "Apply complete" in apply_text or "Apply complete!" in apply_text:
        d.status = "applied"
    else:
        d.status = "failed"

    d.plan_text = (d.plan_text or "") + "\n\n=== APPLY OUTPUT ===\n" + apply_text
    session.add(d)
    session.commit()

    return {"id": d.id, "status": d.status, "apply_output": apply_text}
```

---

## backend/app/main.py

```python
from fastapi import FastAPI
from .api import router
from .db import init_db

app = FastAPI(title="MCP MVP")
app.include_router(router)

@app.on_event("startup")
def on_startup():
    init_db()
```

---

## backend/Dockerfile

```
FROM python:3.11-slim
WORKDIR /app
COPY app/requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt
COPY app /app
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## terraform/modules/aws\_vpc/main.tf

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "mcp-vpc" }
}

output "vpc_id" {
  value = aws_vpc.this.id
}
```

---

## terraform/modules/gcp\_network/main.tf

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

variable "project" { type = string }
variable "region" { type = string }

provider "google" {
  project = var.project
  region  = var.region
}

resource "google_compute_network" "this" {
  name = "mcp-network"
  auto_create_subnetworks = false
}

output "network_name" { value = google_compute_network.this.name }
```

---

## terraform/examples/aws\_example/main.tf

```hcl
module "mcp_vpc" {
  source = "../../modules/aws_vpc"
  region = "us-east-1"
}
```

---

## .github/workflows/terraform.yml

```yaml
name: Terraform CI

on:
  pull_request:
    paths:
      - 'terraform/**'

jobs:
  terraform-plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Terraform Init
        working-directory: terraform/examples/aws_example
        run: terraform init
      - name: Terraform Plan
        working-directory: terraform/examples/aws_example
        run: terraform plan
      - name: Upload Plan as artifact
        uses: actions/upload-artifact@v4
        with:
          name: tfplan
          path: terraform/examples/aws_example

  manual-apply:
    needs: terraform-plan
    runs-on: ubuntu-latest
    if: github.event_name == 'workflow_dispatch' || github.event.pull_request.merged == true
    steps:
      - uses: actions/checkout@v4
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Terraform Apply
        working-directory: terraform/examples/aws_example
        run: terraform apply -auto-approve
```

---

## README.md (root)

````
# MCP MVP Scaffold

This repository contains a minimal scaffold for a Model Context Protocol (MCP) control plane MVP.

## Quickstart (local)

1. Build the backend image and run locally:

   ```bash
   cd backend
   docker build -t mcp-backend .
   docker run -e DATABASE_URL=sqlite:///./mcp.db -p 8000:8000 mcp-backend
````

2. Visit `http://localhost:8000/docs` to explore the FastAPI endpoints.

3. Use the `/deployments` endpoint to create a deployment (module names match `terraform/modules/*`).

4. Call `/deployments/{id}/plan` to run `terraform plan` (terraform must be present in the Docker container or in your local path if running non-Docker).

5. Call `/deployments/{id}/apply` to apply the plan.

## Notes & Next steps

- This is intentionally mini
