#!/usr/bin/env python3
"""
커서룰 현행화 도구
교육 교구 시스템에 특화된 커서룰로 업데이트합니다.
"""

import os
import re
import json
from pathlib import Path
from datetime import datetime

class CursorRulesUpdater:
    """커서룰 현행화 도구"""
    
    def __init__(self, rules_path: str = ".cursor/rules"):
        self.rules_path = Path(rules_path)
        self.updates_applied = 0
        
    def update_global_rules(self):
        """글로벌 규칙을 교육 교구 시스템에 맞게 업데이트"""
        print("📝 글로벌 규칙 업데이트 중...")
        
        content = r"""---
description: AI 활용 교육 교구 시스템의 전반적인 규칙과 가이드라인
globs:
  - "**/*.py"
  - "**/*.ts"
  - "**/*.vue"
  - "**/*.json"
  - "**/*.md"
alwaysApply: true
---

# AI 활용 교육 교구 시스템 규칙

## 🎯 시스템 목표
- **교육 커리큘럼 작성자**: 직관적이고 효율적인 교육 자료 작성 지원
- **교육자**: 수강자에게 최고의 교육 경험 제공
- **수강자**: 체계적이고 일관된 학습 경험

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
        
        self._write_rule_file("global-rules.mdc", content)
        print("✅ 글로벌 규칙 업데이트 완료")
    
    def update_document_handling_rules(self):
        """문서 처리 규칙을 교육 교구 시스템에 맞게 업데이트"""
        print("📝 문서 처리 규칙 업데이트 중...")
        
        content = r"""---
description: 교육 교구 시스템의 문서 처리 및 연결 관리 규칙
globs: "**/*.md", "**/*.vue", "**/*.ts"
alwaysApply: true
---

# 교육 교구 시스템 문서 처리 규칙

## 📄 교육 문서 호출 API 규칙

### **백엔드 API 엔드포인트 (교육 특화)**
- **Curriculum API**: `/api/v1/curriculum` - 교육 커리큘럼 문서 호출
- **Knowledge Base API**: `/api/v1/knowledge-base` - 교육 지식베이스 문서 호출
- **Practice API**: `/api/v1/practice` - 실습 가이드 문서 호출
- **Progress API**: `/api/v1/progress` - 학습 진도 관리

### **교육 자료 API 호출 패턴**
```typescript
// ✅ DO: 교육 자료 호출 패턴
const response = await fetch(`/api/v1/curriculum?curriculum_path=${encodeURIComponent(path)}`)
const data = await response.json()

// ✅ DO: 실습 가이드 호출
const practiceResponse = await fetch(`/api/v1/practice?guide_id=${guideId}`)
const practiceData = await practiceResponse.json()

// ❌ DON'T: 직접 경로 사용 (보안 위험)
const response = await fetch(`/api/v1/curriculum?curriculum_path=${path}`)
```

## 🏷️ 교육 문서 제목 처리 규칙

### **교육 과정 제목 구조**
```markdown
<!-- ✅ DO: 교육 과정 제목 구조 -->
# 🎯 Cloud Basic - 1일차: AWS 기초 실습
## 📚 실습 가이드
### 🔧 실습 환경 준비
#### 💻 단계별 실습

<!-- ❌ DON'T: 일관성 없는 제목 -->
# Cloud Basic
## 실습
### 환경
```

### **제목 추출 로직 (교육 특화)**
```typescript
// ✅ DO: 교육 문서 제목 추출
const titleText = computed(() => {
  if (!props.content) return '';
  
  // 교육 과정 제목 추출 (이모지 포함)
  const match = props.content.match(/^\s*#{1,6}\s+(.+)$/m);
  if (match) {
    const title = match[1].trim();
    // 교육 과정 제목 정리
    return title.replace(/^🎯\s*/, '').replace(/^📚\s*/, '').trim();
  }
  
  // Fallback: 파일명에서 교육 과정 제목 생성
  return props.path ? 
    props.path.split('/').pop()
      .replace(/_/g, ' ')
      .replace(/\.md$/i, '') : '';
});
```

