# backend/ai_document_generator.py
import google.generativeai as genai
import os
import json
import re
import logging
from typing import Optional, Dict, List, Any
from datetime import datetime

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class AIDocumentGenerator:
    def __init__(self, model_name: str = 'gemini-1.5-flash'):
        self.api_key = os.getenv("GEMINI_API_KEY")
        if not self.api_key:
            logger.warning("GEMINI_API_KEY not set. AI document generation will be limited or fail.")
        else:
            genai.configure(api_key=self.api_key)
        
        self.model = genai.GenerativeModel(model_name)
        self.temperature = 0.7
        self.max_tokens = 4000

    def _create_enhanced_prompt(self, query: str, extracted_content: str, search_results: List[Dict], 
                               doc_type: str = "guide", language: str = "ko") -> str:
        """향상된 프롬프트 생성"""
        
        # 문서 타입별 프롬프트 템플릿
        templates = {
            "guide": {
                "ko": "기술 가이드 문서",
                "en": "Technical Guide"
            },
            "tutorial": {
                "ko": "단계별 튜토리얼",
                "en": "Step-by-step Tutorial"
            },
            "reference": {
                "ko": "참조 문서",
                "en": "Reference Documentation"
            },
            "comparison": {
                "ko": "비교 분석 문서",
                "en": "Comparison Analysis"
            }
        }
        
        doc_type_desc = templates.get(doc_type, templates["guide"]).get(language, "Technical Document")
        
        # 검색 결과를 구조화된 형태로 변환
        sources_markdown = ""
        if search_results:
            sources_markdown = "\n\n## 참고 자료\n"
            for i, result in enumerate(search_results, 1):
                title = result.get('title', 'Unknown Title')
                link = result.get('link', '#')
                snippet = result.get('snippet', '')
                source = result.get('source', 'Unknown')
                date = result.get('date', '')
                
                sources_markdown += f"{i}. **{title}**\n"
                sources_markdown += f"   - 링크: {link}\n"
                if snippet:
                    sources_markdown += f"   - 요약: {snippet[:100]}...\n"
                if source != 'Unknown':
                    sources_markdown += f"   - 출처: {source}\n"
                if date:
                    sources_markdown += f"   - 날짜: {date}\n"
                sources_markdown += "\n"

        prompt = f"""
당신은 전문 기술 문서 작성자이자 클라우드 엔지니어입니다. 제공된 쿼리와 추출된 콘텐츠를 기반으로 구조화된 지식베이스 문서를 작성해야 합니다.

**문서 타입**: {doc_type_desc}
**언어**: {language}

**작성 지침**:
1. **제목**: 명확하고 검색 가능한 제목 (한국어, 최대 50자)
2. **슬러그**: URL 친화적인 슬러그 (소문자, 하이픈, 특수문자 없음, 최대 50자)
3. **구조**: 제목, 부제목, 글머리 기호, 코드 블록을 적절히 사용하여 구성
4. **언어**: 한국어로 작성
5. **간결성**: 직접적이고 불필요한 전문용어 피하기
6. **중점**: 추출된 콘텐츠에서 쿼리와 직접 관련된 정보 우선
7. **출처 표기**: 문서 끝에 "참고 자료" 섹션 포함
8. **품질**: 정확하고 실용적인 정보 제공

**출력 형식**: JSON 객체로만 응답 (title, slug, content 키 포함)

---

**쿼리**: {query}

**추출된 콘텐츠**: {extracted_content}

**참고 자료**: {sources_markdown}

**생성된 문서는 다음 구조를 따라야 합니다**:
- 개요/소개
- 주요 개념 설명
- 실용적인 예제나 단계
- 모범 사례
- 주의사항
- 참고 자료
"""

        return prompt

    def _validate_generated_content(self, content: Dict) -> Dict[str, Any]:
        """생성된 콘텐츠의 품질 검증"""
        validation_result = {
            "is_valid": True,
            "issues": [],
            "suggestions": []
        }
        
        # 필수 키 확인
        required_keys = ['title', 'slug', 'content']
        for key in required_keys:
            if key not in content:
                validation_result["is_valid"] = False
                validation_result["issues"].append(f"Missing required key: {key}")
        
        if not validation_result["is_valid"]:
            return validation_result
        
        # 제목 길이 확인
        title = content.get('title', '')
        if len(title) > 50:
            validation_result["suggestions"].append("제목이 너무 깁니다 (50자 이하 권장)")
        
        # 슬러그 형식 확인
        slug = content.get('slug', '')
        if not re.match(r'^[a-z0-9\-]+$', slug):
            validation_result["issues"].append("슬러그 형식이 올바르지 않습니다 (소문자, 숫자, 하이픈만 허용)")
        
        # 콘텐츠 길이 확인
        content_text = content.get('content', '')
        if len(content_text) < 100:
            validation_result["suggestions"].append("콘텐츠가 너무 짧습니다")
        elif len(content_text) > 10000:
            validation_result["suggestions"].append("콘텐츠가 너무 깁니다")
        
        # 마크다운 구조 확인
        if not re.search(r'^#\s+', content_text, re.MULTILINE):
            validation_result["suggestions"].append("H1 제목이 없습니다")
        
        # 참고 자료 섹션 확인
        if "참고 자료" not in content_text and "## 참고 자료" not in content_text:
            validation_result["suggestions"].append("참고 자료 섹션이 없습니다")
        
        return validation_result

    def _improve_content_quality(self, content: Dict, validation_result: Dict) -> Dict:
        """콘텐츠 품질 개선"""
        improved_content = content.copy()
        
        # 제목이 너무 긴 경우 개선
        title = improved_content.get('title', '')
        if len(title) > 50:
            # 첫 번째 문장이나 주요 키워드만 사용
            words = title.split()
            if len(words) > 8:
                improved_content['title'] = ' '.join(words[:8]) + '...'
        
        # 슬러그가 잘못된 경우 수정
        slug = improved_content.get('slug', '')
        if not re.match(r'^[a-z0-9\-]+$', slug):
            # 제목에서 유효한 슬러그 생성
            clean_title = re.sub(r'[^a-zA-Z0-9\s]', '', title.lower())
            improved_content['slug'] = re.sub(r'\s+', '-', clean_title.strip())
        
        return improved_content

    async def generate_document(self, query: str, extracted_content: str, 
                               search_results: List[Dict], doc_type: str = "guide") -> Optional[Dict]:
        """
        LLM을 사용하여 구조화된 지식베이스 문서를 생성합니다.
        
        Args:
            query: 사용자 쿼리
            extracted_content: 추출된 콘텐츠
            search_results: 검색 결과 목록
            doc_type: 문서 타입 ("guide", "tutorial", "reference", "comparison")
            
        Returns:
            Dict with 'title', 'slug', 'content', 'metadata'
        """
        logger.info(f"Generating {doc_type} document for query: {query}")

        try:
            # 향상된 프롬프트 생성
            prompt = self._create_enhanced_prompt(query, extracted_content, search_results, doc_type)
            
            # LLM 호출
            response = await self.model.generate_content_async(
                prompt,
                generation_config=genai.types.GenerationConfig(
                    temperature=self.temperature,
                    max_output_tokens=self.max_tokens,
                    response_mime_type="application/json"
                )
            )
            
            # JSON 파싱
            try:
                generated_data = json.loads(response.text)
            except json.JSONDecodeError as e:
                logger.error(f"Failed to parse LLM response as JSON: {e}")
                # JSON 파싱 실패 시 텍스트에서 JSON 추출 시도
                json_match = re.search(r'\{.*\}', response.text, re.DOTALL)
                if json_match:
                    generated_data = json.loads(json_match.group())
                else:
                    logger.error("Could not extract JSON from response")
                    return None
            
            # 품질 검증
            validation_result = self._validate_generated_content(generated_data)
            
            if not validation_result["is_valid"]:
                logger.error(f"Generated content validation failed: {validation_result['issues']}")
                return None
            
            # 품질 개선
            if validation_result["suggestions"]:
                logger.info(f"Quality suggestions: {validation_result['suggestions']}")
                generated_data = self._improve_content_quality(generated_data, validation_result)
            
            # 메타데이터 추가
            generated_data['metadata'] = {
                'generated_at': datetime.now().isoformat(),
                'query': query,
                'doc_type': doc_type,
                'sources_count': len(search_results),
                'validation_passed': True,
                'quality_suggestions': validation_result.get('suggestions', [])
            }
            
            logger.info(f"Successfully generated document: {generated_data.get('title', 'Unknown')}")
            return generated_data

        except Exception as e:
            logger.error(f"Error generating document with LLM: {e}")
            return None

    async def generate_multiple_formats(self, query: str, extracted_content: str, 
                                      search_results: List[Dict]) -> Dict[str, Optional[Dict]]:
        """
        여러 형식의 문서를 동시에 생성합니다.
        
        Returns:
            Dict with different document formats
        """
        formats = ["guide", "tutorial", "reference"]
        results = {}
        
        for doc_type in formats:
            try:
                result = await self.generate_document(query, extracted_content, search_results, doc_type)
                results[doc_type] = result
            except Exception as e:
                logger.error(f"Failed to generate {doc_type} format: {e}")
                results[doc_type] = None
        
        return results

    def generate_summary(self, content: str, max_length: int = 200) -> str:
        """콘텐츠 요약 생성"""
        try:
            prompt = f"""
다음 콘텐츠를 {max_length}자 이내로 요약해주세요:

{content}

요약:
"""
            
            response = self.model.generate_content(prompt)
            return response.text.strip()
        except Exception as e:
            logger.error(f"Error generating summary: {e}")
            return content[:max_length] + "..." if len(content) > max_length else content

# Instantiate the service
ai_document_generator_instance = AIDocumentGenerator()
