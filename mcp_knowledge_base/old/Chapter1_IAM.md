## Chapter 1: 클라우드 계정 및 IAM

### 개요
조직의 보안 출발점은 신원과 권한 관리입니다. Azure Entra ID, AWS IAM, GCP IAM의 핵심 개념을 비교하고 최소 권한 원칙을 실습으로 체득합니다.

### 학습 목표
- 최소 권한 원칙에 따라 사용자/그룹/역할을 설계한다.
- 플랫폼별 RBAC/IAM 모델을 이해하고 실제로 권한을 부여한다.
- MFA/조건부 접근, 권한 경계 등 보안 강화를 적용한다.

### 준비물
- Azure/AWS/GCP 콘솔 접근 권한(Owner/Administrator)
- 각 플랫폼 CLI: az, awscli, gcloud 설치 및 로그인

### 실습 1: 사용자/그룹/역할 설계 및 할당 (플랫폼별)

#### Azure
- 포털: Subscription/Resource group → Access control (IAM)
- 작업: 그룹 생성, 역할(Reader/Contributor/Storage Blob Data Reader) 할당, MFA(Conditional Access) 정책 적용
- CLI 예시:
```
az ad group create --display-name DevTeam --mail-nickname devteam
az role assignment create \
  --assignee-object-id <USER_OR_GROUP_OBJECT_ID> \
  --role "Reader" \
  --scope "/subscriptions/<SUB_ID>/resourceGroups/<RG_NAME>"
```

#### AWS
- 콘솔: IAM → Users/Groups/Policies → MFA 설정
- 작업: 사용자/그룹 생성, ReadOnlyAccess 등 최소 권한 부여, 콘솔 MFA 의무화
- CLI 예시:
```
aws iam create-user --user-name dev-user
aws iam create-group --group-name DevTeam
aws iam add-user-to-group --user-name dev-user --group-name DevTeam
aws iam attach-group-policy --group-name DevTeam \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess
```

#### GCP
- 콘솔: IAM & Admin → IAM → 역할(Viewer/Editor/Storage Admin) 바인딩, 2단계 인증 정책
- 작업: 프로젝트 단위 역할 바인딩, 서비스 계정 최소 권한
- CLI 예시:
```
gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member=user:<EMAIL> --role=roles/viewer
```

### 실습 2: 서비스 계정/권한 경계/조건부 정책
- 서비스 계정에 특정 리소스 작업만 허용(예: S3 PutObject, Storage Object Admin 제한)
- 권한 경계(aws)/조건부 접근(azure)/정책 조건(gcp)로 과도한 권한 부여 차단

### 검증 체크리스트
- 콘솔/CLI로 권한이 의도한 범위로만 동작하는지 확인(허용/거부 케이스 테스트)
- MFA 활성 스크린샷 및 정책 증빙
- 태그/라벨 기반 접근 제어(가능한 범위) 검토

### 트러블슈팅 가이드
- 권한 거부 발생 시: 리소스 스코프, 상속된 역할, 정책 조건(시간/IP) 확인
- 중복 정책 충돌: 명시적 Deny 우선, 상위 스코프 역할 교차 점검

### 마무리 및 다음 단계
- 프로젝트/폴더/구독 레벨 표준 역할 카탈로그 정의
- 감사 로깅 활성화 및 정기 권한 검토 프로세스 마련

---

## 팀 역할 기반 실습 가이드

### Finance (재무팀)
- 비용 태깅 표준 수립: 모든 리소스에 `project`, `department`, `env`, `owner` 태그/라벨 적용
- 예산 알림 구성: AWS Budgets/Cost Anomaly, GCP Budget Alerts, Azure Cost Management 예산 알림
- 정책: 무태그 리소스 차단 정책 탐색(Policy/Organization Policy) 및 리포트 자동화

### IT 운영팀 & DevOps 엔지니어
- IaC로 IAM 베이스라인 정의(Terraform): 표준 역할/그룹/정책 템플릿화, PR 리뷰/승인 플로우 구성
- 계정/권한 프로비저닝 자동화: 신규 팀 온보딩 시 파이프라인으로 사용자/그룹/역할 생성
- 중앙 로깅/모니터링: IAM 변경 이벤트(Audit) 수집 대시보드 구성

