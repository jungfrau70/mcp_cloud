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
from fastapi import FastAPI, HTTPException, Depends, Security, WebSocket, WebSocketDisconnect, Request
from fastapi.security.api_key import APIKeyHeader
from pydantic import BaseModel
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from typing import List, Optional
from datetime import datetime
import google.generativeai as genai
from models import Base, Deployment, DeploymentStatus, DataSource
from fastapi.middleware.cors import CORSMiddleware # Import CORSMiddleware

from fastapi.responses import StreamingResponse, FileResponse
from rag_service import rag_service_instance
import asyncio
from io import BytesIO

# Markdown to PDF conversion (optional import)
try:
    from markdown_pdf import MarkdownPdf, Section
    HAS_MARKDOWN_PDF = True
except ImportError:
    HAS_MARKDOWN_PDF = False
    print("Warning: markdown_pdf module not available. PDF conversion will be disabled.")

try:
    import pty
    HAS_PTY = True
except Exception:
    HAS_PTY = False

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
        from_attributes = True

# DataSource CRUD를 위한 Pydantic 모델들
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
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

# AI Assistant를 위한 Pydantic 모델
class AgentQueryRequest(BaseModel):
    query: str

# 지식베이스를 위한 모델
class DocumentContentRequest(BaseModel):
    path: str
        
# Markdown to PDF conversion request
class MarkdownToPdfRequest(BaseModel):
    markdown: str
    filename: Optional[str] = "document.md"

# 데이터베이스 URL 환경변수 가져오기 (Docker 환경 우선)
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://mcpuser:mcppassword@mcp_postgres:5432/mcp_db")
print(f"🔗 Database URL: {DATABASE_URL}")

# Gemini API Key 환경변수 가져오기
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "dummy_key")

# API Key for authentication
MCP_API_KEY = os.getenv("MCP_API_KEY", "my_mcp_eagle_tiger")

api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)

async def get_api_key(request: Request):
    # Accept API key via header or `api_key` query parameter
    provided = request.headers.get("x-api-key") or request.query_params.get("api_key")
    # Read current expected key dynamically to respect test-time env overrides
    expected = os.getenv("MCP_API_KEY", MCP_API_KEY)
    if provided == expected:
        return provided
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

tags_metadata = [
    {
        "name": "Health Check",
        "description": "Application health and status endpoints"
    },
    {
        "name": "Data Sources",
        "description": "CRUD operations for cloud data sources and queries"
    },
    {
        "name": "AI Agent",
        "description": "RAG-powered AI agent for natural language queries"
    },
    {
        "name": "Knowledge Base",
        "description": "Knowledge base tree structure and content management"
    },
    {
        "name": "Curriculum",
        "description": "Educational curriculum content and slide management"
    },
    # {
    #     "name": "Document Conversion",
    #     "description": "Markdown to PDF conversion services"
    # },
    {
        "name": "Deployments",
        "description": "Infrastructure deployment lifecycle management"
    },
    {
        "name": "CLI Commands",
        "description": "Read-only CLI command execution for cloud providers"
    },
    {
        "name": "AI Terraform",
        "description": "AI-powered Terraform code generation and validation"
    },
    {
        "name": "AI Analysis",
        "description": "AI-powered cost and security analysis"
    },
    {
        "name": "AI Assistant",
        "description": "AI assistant for interactive queries and support"
    },
    {
        "name": "AI Knowledge",
        "description": "AI knowledge base search and management"
    },
    {
        "name": "AI Infrastructure",
        "description": "AI-powered infrastructure recommendations"
    }
]

app = FastAPI(
    title="Bigs API",
    description="Multi-Cloud Platform for Infrastructure as Code with AI Assistant",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_tags=tags_metadata
)

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

