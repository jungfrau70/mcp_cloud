# backend/main.py
# =========================
# FastAPI 애플리케이션의 메인 파일
import os
import json
from dotenv import load_dotenv

# Load environment variables from .env file (if exists)
env_path = os.path.join(os.path.dirname(__file__), 'env', '.env')
if os.path.exists(env_path):
    load_dotenv(dotenv_path=env_path)

import subprocess
import tempfile
import shutil
from fastapi import FastAPI, HTTPException, Depends, Security
from fastapi.security.api_key import APIKeyHeader
from pydantic import BaseModel
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from typing import List, Optional
from datetime import datetime
import google.generativeai as genai
from models import Base, Deployment, DeploymentStatus
from fastapi.middleware.cors import CORSMiddleware # Import CORSMiddleware

from fastapi.responses import StreamingResponse
from rag_service import rag_service_instance
import asyncio

# Pydantic 모델 정의
class TerraformContent(BaseModel):
    module_code: str

class ReadOnlyCliRequest(BaseModel):
    provider: str
    command_name: str
    args: Optional[dict] = {}

class ReadOnlyCliResponse(BaseModel):
    success: bool
    stdout: Optional[str] = None
    stderr: Optional[str] = None

class GeminiReviewResponse(BaseModel):
    summary: str
    issues: List[str] = []

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
    created_at: datetime
    updated_at: datetime
    terraform_plan_output: Optional[str] = None
    terraform_apply_log: Optional[str] = None
    gemini_review_summary: Optional[str] = None
    gemini_review_issues: Optional[List[str]] = None

class DataSourceRequest(BaseModel):
    provider: str
    data_type: str
    data_name: str
    config: dict

class DataSourceResponse(BaseModel):
    success: bool
    output: Optional[dict] = None
    error: Optional[str] = None
    
    class Config:
        orm_mode = True

# AI Assistant를 위한 Pydantic 모델
class AgentQueryRequest(BaseModel):
    query: str

# 지식베이스를 위한 모델
class DocumentContentRequest(BaseModel):
    path: str
        
# 데이터베이스 URL 환경변수 가져오기 (Docker 환경 우선)
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://mcpuser:mcppassword@mcp_postgres:5432/mcp_db")
print(f"🔗 Database URL: {DATABASE_URL}")

# Gemini API Key 환경변수 가져오기
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "dummy_key")

# API Key for authentication
MCP_API_KEY = os.getenv("MCP_API_KEY", "my_mcp_eagle_tiger")

api_key_header = APIKeyHeader(name="X-API-Key", auto_error=True)

async def get_api_key(api_key: str = Security(api_key_header)):
    if api_key == MCP_API_KEY:
        return api_key
    else:
        raise HTTPException(status_code=403, detail="Could not validate credentials")

# SQLAlchemy 엔진 생성 (에러 처리 추가)
try:
    engine = create_engine(DATABASE_URL, echo=False)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    
    # 데이터베이스 연결 테스트 (SQLAlchemy 2.0 호환)
    from sqlalchemy import text
    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))
        print("Database connection successful!")
        
except Exception as e:
    print(f"Database connection failed: {e}")
    print("Using in-memory database for now...")
    # SQLite 인메모리 데이터베이스로 폴백
    engine = create_engine("sqlite:///:memory:", echo=False)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 데이터베이스 테이블 생성 (에러 처리 추가)
try:
    Base.metadata.create_all(bind=engine)
    print("Database tables created successfully!")
except Exception as e:
    print(f"Failed to create database tables: {e}")

app = FastAPI()

# CORS Middleware
origins = [
    "http://localhost",
    "http://localhost:3000", # React frontend origin
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ===================================
# Constants & Helper Functions
# ===================================
KNOWLEDGE_BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'mcp_knowledge_base'))

def get_knowledge_base_structure(path):
    """ Recursively builds a dictionary representing the directory structure. """
    structure = {}
    for item in os.listdir(path):
        item_path = os.path.join(path, item)
        if os.path.isdir(item_path):
            structure[item] = get_knowledge_base_structure(item_path)
        elif item.endswith('.md'):
            if 'files' not in structure:
                structure['files'] = []
            structure['files'].append(item)
    # Sort files for consistent ordering
    if 'files' in structure:
        structure['files'].sort()
    return structure