### 개발팀 (Development)
- 셀프서비스 온보딩: 제공된 템플릿으로 서비스 계정/권한 요청(PR 기반)
- MFA 등록 및 비밀관리 표준 준수(Secret Manager/Key Vault/Secrets Manager)
- 최소 권한 검증: 앱이 필요한 API만 호출되는지 테스트 케이스 작성

### 운영팀 (SRE)
- 접근/권한 관련 SLI/SLO 정의(권한 오류율, 승인 리드타임)
- 정책 위반 탐지 룰 및 알림 설정(과도 권한, 공개 리소스)
- 접근 장애 런북 작성(승인 누락/정책 충돌/토큰 만료)

### 자동화 실행 경로
- CLI: `cloud_basic/automation/cli/aws/ch1_iam.sh`, `cloud_basic/automation/cli/azure/ch1_iam.sh`, `cloud_basic/automation/cli/gcp/ch1_iam.sh`
- Terraform: `cloud_basic/automation/terraform/aws/ch1_iam`, `cloud_basic/automation/terraform/azure/ch1_iam`, `cloud_basic/automation/terraform/gcp/ch1_iam`
- 참고: `cloud_basic/자동화_사용안내.md`

---

## 비용관리자 vs IT관리자 역할 구분 (명시)

### 정의
- 비용관리자(Cost Manager): 예산/비용 가시화와 알림 설정, 태깅 표준 준수 여부 점검, 비용 리포팅을 담당. 리소스 생성/변경 권한은 없음(원칙적으로).
- IT관리자(운영/DevOps): 인프라 리소스 생성/변경/배포 자동화를 담당. 청구/비용 데이터는 조회 불가(원칙적으로).

### 클라우드별 권한 범위(RBAC/IAM)
- Azure
  - 비용관리자: Billing Reader, Cost Management Reader/Contributor(필요 시) — 구독/관리그룹 스코프. Resource Group 수준 쓰기 권한 금지.
  - IT관리자: Subscription/Resource Group Contributor(또는 서비스별 제한 역할). Billing/CMA 권한 미부여.
- AWS
  - 비용관리자: Billing 콘솔 접근 허용(루트/Account 설정에서 IAM Billing Access 활성화 필요), Cost Explorer(Read 전용), Budgets(생성/조회), aws-portal:* 한정 권한. EC2/S3 등 리소스 조작 권한 명시적 Deny 또는 Permission Boundary로 차단.
  - IT관리자: PowerUserAccess 또는 서비스 한정 정책(EC2/VPC/IAM 역할 최소화). aws-portal/*, ce:*, budgets:* 등 청구/비용 권한 미부여.
- GCP
  - 비용관리자: Billing Account Viewer(또는 Admin), 프로젝트에는 Viewer 수준만 부여. 리소스 쓰기 금지.
  - IT관리자: 프로젝트 단위 Editor/서비스별 역할(Compute Admin 등). Billing Account 역할 미부여.

### 권한 경계/정책 적용 예
- AWS: Permission Boundary로 `ec2:*`, `s3:*` 등 리소스 조작을 비용관리자에게 명시적 Deny. 비용 관련 `ce:Get*`, `budgets:*`만 허용.
- Azure: 비용관리자는 관리그룹/구독 스코프에 Cost Management 역할만, 리소스 그룹에는 Reader 이하. IT관리자는 RG/구독 Contributor, Billing 역할 없음.
- GCP: Billing Account 역할은 비용관리자에게만. IT관리자는 프로젝트 역할만 부여(roles/billing.* 금지).

### 승인/운영 흐름(요지)
1) DevOps가 IaC(PR) 생성 → 2) CI에서 Plan/보안스캔 → 3) 비용관리자가 예상비용/태깅 준수 검토(승인) → 4) DevOps가 Apply → 5) SRE 모니터링/런북.

### 분리 검증 체크리스트
- 비용관리자 계정으로 리소스 생성/수정이 불가능한가?
- IT관리자 계정으로 청구/예산 화면 접근이 차단되는가?
- 태깅 미준수 리소스가 비용 리포트에서 탐지되는가?

---
◀ 이전: [실습_시나리오.md](실습_시나리오.md) | 다음 ▶: [Chapter2_VM.md](Chapter2_VM.md)