def get_knowledge_base_structure(path, is_root: bool = False, show_hidden: bool = False):
    """ Recursively builds a dictionary representing the directory structure.
    - Directories are ordered alphabetically with 'appendix' placed last.
    - Markdown files are listed under the special key 'files' and sorted alphabetically.
    - show_hidden: If True, includes hidden files and directories (starting with '.')
    """
    structure: dict = {}

    directories: List[str] = []
    markdown_files: List[str] = []

    for item in os.listdir(path):
        # Skip hidden files/directories unless show_hidden is True
        if not show_hidden and item.startswith('.'):
            continue
            
        item_path = os.path.join(path, item)
        if os.path.isdir(item_path):
            directories.append(item)
        elif item.endswith('.md'):
            # Exclude Curriculum.md from the root textbook listing
            if is_root and item.lower() == 'curriculum.md':
                continue
            markdown_files.append(item)

    # Order directories with 'appendix' always at the end (case-insensitive)
    directories.sort(key=lambda name: (name.lower() == 'appendix', name.lower()))

    for directory_name in directories:
        structure[directory_name] = get_knowledge_base_structure(os.path.join(path, directory_name), is_root=False, show_hidden=show_hidden)

    if markdown_files:
        markdown_files.sort()
        structure['files'] = markdown_files

    return structure

# ===================================

# ===================================
# DataSource CRUD Endpoints
# ===================================

@app.post("/api/v1/datasources/", response_model=DataSourceInDB, dependencies=[Depends(get_api_key)], tags=["Data Sources"])
def create_data_source(datasource: DataSourceCreate, db: Session = Depends(get_db)):
    db_datasource = db.query(DataSource).filter(DataSource.name == datasource.name).first()
    if db_datasource:
        raise HTTPException(status_code=400, detail="DataSource with this name already exists")
    new_datasource = DataSource(**datasource.dict())
    db.add(new_datasource)
    db.commit()
    db.refresh(new_datasource)
    return new_datasource

