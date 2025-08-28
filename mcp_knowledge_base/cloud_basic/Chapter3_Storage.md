## Chapter 3: 클라우드 스토리지와 정적 웹/아카이빙

### 개요
객체 스토리지는 정적 웹, 백업/아카이빙, 데이터 공유에 폭넓게 사용됩니다. 본 장에서는 정적 웹사이트 호스팅과 라이프사이클 기반 비용 최적화를 다룹니다.

### 학습 목표
- 정적 웹사이트를 안전하게 공개한다(공개 범위 최소화 원칙 이해)
- 라이프사이클/버전관리로 비용과 복구 가능성을 균형 잡는다
- 플랫폼 과금/클래스 차이를 이해하고 최적화한다

### 실습 1: 정적 웹사이트 호스팅 (플랫폼별)
#### Azure
- Storage account → Static website 활성화 → $web 컨테이너 업로드
- CLI:
```
az storage account create -n <acct> -g rg-lab -l koreacentral --sku Standard_LRS
az storage blob service-properties update --account-name <acct> --static-website \
  --index-document index.html --404-document 404.html
az storage blob upload-batch -s ./site -d '$web' --account-name <acct>
```

#### AWS
- S3 버킷 생성 → 정적 웹 활성화 → 최소 공개 정책 → CloudFront 연동 고려
- CLI:
```
aws s3 mb s3://lab-static-<uid>
aws s3 sync ./site s3://lab-static-<uid>
```

#### GCP
- Cloud Storage 버킷 생성 → `gsutil web set`으로 index/404 지정 → 공개 주의
- CLI:
```
gsutil mb -l ASIA-NORTHEAST3 gs://lab-static-<uid>
gsutil cp -r ./site/* gs://lab-static-<uid>
gsutil web set -m index.html -e 404.html gs://lab-static-<uid>
gsutil iam ch allUsers:objectViewer gs://lab-static-<uid>
```

### 실습 2: 라이프사이클/버전관리/아카이빙
- 30일 경과 객체 Cool/IA/Coldline로 이동, 90일 후 삭제 정책 구성
- 버전관리 활성화 후 삭제/덮어쓰기 복구 실습
- 비용 계산기/청구 대시보드로 전후 비교

### 운영 체크리스트
- 공개 객체 최소화(서명 URL/정책, CDN+WAF 권장)
- 삭제 보호/버전 관리와 보존 규정 준수
- KMS 암호화/전송 암호화/액세스 로그 활성화

---

## 팀 역할 기반 실습 가이드

### Finance (재무팀)
- 스토리지 비용 분석 대시보드 생성(클래스/리전/버킷별)
- 라이프사이클 정책에 따른 비용 절감 효과 리포트
- 무태그 버킷 탐지 및 경보(정책 검토)

### IT 운영팀 & DevOps 엔지니어
- 정적 웹/버킷/정책 IaC 모듈화 및 PR 승인 플로우
- 퍼블릭 액세스 통합 정책: 차단 기본, 예외 승인 프로세스
- 로그/액세스 모니터링 파이프라인 구성

### 개발팀 (Development)
- 정적 자산 빌드/배포 자동화 스크립트 작성
- 서명 URL/사전 서명 정책 활용 패턴 구현(필요 시)
- 객체 버전 관리 기반 롤백 테스트

### 운영팀 (SRE)
- 스토리지 가용성/오류율 SLI/SLO 설정
- 공개 객체/권한 변경 이상 탐지 및 알림 룰 구성
- 데이터 보존/파기 절차 점검 및 감사 대응

### 자동화 실행 경로
- CLI: `cloud_basic/automation/cli/aws/ch3_storage.sh`, `cloud_basic/automation/cli/azure/ch3_storage.sh`, `cloud_basic/automation/cli/gcp/ch3_storage.sh`
- Terraform: `cloud_basic/automation/terraform/aws/ch3_storage`, `cloud_basic/automation/terraform/azure/ch3_storage`, `cloud_basic/automation/terraform/gcp/ch3_storage`
- 참고: `cloud_basic/자동화_사용안내.md`

