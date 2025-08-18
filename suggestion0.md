## 교구형 프론트엔드 재설계 제안서

### 목적과 배경
- **목적**: 일반 웹사이트형 UI를 학습·실습에 최적화된 교구형 워크벤치로 전환
- **배경**: AI 에이전트와 함께 클라우드 IaaS/PaaS 설계·검증·배포를 단계적으로 학습/실습

### 핵심 컨셉
- **3-페인 워크벤치**
  - 좌: 레슨/체크리스트(진행도)
  - 중: 실습 캔버스(Guide, CLI, Terraform, Result 탭)
  - 우: AI 코치(컨텍스트 힌트/퀴즈/요약)
- **단계 기반 학습**: 목표 → 설계 → 프로비저닝 → 검증 순환을 구조화
- **안전 실습**: 읽기전용 CLI, 변경은 Terraform 코드 → 승인 → Apply

### 정보 구조(IA) 및 라우팅
- **신규 경로**
  - `/learn`: 레슨 카탈로그
  - `/learn/[slug]`: 레슨 워크벤치(교육 레이아웃 적용)
- **기존 경로 재활용**
  - `/ai-assistant`: 자유 대화/도구 미니앱 유지
  - `/cli`: 읽기전용 API 그대로, 워크벤치의 CLI 탭에서 호출

### 화면 레이아웃
- **교육 레이아웃(`education`)**
  - 상단: 레슨 타이틀/툴바(리셋, 해설 등)
  - 본문: 12 그리드(3-6-3) 좌/중/우 페인
- **네비게이션**
  - 글로벌 내비에 `교구(/learn)` 항목 추가

### 주요 페이지
- **`/learn`**: 레슨 카드 리스트(난이도, 예상시간, 요약)
- **`/learn/[slug]`**: 워크벤치
  - 좌: `LessonSidebar` 체크리스트
  - 중: `LabTabs` (Guide, CLI, Terraform, Result)
  - 우: `CoachPanel` (레슨 컨텍스트 기반 AI)

### 핵심 컴포넌트
- **`LessonSidebar`**
  - 섹션/스텝 체크리스트, 진행도 상태 저장(초기: 로컬, 확장: 백엔드 동기화)
- **`LabTabs`**
  - Guide: 레슨 가이드 표시
  - CLI: `/api/v1/cli/read-only` 호출(읽기전용)
  - Terraform: 요구사항 → 코드 생성(`POST /ai/assistant/terraform-generate`)
  - Result: 자동 검증 결과/점수/조언 표시
- **`CoachPanel`**
  - 컨텍스트 질의 → `POST /ai/assistant/query-sync` 연동
  - 힌트/요약/간단 퀴즈(확장)

### 사용자 플로우
1) `/learn`에서 레슨 선택 → 2) Guide 탭에서 목표/제약 확인 → 3) CLI 탭으로 안전 조회 → 4) Terraform 탭에서 코드 생성/리뷰 → 5) Result 탭에서 자동 체크 → 6) 우측 AI 코치로 힌트/요약

### 상태/데이터 모델(프론트)
- **`LessonMeta`**: `{ slug, title, sections, guide }`
- **`Progress`**: `{ stepKey: boolean }` 체크리스트 완료 여부
- **`LabState`**: CLI 결과, TF 생성물, 검증 결과

### 백엔드 연동 포인트
- **AI 질의**: `POST /ai/assistant/query-sync` (헤더 `X-API-Key`)
- **TF 생성**: `POST /ai/assistant/terraform-generate`
- **CLI 읽기전용**: `POST /api/v1/cli/read-only`
- (확장) 검증 실행, 진행도 저장, 승인 워크플로 연동 API

### 보안/권한/안전장치
- **CLI는 읽기전용**으로 고정
- **변경은 Terraform** 경로만 허용(승인 워크플로 필수)
- **환경변수**: `NUXT_PUBLIC_API_BASE_URL`, `MCP_API_KEY`

### 접근성/국제화
- 키보드 내비/포커스 스타일, 충분한 색 대비
- 로딩/알림 라이브 리더 텍스트
- 국제화는 문구 슬롯팅 → 후속 i18n 적용

### 성능 전략
- 지연 로딩(코치/탭), API 응답 캐시, 렌더 최소화

### 도입 단계(마이그레이션)
- 1단계: `/learn`, `education` 레이아웃, 1개 레슨(MVP)
- 2단계: 진행도 로컬 저장, Result 탭 샘플 검증
- 3단계: 백엔드 진행도/검증 API, 퀴즈 카드
- 4단계: 승인/보안/비용 통합, 대시보드

### 성공 지표
- 학습 완료율/시간, 자동 검증 통과율, AI 코치 상호작용 빈도, 이탈 포인트

### 수용 기준(AC)
- `/learn`에서 최소 3개 샘플 레슨 노출
- `/learn/[slug]` 3-페인 워크벤치 정상 동작
- CLI 탭에서 읽기전용 API 호출 성공
- TF 탭에서 코드 생성/렌더 확인
- AI 코치 질의/응답 성공

### 우선순위 To-Do
- **P0**: `/learn`, `education` 레이아웃, `LessonSidebar`, `LabTabs(cli/tf)`, `CoachPanel`
- **P1**: Result 자동 검증(샘플), 진행도 로컬 저장
- **P2**: 백엔드 진행도/검증 API, 퀴즈
- **P3**: 승인/보안/비용 통합, 대시보드