@app.get("/api/v1/datasources/", response_model=List[DataSourceInDB], dependencies=[Depends(get_api_key)], tags=["Data Sources"])
def list_data_sources(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    datasources = db.query(DataSource).offset(skip).limit(limit).all()
    return datasources

@app.get("/api/v1/datasources/{datasource_id}", response_model=DataSourceInDB, dependencies=[Depends(get_api_key)], tags=["Data Sources"])
def get_data_source(datasource_id: int, db: Session = Depends(get_db)):
    db_datasource = db.query(DataSource).filter(DataSource.id == datasource_id).first()
    if db_datasource is None:
        raise HTTPException(status_code=404, detail="DataSource not found")
    return db_datasource

@app.put("/api/v1/datasources/{datasource_id}", response_model=DataSourceInDB, dependencies=[Depends(get_api_key)], tags=["Data Sources"])
def update_data_source(datasource_id: int, datasource: DataSourceUpdate, db: Session = Depends(get_db)):
    db_datasource = db.query(DataSource).filter(DataSource.id == datasource_id).first()
    if db_datasource is None:
        raise HTTPException(status_code=404, detail="DataSource not found")
    
    for key, value in datasource.dict().items():
        setattr(db_datasource, key, value)
    
    db.commit()
    db.refresh(db_datasource)
    return db_datasource

@app.delete("/api/v1/datasources/{datasource_id}", response_model=DataSourceInDB, dependencies=[Depends(get_api_key)], tags=["Data Sources"])
def delete_data_source(datasource_id: int, db: Session = Depends(get_db)):
    db_datasource = db.query(DataSource).filter(DataSource.id == datasource_id).first()
    if db_datasource is None:
        raise HTTPException(status_code=404, detail="DataSource not found")
    db.delete(db_datasource)
    db.commit()
    return db_datasource

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

@app.get("/", tags=["Health Check"])
def read_root():
    return {"message": "MCP Backend is running!"}

@app.get("/health", tags=["Health Check"])
def health_check():
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

@app.post("/api/v1/agent/query", dependencies=[Depends(get_api_key)], tags=["AI Agent"])
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

@app.get("/api/v1/knowledge-base/tree", dependencies=[Depends(get_api_key)], tags=["Knowledge Base"])
async def get_knowledge_base_tree(show_hidden: bool = False):
    """
    지식 베이스의 디렉토리 구조를 JSON 형태로 반환합니다.
    show_hidden: 숨김 파일과 디렉토리(점으로 시작하는)를 포함할지 여부
    """
    try:
        tree = get_knowledge_base_structure(KNOWLEDGE_BASE_DIR, show_hidden=show_hidden)
        return tree
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to read knowledge base structure: {e}")

@app.post("/api/v1/knowledge-base/content", dependencies=[Depends(get_api_key)], tags=["Knowledge Base"])
async def get_document_content(request: DocumentContentRequest):
    """
    요청된 마크다운 파일의 내용을 반환합니다.
    보안을 위해 파일 경로는 mcp_knowledge_base 내로 제한됩니다.
    """
    try:
        # Sanitize the requested path to prevent directory traversal
        # os.path.join will handle the slashes correctly for the OS
        relative_path = os.path.normpath(request.path.strip(r'./\ ')) # Corrected escape sequence here
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


# ===================================
# Curriculum Endpoints
# ===================================
TEXTBOOK_DIR = os.path.join(KNOWLEDGE_BASE_DIR, 'textbook')
SLIDES_DIR = os.path.join(KNOWLEDGE_BASE_DIR, 'slides')

@app.get("/api/v1/curriculum/tree", dependencies=[Depends(get_api_key)], tags=["Curriculum"])
async def get_curriculum_tree():
    """
    Returns the directory structure of the textbook as JSON.
    """
    try:
        # We can reuse the existing helper function
        tree = get_knowledge_base_structure(TEXTBOOK_DIR, is_root=True)
        return tree
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to read curriculum structure: {e}")

@app.get("/api/v1/curriculum/content", dependencies=[Depends(get_api_key)], tags=["Curriculum"])
async def get_curriculum_content(path: str):
    """
    Returns the content of a requested markdown file from the textbook directory.
    """
    try:
        # Sanitize and normalize path (cross-platform)
        normalized = path.replace("\\", "/").lstrip("/ ")
        relative_path = os.path.normpath(normalized)
        print(f"normalized relative_path: {relative_path}")

        secure_path = os.path.join(TEXTBOOK_DIR, relative_path)

        if not os.path.commonpath([TEXTBOOK_DIR]) == os.path.commonpath([TEXTBOOK_DIR, secure_path]):
            raise HTTPException(status_code=400, detail="Invalid file path.")

        if not os.path.exists(secure_path) or not secure_path.endswith('.md'):
            raise HTTPException(status_code=404, detail="File not found or not a markdown file.")

        with open(secure_path, 'r', encoding='utf-8') as f:
            content = f.read()
        return {"path": relative_path, "content": content}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to read content: {e}")

@app.get("/api/v1/slides", dependencies=[Depends(get_api_key)], tags=["Slides"])
async def get_slide_download(textbook_path: str):
    """
    Finds the corresponding slide for a textbook path and returns it for download.
    For now, it returns the markdown content. PDF conversion can be added later.
    """
    try:
        # Normalize incoming URL path for cross-platform handling
        normalized = textbook_path.replace("\\", "/").lstrip("/ ")
        # If caller provided a nested relative path under slides, use it directly
        direct_path = os.path.join(SLIDES_DIR, normalized)
        if os.path.isdir(os.path.dirname(direct_path)) and os.path.exists(direct_path):
            slide_path = direct_path
        else:
            # Search recursively across slides directory
            basename = os.path.basename(normalized)
            topic_base = os.path.splitext(basename)[0]
            topic_base_lower = topic_base.lower()

            found_path: str | None = None

            def walk_files():
                for root, _, files in os.walk(SLIDES_DIR):
                    for name in files:
                        if not name.lower().endswith('.md'):
                            continue
                        yield os.path.join(root, name), name

            # 1) Exact filename match (case-insensitive)
            for fpath, name in walk_files():
                if name.lower() == basename.lower():
                    found_path = fpath
                    break

            # 2) Startswith topic base (e.g., "7-2_advanced_devops*")
            if not found_path:
                for fpath, name in walk_files():
                    if name.lower().startswith(topic_base_lower):
                        found_path = fpath
                        break

            # 3) Contains topic base anywhere
            if not found_path:
                for fpath, name in walk_files():
                    if topic_base_lower in name.lower():
                        found_path = fpath
                        break

            # 4) Remove chapter prefix before first underscore and try contains (e.g., "advanced_devops")
            if not found_path and '_' in topic_base:
                remainder = topic_base.split('_', 1)[1].lower()
                for fpath, name in walk_files():
                    if remainder and remainder in name.lower():
                        found_path = fpath
                        break

            # 5) part/day prefix + any topic (e.g., "3-7_*")
            if not found_path:
                parts = normalized.split('/')
                if len(parts) >= 3 and parts[0].lower().startswith('part') and parts[1].lower().startswith('day'):
                    part_num = parts[0].lower().replace('part', '')
                    day_num = parts[1].lower().replace('day', '')
                    slide_prefix = f"{part_num}-{day_num}_"
                    for fpath, name in walk_files():
                        if name.lower().startswith(slide_prefix):
                            found_path = fpath
                            break

            if not found_path:
                raise HTTPException(status_code=404, detail="Slide mapping is not defined for this document.")

            slide_path = found_path

        # slide_path determined above; compute a safe filename for download header
        found_slide = os.path.basename(slide_path)
        # Try Marp PDF conversion if available; fallback to raw markdown
        import shutil, subprocess, tempfile
        marp_bin = shutil.which("marp")
        if marp_bin:
            with tempfile.TemporaryDirectory() as tmpdir:
                pdf_out = os.path.join(tmpdir, os.path.splitext(found_slide)[0] + ".pdf")
                try:
                    # Optional browser path for puppeteer (Windows/enterprise env)
                    browser_path = os.getenv("MARP_BROWSER_PATH")
                    cmd = [
                        marp_bin,
                        slide_path,
                        "--pdf",
                        "--allow-local-files",
                        "--timeout",
                        os.getenv("MARP_TIMEOUT_MS", "120000"),
                        "-o",
                        pdf_out,
                    ]
                    if browser_path:
                        cmd.extend(["--browser", browser_path])
                    # Allow setting PUPPETEER_EXECUTABLE_PATH via env
                    env = os.environ.copy()
                    if os.getenv("PUPPETEER_EXECUTABLE_PATH"):
                        env["PUPPETEER_EXECUTABLE_PATH"] = os.getenv("PUPPETEER_EXECUTABLE_PATH")
                    subprocess.run(
                        cmd,
                        check=True,
                        capture_output=True,
                        text=True,
                        env=env,
                    )
                    return FileResponse(
                        pdf_out,
                        media_type="application/pdf",
                        filename=os.path.basename(pdf_out),
                    )
                except subprocess.CalledProcessError:
                    pass
        # No marp available or conversion failed: return markdown
        return FileResponse(
            slide_path,
            media_type="text/markdown; charset=utf-8",
            filename=found_slide,
        )

    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get slide: {e}")

# # Generic Markdown -> PDF conversion using Marp (if available)
# @app.post("/api/v1/slides/pdf", dependencies=[Depends(get_api_key)], tags=["Slides"])
# async def convert_markdown_to_pdf(req: MarkdownToPdfRequest):
#     try:
#         import shutil, tempfile, subprocess, os as _os
#         marp_bin = shutil.which("marp")
#         # Write markdown to temp file
#         with tempfile.TemporaryDirectory() as tmpdir:
#             md_path = _os.path.join(tmpdir, req.filename or "document.md")
#             with open(md_path, "w", encoding="utf-8") as f:
#                 f.write(req.markdown)
#             if marp_bin:
#                 pdf_out = _os.path.join(tmpdir, _os.path.splitext(_os.path.basename(md_path))[0] + ".pdf")
#                 try:
#                     subprocess.run([marp_bin, md_path, "--pdf", "--allow-local-files", "-o", pdf_out],
#                                    check=True, capture_output=True, text=True)
#                     return FileResponse(pdf_out, media_type="application/pdf",
#                                          filename=_os.path.basename(pdf_out))
#                 except subprocess.CalledProcessError as e:
#                     raise HTTPException(status_code=500, detail=f"Marp conversion failed: {e.stderr or e.stdout}")
#             # Fallback: return markdown if Marp not available
#             return FileResponse(md_path, media_type="text/markdown; charset=utf-8",
#                                  filename=_os.path.basename(md_path))
#     except HTTPException:
#         raise
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Failed to convert markdown: {e}")

@app.get("/api/v1/slides/{slide_name}/pdf", dependencies=[Depends(get_api_key)], tags=["Slides"])
async def get_slide_pdf(slide_name: str):
    """
    Converts a specified slide markdown file to PDF and returns it.
    """
    try:
        # Sanitize the slide_name to prevent directory traversal
        # Use os.path.abspath to get the absolute path, then check if it's within SLIDES_DIR
        requested_path = os.path.join(SLIDES_DIR, slide_name.strip(r'./\ '))
        print(requested_path)
        
        # Ensure the file is a markdown file
        if not requested_path.endswith('.md'):
            requested_path += '.md'

        # Resolve the real path to handle '..' and symlinks
        real_path = os.path.realpath(requested_path)

        # Security Check: Ensure the real path is within the SLIDES_DIR
        if not real_path.startswith(os.path.realpath(SLIDES_DIR)):
            raise HTTPException(status_code=400, detail="Invalid or malicious slide name.")

        slide_path = real_path # Use the real_path for opening the file

        if not os.path.exists(slide_path):
            raise HTTPException(status_code=404, detail="Slide not found.")

        # Read markdown content
        with open(slide_path, 'r', encoding='utf-8') as f:
            markdown_content = f.read()

        # Convert markdown to PDF
        if not HAS_MARKDOWN_PDF:
            # Fallback: return markdown content as text
            return StreamingResponse(
                iter([markdown_content]),
                media_type="text/markdown",
                headers={'Content-Disposition': f'attachment; filename="{os.path.splitext(slide_name)[0]}.md"'}
            )
            
        # Use MarkdownPdf if available
        pdf = MarkdownPdf()
        pdf.add_section(Section(markdown_content, toc=False))
        
        # Save PDF to a BytesIO object
        buffer = BytesIO()
        pdf.save(buffer)
        buffer.seek(0) # Rewind to the beginning of the buffer

        return StreamingResponse(
            buffer,
            media_type="application/pdf",
            headers={'Content-Disposition': f'attachment; filename="{os.path.splitext(slide_name)[0]}.pdf"'}
        )

    except HTTPException as e:
        raise e
    except Exception as e:
        print(f"Error during PDF conversion: {e}") # Added for debugging
        raise HTTPException(status_code=500, detail=f"Failed to convert slide to PDF: {e}")




@app.post("/api/v1/deployments/", response_model=DeploymentResponse, dependencies=[Depends(get_api_key)], tags=["Deployments"])
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

@app.get("/api/v1/deployments/{deployment_id}", response_model=DeploymentResponse, tags=["Deployments"])
def get_deployment(deployment_id: int, db: Session = Depends(get_db)):
    deployment = db.query(Deployment).filter(Deployment.id == deployment_id).first()
    if not deployment:
        raise HTTPException(status_code=404, detail="Deployment not found")
    return deployment

@app.post("/api/v1/deployments/{deployment_id}/review_with_gemini", response_model=GeminiReviewResponse, dependencies=[Depends(get_api_key)], tags=["Deployments"])
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
        # existing
        "get-caller-identity": ["aws", "sts", "get-caller-identity"],
        # frontend expects these
        "s3_ls": ["aws", "s3", "ls"],
        "ec2_describe_instances": ["aws", "ec2", "describe-instances"],
        "iam_list_users": ["aws", "iam", "list-users"],
        "vpc_describe_vpcs": ["aws", "ec2", "describe-vpcs"],
    },
    "gcp": {
        # existing
        "auth-list": ["gcloud", "auth", "list"],
        # frontend expects these
        "gcloud_zones_list": ["gcloud", "compute", "zones", "list"],
        "gcloud_projects_list": ["gcloud", "projects", "list"],
        "gcloud_storage_buckets_list": ["gcloud", "storage", "buckets", "list"],
        "gcloud_compute_instances_list": ["gcloud", "compute", "instances", "list"],
    }
}