## 🔗 교육 자료 내부 링크 처리 규칙

### **학습 경로 네비게이션**
```markdown
<!-- ✅ DO: 교육 과정 네비게이션 -->
<div align="center">

[← 이전: Cloud Basic 1일차](../README.md) | 
[📚 전체 커리큘럼](../../../curriculum.md) | 
[🏠 학습 경로로 돌아가기](../../../index.md) | 
[다음: Cloud Basic 2일차 →](../README.md)

</div>
```

### **실습 가이드 링크 처리**
```typescript
// ✅ DO: 실습 가이드 링크 처리
const setupPracticeLinks = async () => {
  // 실습 가이드 링크 인터셉트
  document.addEventListener('click', async (event) => {
    const link = event.target.closest('a[href]');
    if (!link) return;
    
    const href = link.getAttribute('href');
    
    // 실습 가이드 링크 처리
    if (href.startsWith('/practice/')) {
      event.preventDefault();
      await loadPracticeGuide(href);
    }
    
    // 교육 자료 링크 처리
    if (href.startsWith('/curriculum/')) {
      event.preventDefault();
      await loadCurriculum(href);
    }
  });
};
```

## 📁 교육 자료 파일 경로 처리 규칙

### **안전한 교육 자료 경로 처리**
```python
# ✅ DO: 교육 자료 경로 안전 처리
def _safe_education_path(rel: str) -> Path:
    rel = (rel or '').strip().lstrip('/\\')
    p = (EDUCATION_ROOT / rel).resolve()
    if not str(p).startswith(str(EDUCATION_ROOT)):
        raise HTTPException(status_code=400, detail='Invalid education path')
    return p

# ✅ DO: 교육 과정별 경로 처리
def get_curriculum_path(course: str, day: int, lesson: str) -> str:
    return f"curriculum/{course}/day{day:02d}/{lesson}.md"
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

## 🎨 교육 자료 UI 표시 규칙

### **교육 과정 로딩 상태 표시**
```vue
<!-- ✅ DO: 교육 과정 로딩 표시 -->
<div v-if="isLoading" class="education-loading">
  <div class="loading-spinner"></div>
  <span>교육 자료를 불러오는 중...</span>
</div>

<!-- ✅ DO: 실습 가이드 로딩 표시 -->
<div v-if="practiceLoading" class="practice-loading">
  <div class="practice-spinner"></div>
  <span>실습 가이드를 준비하는 중...</span>
</div>
```

### **교육 과정 제목 표시**
```vue
<!-- ✅ DO: 교육 과정 제목 표시 -->
<div class="education-header">
  <h1 class="course-title">
    <span class="course-icon">🎯</span>
    {{ courseTitle }}
  </h1>
  <div class="course-meta">
    <span class="course-level">{{ courseLevel }}</span>
    <span class="course-duration">{{ courseDuration }}</span>
  </div>
