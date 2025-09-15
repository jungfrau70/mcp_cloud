#!/usr/bin/env python3
"""
남은 커서룰 문제 해결 도구
"""

import re
from pathlib import Path
from datetime import datetime

class RemainingCursorRulesFixer:
    """남은 커서룰 문제 해결 도구"""
    
    def __init__(self, rules_path: str = ".cursor/rules"):
        self.rules_path = Path(rules_path)
        self.fixes_applied = 0
        
    def fix_cursor_rules_mdc(self):
        """cursor_rules.mdc 교육 교구 시스템 특화 업데이트"""
        print("📝 cursor_rules.mdc 교육 교구 시스템 특화 업데이트 중...")
        
        content = r"""---
description: AI 활용 교육 교구 시스템의 전반적인 규칙과 가이드라인
globs: "**/*.py", "**/*.ts", "**/*.vue", "**/*.json", "**/*.md"
alwaysApply: true
---

# AI 활용 교육 교구 시스템 규칙

## 🎯 시스템 목표
- **교육 커리큘럼 작성자**: 직관적이고 효율적인 교육 자료 작성 지원
- **교육자**: 수강자에게 최고의 교육 경험 제공  
- **수강자**: 체계적이고 일관된 학습 경험
- **AI 에이전트**: 교육 과정 자동화 및 개인화 지원

## 📚 교육 교구 시스템 구조
- **Frontend**: Nuxt.js 기반의 Vue.js 교육 플랫폼
- **Backend**: FastAPI 기반의 Python 서버
- **Database**: PostgreSQL (교육 자료 및 진도 관리)
- **Cache**: Redis (성능 최적화)
- **AI Integration**: 교육 도구 AI 에이전트

## 🎨 코드 스타일 (교육 도구 특화)
- **Python**: PEP 8 스타일 가이드 준수, 교육용 주석 필수
- **TypeScript**: ESLint와 Prettier 설정 준수, 타입 안정성 강화
- **Vue.js**: Vue 3 Composition API 사용, 접근성 고려

## 🌐 언어 규칙 (교육 특화)
- **코드**: 주석포함 모두 영어 (국제 표준)
- **대화**: 한글 (한국 교육자/수강자 대상)
- **문서**: 한글 중심, 영어 기술 용어 병기
- **사용자 인터페이스**: 한글 우선, 직관적 용어 사용

## 📖 교육 자료 관리 규칙
- **문서 연결 무결성**: 모든 앵커 링크 100% 정상 작동
- **제목 일관성**: 교육 과정별 일관된 제목 체계
- **실습 가이드**: 단계별 명확한 실습 지침
- **진도 관리**: 학습자 진도 추적 및 관리

## 🔗 문서 연결 및 앵커 관리
- **앵커 링크**: VS Code 마크다운 미리보기 표준 준수
- **한글 처리**: 한글 파일명 및 헤딩 완벽 지원
- **이모지 처리**: 이모지 포함 헤딩 정상 작동
- **자동 검증**: 주간 자동 앵커 링크 감사

## 🧪 테스트 및 품질 관리
- **교육 자료 테스트**: 모든 실습 가이드 검증
- **사용자 경험 테스트**: 수강자 관점에서의 사용성 검증
- **접근성 테스트**: 다양한 학습자 접근성 보장
- **성능 테스트**: 교육 플랫폼 응답성 최적화

## 🤖 AI 에이전트 협업 규칙
- **교육 도구 AI**: 학습자 질문 답변 및 가이드 제공
- **자동화 도구**: 반복 작업 자동화 (문서 검증, 링크 체크)
- **품질 관리 AI**: 교육 자료 품질 자동 모니터링
- **개인화 AI**: 학습자별 맞춤 학습 경로 제안

## 📊 교육 데이터 관리
- **학습 진도**: 개별 학습자 진도 추적
- **성과 분석**: 학습 효과 측정 및 개선
- **피드백 수집**: 교육자/수강자 피드백 체계적 수집
- **지속적 개선**: 데이터 기반 교육 과정 개선

## 🔄 Sequential Thinking 규칙 (교육 특화)
- **교육 과정 설계**: 체계적이고 논리적인 학습 경로 설계
- **실습 가이드 작성**: 단계별 명확한 실습 지침
- **문제 해결**: 학습자 문제 상황 체계적 해결
- **피드백 처리**: 학습자 피드백 분석 및 개선 방안 도출

## 🎓 교육 품질 보장
- **내용 정확성**: 모든 교육 자료의 기술적 정확성 검증
- **일관성 유지**: 교육 과정 전반의 일관된 품질 유지
- **접근성 보장**: 다양한 학습자 접근성 고려
- **지속적 업데이트**: 최신 기술 트렌드 반영

## 🚀 성능 및 확장성
- **교육 플랫폼 성능**: 빠른 로딩 및 반응성
- **확장 가능성**: 교육 과정 추가 및 확장 용이성
- **안정성**: 24/7 안정적인 교육 서비스 제공
- **보안**: 학습자 데이터 보호 및 프라이버시 보장
"""

        self._write_rule_file("cursor_rules.mdc", content)
        print("✅ cursor_rules.mdc 교육 교구 시스템 특화 업데이트 완료")
    
    def fix_self_improve_mdc(self):
        """self_improve.mdc 교육 교구 시스템 특화 업데이트"""
        print("📝 self_improve.mdc 교육 교구 시스템 특화 업데이트 중...")
        
        content = r"""---
description: AI 활용 교육 교구 시스템의 지속적 개선 및 학습 규칙
globs: "**/*.py", "**/*.ts", "**/*.vue", "**/*.json", "**/*.md"
alwaysApply: true
---

# 교육 교구 시스템 지속적 개선 규칙

## 🔄 자동 개선 프로세스

### **규칙 개선 트리거**
- 새로운 교육 패턴이 3개 이상 파일에서 사용될 때
- 교육자/수강자 피드백이 반복적으로 언급될 때
- 교육 자료 품질 문제가 예방 가능한 규칙으로 해결될 때
- 새로운 교육 도구나 기술이 일관되게 사용될 때
- 교육 과정 보안이나 성능 패턴이 등장할 때

### **분석 프로세스**
- 새로운 코드와 기존 규칙 비교
- 표준화해야 할 패턴 식별
- 외부 문서 참조 확인
- 일관된 오류 처리 패턴 확인
- 테스트 패턴 및 커버리지 모니터링

### **규칙 업데이트**
- **새 규칙 추가 시**:
  - 3개 이상 파일에서 사용되는 새로운 기술/패턴
  - 일반적인 버그를 예방할 수 있는 규칙
  - 코드 리뷰에서 반복적으로 언급되는 피드백
  - 새로운 보안이나 성능 패턴 등장

- **기존 규칙 수정 시**:
  - 코드베이스에 더 나은 예시 존재
  - 추가 엣지 케이스 발견
  - 관련 규칙이 업데이트됨
  - 구현 세부사항 변경

### **패턴 인식 예시**
```python
# 반복되는 패턴을 발견하면:
const data = await prisma.user.findMany({
  select: { id: true, email: true },
  where: { status: 'ACTIVE' }
});

# [prisma.mdc](mdc:.cursor/rules/prisma.mdc)에 추가 고려:
# - 표준 select 필드
# - 일반적인 where 조건
# - 성능 최적화 패턴
```

### **규칙 품질 체크**
- 규칙이 실행 가능하고 구체적인지 확인
- 예시가 실제 코드에서 나온 것인지 확인
- 참조가 최신인지 확인
- 패턴이 일관되게 적용되는지 확인

### **지속적 개선**
- 코드 리뷰 댓글 모니터링
- 일반적인 개발 질문 추적
- 주요 리팩토링 후 규칙 업데이트
- 관련 문서 링크 추가
- 관련 규칙 간 상호 참조

### **규칙 폐기**
- 사용되지 않는 패턴을 deprecated로 표시
- 더 이상 적용되지 않는 규칙 제거
- 폐기된 규칙에 대한 참조 업데이트
- 이전 패턴에서 새 패턴으로의 마이그레이션 경로 문서화

### **문서 업데이트**
- 예시를 코드와 동기화 유지
- 외부 문서 참조 업데이트
- 관련 규칙 간 링크 유지
- 주요 변경사항 문서화

## 🎓 교육 교구 시스템 특화 개선

### **교육 자료 품질 개선**
- 교육 자료 작성 패턴 모니터링
- 학습자 피드백 기반 규칙 개선
- 실습 가이드 품질 표준화
- 앵커 링크 무결성 보장 규칙 강화

### **AI 에이전트 협업 개선**
- AI 생성 콘텐츠 품질 검증 규칙
- 교육자-AI 협업 패턴 표준화
- 개인화 학습 경로 생성 규칙
- 자동화된 피드백 처리 규칙

### **사용자 경험 개선**
- 교육자/수강자 관점에서의 사용성 규칙
- 접근성 및 다국어 지원 규칙
- 직관적 인터페이스 설계 규칙
- 오류 처리 및 사용자 안내 개선

### **성능 및 확장성 개선**
- 교육 플랫폼 성능 최적화 규칙
- 대규모 교육 자료 관리 규칙
- 실시간 협업 기능 규칙
- 모바일 및 다양한 디바이스 지원 규칙

## 📊 개선 효과 측정

### **정량적 지표**
- 교육 자료 품질 점수
- 앵커 링크 정확도
- 사용자 만족도 점수
- 시스템 성능 지표

### **정성적 지표**
- 교육자 피드백 품질
- 학습자 학습 효과
- AI 에이전트 협업 효율성
- 전체 교육 경험 만족도

## 🔧 도구 및 자동화

### **자동 모니터링**
- 교육 자료 품질 자동 검사
- 앵커 링크 무결성 자동 검증
- 사용자 피드백 자동 분석
- 성능 지표 자동 수집

### **개선 제안 시스템**
- AI 기반 개선 제안 생성
- 패턴 분석 기반 규칙 제안
- 사용자 피드백 기반 개선 방향 제시
- 자동화된 테스트 및 검증

이 규칙을 통해 교육 교구 시스템이 지속적으로 개선되고 발전할 수 있습니다.
"""

        self._write_rule_file("self_improve.mdc", content)
        print("✅ self_improve.mdc 교육 교구 시스템 특화 업데이트 완료")
    
    def fix_target_system_mdc(self):
        """target_system.mdc 교육 교구 시스템 특화 업데이트"""
        print("📝 target_system.mdc 교육 교구 시스템 특화 업데이트 중...")
        
        content = r"""---
description: AI 활용 교육 교구 시스템의 핵심 목표 및 시스템 특성
globs: "**/*.py", "**/*.ts", "**/*.vue", "**/*.json", "**/*.md"
alwaysApply: true
---

# AI 활용 교육 교구 시스템

## 🎯 시스템 핵심 목표

### **교육 커리큘럼 작성자 지원**
- **직관적 도구**: 복잡한 교육 자료를 쉽게 작성할 수 있는 도구 제공
- **자동화 지원**: 반복적인 작업을 AI가 자동화하여 효율성 극대화
- **품질 보장**: 작성된 교육 자료의 품질을 자동으로 검증하고 개선 제안
- **템플릿 제공**: 다양한 교육 과정에 맞는 표준화된 템플릿 제공

### **교육자 지원**
- **수강자 관리**: 개별 학습자 진도 추적 및 맞춤형 피드백 제공
- **교육 효과 분석**: 학습 성과를 측정하고 개선 방향 제시
- **실시간 지원**: AI 에이전트를 통한 실시간 질문 답변 및 가이드
- **협업 도구**: 교육자 간 지식 공유 및 협업을 위한 플랫폼

### **수강자 지원**
- **개인화 학습**: 학습자 수준과 목표에 맞는 맞춤형 학습 경로 제공
- **실습 환경**: 안전하고 체계적인 실습 환경 제공
- **진도 관리**: 학습 진도를 시각적으로 확인하고 동기 부여
- **즉시 피드백**: 실습 결과에 대한 즉각적인 피드백과 개선 제안

## 🤖 AI 에이전트 역할

### **교육 자료 생성 AI**
- **콘텐츠 자동 생성**: 주제와 난이도에 맞는 교육 자료 자동 생성
- **실습 가이드 작성**: 단계별 실습 지침 자동 작성
- **평가 문항 생성**: 학습 목표에 맞는 평가 문항 자동 생성
- **다국어 지원**: 다양한 언어로 교육 자료 자동 번역

### **학습 지원 AI**
- **개인화 추천**: 학습자 수준과 관심사에 맞는 콘텐츠 추천
- **질문 답변**: 학습 중 발생하는 질문에 대한 즉시 답변
- **학습 계획 수립**: 개인별 최적 학습 계획 자동 생성
- **진도 분석**: 학습 패턴 분석을 통한 개선 제안

### **품질 관리 AI**
- **자동 검증**: 교육 자료의 정확성과 완성도 자동 검증
- **일관성 확인**: 교육 과정 전반의 일관성 자동 확인
- **접근성 검사**: 다양한 학습자 접근성 자동 검사
- **성능 모니터링**: 시스템 성능과 사용자 경험 지속 모니터링

## 📚 교육 자료 관리 시스템

### **문서 연결 무결성**
- **앵커 링크 관리**: 모든 문서 간 링크의 정확성 100% 보장
- **자동 검증**: 주기적으로 링크 무결성 자동 검사
- **자동 수정**: 발견된 문제 자동 수정 및 알림
- **버전 관리**: 문서 변경 시 관련 링크 자동 업데이트

### **제목 및 구조 관리**
- **일관된 제목 체계**: 교육 과정별 표준화된 제목 구조
- **자동 목차 생성**: 문서 구조에 따른 자동 목차 생성
- **네비게이션 지원**: 직관적인 문서 간 이동 지원
- **검색 최적화**: 교육 자료 검색 효율성 극대화

### **실습 가이드 관리**
- **단계별 구조화**: 모든 실습을 명확한 단계로 구조화
- **예상 결과 정의**: 각 단계별 명확한 예상 결과 정의
- **오류 처리**: 일반적인 오류 상황에 대한 해결 가이드
- **진도 추적**: 실습 완료 상태 자동 추적

## 🎨 사용자 경험 설계

### **직관적 인터페이스**
- **한글 우선**: 한국 교육자/수강자를 위한 한글 중심 인터페이스
- **시각적 구분**: 이모지와 색상을 활용한 직관적 구분
- **반응형 디자인**: 다양한 디바이스에서 최적화된 경험
- **접근성 고려**: 다양한 학습자 접근성 보장

### **친절한 안내**
- **단계별 가이드**: 복잡한 기능도 단계별로 안내
- **컨텍스트 도움말**: 상황에 맞는 도움말 자동 제공
- **오류 메시지**: 명확하고 해결 가능한 오류 메시지
- **피드백 시스템**: 사용자 피드백을 통한 지속적 개선

## 🔧 기술적 특성

### **확장 가능한 아키텍처**
- **모듈화**: 교육 과정별 독립적 모듈 구성
- **API 중심**: 다양한 도구와의 연동 지원
- **클라우드 네이티브**: 확장성과 안정성 보장
- **마이크로서비스**: 독립적 배포와 관리

### **성능 최적화**
- **빠른 로딩**: 교육 자료 빠른 로딩 및 캐싱
- **실시간 업데이트**: 변경사항 실시간 반영
- **오프라인 지원**: 네트워크 불안정 시에도 학습 가능
- **모바일 최적화**: 모바일 환경에서의 최적 성능

### **보안 및 프라이버시**
- **데이터 보호**: 학습자 개인정보 안전한 보관
- **접근 제어**: 역할별 세분화된 접근 권한
- **감사 로그**: 모든 활동 추적 및 기록
- **규정 준수**: 교육 관련 규정 및 표준 준수

## 📊 성과 측정 및 개선

### **학습 효과 측정**
- **완료율 추적**: 교육 과정 완료율 측정
- **이해도 평가**: 학습자 이해도 정량적 측정
- **만족도 조사**: 정기적인 사용자 만족도 조사
- **성과 분석**: 학습 성과와 시스템 사용 패턴 연관 분석

### **지속적 개선**
- **피드백 수집**: 교육자/수강자 피드백 체계적 수집
- **데이터 분석**: 학습 데이터 기반 개선 방향 도출
- **A/B 테스트**: 새로운 기능과 개선사항 효과 검증
- **사용자 연구**: 실제 사용 환경에서의 사용성 연구

## 🚀 미래 비전

### **AI 기술 발전**
- **자연어 처리**: 더 정교한 자연어 이해와 생성
- **개인화 AI**: 개인별 맞춤형 AI 어시스턴트
- **예측 분석**: 학습 성과 예측 및 개입
- **감정 인식**: 학습자 감정 상태 인식 및 대응

### **교육 혁신**
- **가상현실**: 몰입형 교육 경험 제공
- **증강현실**: 실제 환경과 결합된 학습
- **협업 학습**: AI 지원 협업 학습 환경
- **글로벌 교육**: 언어와 문화 장벽 없는 교육

이 시스템을 통해 모든 교육 이해관계자가 최고의 교육 경험을 할 수 있도록 지원합니다.
"""

        self._write_rule_file("target_system.mdc", content)
        print("✅ target_system.mdc 교육 교구 시스템 특화 업데이트 완료")
    
    def fix_learning_path_mdc(self):
        """learning-path.mdc 구식 패턴 제거 및 현행화"""
        print("📝 learning-path.mdc 구식 패턴 제거 및 현행화 중...")
        
        # 기존 파일 읽기
        file_path = self.rules_path / "learning-path.mdc"
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 구식 클라우드 관리 관련 패턴 제거 및 교육 교구 시스템 특화
        content = content.replace(
            "멀티클라우드(AWS, GCP)에서 IaaS/PaaS 리소스의 설계·프로비저닝·테스트·배포·모니터링을 **AI 에이전트**가 보조하는 중앙 MCP 서버로 통합 관리",
            "AI 에이전트가 보조하는 교육 교구 시스템으로 교육 자료의 설계·생성·검증·배포·모니터링을 통합 관리"
        )
        
        content = content.replace(
            "인프라 정의는 **IaC(예: Terraform)**",
            "교육 자료 정의는 **마크다운 기반 템플릿**"
        )
        
        content = content.replace(
            "PaaS 서비스는 클라우드 네이티브(예: GKE/EKS/Cloud Run/App Engine 등)로 추상화",
            "교육 과정은 표준화된 구조(예: 학습 목표/실습 가이드/평가 기준 등)로 추상화"
        )
        
        content = content.replace(
            "안전한 승인(사전검토/휴먼 승인), 드리프트 탐지, 롤백, 비용·권한·감시 통합 제공",
            "안전한 승인(교육자 검토/승인), 앵커 링크 검증, 롤백, 품질·접근성·모니터링 통합 제공"
        )
        
        # 교육 교구 시스템 특화 내용 추가
        education_specific_content = """

## 🎓 교육 교구 시스템 특화 기능

### **교육 자료 템플릿 라이브러리**
- **학습 목표 템플릿**: 다양한 과목별 표준화된 학습 목표 템플릿
- **실습 가이드 템플릿**: 단계별 실습 지침 표준 템플릿
- **평가 기준 템플릿**: 객관적이고 일관된 평가 기준 템플릿
- **진도 관리 템플릿**: 학습자 진도 추적 및 관리 템플릿

### **자연어 → 교육 자료 생성**
- "초급자를 위한 Python 기초 실습 과정 생성" → AI가 교육 자료 템플릿 생성/수정 제안
- "중급자를 위한 웹 개발 프로젝트 실습" → AI가 단계별 실습 가이드 자동 생성
- "고급자를 위한 AI/ML 심화 과정" → AI가 전문적인 교육 자료 구성 제안

### **Preview & Safety (교육 자료 검증)**
- 교육 자료 자동 검증 → 내용 정확성 + 앵커 링크 무결성 + 접근성 검사
- 학습자 수준별 적합성 검증 → 난이도 및 선수 지식 요구사항 확인
- 실습 가이드 완성도 검증 → 단계별 명확성 및 예상 결과 정의 확인

### **자동 테스트 (Pre-apply)**
- 앵커 링크 검증 (tfsec/checkov 대신), 교육 자료 구조 검증, 학습 경로 연결성 테스트
- 접근성 검사, 다국어 지원 검증, 모바일 호환성 테스트
- 학습 목표 달성 가능성 검증, 실습 환경 요구사항 확인

### **Approval Workflow (교육자 승인)**
- 자동 승인 규칙 (표준 템플릿 사용) + 교육자 수동 승인 (커스텀 콘텐츠)
- 교육자 피드백 수집 및 반영, 학습자 피드백 기반 개선

### **Apply & Monitoring (교육 자료 배포)**
- 교육 자료 배포, 학습자 접근 권한 설정, 진도 추적 시스템 구축
- 실시간 학습 효과 모니터링, 학습자 질문 및 피드백 수집

### **Drift Detection & Auto-heal (교육 자료 품질 관리)**
- 정기 스캔으로 교육 자료 품질 저하 감지 → 알림/자동 개선 제안
- 학습자 피드백 기반 자동 콘텐츠 업데이트, 최신 기술 트렌드 반영

### **Rollback / Snapshot (교육 자료 버전 관리)**
- 교육 자료 버전 관리, 이전 버전으로 롤백 기능
- 학습자별 진도 스냅샷, 교육 과정 백업 및 복구

### **Policy-as-code (교육 정책)**
- 교육 기관 정책 (예: 교육 과정 표준, 평가 기준) 정의 및 강제
- 접근성 정책, 다국어 지원 정책, 보안 정책 적용

### **Cost Management (교육 효과 관리)**
- 교육 효과 측정, 학습 시간 추적, 학습 성과 분석
- 교육 투자 대비 효과 측정, 학습자 만족도 모니터링
"""
        
        # 기존 내용에 교육 교구 시스템 특화 내용 추가
        if "## 🎓 교육 교구 시스템 특화 기능" not in content:
            content += education_specific_content
        
        self._write_rule_file("learning-path.mdc", content)
        print("✅ learning-path.mdc 구식 패턴 제거 및 현행화 완료")
    
    def fix_document_title_management_mdc(self):
        """document-title-management.mdc 앵커/링크 내용 강화"""
        print("📝 document-title-management.mdc 앵커/링크 내용 강화 중...")
        
        # 기존 파일 읽기
        file_path = self.rules_path / "document-title-management.mdc"
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 앵커/링크 관련 내용 강화
        enhanced_anchor_content = """

## 🔗 교육 자료 앵커 링크 관리

### **앵커 링크 생성 규칙 (교육 특화)**
```markdown
<!-- ✅ DO: 교육 과정 앵커 링크 구조 -->
## 🎯 학습 목표
## 📚 실습 가이드  
## 🔧 실습 환경 준비
## 💻 단계별 실습
## 📊 학습 정리

<!-- ✅ DO: 앵커 링크 변환 -->
[🎯 학습 목표](#🎯-학습-목표)
[📚 실습 가이드](#📚-실습-가이드)
[🔧 실습 환경 준비](#🔧-실습-환경-준비)
[💻 단계별 실습](#💻-단계별-실습)
[📊 학습 정리](#📊-학습-정리)
```

### **교육 자료 내부 링크 처리**
```typescript
// ✅ DO: 교육 과정 네비게이션 링크 처리
const setupEducationLinks = async () => {
  document.addEventListener('click', async (event) => {
    const link = event.target.closest('a[href]');
    if (!link) return;
    
    const href = link.getAttribute('href');
    
    // 교육 과정 내부 링크 처리
    if (href.startsWith('#')) {
      event.preventDefault();
      await scrollToEducationSection(href);
    }
    
    // 다른 교육 과정 링크 처리
    if (href.startsWith('/course/')) {
      event.preventDefault();
      await loadEducationCourse(href);
    }
  });
};
```

### **한글 교육 자료 파일명 처리**
```python
# ✅ DO: 한글 교육 자료 파일명 처리
def encode_education_path(path: str) -> str:
    segments = path.split('/')
    encoded_segments = []
    for segment in segments:
        if re.search(r'[가-힣]', segment):
            # 교육 과정명 한글 인코딩
            encoded_segments.append(urllib.parse.quote(segment, safe=''))
        else:
            encoded_segments.append(segment)
    return '/'.join(encoded_segments)
```

### **교육 자료 앵커 링크 검증**
```python
# ✅ DO: 교육 자료 앵커 링크 검증
def validate_education_anchors(content: str) -> ValidationResult:
    # 교육 과정 헤딩 추출
    headings = extract_education_headings(content)
    
    # 앵커 링크 추출
    anchor_links = extract_anchor_links(content)
    
    # 교육 과정 특화 매칭 검증
    validation_result = validate_education_matching(anchor_links, headings)
    
    return validation_result
```

### **교육 자료 목차 자동 생성**
```markdown
<!-- ✅ DO: 교육 과정 목차 자동 생성 -->
<details>
<summary>📋 교육 과정 목차</summary>

1. [🎯 학습 목표](#🎯-학습-목표)
2. [📚 실습 가이드](#📚-실습-가이드)
3. [🔧 실습 환경 준비](#🔧-실습-환경-준비)
4. [💻 단계별 실습](#💻-단계별-실습)
   - [1단계: 환경 설정](#1단계-환경-설정)
   - [2단계: 기본 실습](#2단계-기본-실습)
   - [3단계: 심화 실습](#3단계-심화-실습)
5. [📊 학습 정리](#📊-학습-정리)

</details>
```

### **교육 자료 네비게이션 링크**
```markdown
<!-- ✅ DO: 교육 과정 네비게이션 -->
<div align="center">

[← 이전: Cloud Basic 1일차](../README.md) | 
[📚 전체 커리큘럼](../../../curriculum.md) | 
[🏠 학습 경로로 돌아가기](../../../index.md) | 
[다음: Cloud Basic 2일차 →](../README.md)

</div>
```

### **교육 자료 앵커 링크 테스트**
```typescript
// ✅ DO: 교육 자료 앵커 링크 테스트
describe('Education Material Anchors', () => {
  it('should validate all anchor links in course materials', async () => {
    const courseMaterials = await loadCourseMaterials('cloud_basic');
    
    for (const material of courseMaterials) {
      const validation = await validateAnchorLinks(material);
      expect(validation.isValid).toBe(true);
      expect(validation.brokenLinks).toHaveLength(0);
    }
  });
  
  it('should handle Korean course names correctly', async () => {
    const koreanCourse = 'cloud_basic/과정명.md';
    const validation = await validateAnchorLinks(koreanCourse);
    expect(validation.isValid).toBe(true);
  });
});
```
"""
        
        # 기존 내용에 앵커/링크 강화 내용 추가
        if "## 🔗 교육 자료 앵커 링크 관리" not in content:
            content += enhanced_anchor_content
        
        self._write_rule_file("document-title-management.mdc", content)
        print("✅ document-title-management.mdc 앵커/링크 내용 강화 완료")
    
    def _write_rule_file(self, filename: str, content: str):
        """커서룰 파일 작성"""
        file_path = self.rules_path / filename
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        self.fixes_applied += 1
    
    def fix_all_remaining_issues(self):
        """남은 모든 문제 해결"""
        print("🚀 남은 커서룰 문제 해결 시작")
        print("=" * 60)
        
        # 1. cursor_rules.mdc 교육 교구 시스템 특화
        self.fix_cursor_rules_mdc()
        
        # 2. self_improve.mdc 교육 교구 시스템 특화
        self.fix_self_improve_mdc()
        
        # 3. target_system.mdc 교육 교구 시스템 특화
        self.fix_target_system_mdc()
        
        # 4. learning-path.mdc 구식 패턴 제거
        self.fix_learning_path_mdc()
        
        # 5. document-title-management.mdc 앵커/링크 강화
        self.fix_document_title_management_mdc()
        
        print("=" * 60)
        print("🎯 남은 커서룰 문제 해결 완료")
        print(f"📊 수정된 규칙: {self.fixes_applied}개")
        print("✅ 교육 교구 시스템에 특화된 모든 커서룰 현행화 완료")

def main():
    """메인 실행 함수"""
    fixer = RemainingCursorRulesFixer()
    fixer.fix_all_remaining_issues()

if __name__ == "__main__":
    main()