@app.post("/api/v1/cli/read-only-legacy", response_model=ReadOnlyCliResponse, dependencies=[Depends(get_api_key)], tags=["CLI Commands"])
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
@app.post("/api/v1/cli/read-only", response_model=ReadOnlyCliResponse, dependencies=[Depends(get_api_key)], tags=["CLI Commands"])
def run_readonly_cli_command_v1(request: ReadOnlyCliRequest):
    return run_readonly_cli_command(request)

@app.post("/api/v1/deployments/{deployment_id}/plan", response_model=DeploymentResponse, dependencies=[Depends(get_api_key)], tags=["Deployments"])
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

@app.post("/api/v1/deployments/{deployment_id}/apply", response_model=DeploymentResponse, dependencies=[Depends(get_api_key)], tags=["Deployments"])
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

@app.post("/api/v1/deployments/{deployment_id}/approve", response_model=DeploymentResponse, dependencies=[Depends(get_api_key)], tags=["Deployments"])
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

@app.post("/api/v1/data-sources/query", response_model=DataSourceResponse, dependencies=[Depends(get_api_key)], tags=["Data Sources"])
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

# Backward-compatible API without versioned prefix
@app.post("/api/v1/data-sources/query-legacy", response_model=DataSourceResponse, dependencies=[Depends(get_api_key)], tags=["Data Sources"])
def query_data_source_legacy(request: DataSourceRequest):
    return query_data_source(request)