</div>
```

## 🧪 교육 자료 테스트 규칙

### **교육 자료 연결 테스트**
```typescript
// ✅ DO: 교육 자료 링크 테스트
describe('Education Material Links', () => {
  it('should load curriculum correctly', async () => {
    const response = await fetch('/api/v1/curriculum?path=cloud_basic/day1');
    expect(response.status).toBe(200);
    const data = await response.json();
    expect(data.title).toContain('Cloud Basic');
  });
  
  it('should handle Korean course names', async () => {
    const koreanPath = 'cloud_basic/과정명.md';
    const response = await fetch(`/api/v1/curriculum?path=${encodeURIComponent(koreanPath)}`);
    expect(response.status).toBe(200);
  });
});
```

### **실습 가이드 테스트**
```typescript
// ✅ DO: 실습 가이드 테스트
describe('Practice Guide', () => {
  it('should validate practice steps', () => {
    const practiceGuide = loadPracticeGuide('aws-basic-practice');
    expect(practiceGuide.steps).toHaveLength(5);
    expect(practiceGuide.steps[0]).toHaveProperty('title');
    expect(practiceGuide.steps[0]).toHaveProperty('instructions');
  });
});
```

## 🚨 교육 자료 보안 고려사항

### **교육 자료 접근 제어**
- **학습자 권한**: 등록된 학습자만 교육 자료 접근
- **교육자 권한**: 교육 자료 수정 및 관리 권한
- **관리자 권한**: 전체 교육 시스템 관리 권한

### **교육 데이터 보호**
- **개인정보 보호**: 학습자 개인정보 암호화 저장
- **진도 데이터**: 학습 진도 데이터 안전한 저장
- **피드백 데이터**: 학습자 피드백 익명화 처리

## 📚 관련 파일

- [ContentView.vue](mdc:frontend/components/ContentView.vue) - 교육 자료 표시 컴포넌트
- [curriculum.py](mdc:backend/app/api/routes/curriculum.py) - 교육 커리큘럼 API
- [path.ts](mdc:frontend/utils/path.ts) - 교육 자료 경로 처리
- [default.vue](mdc:frontend/layouts/default.vue) - 교육 플랫폼 레이아웃

## 🔄 교육 자료 업데이트 가이드

### **새로운 교육 과정 추가 시**
1. 교육 과정 디렉토리 구조 생성
2. 커리큘럼 문서 작성 및 연결
3. 실습 가이드 작성 및 검증
4. 학습 경로에 새 과정 추가
5. 테스트 및 품질 검증

### **기존 교육 자료 수정 시**
1. 수정 전 백업 생성
2. 교육 자료 내용 수정
3. 연결 링크 검증 및 수정
4. 실습 가이드 호환성 확인
5. 수정 후 테스트 실행
"""
        
        self._write_rule_file("document-handling.mdc", content)
        print("✅ 문서 처리 규칙 업데이트 완료")
    
    def update_learning_path_rules(self):
        """학습 경로 규칙을 교육 교구 시스템에 맞게 업데이트"""
        print("📝 학습 경로 규칙 업데이트 중...")
        
        content = r"""---
description: 교육 교구 시스템의 학습 경로 및 링크 관리 규칙
globs: "**/*.md", "**/learning-path.md", "**/curriculum.md"
alwaysApply: true
---

# 교육 교구 시스템 학습 경로 관리 규칙

## 📚 교육 과정 네비게이션 구조

### **교육 과정 필수 원칙**
- **완전성**: 모든 교육 자료를 빠짐없이 포함 (필수)
- **일관성**: 교육 과정 전반의 일관된 구조 유지 (필수)
- **접근성**: 모든 학습자가 쉽게 접근할 수 있는 구조 (필수)

### **교육 과정 네비게이션 링크**
모든 주요 교육 문서에는 다음 네비게이션 링크가 **반드시** 포함되어야 합니다:

```markdown
<div align="center">

[← 이전: [과정명] [일차] 메인](../README.md) | 
[📚 전체 커리큘럼](../../../curriculum.md) | 
[🏠 학습 경로로 돌아가기](../../../index.md) | 
[다음: [과정명] [일차] →](../README.md)