# ===================================

# Gemini API 설정
genai.configure(api_key=GEMINI_API_KEY)

def run_terraform_command(command: List[str], working_dir: str):
    """
    지정된 디렉터리에서 Terraform 명령어를 실행합니다.
    """
    try:
        result = subprocess.run(
            command,
            cwd=working_dir,
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        # Re-raise the exception to be handled by the caller
        raise e
    except FileNotFoundError:
        raise HTTPException(status_code=500, detail="Terraform 실행 파일을 찾을 수 없습니다.")

@app.get("/")
def read_root():
    return {"message": "MCP Backend is running!"}

@app.get("/health")
def health_check():
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

@app.post("/api/v1/agent/query", dependencies=[Depends(get_api_key)])
async def agent_query(request: AgentQueryRequest):
    """
    사용자 쿼리를 받아 RAG 체인을 통해 스트리밍 응답을 반환합니다.
    """
    if not rag_service_instance:
        raise HTTPException(status_code=503, detail="RAG service is not available.")
    
    try:
        return StreamingResponse(
            rag_service_instance.query_stream(request.query), 
            media_type="text/event-stream"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred in the RAG service: {e}")

@app.get("/api/v1/knowledge-base/tree", dependencies=[Depends(get_api_key)])
async def get_knowledge_base_tree():
    """
    지식 베이스의 디렉토리 구조를 JSON 형태로 반환합니다.
    """
    try:
        tree = get_knowledge_base_structure(KNOWLEDGE_BASE_DIR)
        return tree
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to read knowledge base structure: {e}")

@app.post("/api/v1/knowledge-base/content", dependencies=[Depends(get_api_key)])
async def get_document_content(request: DocumentContentRequest):
    """
    요청된 마크다운 파일의 내용을 반환합니다.
    보안을 위해 파일 경로는 mcp_knowledge_base 내로 제한됩니다.
    """
    try:
        # Sanitize the requested path to prevent directory traversal
        # os.path.join will handle the slashes correctly for the OS
        relative_path = os.path.normpath(request.path.strip(r'./\ '))
        secure_path = os.path.join(KNOWLEDGE_BASE_DIR, relative_path)

        # Security Check: Ensure the final path is within the knowledge base directory
        if not os.path.commonpath([KNOWLEDGE_BASE_DIR]) == os.path.commonpath([KNOWLEDGE_BASE_DIR, secure_path]):
            raise HTTPException(status_code=400, detail="Invalid or malicious file path.")

        if not os.path.exists(secure_path) or not secure_path.endswith('.md'):
            raise HTTPException(status_code=404, detail="File not found or not a markdown file.")

        with open(secure_path, 'r', encoding='utf-8') as f:
            content = f.read()
        return {"path": relative_path, "content": content}

    except HTTPException as e:
        # Re-raise HTTP exceptions to let FastAPI handle them
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to read document content: {e}")



@app.post("/deployments/", response_model=DeploymentResponse, dependencies=[Depends(get_api_key)])
def create_deployment(request: DeploymentRequest, db: Session = Depends(get_db)):
    new_deployment = Deployment(
        name=request.name,
        cloud=request.cloud,
        module=request.module,
        vars=request.vars,
        status=DeploymentStatus.CREATED
    )
    db.add(new_deployment)
    db.commit()
    db.refresh(new_deployment)
    return new_deployment

@app.get("/deployments/{deployment_id}", response_model=DeploymentResponse)
def get_deployment(deployment_id: int, db: Session = Depends(get_db)):
    deployment = db.query(Deployment).filter(Deployment.id == deployment_id).first()
    if not deployment:
        raise HTTPException(status_code=404, detail="Deployment not found")
    return deployment

@app.post("/deployments/{deployment_id}/review_with_gemini", response_model=GeminiReviewResponse, dependencies=[Depends(get_api_key)])
async def review_terraform_with_gemini(deployment_id: int, content: TerraformContent, db: Session = Depends(get_db)):
    deployment = db.query(Deployment).filter(Deployment.id == deployment_id).first()
    if not deployment:
        raise HTTPException(status_code=404, detail="Deployment not found")
        
    try:
        model = genai.GenerativeModel('gemini-1.5-flash')
        
        prompt = f"""
        다음 Terraform 모듈 코드를 분석하고, 유효성 검증 및 보안 취약점을 검토해줘.
        1. HCL(HashiCorp Configuration Language) 문법 오류가 없는지 확인해줘.
        2. 변수(variables)와 출력(outputs)이 명확하게 정의되었는지 확인해줘.
        3. 일반적인 보안 취약점(예: 하드코딩된 비밀번호)이 없는지 확인해줘.
        4. 모듈의 목적과 기능을 100자 내외로 요약해줘. 
        
        응답은 반드시 아래와 같은 JSON 형식으로 해줘:
        {{
            "summary": "모듈에 대한 요약",
            "issues": ["이슈 1", "이슈 2", "..."]
        }}

        ---
        Terraform Code:
        {content.module_code}
        ---
        """
        
        response = await model.generate_content_async(
            prompt,
            generation_config=genai.types.GenerationConfig(
                response_mime_type="application/json"
            )
        )
        
        gemini_result = json.loads(response.text)
        
        deployment.gemini_review_summary = gemini_result.get("summary")
        deployment.gemini_review_issues = gemini_result.get("issues")
        db.commit()
        db.refresh(deployment)
        
        return GeminiReviewResponse(**gemini_result)
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An unexpected error occurred: {e}")

READ_ONLY_COMMAND_WHITELIST = {
    "aws": {
        "get-caller-identity": ["aws", "sts", "get-caller-identity"]
    },
    "gcp": {
        "auth-list": ["gcloud", "auth", "list"]
    }
}

@app.post("/cli/read-only", response_model=ReadOnlyCliResponse, dependencies=[Depends(get_api_key)])
def run_readonly_cli_command(request: ReadOnlyCliRequest):
    """
    Executes a whitelisted, read-only CLI command for AWS or GCP.
    """
    provider_commands = READ_ONLY_COMMAND_WHITELIST.get(request.provider)
    if not provider_commands:
        raise HTTPException(status_code=400, detail=f"Provider '{request.provider}' is not supported.")

    command_template = provider_commands.get(request.command_name)
    if not command_template:
        raise HTTPException(status_code=400, detail=f"Command '{request.command_name}' is not a valid or allowed read-only command.")

    # Basic argument handling (more sophisticated validation can be added)
    command = command_template.copy()
    if request.args:
        for key, value in request.args.items():
            command.append(f"--{key}")
            command.append(str(value))

    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=False # We handle the return code manually
        )
        
        success = result.returncode == 0
        return ReadOnlyCliResponse(
            success=success,
            stdout=result.stdout.strip(),
            stderr=result.stderr.strip()
        )

    except FileNotFoundError:
        raise HTTPException(status_code=500, detail=f"Could not find the command for provider '{request.provider}'. Is the CLI installed?")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An unexpected error occurred: {e}")

# Backward-compatible API under versioned prefix
@app.post("/api/v1/cli/read-only", response_model=ReadOnlyCliResponse, dependencies=[Depends(get_api_key)])
def run_readonly_cli_command_v1(request: ReadOnlyCliRequest):
    return run_readonly_cli_command(request)

@app.post("/deployments/{deployment_id}/plan", response_model=DeploymentResponse, dependencies=[Depends(get_api_key)])
def run_plan(deployment_id: int, db: Session = Depends(get_db)):
    deployment = db.query(Deployment).filter(Deployment.id == deployment_id).first()
    if not deployment:
        raise HTTPException(status_code=404, detail="Deployment not found")
        
    if deployment.status not in [DeploymentStatus.CREATED, DeploymentStatus.FAILED]:
        raise HTTPException(status_code=400, detail=f"Cannot run plan for deployment with status: {deployment.status}")

    # Note: This path needs to be flexible for local vs. container execution.
    # For now, we assume a 'terraform_modules' directory exists at the project root.
    module_path = os.path.join("terraform_modules", deployment.module)
    if not os.path.isdir(module_path):
        raise HTTPException(status_code=404, detail=f"Terraform module not found at: {module_path}")

    try:
        plan_output = run_terraform_command(
            ["terraform", "plan"], # Simplified for now, vars handling needed
            working_dir=module_path
        )
        deployment.status = DeploymentStatus.PLANNED
    except subprocess.CalledProcessError as e:
        plan_output = e.stderr
        deployment.status = DeploymentStatus.FAILED

    deployment.terraform_plan_output = plan_output
    
    db.commit()
    db.refresh(deployment)
    
    return deployment

@app.post("/deployments/{deployment_id}/apply", response_model=DeploymentResponse, dependencies=[Depends(get_api_key)])
def run_apply(deployment_id: int, db: Session = Depends(get_db)):
    deployment = db.query(Deployment).filter(Deployment.id == deployment_id).first()
    if not deployment:
        raise HTTPException(status_code=404, detail="Deployment not found")

    if deployment.status != DeploymentStatus.PLANNED:
        raise HTTPException(status_code=400, detail=f"Cannot run apply for deployment with status: {deployment.status}")

    module_path = os.path.join("terraform_modules", deployment.module)
    
    try:
        apply_log = run_terraform_command(
            ["terraform", "apply", "-auto-approve"], # Simplified
            working_dir=module_path
        )
        deployment.status = DeploymentStatus.APPLIED
    except subprocess.CalledProcessError as e:
        apply_log = e.stderr
        deployment.status = DeploymentStatus.FAILED
    
    deployment.terraform_apply_log = apply_log
    
    db.commit()
    db.refresh(deployment)
    
    return deployment

@app.post("/deployments/{deployment_id}/approve", response_model=DeploymentResponse, dependencies=[Depends(get_api_key)])
def approve_deployment(deployment_id: int, db: Session = Depends(get_db)):
    deployment = db.query(Deployment).filter(Deployment.id == deployment_id).first()
    if not deployment:
        raise HTTPException(status_code=404, detail="Deployment not found")
        
    if deployment.status != DeploymentStatus.PLANNED:
        raise HTTPException(status_code=400, detail=f"Cannot approve deployment with status: {deployment.status}")
        
    deployment.status = DeploymentStatus.AWAITING_APPROVAL
    db.commit()
    db.refresh(deployment)
    
    return deployment

@app.post("/api/v1/data-sources/query", response_model=DataSourceResponse, dependencies=[Depends(get_api_key)])
def query_data_source(request: DataSourceRequest):
    temp_dir = tempfile.mkdtemp()
    try:
        # HCL 생성 (안전한 문자열 조합)
        lines: List[str] = []
        lines.append("terraform {")
        lines.append("  required_providers {")
        lines.append(f"    {request.provider} = {{")
        lines.append(f"      source = \"hashicorp/{request.provider}\"")
        lines.append("    }")
        lines.append("  }")
        lines.append("}")
        lines.append("")
        lines.append(f"provider \"{request.provider}\" {{}}")
        lines.append("")
        lines.append(f"data \"{request.data_type}\" \"{request.data_name}\" {{")
        for k, v in request.config.items():
            if isinstance(v, str):
                lines.append(f"  {k} = \"{v}\"")
            else:
                lines.append(f"  {k} = {json.dumps(v)}")
        lines.append("}")
        lines.append("")
        lines.append("output \"result\" {")
        lines.append(f"  value = data.{request.data_type}.{request.data_name}")
        lines.append("  sensitive = true")
        lines.append("}")
        hcl_config = "\n".join(lines)

        tf_file_path = os.path.join(temp_dir, "main.tf")
        with open(tf_file_path, "w", encoding="utf-8") as f:
            f.write(hcl_config)

        # Terraform init & apply (non-JSON). Use separate 'terraform output -json' for outputs
        run_terraform_command(["terraform", "init", "-input=false"], temp_dir)
        run_terraform_command(["terraform", "apply", "-auto-approve", "-input=false"], temp_dir)

        # 결과 파싱: 'terraform output -json'에서 안전하게 추출
        try:
            outputs_raw = run_terraform_command(["terraform", "output", "-json"], temp_dir)
            output_json = json.loads(outputs_raw)
            result = output_json.get("result", {}).get("value")
        except Exception as parse_err:
            return DataSourceResponse(success=False, error=f"Failed to parse terraform outputs: {parse_err}")

        return DataSourceResponse(success=True, output=result)

    except subprocess.CalledProcessError as e:
        err_text = e.stderr if e.stderr else (e.stdout if e.stdout else "Terraform command failed without stderr/stdout.")
        return DataSourceResponse(success=False, error=err_text)
    except Exception as e:
        print(f"Error in query_data_source: {e}") # Debug print
        return DataSourceResponse(success=False, error=str(e))
    finally:
        shutil.rmtree(temp_dir)

# AI Agent 고도화 기능을 위한 새로운 API 엔드포인트들

@app.post("/ai/terraform/generate", dependencies=[Depends(get_api_key)])
async def generate_terraform_code(request: dict):
    """자연어 요구사항을 바탕으로 Terraform 코드를 생성합니다."""
    try:
        requirements = request.get("requirements", "")
        cloud_provider = request.get("cloud_provider", "aws")
        
        if not requirements:
            raise HTTPException(status_code=400, detail="요구사항이 필요합니다")
        
        if cloud_provider not in ["aws", "gcp"]:
            raise HTTPException(status_code=400, detail="지원되는 클라우드 제공자: aws, gcp")
        
        result = rag_service_instance.generate_terraform_code(requirements, cloud_provider)
        return {"success": True, "result": result}
    
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.post("/ai/terraform/validate", dependencies=[Depends(get_api_key)])
async def validate_terraform_code(request: dict):
    """Terraform 코드의 유효성을 검증합니다."""
    try:
        terraform_code = request.get("terraform_code", "")
        
        if not terraform_code:
            raise HTTPException(status_code=400, detail="Terraform 코드가 필요합니다")
        
        result = rag_service_instance.validate_terraform_code(terraform_code)
        return {"success": True, "result": result}
    
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.post("/ai/cost/analyze", dependencies=[Depends(get_api_key)])
async def analyze_infrastructure_cost(request: dict):
    """인프라 설명을 바탕으로 비용 분석을 수행합니다."""
    try:
        infrastructure_description = request.get("infrastructure_description", "")
        cloud_provider = request.get("cloud_provider", "aws")
        
        if not infrastructure_description:
            raise HTTPException(status_code=400, detail="인프라 설명이 필요합니다")
        
        if cloud_provider not in ["aws", "gcp"]:
            raise HTTPException(status_code=400, detail="지원되는 클라우드 제공자: aws, gcp")
        
        result = rag_service_instance.analyze_cost(infrastructure_description, cloud_provider)
        return {"success": True, "result": result}
    
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.post("/ai/security/audit", dependencies=[Depends(get_api_key)])
async def audit_infrastructure_security(request: dict):
    """인프라 설명을 바탕으로 보안 감사를 수행합니다."""
    try:
        infrastructure_description = request.get("infrastructure_description", "")
        cloud_provider = request.get("cloud_provider", "aws")
        
        if not infrastructure_description:
            raise HTTPException(status_code=400, detail="인프라 설명이 필요합니다")
        
        if cloud_provider not in ["aws", "gcp"]:
            raise HTTPException(status_code=400, detail="지원되는 클라우드 제공자: aws, gcp")
        
        result = rag_service_instance.audit_security(infrastructure_description, cloud_provider)
        return {"success": True, "result": result}
    
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.post("/ai/assistant/query", dependencies=[Depends(get_api_key)])
async def query_ai_assistant(request: dict):
    """AI 어시스턴트에게 질문하고 답변을 받습니다."""
    try:
        question = request.get("question", "")
        
        if not question:
            raise HTTPException(status_code=400, detail="질문이 필요합니다")
        
        # 스트리밍 응답을 위한 제너레이터
        async def generate_response():
            async for chunk in rag_service_instance.query_stream(question):
                yield f"data: {json.dumps({'chunk': chunk}, ensure_ascii=False)}\n\n"
        
        return StreamingResponse(generate_response(), media_type="text/plain")
    
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.post("/ai/assistant/query-sync", dependencies=[Depends(get_api_key)])
async def query_ai_assistant_sync(request: dict):
    """AI 어시스턴트에게 질문하고 동기적으로 답변을 받습니다."""
    try:
        question = request.get("question", "")
        
        if not question:
            raise HTTPException(status_code=400, detail="질문이 필요합니다")
        
        answer = rag_service_instance.query(question)
        return {"success": True, "answer": answer}
    
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.get("/ai/knowledge/search", dependencies=[Depends(get_api_key)])
async def search_knowledge_base(query: str, limit: int = 3):
    """지식베이스에서 관련 문서를 검색합니다."""
    try:
        if not query:
            raise HTTPException(status_code=400, detail="검색 쿼리가 필요합니다")
        
        documents = rag_service_instance.get_similar_documents(query, limit)
        
        # Document 객체를 직렬화 가능한 형태로 변환
        serialized_docs = []
        for doc in documents:
            serialized_docs.append({
                "content": doc.page_content,
                "metadata": doc.metadata
            })
        
        return {"success": True, "documents": serialized_docs}
    
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.post("/ai/knowledge/update", dependencies=[Depends(get_api_key)])
async def update_knowledge_base():
    """지식베이스를 업데이트합니다."""
    try:
        success = rag_service_instance.update_knowledge_base()
        if success:
            return {"success": True, "message": "지식베이스가 성공적으로 업데이트되었습니다"}
        else:
            return {"success": False, "error": "지식베이스 업데이트에 실패했습니다"}
    
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.post("/ai/infrastructure/recommend", dependencies=[Depends(get_api_key)])
async def get_infrastructure_recommendations(request: dict):
    """사용자 요구사항에 따라 인프라 아키텍처를 추천합니다."""
    try:
        requirements = request.get("requirements", "")
        cloud_provider = request.get("cloud_provider", "aws")
        budget_constraint = request.get("budget_constraint", "")
        security_requirements = request.get("security_requirements", "")
        
        if not requirements:
            raise HTTPException(status_code=400, detail="요구사항이 필요합니다")
        
        # 종합적인 인프라 추천을 위한 프롬프트 생성
        prompt = f"""
        다음 요구사항에 따라 {cloud_provider} 클라우드 인프라 아키텍처를 추천해주세요:
        
        요구사항: {requirements}
        예산 제약: {budget_constraint if budget_constraint else '제한 없음'}
        보안 요구사항: {security_requirements if security_requirements else '기본 보안'}
        
        다음 형식으로 JSON 응답을 제공해주세요:
        {{
            "architecture_overview": "전체 아키텍처 개요",
            "recommended_services": ["추천 서비스 목록"],
            "estimated_monthly_cost": "예상 월 비용",
            "security_features": ["보안 기능"],
            "scalability_features": ["확장성 기능"],
            "terraform_modules": ["필요한 Terraform 모듈"],
            "deployment_steps": ["배포 단계"],
            "best_practices": ["모범 사례"],
            "risk_mitigation": ["위험 완화 방안"]
        }}
        """
        
        # Gemini API를 직접 호출하여 추천 생성
        import google.generativeai as genai
        genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel('gemini-pro')
        
        response = model.generate_content(prompt)
        
        try:
            # JSON 응답을 파싱
            import re
            json_match = re.search(r'\{.*\}', response.text, re.DOTALL)
            if json_match:
                result = json.loads(json_match.group())
                return {"success": True, "recommendations": result}
            else:
                return {"success": True, "recommendations": {"raw_response": response.text}}
        except json.JSONDecodeError:
            return {"success": True, "recommendations": {"raw_response": response.text}}
    
    except Exception as e:
        return {"success": False, "error": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
