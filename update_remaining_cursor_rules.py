#!/usr/bin/env python3
"""
나머지 커서룰 현행화 도구
교육 교구 시스템에 특화된 나머지 커서룰들을 업데이트합니다.
"""

import os
import re
import json
from pathlib import Path
from datetime import datetime

class RemainingCursorRulesUpdater:
    # 나머지 커서룰 현행화 도구
    
    def __init__(self, rules_path: str = ".cursor/rules"):
        self.rules_path = Path(rules_path)
        self.updates_applied = 0
        
    def update_content_creation_rules(self):
        # 콘텐츠 생성 규칙을 교육 교구 시스템에 맞게 업데이트
        print("📝 콘텐츠 생성 규칙 업데이트 중...")
        
        content = r"""---
description: 교육 교구 시스템의 콘텐츠 생성 및 관리 규칙
globs: "**/*.md", "**/*.vue", "**/*.ts", "**/*.py"
alwaysApply: true
---

# 교육 교구 시스템 콘텐츠 생성 규칙

## 📚 교육 자료 작성 원칙

### **교육 자료 구조화**
- **명확한 학습 목표**: 각 교육 자료는 구체적인 학습 목표를 명시
- **단계별 진행**: 복잡한 내용을 단계별로 분해하여 설명
- **실습 중심**: 이론과 실습을 균형있게 배치
- **피드백 반영**: 학습자 피드백을 지속적으로 반영

### **교육 자료 작성 가이드라인**
```markdown
<!-- ✅ DO: 교육 자료 구조 -->
# 🎯 [과정명] - [일차]: [주제]

## 📚 학습 목표
- 구체적이고 측정 가능한 목표
- 학습 후 달성할 수 있는 능력 명시

## 🔧 실습 환경 준비
- 필요한 도구 및 환경 설정
- 단계별 설치 가이드

## 💻 단계별 실습
### 1단계: [실습 제목]
- 명확한 실습 지침
- 예상 결과 및 확인 방법

## 📊 학습 정리
- 핵심 개념 요약
- 다음 단계 안내
```

## 🎨 UI/UX 디자인 원칙 (교육 특화)

### **학습자 중심 디자인**
- **직관적 네비게이션**: 학습자가 쉽게 찾을 수 있는 구조
- **진도 표시**: 현재 학습 위치와 진행 상황 명확히 표시
- **접근성 고려**: 다양한 학습자 접근성 보장
- **반응형 디자인**: 다양한 디바이스에서 최적화

### **교육 도구 UI 컴포넌트**
```vue
<!-- ✅ DO: 교육 과정 카드 컴포넌트 -->
<template>
  <div class="course-card">
    <div class="course-header">
      <span class="course-icon">{{ courseIcon }}</span>
      <h3 class="course-title">{{ courseTitle }}</h3>
    </div>
    <div class="course-meta">
      <span class="course-level">{{ courseLevel }}</span>
      <span class="course-duration">{{ courseDuration }}</span>
    </div>
    <div class="course-progress">
      <div class="progress-bar" :style="{ width: progress + '%' }"></div>
    </div>
  </div>
</template>
```

## 🤖 AI 활용 콘텐츠 생성

### **AI 도구 활용 규칙**
- **콘텐츠 생성**: AI를 활용한 교육 자료 초안 작성
- **품질 검증**: AI 생성 콘텐츠의 정확성 검증 필수
- **개인화**: 학습자 수준에 맞는 맞춤형 콘텐츠 생성
- **지속적 학습**: AI 모델의 성능 지속적 개선

### **AI 콘텐츠 생성 프로세스**
```python
# ✅ DO: AI 콘텐츠 생성 프로세스
def generate_educational_content(topic: str, level: str, duration: int):
    # 교육 콘텐츠 AI 생성
    
    # 1. 학습 목표 생성
    learning_objectives = ai_generate_objectives(topic, level)
    
    # 2. 실습 가이드 생성
    practice_guide = ai_generate_practice_guide(topic, duration)
    
    # 3. 평가 기준 생성
    assessment_criteria = ai_generate_assessment(topic, level)
    
    # 4. 품질 검증
    validated_content = validate_educational_content({
        'objectives': learning_objectives,
        'practice': practice_guide,
        'assessment': assessment_criteria
    })
    
    return validated_content
```

## 📝 문서 작성 표준

### **마크다운 작성 규칙**
- **헤딩 구조**: H1(과정명) → H2(섹션) → H3(실습) → H4(세부사항)
- **코드 블록**: 언어별 문법 하이라이팅 필수
- **이미지**: 교육 자료에 적합한 이미지 사용, alt 텍스트 필수
- **링크**: 모든 링크는 유효하고 관련성 있는 내용

### **코드 예시 작성 규칙**
```typescript
// ✅ DO: 교육용 코드 예시
/**
 * 교육 과정: Cloud Basic - AWS S3 실습
 * 목적: S3 버킷 생성 및 파일 업로드 학습
 * 난이도: 초급
 */
export class S3PracticeGuide {
  private bucketName: string;
  
  constructor(bucketName: string) {
    this.bucketName = bucketName;
  }
  
  /**
   * S3 버킷에 파일 업로드
   * @param file - 업로드할 파일
   * @returns 업로드 결과
   */
  async uploadFile(file: File): Promise<UploadResult> {
    // 실습 단계별 주석 포함
    const uploadParams = {
      Bucket: this.bucketName,
      Key: file.name,
      Body: file
    };
    
    return await s3.upload(uploadParams).promise();
  }
}
```

## 🧪 교육 자료 테스트 규칙

### **콘텐츠 품질 검증**
- **정확성 검증**: 기술적 내용의 정확성 확인
- **완성도 검증**: 모든 실습 단계가 완료 가능한지 확인
- **일관성 검증**: 교육 과정 전반의 일관성 유지
- **접근성 검증**: 다양한 학습자 접근성 보장

### **자동화된 콘텐츠 검증**
```python
# ✅ DO: 교육 콘텐츠 자동 검증
def validate_educational_content(content: dict) -> ValidationResult:
    # 교육 콘텐츠 자동 검증
    
    validation_result = {
        'is_valid': True,
        'errors': [],
        'warnings': []
    }
    
    # 1. 학습 목표 검증
    if not content.get('objectives') or len(content['objectives']) < 2:
        validation_result['errors'].append('학습 목표가 부족합니다.')
        validation_result['is_valid'] = False
    
    # 2. 실습 가이드 검증
    if not content.get('practice') or len(content['practice']['steps']) < 3:
        validation_result['warnings'].append('실습 단계가 부족할 수 있습니다.')
    
    # 3. 코드 예시 검증
    if content.get('code_examples'):
        for example in content['code_examples']:
            if not validate_code_syntax(example['code'], example['language']):
                validation_result['errors'].append(f'코드 문법 오류: {example["title"]}')
                validation_result['is_valid'] = False
    
    return validation_result
```

## 📊 콘텐츠 성과 측정

### **학습 효과 지표**
- **완료율**: 교육 과정 완료 비율
- **이해도**: 학습자 이해도 평가 점수
- **만족도**: 학습자 만족도 설문 결과
- **실습 성공률**: 실습 단계별 성공률

### **콘텐츠 개선 프로세스**
```python
# ✅ DO: 콘텐츠 성과 분석
def analyze_content_performance(content_id: str) -> PerformanceReport:
    # 콘텐츠 성과 분석 및 개선 제안
    
    # 학습자 데이터 수집
    learner_data = get_learner_data(content_id)
    
    # 성과 지표 계산
    completion_rate = calculate_completion_rate(learner_data)
    satisfaction_score = calculate_satisfaction(learner_data)
    difficulty_score = calculate_difficulty(learner_data)
    
    # 개선 제안 생성
    improvement_suggestions = generate_improvement_suggestions({
        'completion_rate': completion_rate,
        'satisfaction': satisfaction_score,
        'difficulty': difficulty_score
    })
    
    return PerformanceReport(
        content_id=content_id,
        metrics={
            'completion_rate': completion_rate,
            'satisfaction': satisfaction_score,
            'difficulty': difficulty_score
        },
        suggestions=improvement_suggestions
    )
```

## 🔄 콘텐츠 업데이트 및 유지보수

### **정기 업데이트 규칙**
- **주간 검토**: 학습자 피드백 기반 콘텐츠 검토
- **월간 업데이트**: 기술 트렌드 반영 및 내용 보완
- **분기별 개편**: 교육 과정 구조 전면 검토
- **연간 혁신**: 새로운 교육 방법론 도입

### **버전 관리**
```python
# ✅ DO: 콘텐츠 버전 관리
class ContentVersionManager:
    def __init__(self):
        self.current_version = "1.0.0"
    
    def create_new_version(self, content_id: str, changes: dict) -> str:
        # 새 버전 생성
        version = self.increment_version()
        
        # 변경사항 기록
        self.record_changes(content_id, version, changes)
        
        # 이전 버전 백업
        self.backup_previous_version(content_id, version)
        
        return version
    
    def rollback_version(self, content_id: str, target_version: str):
        # 이전 버전으로 롤백
        if self.is_valid_version(target_version):
            self.restore_version(content_id, target_version)
        else:
            raise ValueError(f"유효하지 않은 버전: {target_version}")
```

## 📚 관련 파일

- [ContentView.vue](mdc:frontend/components/ContentView.vue) - 교육 콘텐츠 표시
- [SyllabusExplorer.vue](mdc:frontend/components/SyllabusExplorer.vue) - 교육 과정 탐색
- [curriculum.py](mdc:backend/app/api/routes/curriculum.py) - 교육 과정 API
- [content_validator.py](mdc:backend/app/utils/content_validator.py) - 콘텐츠 검증

이 규칙을 통해 고품질의 교육 콘텐츠를 지속적으로 생성하고 관리할 수 있습니다.
"""
        
        self._write_rule_file("content_creation_rules.mdc", content)
        print("✅ 콘텐츠 생성 규칙 업데이트 완료")
    
    def update_development_environment_rules(self):
        # 개발 환경 규칙을 교육 교구 시스템에 맞게 업데이트
        print("📝 개발 환경 규칙 업데이트 중...")
        
        content = r"""---
description: 교육 교구 시스템 개발 환경 설정 및 관리 규칙
globs: "**/*.py", "**/*.ts", "**/*.vue", "**/*.json", "**/*.md"
alwaysApply: true
---

# 교육 교구 시스템 개발 환경 규칙

## 🛠️ 개발 환경 구성

### **교육 교구 시스템 개발 스택**
- **Frontend**: Nuxt.js 3 + Vue.js 3 + TypeScript
- **Backend**: FastAPI + Python 3.9+
- **Database**: PostgreSQL 14+ (교육 자료 및 진도 관리)
- **Cache**: Redis 6+ (성능 최적화)
- **AI Integration**: OpenAI API / Anthropic Claude API
- **Testing**: Vitest (Frontend) + Pytest (Backend)

### **개발 환경 설정**
```bash
# ✅ DO: 개발 환경 초기 설정
# 1. 프로젝트 클론
git clone <repository-url>
cd mcp_cloud

# 2. 백엔드 환경 설정
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# 3. 프론트엔드 환경 설정
cd ../frontend
npm install

# 4. 데이터베이스 설정
docker-compose up -d postgres redis

# 5. 환경 변수 설정
cp .env.example .env
# .env 파일에 필요한 환경 변수 설정
```

## 🎯 교육 교구 시스템 특화 설정

### **교육 자료 관리 설정**
```python
# ✅ DO: 교육 자료 관리 설정
# backend/app/config/education.py
class EducationConfig:
    # 교육 자료 루트 디렉토리
    KNOWLEDGE_BASE_ROOT = Path("mcp_knowledge_base")
    
    # 지원하는 교육 과정
    SUPPORTED_COURSES = [
        "cloud_basic",
        "cloud_container", 
        "cloud_master"
    ]
    
    # 교육 자료 파일 확장자
    SUPPORTED_EXTENSIONS = [".md", ".mdx"]
    
    # 앵커 링크 자동 검증 설정
    AUTO_VALIDATE_ANCHORS = True
    ANCHOR_VALIDATION_SCHEDULE = "weekly"  # weekly, daily, on_change
```

### **AI 에이전트 설정**
```python
# ✅ DO: AI 에이전트 설정
# backend/app/config/ai_agent.py
class AIAgentConfig:
    # AI 모델 설정
    DEFAULT_MODEL = "gpt-4"
    FALLBACK_MODEL = "gpt-3.5-turbo"
    
    # 교육 도구 특화 프롬프트
    EDUCATION_PROMPTS = {
        "content_generation": "교육 자료 생성 프롬프트",
        "practice_guide": "실습 가이드 생성 프롬프트",
        "assessment": "평가 기준 생성 프롬프트"
    }
    
    # 응답 품질 설정
    MAX_TOKENS = 4000
    TEMPERATURE = 0.7
    TOP_P = 0.9
```

## 🧪 교육 교구 시스템 테스트 환경

### **교육 자료 테스트**
```python
# ✅ DO: 교육 자료 테스트 설정
# tests/education/test_content_validation.py
import pytest
from backend.app.utils.content_validator import ContentValidator

class TestEducationContent:
    def test_anchor_links_validation(self):
        # 앵커 링크 검증 테스트
        validator = ContentValidator()
        result = validator.validate_anchor_links("test_course.md")
        assert result.is_valid == True
        assert len(result.errors) == 0
    
    def test_learning_objectives_completeness(self):
        # 학습 목표 완성도 테스트
        validator = ContentValidator()
        result = validator.validate_learning_objectives("test_course.md")
        assert len(result.objectives) >= 2
        assert all(obj.is_measurable for obj in result.objectives)
    
    def test_practice_guide_structure(self):
        # 실습 가이드 구조 테스트
        validator = ContentValidator()
        result = validator.validate_practice_guide("test_course.md")
        assert len(result.steps) >= 3
        assert all(step.has_expected_result for step in result.steps)
```

### **교육 과정 통합 테스트**
```typescript
// ✅ DO: 교육 과정 통합 테스트
// frontend/tests/education/course-integration.test.ts
import { describe, it, expect } from 'vitest'
import { CourseManager } from '@/composables/useCourseManager'

describe('Course Integration', () => {
  it('should load course curriculum correctly', async () => {
    const courseManager = new CourseManager()
    const curriculum = await courseManager.loadCurriculum('cloud_basic')
    
    expect(curriculum).toBeDefined()
    expect(curriculum.title).toContain('Cloud Basic')
    expect(curriculum.days).toHaveLength(3)
  })
  
  it('should validate all anchor links', async () => {
    const courseManager = new CourseManager()
    const validation = await courseManager.validateAnchorLinks('cloud_basic')
    
    expect(validation.isValid).toBe(true)
    expect(validation.brokenLinks).toHaveLength(0)
  })
})
```

## 🚀 교육 교구 시스템 배포 환경

### **Docker 컨테이너 설정**
```dockerfile
# ✅ DO: 교육 교구 시스템 Dockerfile
# Dockerfile.education
FROM node:18-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci --only=production
COPY frontend/ ./
RUN npm run build

FROM python:3.9-slim AS backend-builder
WORKDIR /app/backend
COPY backend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/ ./

FROM nginx:alpine AS production
# 교육 자료 정적 파일 서빙 설정
COPY --from=frontend-builder /app/frontend/dist /usr/share/nginx/html
COPY nginx/education.conf /etc/nginx/conf.d/default.conf
```

### **교육 환경별 설정**
```yaml
# ✅ DO: 교육 환경별 Docker Compose 설정
# docker-compose.education.yml
version: '3.8'
services:
  education-app:
    build:
      context: .
      dockerfile: Dockerfile.education
    ports:
      - "3000:80"
    environment:
      - NODE_ENV=production
      - EDUCATION_MODE=true
    volumes:
      - ./mcp_knowledge_base:/app/knowledge_base:ro
    depends_on:
      - postgres
      - redis
  
  postgres:
    image: postgres:14
    environment:
      POSTGRES_DB: education_db
      POSTGRES_USER: education_user
      POSTGRES_PASSWORD: education_pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:6-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

## 📊 교육 교구 시스템 모니터링

### **교육 자료 품질 모니터링**
```python
# ✅ DO: 교육 자료 품질 모니터링
# backend/app/monitoring/education_metrics.py
class EducationMetricsCollector:
    def __init__(self):
        self.metrics = {}
    
    def collect_content_quality_metrics(self):
        # 교육 자료 품질 지표 수집
        return {
            'total_courses': self.count_courses(),
            'valid_anchor_links': self.count_valid_anchors(),
            'broken_links': self.count_broken_links(),
            'content_freshness': self.calculate_freshness(),
            'learner_satisfaction': self.get_satisfaction_score()
        }
    
    def collect_learning_effectiveness_metrics(self):
        # 학습 효과 지표 수집
        return {
            'completion_rates': self.get_completion_rates(),
            'learning_progress': self.get_progress_metrics(),
            'practice_success_rates': self.get_practice_success(),
            'assessment_scores': self.get_assessment_scores()
        }
```

### **성능 모니터링 설정**
```yaml
# ✅ DO: 교육 교구 시스템 모니터링 설정
# monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'education-backend'
    static_configs:
      - targets: ['backend:8000']
    metrics_path: '/metrics'
  
  - job_name: 'education-frontend'
    static_configs:
      - targets: ['frontend:3000']
    metrics_path: '/api/metrics'
  
  - job_name: 'education-database'
    static_configs:
      - targets: ['postgres:5432']
```

## 🔧 개발 도구 및 유틸리티

### **교육 자료 관리 도구**
```python
# ✅ DO: 교육 자료 관리 도구
# tools/education_manager.py
class EducationManager:
    def __init__(self):
        self.knowledge_base = KnowledgeBase()
        self.validator = ContentValidator()
    
    def create_new_course(self, course_name: str, structure: dict):
        # 새 교육 과정 생성
        # 1. 디렉토리 구조 생성
        self.create_course_structure(course_name, structure)
        
        # 2. 기본 템플릿 파일 생성
        self.create_template_files(course_name)
        
        # 3. 앵커 링크 검증
        self.validate_course_links(course_name)
        
        # 4. 학습 경로 업데이트
        self.update_learning_paths(course_name)
    
    def validate_all_courses(self):
        # 모든 교육 과정 검증
        results = {}
        for course in self.knowledge_base.get_courses():
            results[course] = self.validator.validate_course(course)
        return results
```

## 📚 관련 파일

- [package.json](mdc:frontend/package.json) - 프론트엔드 의존성
- [requirements.txt](mdc:backend/requirements.txt) - 백엔드 의존성
- [docker-compose.yml](mdc:docker-compose.yml) - 컨테이너 설정
- [vitest.config.ts](mdc:frontend/vitest.config.ts) - 프론트엔드 테스트 설정
- [pytest.ini](mdc:backend/pytest.ini) - 백엔드 테스트 설정

이 규칙을 통해 교육 교구 시스템의 개발 환경을 효율적으로 관리할 수 있습니다.
"""
        
        self._write_rule_file("development-environment.mdc", content)
        print("✅ 개발 환경 규칙 업데이트 완료")
    
    def update_project_guidelines(self):
        # 프로젝트 가이드라인을 교육 교구 시스템에 맞게 업데이트
        print("📝 프로젝트 가이드라인 업데이트 중...")
        
        content = r"""---
description: 교육 교구 시스템 프로젝트 가이드라인 및 개발 표준
globs: "**/*.py", "**/*.ts", "**/*.vue", "**/*.json", "**/*.md"
alwaysApply: true
---

# 교육 교구 시스템 프로젝트 가이드라인

## 🎯 프로젝트 개요

### **교육 교구 시스템 목표**
- **교육 커리큘럼 작성자**: 직관적이고 효율적인 교육 자료 작성 지원
- **교육자**: 수강자에게 최고의 교육 경험 제공  
- **수강자**: 체계적이고 일관된 학습 경험
- **AI 에이전트**: 교육 과정 자동화 및 개인화 지원

### **핵심 기능**
- **교육 자료 관리**: 마크다운 기반 교육 자료 체계적 관리
- **학습 경로 관리**: 단계별 학습 경로 및 진도 추적
- **실습 가이드**: 단계별 실습 지침 및 검증
- **AI 지원**: 교육 자료 생성 및 학습자 지원
- **품질 관리**: 자동화된 교육 자료 품질 검증

## 🏗️ 아키텍처 가이드라인

### **시스템 아키텍처**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   AI Agent      │
│   (Nuxt.js)     │◄──►│   (FastAPI)     │◄──►│   (OpenAI)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Education     │    │   Database      │    │   Knowledge     │
│   Materials     │    │   (PostgreSQL)  │    │   Base          │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **모듈 구조**
- **Frontend**: Vue.js 3 + TypeScript + Nuxt.js 3
- **Backend**: FastAPI + Python 3.9+ + SQLAlchemy
- **Database**: PostgreSQL 14+ (교육 자료 및 진도 관리)
- **Cache**: Redis 6+ (성능 최적화)
- **AI Integration**: OpenAI API / Anthropic Claude API
- **File Storage**: 로컬 파일 시스템 (교육 자료)

## 📁 디렉토리 구조 가이드라인

### **프로젝트 루트 구조**
```
mcp_cloud/
├── frontend/                 # 프론트엔드 애플리케이션
│   ├── components/          # Vue 컴포넌트
│   ├── pages/              # 페이지 라우팅
│   ├── composables/        # 재사용 가능한 로직
│   ├── utils/              # 유틸리티 함수
│   └── assets/             # 정적 자산
├── backend/                # 백엔드 애플리케이션
│   ├── app/                # FastAPI 애플리케이션
│   ├── api/                # API 라우터
│   ├── models/             # 데이터 모델
│   ├── services/           # 비즈니스 로직
│   └── utils/              # 유틸리티 함수
├── mcp_knowledge_base/     # 교육 자료 저장소
│   ├── cloud_basic/        # Cloud Basic 과정
│   ├── cloud_container/    # Cloud Container 과정
│   └── cloud_master/       # Cloud Master 과정
├── tools/                  # 개발 도구
├── tests/                  # 테스트 코드
└── docs/                   # 프로젝트 문서
```

### **교육 자료 디렉토리 구조**
```
mcp_knowledge_base/
├── [과정명]/
│   ├── learning-path.md    # 학습 경로 메인
│   ├── curriculum.md       # 커리큘럼 개요
│   └── textbook/           # 교재
│       ├── Day1/           # 1일차
│       │   ├── README.md   # 메인 페이지
│       │   ├── practice/   # 실습 가이드
│       │   └── theory/     # 이론 자료
│       └── Day2/           # 2일차
└── index.md                # 전체 인덱스
```

## 💻 코드 작성 가이드라인

### **Python 백엔드 가이드라인**
```python
# ✅ DO: 교육 교구 시스템 Python 코드
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session

class CourseContent(BaseModel):
    # 교육 과정 콘텐츠 모델
    title: str = Field(..., description="교육 과정 제목")
    description: str = Field(..., description="교육 과정 설명")
    learning_objectives: List[str] = Field(..., description="학습 목표")
    duration: int = Field(..., description="예상 소요 시간(분)")
    difficulty: str = Field(..., description="난이도 (초급/중급/고급)")
    
    class Config:
        json_schema_extra = {
            "example": {
                "title": "Cloud Basic - AWS 기초 실습",
                "description": "AWS 클라우드 서비스 기초 학습",
                "learning_objectives": [
                    "AWS 계정 생성 및 설정",
                    "EC2 인스턴스 생성 및 관리",
                    "S3 스토리지 서비스 활용"
                ],
                "duration": 120,
                "difficulty": "초급"
            }
        }

class EducationService:
    # 교육 서비스 클래스
    
    def __init__(self, db: Session):
        self.db = db
    
    async def get_course_content(self, course_id: str) -> Optional[CourseContent]:
        # 교육 과정 콘텐츠 조회
        try:
            # 교육 자료 로드
            content = await self._load_course_materials(course_id)
            
            # 앵커 링크 검증
            validation_result = await self._validate_anchor_links(content)
            if not validation_result.is_valid:
                raise HTTPException(
                    status_code=422, 
                    detail=f"교육 자료 검증 실패: {validation_result.errors}"
                )
            
            return CourseContent(**content)
            
        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"교육 과정 로드 실패: {str(e)}"
            )
```

### **TypeScript 프론트엔드 가이드라인**
```typescript
// ✅ DO: 교육 교구 시스템 TypeScript 코드
interface CourseContent {
  title: string
  description: string
  learningObjectives: string[]
  duration: number
  difficulty: '초급' | '중급' | '고급'
  progress?: number
}

interface EducationState {
  currentCourse: CourseContent | null
  learningProgress: Record<string, number>
  completedLessons: string[]
}

export const useEducationStore = defineStore('education', () => {
  // 상태
  const state = reactive<EducationState>({
    currentCourse: null,
    learningProgress: {},
    completedLessons: []
  })
  
  // 액션
  const loadCourse = async (courseId: string): Promise<void> => {
    try {
      const response = await $fetch<CourseContent>(`/api/v1/courses/${courseId}`)
      state.currentCourse = response
      
      // 학습 진도 로드
      await loadLearningProgress(courseId)
      
    } catch (error) {
      console.error('교육 과정 로드 실패:', error)
      throw new Error('교육 과정을 불러올 수 없습니다.')
    }
  }
  
  const updateProgress = async (lessonId: string, progress: number): Promise<void> => {
    state.learningProgress[lessonId] = progress
    
    // 백엔드에 진도 저장
    await $fetch(`/api/v1/progress/${lessonId}`, {
      method: 'PUT',
      body: { progress }
    })
  }
  
  return {
    state: readonly(state),
    loadCourse,
    updateProgress
  }
})
```

## 🧪 테스트 가이드라인

### **교육 자료 테스트**
```python
# ✅ DO: 교육 자료 테스트
import pytest
from backend.app.services.education_service import EducationService
from backend.app.utils.content_validator import ContentValidator

class TestEducationContent:
    @pytest.fixture
    def education_service(self, db_session):
        return EducationService(db_session)
    
    @pytest.fixture
    def content_validator(self):
        return ContentValidator()
    
    async def test_course_content_loading(self, education_service):
        # 교육 과정 콘텐츠 로딩 테스트
        content = await education_service.get_course_content("cloud_basic")
        
        assert content is not None
        assert content.title == "Cloud Basic - AWS 기초 실습"
        assert len(content.learning_objectives) >= 2
    
    async def test_anchor_links_validation(self, content_validator):
        # 앵커 링크 검증 테스트
        result = await content_validator.validate_anchor_links("test_course.md")
        
        assert result.is_valid == True
        assert len(result.errors) == 0
        assert result.coverage_rate >= 0.95
```

### **프론트엔드 컴포넌트 테스트**
```typescript
// ✅ DO: 교육 컴포넌트 테스트
import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import CourseCard from '@/components/CourseCard.vue'

describe('CourseCard', () => {
  it('should display course information correctly', () => {
    const course = {
      title: 'Cloud Basic - AWS 기초 실습',
      description: 'AWS 클라우드 서비스 기초 학습',
      difficulty: '초급',
      duration: 120
    }
    
    const wrapper = mount(CourseCard, {
      props: { course }
    })
    
    expect(wrapper.text()).toContain(course.title)
    expect(wrapper.text()).toContain(course.description)
    expect(wrapper.text()).toContain(course.difficulty)
  })
  
  it('should handle course click events', async () => {
    const course = { id: 'cloud_basic', title: 'Test Course' }
    const wrapper = mount(CourseCard, {
      props: { course }
    })
    
    await wrapper.find('.course-card').trigger('click')
    
    expect(wrapper.emitted('course-selected')).toBeTruthy()
    expect(wrapper.emitted('course-selected')[0]).toEqual([course.id])
  })
})
```

## 📊 성능 가이드라인

### **교육 자료 로딩 최적화**
```python
# ✅ DO: 교육 자료 로딩 최적화
from functools import lru_cache
from typing import Dict, Any
import asyncio

class OptimizedEducationService:
    def __init__(self):
        self._cache = {}
        self._loading_tasks = {}
    
    @lru_cache(maxsize=100)
    async def get_course_metadata(self, course_id: str) -> Dict[str, Any]:
        # 교육 과정 메타데이터 캐싱
        # 메타데이터만 먼저 로드
        return await self._load_course_metadata(course_id)
    
    async def get_course_content_async(self, course_id: str) -> Dict[str, Any]:
        # 비동기 교육 과정 콘텐츠 로드
        if course_id in self._loading_tasks:
            return await self._loading_tasks[course_id]
        
        task = asyncio.create_task(self._load_full_course_content(course_id))
        self._loading_tasks[course_id] = task
        
        try:
            result = await task
            return result
        finally:
            self._loading_tasks.pop(course_id, None)
```

### **프론트엔드 성능 최적화**
```typescript
// ✅ DO: 프론트엔드 성능 최적화
import { defineAsyncComponent } from 'vue'

// 교육 컴포넌트 지연 로딩
export const CourseContent = defineAsyncComponent({
  loader: () => import('@/components/CourseContent.vue'),
  loadingComponent: LoadingSpinner,
  errorComponent: ErrorComponent,
  delay: 200,
  timeout: 3000
})

// 교육 자료 가상 스크롤링
export const useVirtualScroll = (items: Ref<any[]>) => {
  const visibleItems = ref<any[]>([])
  const scrollTop = ref(0)
  const itemHeight = 100
  
  const updateVisibleItems = () => {
    const start = Math.floor(scrollTop.value / itemHeight)
    const end = Math.min(start + 10, items.value.length)
    visibleItems.value = items.value.slice(start, end)
  }
  
  return {
    visibleItems,
    scrollTop,
    updateVisibleItems
  }
}
```

## 🔒 보안 가이드라인

### **교육 자료 접근 제어**
```python
# ✅ DO: 교육 자료 접근 제어
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer
from jose import JWTError, jwt

security = HTTPBearer()

class EducationAccessControl:
    def __init__(self):
        self.role_permissions = {
            'student': ['read'],
            'instructor': ['read', 'write'],
            'admin': ['read', 'write', 'delete']
        }
    
    async def check_course_access(self, course_id: str, user_role: str) -> bool:
        # 교육 과정 접근 권한 확인
        if user_role not in self.role_permissions:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="접근 권한이 없습니다."
            )
        
        # 교육 과정별 접근 제어 로직
        return await self._validate_course_access(course_id, user_role)
    
    async def check_content_modification(self, content_id: str, user_role: str) -> bool:
        # 교육 자료 수정 권한 확인
        if 'write' not in self.role_permissions.get(user_role, []):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="교육 자료 수정 권한이 없습니다."
            )
        
        return True
```

## 📚 관련 파일

- [README.md](mdc:README.md) - 프로젝트 개요
- [CONTRIBUTING.md](mdc:CONTRIBUTING.md) - 기여 가이드라인
- [CHANGELOG.md](mdc:CHANGELOG.md) - 변경 이력
- [LICENSE](mdc:LICENSE) - 라이선스 정보

이 가이드라인을 통해 교육 교구 시스템의 일관성 있고 고품질의 개발을 보장할 수 있습니다.
"""
        
        self._write_rule_file("project-guidelines.mdc", content)
        print("✅ 프로젝트 가이드라인 업데이트 완료")
    
    def _write_rule_file(self, filename: str, content: str):
        # 커서룰 파일 작성
        file_path = self.rules_path / filename
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        self.updates_applied += 1
    
    def update_all_remaining_rules(self):
        # 나머지 모든 커서룰 업데이트
        print("🚀 나머지 커서룰 현행화 시작")
        print("=" * 60)
        
        # 1. 콘텐츠 생성 규칙 업데이트
        self.update_content_creation_rules()
        
        # 2. 개발 환경 규칙 업데이트
        self.update_development_environment_rules()
        
        # 3. 프로젝트 가이드라인 업데이트
        self.update_project_guidelines()
        
        print("\n" + "=" * 60)
        print("🎯 나머지 커서룰 현행화 완료")
        print(f"📊 업데이트된 규칙: {self.updates_applied}개")
        print("✅ 교육 교구 시스템에 특화된 모든 커서룰 현행화 완료")

def main():
    # 메인 실행 함수
    updater = RemainingCursorRulesUpdater()
    updater.update_all_remaining_rules()

if __name__ == "__main__":
    main()