</div>
```

### **교육 과정 링크 구조 규칙**
- **이전 과정**: `[← 이전: [과정명] [일차] 메인](../README.md)`
- **전체 커리큘럼**: `[📚 전체 커리큘럼](../../../curriculum.md)`
- **학습 경로**: `[🏠 학습 경로로 돌아가기](../../../index.md)`
- **다음 과정**: `[다음: [과정명] [일차] →](../README.md)` (해당하는 경우)

## 🔗 교육 자료 앵커 링크 규칙

### **교육 과정 앵커 링크 표준**
교육 과정 헤딩을 앵커 링크로 변환할 때 다음 규칙을 **반드시** 준수해야 합니다:

```markdown
## 🎯 학습 목표
```
↓ 앵커 링크
```markdown
[🎯 학습 목표](#🎯-학습-목표)
```

### **교육 과정 앵커 변환 규칙**
1. **이모지 유지**: `🎯 학습 목표` → `🎯-학습-목표`
2. **특수문자 처리**: `AWS S3 실습` → `aws-s3-실습`
3. **공백을 하이픈으로 변환**: `GitHub Actions` → `github-actions`
4. **소문자 변환**: `README` → `readme`
5. **연속 하이픈 정리**: `Prometheus + Grafana` → `prometheus-grafana`

### **교육 과정 목차 앵커 링크 검증**
모든 교육 과정 목차의 앵커 링크는 실제 헤딩과 **정확히 일치**해야 합니다:

```markdown
<!-- ✅ 올바른 예시 -->
1. [🎯 학습 목표](#🎯-학습-목표)
2. [📚 실습 가이드](#📚-실습-가이드)
3. [🔧 실습 환경 준비](#🔧-실습-환경-준비)

<!-- ❌ 잘못된 예시 -->
1. [🎯 학습 목표](#-학습-목표)  <!-- 이모지가 앵커에서 누락 -->
2. [📚 실습 가이드](#📚-실습-가이드)  <!-- 이모지가 앵커에 포함됨 -->
```

## 🛠️ 교육 자료 자동 검사 및 수정

### **교육 자료 앵커 링크 검사 도구**
새로운 교육 자료 작성 시 다음 Python 스크립트로 앵커 링크를 검증하세요:

```python
#!/usr/bin/env python3
import re

def normalize_education_anchor(text):
    # 교육 과정 헤딩을 앵커 링크 형식으로 변환
    # 이모지 유지하면서 정규화
    text = re.sub(r'[^\w\s가-힣🎯📚🔧🚀💰📊🔄🛠️]', '', text)
    text = re.sub(r'\s+', '-', text.strip())
    return text.lower()

def check_education_anchor_links(content):
    # 교육 자료 앵커 링크 오류 검사
    # 헤딩 추출
    headings = set()
    for line in content.split('\n'):
        match = re.match(r'^(#{2,6})\s+(.+)$', line.strip())
        if match:
            title = match.group(2).strip()
            anchor = normalize_education_anchor(title)
            headings.add(anchor)
    
    # 앵커 링크 검사
    errors = []
    for line_num, line in enumerate(content.split('\n'), 1):
        matches = re.finditer(r'\[([^\]]+)\]\(#([^)]+)\)', line)
        for match in matches:
            anchor = match.group(2)
            if anchor not in headings:
                errors.append(f"라인 {line_num}: '{anchor}' 앵커를 찾을 수 없음")
    
    return errors
```

## 📋 교육 자료 작성 체크리스트

### **새 교육 자료 작성 시**
- [ ] **필수**: 모든 관련 교육 자료를 누락 없이 포함
- [ ] **필수**: 교육 과정 일관성 유지
- [ ] 네비게이션 링크 4개 요소 모두 포함
- [ ] 목차의 앵커 링크가 실제 헤딩과 일치
- [ ] 이모지가 포함된 헤딩의 앵커 링크 정확성 확인
- [ ] 상대 경로 링크가 올바른 위치를 가리키는지 확인
- [ ] 교육 과정명이 실제 디렉토리 구조와 일치하는지 확인

### **기존 교육 자료 수정 시**
- [ ] 수정된 헤딩의 앵커 링크 업데이트
- [ ] 목차의 해당 항목 앵커 링크 수정
- [ ] 네비게이션 링크 경로 유효성 확인
- [ ] 관련 교육 자료와의 연결성 확인

### **정기 점검 (주 1회)**
- [ ] 전체 교육 자료 앵커 링크 검사
- [ ] 깨진 링크 수정
- [ ] 교육 과정 네비게이션 구조 일관성 확인
- [ ] 학습자 피드백 반영

## 🚨 교육 자료 주의사항

### **절대 금지사항**
- ❌ 이모지가 앵커 링크에서 누락된 경우: `#-학습-목표`
- ❌ 특수문자가 앵커 링크에 포함된 경우: `#📚-실습-가이드`
- ❌ 대소문자가 혼재된 앵커: `#GitHub-Actions`
- ❌ 연속 하이픈이 포함된 앵커: `#prometheus--grafana`

### **권장사항**
- ✅ 교육 과정 헤딩 작성 시 일관된 형식 사용
- ✅ 목차 생성 시 자동화 도구 활용
- ✅ 교육 자료 수정 시 앵커 링크 동기화 확인
- ✅ 정기적인 링크 검사 및 수정

## 📊 교육 자료 품질 지표

### **목표 수준**
- **앵커 링크 정확도**: 100%
- **교육 과정 네비게이션 링크 완성도**: 100%
- **깨진 링크 수**: 0개
- **학습자 네비게이션 만족도**: 최고 수준

### **모니터링 방법**
- 자동화된 앵커 링크 검사 도구 실행
- 학습자 피드백 수집 및 분석
- 정기적인 교육 자료 구조 검토

## 🎓 교육 과정 완전성 검증

### **Top-down 검증 (교육 경로 → 실제 자료)**
모든 교육 경로에서 참조하는 자료가 실제로 존재하는지 확인:

```python
def validate_education_top_down_links(learning_path_file):
    # 교육 경로에서 참조하는 모든 자료의 존재 여부 검증
    import os
    import re
    
    errors = []
    with open(learning_path_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 상대 경로 링크 추출
    links = re.findall(r'\[([^\]]+)\]\(\./([^)]+)\)', content)
    
    for link_text, file_path in links:
        full_path = os.path.join(os.path.dirname(learning_path_file), file_path)
        if not os.path.exists(full_path):
            errors.append(f"누락된 교육 자료: {file_path}")
    
    return errors
```

### **Bottom-up 검증 (실제 자료 → 교육 경로)**
실제 존재하는 모든 교육 자료가 교육 경로에 포함되어 있는지 확인:

```python
def validate_education_bottom_up_coverage(learning_path_file, course_directory):
    # 실제 교육 자료들이 교육 경로에 모두 포함되어 있는지 검증
    import os
    import re
    import glob
    
    # 교육 경로에서 참조하는 파일 목록 추출
    with open(learning_path_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    referenced_files = set()
    links = re.findall(r'\[([^\]]+)\]\(\./([^)]+)\)', content)
    for link_text, file_path in links:
        referenced_files.add(file_path)
    
    # 실제 존재하는 교육 자료 목록
    actual_files = set()
    for md_file in glob.glob(os.path.join(course_directory, '**/*.md'), recursive=True):
        rel_path = os.path.relpath(md_file, course_directory)
        actual_files.add(rel_path.replace('\\', '/'))
    
    # 누락된 교육 자료 찾기
    missing_files = actual_files - referenced_files
    
    # 백업 파일과 README 파일 제외
    missing_files = {f for f in missing_files 
                    if not f.endswith('.backup') 
                    and not f.endswith('README.md')
                    and f != 'learning-path.md'}
    
    return list(missing_files)
```

이 규칙을 통해 교육자와 학습자들이 원활하고 일관된 교육 경험을 할 수 있도록 합니다.
"""
        
        self._write_rule_file("learning-path.mdc", content)
        print("✅ 학습 경로 규칙 업데이트 완료")
    
    def _write_rule_file(self, filename: str, content: str):
        """커서룰 파일 작성"""
        file_path = self.rules_path / filename
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        self.updates_applied += 1
    
    def update_all_rules(self):
        """모든 커서룰 업데이트"""
        print("🚀 교육 교구 시스템 커서룰 현행화 시작")
        print("=" * 60)
        
        # 1. 글로벌 규칙 업데이트
        self.update_global_rules()
        
        # 2. 문서 처리 규칙 업데이트
        self.update_document_handling_rules()
        
        # 3. 학습 경로 규칙 업데이트
        self.update_learning_path_rules()
        
        print("\n" + "=" * 60)
        print("🎯 커서룰 현행화 완료")
        print(f"📊 업데이트된 규칙: {self.updates_applied}개")
        print("✅ 교육 교구 시스템에 특화된 커서룰로 현행화 완료")

def main():
    """메인 실행 함수"""
    updater = CursorRulesUpdater()
    updater.update_all_rules()

if __name__ == "__main__":
    main()
