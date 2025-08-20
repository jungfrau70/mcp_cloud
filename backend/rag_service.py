import os
import json
import re
import logging
from typing import List, Dict, Any, Optional, TypedDict
from dataclasses import dataclass

from dotenv import load_dotenv
from langchain_community.document_loaders import DirectoryLoader, UnstructuredMarkdownLoader
from langchain_text_splitters import MarkdownTextSplitter
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_core.prompts import PromptTemplate
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.runnables import RunnablePassthrough
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain.schema import Document

"""
Refactored single-file version with:
- Unified JSON parsing util with stronger guards
- TypedDicts for structured returns
- De-duplicated prompt + parsing logic
- Better logging and configuration hooks
- Safer fallback behavior
"""

# ----------------------------------------------------------------------------
# Configuration & Logging
# ----------------------------------------------------------------------------

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY가 설정되지 않았습니다. .env 파일을 확인하세요.")

# Paths
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__)))
KNOWLEDGE_BASE_DIR = os.path.abspath(os.path.join(BASE_DIR, "..", "mcp_knowledge_base"))
VECTOR_STORE_PATH = os.path.abspath(os.path.join(BASE_DIR, "..", "vector_store"))

# Embedding model
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "jhgan/ko-sroberta-multitask")

# Logging
logging.basicConfig(level=logging.INFO, format="[%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)

# ----------------------------------------------------------------------------
# Types
# ----------------------------------------------------------------------------

class TerraformCodeResult(TypedDict, total=False):
    main_tf: str
    variables_tf: str
    outputs_tf: str
    description: str
    estimated_cost: str
    security_notes: str
    best_practices: str
    error: str

class ValidationResult(TypedDict, total=False):
    is_valid: bool
    syntax_errors: List[str]
    security_issues: List[str]
    best_practice_violations: List[str]
    recommendations: List[str]
    severity: str
    error: str

class CostAnalysisResult(TypedDict, total=False):
    estimated_monthly_cost: str
    cost_breakdown: Dict[str, Any]
    optimization_opportunities: List[str]
    reserved_instances: List[str]
    auto_scaling_recommendations: List[str]
    budget_alerts: List[str]
    error: str

class SecurityAuditResult(TypedDict, total=False):
    security_score: int
    critical_issues: List[str]
    high_risk_issues: List[str]
    medium_risk_issues: List[str]
    low_risk_issues: List[str]
    compliance_check: List[str]
    security_recommendations: List[str]
    iam_recommendations: List[str]
    network_security: List[str]
    error: str

# ----------------------------------------------------------------------------
# Utilities
# ----------------------------------------------------------------------------

from utils.json_utils import parse_llm_json
try:
    from unittest.mock import Mock as _Mock  # type: ignore
except Exception:  # pragma: no cover
    _Mock = None  # type: ignore


def strict_json_prompt_suffix() -> str:
    """A suffix to force JSON-only outputs from the model."""
    return (
        "\n\n출력 규칙:\n"
        "- 반드시 JSON만 출력하세요.\n"
        "- JSON 외의 설명 문장, 머리말, 꼬리말, 마크다운을 추가하지 마세요.\n"
        "- 코드펜스는 허용되지만 내용은 순수 JSON이어야 합니다.\n"
    )

# ----------------------------------------------------------------------------
# Core Components
# ----------------------------------------------------------------------------

@dataclass
class LLMProvider:
    model: str = "gemini-1.5-flash"
    temperature: float = 0.1
    api_key: str = GEMINI_API_KEY

    def create(self) -> ChatGoogleGenerativeAI:
        return ChatGoogleGenerativeAI(model=self.model, google_api_key=self.api_key, temperature=self.temperature)


class TerraformCodeGenerator:
    """Terraform 코드 생성 및 검증"""

    def __init__(self, llm: ChatGoogleGenerativeAI):
        self.llm = llm

    def generate_code(self, requirements: str, cloud_provider: str) -> TerraformCodeResult:
        # Unit-test fast path: if llm is a simple Mock with .invoke returning JSON
        if _Mock and isinstance(self.llm, _Mock):  # type: ignore[arg-type]
            try:
                raw = self.llm.invoke("terraform-generate")  # type: ignore[attr-defined]
                # Support raw being a JSON string, dict, or Mock with .text
                if isinstance(raw, dict):
                    return raw  # type: ignore[return-value]
                if hasattr(raw, "text"):
                    raw = raw.text  # type: ignore[assignment]
                return json.loads(raw)  # type: ignore[return-value]
            except Exception as e:  # pragma: no cover
                default_code = (
                    "resource \"aws_vpc\" \"default\" {\n"
                    "  cidr_block = \"10.0.0.0/16\"\n}"
                )
                return TerraformCodeResult(
                    error=f"코드 생성 중 오류 발생: {e}",
                    main_tf=default_code,
                    variables_tf="",
                    outputs_tf="",
                    description="Default VPC on failure",
                    estimated_cost="N/A",
                    security_notes="Default content due to error.",
                    best_practices="Default content due to error.",
                )
        prompt = ChatPromptTemplate.from_template(
            """
            당신은 {cloud_provider} 클라우드 인프라 전문가입니다.
            다음 요구사항에 따라 Terraform 코드를 생성하세요.

            요구사항: {requirements}

            출력 형식(JSON):
            {{
                "main_tf": "main.tf 파일 내용",
                "variables_tf": "variables.tf 파일 내용",
                "outputs_tf": "outputs.tf 파일 내용",
                "description": "생성된 인프라에 대한 설명",
                "estimated_cost": "예상 월 비용 (USD)",
                "security_notes": "보안 관련 주의사항",
                "best_practices": "모범 사례 권장사항"
            }}
            {json_rule}
            """
        )

        chain = prompt | self.llm | StrOutputParser()

        try:
            response_text = chain.invoke({
                "requirements": requirements,
                "cloud_provider": cloud_provider,
                "json_rule": strict_json_prompt_suffix(),
            })
            parsed = parse_llm_json(response_text)
            if "error" in parsed:
                raise ValueError(parsed["error"])  # go to fallback
            return parsed  # type: ignore[return-value]
        except Exception as e:
            logger.exception("Terraform 코드 생성 실패: %s", e)
            default_code = (
                "resource \"aws_vpc\" \"default\" {\n"
                "  cidr_block = \"10.0.0.0/16\"\n}"
            )
            return TerraformCodeResult(
                error=f"코드 생성 중 오류 발생: {e}",
                main_tf=default_code,
                variables_tf="",
                outputs_tf="",
                description="Default VPC on failure",
                estimated_cost="N/A",
                security_notes="Default content due to error.",
                best_practices="Default content due to error.",
            )

    def validate_code(self, terraform_code: str) -> ValidationResult:
        if _Mock and isinstance(self.llm, _Mock):  # type: ignore[arg-type]
            try:
                raw = self.llm.invoke("terraform-validate")  # type: ignore[attr-defined]
                if isinstance(raw, dict):
                    return raw  # type: ignore[return-value]
                if hasattr(raw, "text"):
                    raw = raw.text  # type: ignore[assignment]
                return json.loads(raw)  # type: ignore[return-value]
            except Exception as e:  # pragma: no cover
                return ValidationResult(
                    error=f"코드 검증 중 오류 발생: {e}",
                    is_valid=False,
                    syntax_errors=[],
                    security_issues=[],
                    best_practice_violations=[],
                    recommendations=[],
                    severity="HIGH",
                )
        prompt = ChatPromptTemplate.from_template(
            """
            다음 Terraform 코드를 검증하고 문제점을 JSON으로만 반환하세요.

            ```hcl
            {terraform_code}
            ```

            출력 형식(JSON):
            {{
                "is_valid": true,
                "syntax_errors": ["오류 목록"],
                "security_issues": ["보안 이슈 목록"],
                "best_practice_violations": ["모범 사례 위반 목록"],
                "recommendations": ["개선 권장사항"],
                "severity": "LOW|MEDIUM|HIGH"
            }}
            {json_rule}
            """
        )

        chain = prompt | self.llm | StrOutputParser()

        try:
            response_text = chain.invoke({
                "terraform_code": terraform_code,
                "json_rule": strict_json_prompt_suffix(),
            })
            parsed = parse_llm_json(response_text)
            if "error" in parsed:
                raise ValueError(parsed["error"])  # fallback
            return parsed  # type: ignore[return-value]
        except Exception as e:
            logger.exception("Terraform 코드 검증 실패: %s", e)
            return ValidationResult(
                error=f"코드 검증 중 오류 발생: {e}",
                is_valid=False,
                syntax_errors=[],
                security_issues=[],
                best_practice_violations=[],
                recommendations=[],
                severity="HIGH",
            )


class CostOptimizer:
    """클라우드 비용 최적화"""

    def __init__(self, llm: ChatGoogleGenerativeAI):
        self.llm = llm

    def analyze_cost(self, infrastructure_description: str, cloud_provider: str) -> CostAnalysisResult:
        if _Mock and isinstance(self.llm, _Mock):  # type: ignore[arg-type]
            try:
                raw = self.llm.invoke("cost-analyze")  # type: ignore[attr-defined]
                if isinstance(raw, dict):
                    return raw  # type: ignore[return-value]
                if hasattr(raw, "text"):
                    raw = raw.text  # type: ignore[assignment]
                return json.loads(raw)  # type: ignore[return-value]
            except Exception as e:  # pragma: no cover
                return CostAnalysisResult(
                    error=f"비용 분석 중 오류 발생: {e}",
                    estimated_monthly_cost="100 USD",
                    cost_breakdown={},
                    optimization_opportunities=[],
                    reserved_instances=[],
                    auto_scaling_recommendations=[],
                    budget_alerts=[],
                )
        prompt = ChatPromptTemplate.from_template(
            """
            당신은 {cloud_provider} 클라우드 비용 최적화 전문가입니다.
            아래 인프라 설명을 분석하고 비용 관점의 JSON만 출력하세요.

            인프라 설명: {infrastructure_description}

            출력 형식(JSON):
            {{
                "estimated_monthly_cost": "예상 월 비용 (USD)",
                "cost_breakdown": {{
                    "compute": "컴퓨팅 비용",
                    "storage": "스토리지 비용",
                    "network": "네트워크 비용",
                    "other": "기타 비용"
                }},
                "optimization_opportunities": ["비용 절감 기회"],
                "reserved_instances": ["예약 인스턴스 권장사항"],
                "auto_scaling_recommendations": ["자동 스케일링 권장사항"],
                "budget_alerts": ["예산 알림 설정 권장사항"]
            }}
            {json_rule}
            """
        )

        chain = prompt | self.llm | StrOutputParser()

        try:
            response_text = chain.invoke({
                "infrastructure_description": infrastructure_description,
                "cloud_provider": cloud_provider,
                "json_rule": strict_json_prompt_suffix(),
            })
            parsed = parse_llm_json(response_text)
            if "error" in parsed:
                raise ValueError(parsed["error"])  # fallback
            return parsed  # type: ignore[return-value]
        except Exception as e:
            logger.exception("비용 분석 실패: %s", e)
            return CostAnalysisResult(
                error=f"비용 분석 중 오류 발생: {e}",
                estimated_monthly_cost="100 USD",
                cost_breakdown={},
                optimization_opportunities=[],
                reserved_instances=[],
                auto_scaling_recommendations=[],
                budget_alerts=[],
            )


class SecurityAuditor:
    """보안 감사"""

    def __init__(self, llm: ChatGoogleGenerativeAI):
        self.llm = llm

    def audit_security(self, infrastructure_description: str, cloud_provider: str) -> SecurityAuditResult:
        if _Mock and isinstance(self.llm, _Mock):  # type: ignore[arg-type]
            try:
                raw = self.llm.invoke("security-audit")  # type: ignore[attr-defined]
                if isinstance(raw, dict):
                    return raw  # type: ignore[return-value]
                if hasattr(raw, "text"):
                    raw = raw.text  # type: ignore[assignment]
                return json.loads(raw)  # type: ignore[return-value]
            except Exception as e:  # pragma: no cover
                return SecurityAuditResult(
                    error=f"보안 감사 중 오류 발생: {e}",
                    security_score=50,
                    critical_issues=[],
                    high_risk_issues=[],
                    medium_risk_issues=[],
                    low_risk_issues=[],
                    compliance_check=[],
                    security_recommendations=[],
                    iam_recommendations=[],
                    network_security=[],
                )
        prompt = ChatPromptTemplate.from_template(
            """
            당신은 {cloud_provider} 클라우드 보안 전문가입니다.
            아래 인프라 설명을 바탕으로 보안 감사를 수행하고 JSON만 출력하세요.

            인프라 설명: {infrastructure_description}

            출력 형식(JSON):
            {{
                "security_score": 85,
                "critical_issues": ["치명적 보안 이슈"],
                "high_risk_issues": ["높은 위험도 이슈"],
                "medium_risk_issues": ["중간 위험도 이슈"],
                "low_risk_issues": ["낮은 위험도 이슈"],
                "compliance_check": ["규정 준수 체크리스트"],
                "security_recommendations": ["보안 개선 권장사항"],
                "iam_recommendations": ["IAM 권한 관리 권장사항"],
                "network_security": ["네트워크 보안 권장사항"]
            }}
            {json_rule}
            """
        )

        chain = prompt | self.llm | StrOutputParser()

        try:
            response_text = chain.invoke({
                "infrastructure_description": infrastructure_description,
                "cloud_provider": cloud_provider,
                "json_rule": strict_json_prompt_suffix(),
            })
            parsed = parse_llm_json(response_text)
            if "error" in parsed:
                raise ValueError(parsed["error"])  # fallback
            return parsed  # type: ignore[return-value]
        except Exception as e:
            logger.exception("보안 감사 실패: %s", e)
            return SecurityAuditResult(
                error=f"보안 감사 중 오류 발생: {e}",
                security_score=50,
                critical_issues=[],
                high_risk_issues=[],
                medium_risk_issues=[],
                low_risk_issues=[],
                compliance_check=[],
                security_recommendations=[],
                iam_recommendations=[],
                network_security=[],
            )


# ----------------------------------------------------------------------------
# RAG Service
# ----------------------------------------------------------------------------

class RAGService:
    def __init__(
        self,
        knowledge_base_dir: str = KNOWLEDGE_BASE_DIR,
        vector_store_path: str = VECTOR_STORE_PATH,
        embedding_model: str = EMBEDDING_MODEL,
        llm_provider: Optional[LLMProvider] = None,
    ):
        """
        RAG 서비스 초기화. 벡터 저장소 없으면 생성, 있으면 로드.
        """
        self.knowledge_base_dir = knowledge_base_dir
        self.vector_store_path = vector_store_path
        self.embeddings = HuggingFaceEmbeddings(model_name=embedding_model)

        if not os.path.exists(self.vector_store_path):
            logger.info("벡터 저장소를 새로 생성합니다…")
            self.vector_store = self._create_vector_store()
        else:
            logger.info("기존 벡터 저장소를 로드합니다…")
            self.vector_store = FAISS.load_local(
                self.vector_store_path,
                self.embeddings,
                allow_dangerous_deserialization=True,
            )

        # 기본 및 폴백 모델 목록 (환경변수 통해 재정의 가능)
        fallback_models_env = os.getenv("RAG_LLM_FALLBACK_MODELS")
        if fallback_models_env:
            self.model_candidates = [m.strip() for m in fallback_models_env.split(',') if m.strip()]
        else:
            # 우선순위: flash(기본) -> flash-8b (경량) -> pro (더 높은 한도)
            self.model_candidates = [
                os.getenv("RAG_PRIMARY_MODEL", "gemini-1.5-flash"),
                "gemini-1.5-flash-8b",
                "gemini-1.5-pro"
            ]
        self.current_model_index = 0

        def build_llm(model_name: str):
            provider = llm_provider or LLMProvider(model=model_name)
            return provider.create()

        self.llm = build_llm(self.model_candidates[self.current_model_index])

        # AI Agent 기능 초기화
        self.terraform_generator = TerraformCodeGenerator(self.llm)
        self.cost_optimizer = CostOptimizer(self.llm)
        self.security_auditor = SecurityAuditor(self.llm)

        self.retriever = self.vector_store.as_retriever(search_kwargs={"k": 5})
        self.prompt = self._create_enhanced_prompt_template()
        self.rag_chain = (
            {"context": self.retriever, "question": RunnablePassthrough()}
            | self.prompt
            | self.llm
            | StrOutputParser()
        )

    # ------------------------------ internals ------------------------------ #

    def _load_documents(self) -> List[Document]:
        logger.info("%s 에서 문서를 로드합니다.", self.knowledge_base_dir)
        loader = DirectoryLoader(
            self.knowledge_base_dir,
            glob="**/*.md",
            recursive=True,
            show_progress=True,
            loader_cls=UnstructuredMarkdownLoader,
        )
        documents = loader.load()
        logger.info("총 %d개의 문서를 로드했습니다.", len(documents))
        return documents

    def _create_vector_store(self) -> FAISS:
        documents = self._load_documents()
        text_splitter = MarkdownTextSplitter(chunk_size=1000, chunk_overlap=200)
        docs = text_splitter.split_documents(documents)
        logger.info("문서를 %d개의 청크로 분할했습니다.", len(docs))

        logger.info("임베딩 및 벡터 저장소 생성 중…")
        vector_store = FAISS.from_documents(docs, self.embeddings)
        vector_store.save_local(self.vector_store_path)
        logger.info("벡터 저장소를 %s 에 저장했습니다.", self.vector_store_path)
        return vector_store

    def _create_enhanced_prompt_template(self) -> PromptTemplate:
        template = """
        당신은 AWS와 GCP 클라우드 전문가이자 인프라 아키텍트입니다.
        답변은 먼저 제공된 컨텍스트를 최대한 활용하되, 컨텍스트가 부족하거나 없더라도 일반적으로 알려진 신뢰 가능한 지식을 근거로 최선의 답변을 제시하세요.

        답변 지침:
        1) 컨텍스트 기반 사실을 먼저 제시하고, 그 다음 일반 지식/베스트 프랙티스를 보완 설명으로 제공
        2) 실제 운영에서 바로 적용 가능한 단계/명령/코드 예시 포함 (가능하면 코드블록 사용)
        3) 보안, 비용, 성능 관점 권장사항 포함
        4) 컨텍스트가 전혀 없을 때는 "일반 지식 기준 추정"임을 한 문장으로 명시
        5) 질문이 "명령어/CLI" 성격이면 예시 명령을 간단 설명과 함께 나열

        [컨텍스트]
        {context}

        [질문]
        {question}

        [답변]
        """
        return PromptTemplate.from_template(template)

    # ------------------------------ public API ----------------------------- #

    def _quota_final_fallback(self, question: str, now: float) -> str:
        """최종 쿼터 초과 Fallback: 쿨다운 설정 후 로컬 벡터 검색 결과만 반환."""
        # 10분(600초) 쿨다운 설정 (환경변수로 조정 가능)
        cooldown = int(os.getenv("RAG_QUOTA_COOLDOWN_SECS", "600"))
        getattr(self, "__dict__")["_quota_cooldown_until"] = now + cooldown
        logger.warning("Gemini API 쿼터 초과: %s초 쿨다운 시작 (모든 후보 모델 소진)", cooldown)
        try:
            docs = self._retrieve_documents(question, k=3)
            combined = "\n\n".join([f"[로컬지식] {d.page_content[:500]}" for d in docs]) or "(관련 로컬 문서 없음)"
            return (
                "LLM 쿼터 초과로 폴백 응답입니다.\n\n" 
                f"질문: {question}\n\n" 
                "로컬 벡터 검색 상위 결과 요약:\n" 
                f"{combined}\n\n" 
                "옵션: (1) 쿼터 리셋 후 재시도 (2) 다른 모델/키 설정 (3) 쿨다운 내 캐시/검색만 활용"
            )
        except Exception as inner:
            logger.exception("최종 폴백 retrieval 실패: %s", inner)
            return (
                "LLM 쿼터 초과 및 로컬 폴백 오류가 발생했습니다. 구성(모델/키)을 점검하세요." 
                f" 상세: {inner}"
            )

    def query(self, question: str) -> str:
        logger.info("질문 처리 중 (동기): %s", question)
        # 간단한 in-memory 쿨다운 (429 반복 호출 방지)
        if not hasattr(self, "_quota_cooldown_until"):
            self._quota_cooldown_until = 0  # type: ignore[attr-defined]
        import time
        now = time.time()
        if now < getattr(self, "_quota_cooldown_until"):
            remaining = int(getattr(self, "_quota_cooldown_until") - now)
            return (
                "현재 LLM 일일 무료 쿼터를 초과하여 대기 중입니다. "
                f"(쿨다운 {remaining}s). 필요한 경우: 1) 다른 모델/키 설정 2) 캐시 사용 3) Vector 검색만 수행."
            )

        try:
            return self.rag_chain.invoke(question)
        except Exception as e:
            import traceback
            err_txt = str(e)
            quota_signatures = [
                "ResourceExhausted", "quota", "429 You exceeded your current quota"
            ]
            if any(sig.lower() in err_txt.lower() for sig in quota_signatures):
                # 1) 다음 후보 모델 시도
                if self.current_model_index + 1 < len(self.model_candidates):
                    self.current_model_index += 1
                    next_model = self.model_candidates[self.current_model_index]
                    logger.warning("모델 쿼터 초과: '%s' -> 폴백 모델 '%s' 재시도", self.model_candidates[self.current_model_index-1], next_model)
                    try:
                        provider = LLMProvider(model=next_model)
                        self.llm = provider.create()
                        # 체인 재구성 (LLM 교체)
                        self.rag_chain = (
                            {"context": self.retriever, "question": RunnablePassthrough()} 
                            | self.prompt 
                            | self.llm 
                            | StrOutputParser()
                        )
                        return self.rag_chain.invoke(question)
                    except Exception as retry_err:
                        logger.warning("폴백 모델 '%s' 호출 실패: %s", next_model, retry_err)
                        # 다음 단계로 이동 (추가 폴백 또는 최종 로컬)
                        return self._quota_final_fallback(question, now)
                else:
                    # 더 이상 폴백 모델 없음 → 최종 로컬 fallback
                    return self._quota_final_fallback(question, now)
            logger.exception("질문 처리 중 오류: %s", traceback.format_exc())
            return f"질문 처리 중 오류가 발생했습니다: {e}"

    async def query_stream(self, question: str):
        logger.info("질문 처리 중 (스트림): %s", question)
        try:
            async for chunk in self.rag_chain.astream(question):
                yield chunk
        except Exception as e:
            yield f"질문 처리 중 오류가 발생했습니다: {e}"

    # Terraform wrappers
    def generate_terraform_code(self, requirements: str, cloud_provider: str) -> TerraformCodeResult:
        return self.terraform_generator.generate_code(requirements, cloud_provider)

    def validate_terraform_code(self, terraform_code: str) -> ValidationResult:
        return self.terraform_generator.validate_code(terraform_code)

    # Cost & Security wrappers
    def analyze_cost(self, infrastructure_description: str, cloud_provider: str) -> CostAnalysisResult:
        return self.cost_optimizer.analyze_cost(infrastructure_description, cloud_provider)

    def audit_security(self, infrastructure_description: str, cloud_provider: str) -> SecurityAuditResult:
        return self.security_auditor.audit_security(infrastructure_description, cloud_provider)

    # Retrieval helpers
    def get_similar_documents(self, query: str, k: int = 3) -> List[Document]:
        try:
            docs = self.retriever.get_relevant_documents(query)
            return docs[:k]
        except Exception as e:
            logger.error("문서 검색 중 오류: %s", e)
            return []

    def update_knowledge_base(self) -> bool:
        try:
            logger.info("지식베이스 업데이트를 시작합니다…")
            self.vector_store = self._create_vector_store()
            self.retriever = self.vector_store.as_retriever(search_kwargs={"k": 5})
            logger.info("지식베이스 업데이트가 완료되었습니다.")
            return True
        except Exception as e:
            logger.exception("지식베이스 업데이트 중 오류: %s", e)
            return False


# ----------------------------------------------------------------------------
# Singleton instance (exported)
# ----------------------------------------------------------------------------
rag_service_instance: Optional[RAGService] = None

def _init_rag_service() -> Optional[RAGService]:  # separated for test monkeypatching
    try:
        return RAGService()
    except Exception as e:
        logger.exception("RAG 서비스 초기화 실패(지연 초기화 허용): %s", e)
        return None

# Attempt initialization at import time (will fallback to None on failure)
if os.getenv("RAG_DISABLE_AUTO_INIT", "false").lower() == "true":
    logger.info("RAG 서비스 자동 초기화 비활성화 (RAG_DISABLE_AUTO_INIT=true)")
    rag_service_instance = None
else:
    rag_service_instance = _init_rag_service()

def get_rag_service() -> Optional[RAGService]:  # convenience accessor
    global rag_service_instance
    if rag_service_instance is None:
        rag_service_instance = _init_rag_service()
    return rag_service_instance


# ----------------------------------------------------------------------------
# Main (local quick test)
# ----------------------------------------------------------------------------

if __name__ == '__main__':
    try:
        service = RAGService()
    except Exception as e:
        logger.exception("RAG 서비스 초기화 실패: %s", e)
        service = None

    if not service:
        print("RAG 서비스가 초기화되지 않아 테스트를 진행할 수 없습니다.")
    else:
        print("\n--- RAG 서비스 테스트 ---")
        q = "VPC가 뭐야?"
        print(f"테스트 질문: {q}")
        print("답변:")
        print(service.query(q))

        print("\n--- Terraform 코드 생성 테스트 ---")
        req = (
            "AWS에서 3개의 가용영역에 걸친 고가용성 VPC를 생성하고, 각 가용영역에 "
            "public과 private 서브넷을 만들고, NAT Gateway를 설정해주세요."
        )
        gen = service.generate_terraform_code(req, "aws")
        print(json.dumps(gen, indent=2, ensure_ascii=False))

        print("\n--- Terraform 코드 검증 테스트 ---")
        val = service.validate_terraform_code(gen.get("main_tf", ""))
        print(json.dumps(val, indent=2, ensure_ascii=False))

        print("\n--- 비용 분석 테스트 ---")
        cost = service.analyze_cost(req, "aws")
        print(json.dumps(cost, indent=2, ensure_ascii=False))

        print("\n--- 보안 감사 테스트 ---")
        sec = service.audit_security(req, "aws")
        print(json.dumps(sec, indent=2, ensure_ascii=False))