# AI Agent 고도화 기능을 위한 새로운 API 엔드포인트들

@app.post("/api/v1/ai/terraform/generate", dependencies=[Depends(get_api_key)], tags=["AI Terraform"])
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

@app.post("/api/v1/ai/terraform/validate", dependencies=[Depends(get_api_key)], tags=["AI Terraform"])
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

@app.post("/api/v1/ai/cost/analyze", dependencies=[Depends(get_api_key)], tags=["AI Analysis"])
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

@app.post("/api/v1/ai/security/audit", dependencies=[Depends(get_api_key)], tags=["AI Analysis"])
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

@app.post("/api/v1/ai/assistant/query", dependencies=[Depends(get_api_key)], tags=["AI Assistant"])
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

@app.post("/api/v1/ai/assistant/query-sync", dependencies=[Depends(get_api_key)], tags=["AI Assistant"])
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

@app.get("/api/v1/ai/knowledge/search", dependencies=[Depends(get_api_key)], tags=["AI Knowledge"])
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

@app.post("/api/v1/ai/knowledge/update", dependencies=[Depends(get_api_key)], tags=["AI Knowledge"])
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

@app.post("/api/v1/ai/infrastructure/recommend", dependencies=[Depends(get_api_key)], tags=["AI Infrastructure"])
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


@app.websocket("/ws/v1/cli/interactive")
async def websocket_interactive_cli(websocket: WebSocket):
    await websocket.accept()
    
    # 첫 번째 메시지에서 API 키 인증 처리
    try:
        auth_message = await websocket.receive_text()
        auth_data = json.loads(auth_message)
        
        if auth_data.get('type') == 'auth':
            provided_key = auth_data.get('api_key')
            expected_key = os.getenv("MCP_API_KEY", MCP_API_KEY)
            
            if provided_key != expected_key:
                await websocket.send_text("Authentication failed. Invalid API key.")
                await websocket.close()
                return
        else:
            await websocket.send_text("Authentication required. Please provide API key.")
            await websocket.close()
            return
    except (json.JSONDecodeError, KeyError):
        await websocket.send_text("Invalid authentication message format.")
        await websocket.close()
        return
    
    if not HAS_PTY:
        await websocket.send_text("Interactive shell is not supported on this platform.")
        await websocket.close()
        return
    
    # This is a simplified implementation using a local pty.
    # For enhanced security, this should be executed inside a Docker container.
    master_fd, slave_fd = pty.openpty()
    
    # Start a shell process
    shell_process = await asyncio.create_subprocess_shell(
        'sh',
        stdin=slave_fd,
        stdout=slave_fd,
        stderr=slave_fd,
        close_fds=True
    )

    # Task to forward output from shell to websocket
    async def forward_output():
        import select
        while True:
            r, _, _ = select.select([master_fd], [], [], 0)
            if r:
                try:
                    output = os.read(master_fd, 1024)
                    if output:
                        await websocket.send_text(output.decode())
                    else:
                        break # EOF
                except (WebSocketDisconnect, OSError):
                    break
            await asyncio.sleep(0.01)

    # Task to forward input from websocket to shell
    async def forward_input():
        try:
            while True:
                data = await websocket.receive_text()
                os.write(master_fd, data.encode())
        except WebSocketDisconnect:
            pass # Client disconnected

    output_task = asyncio.create_task(forward_output())
    input_task = asyncio.create_task(forward_input())

    try:
        await asyncio.gather(output_task, input_task)
    finally:
        # Cleanup
        output_task.cancel()
        input_task.cancel()
        os.close(master_fd)
        os.close(slave_fd)
        if shell_process.returncode is None:
            shell_process.terminate()
            await shell_process.wait()
        print("Interactive session closed.")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
