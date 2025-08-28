## 클라우드실무력강화_활용법(기초) 커리큘럼 — cloud_basic 전용

본 커리큘럼은 클라우드실무력 강화 기초반에 맞게 설계되었습니다. 
사전준비(계정 등록)부터 Chapter 1~4 실습까지, 자동화 스크립트와 제출물 기준을 포함합니다.

> 표기 안내: 🔗 아이콘이 붙은 항목은 클릭 가능한 링크입니다.

---

## Day 0 · 사전준비 (계정 등록/보안/예산)

- 참고 문서
  - 🔗 [사전준비_1_공통사항.md](mdc:mcp_knowledge_base/cloud_basic/prerequisite/사전준비_1_공통사항.md)
  - 🔗 [사전준비_2_계정등록.md](mdc:mcp_knowledge_base/cloud_basic/prerequisite/사전준비_2_계정등록.md)
  - 🔗 [사전준비_3_역할분담.md](mdc:mcp_knowledge_base/cloud_basic/prerequisite/사전준비_3_역할분담.md)
  - 🔗 [사전준비_4_자동화_사용안내.md](mdc:mcp_knowledge_base/cloud_basic/prerequisite/사전준비_4_자동화_사용안내.md)
- 핵심 목표
  - AWS/GCP/Azure 계정(또는 프로젝트/구독) 준비, MFA 등록, 역할 분리(비용관리자 vs IT 관리자)
  - 예산 알림 설정(AWS/GCP/Azure) 및 CLI 초기화(aws/gcloud/az)
- 권장 산출물
  - 체크리스트: 🔗 [실습_계정등록_검증체크리스트.md](mdc:mcp_knowledge_base/cloud_basic/templates/실습_계정등록_검증체크리스트.md)

---

## Day 1 · Chapter 1: 클라우드 계정 및 IAM

- 본문: 🔗 [Chapter1_IAM.md](mdc:mcp_knowledge_base/cloud_basic/Chapter1_IAM.md)
- 자동화 스크립트(선택)
  - AWS: 🔗 [ch1_iam.sh](mdc:mcp_knowledge_base/cloud_basic/automation/cli/aws/ch1_iam.sh)
  - Azure: 🔗 [ch1_iam.sh](mdc:mcp_knowledge_base/cloud_basic/automation/cli/azure/ch1_iam.sh)
  - GCP: 🔗 [ch1_iam.sh](mdc:mcp_knowledge_base/cloud_basic/automation/cli/gcp/ch1_iam.sh)
- Terraform 예제(선택)
  - AWS: `cloud_basic/automation/terraform/aws/ch1_iam`
  - Azure: `cloud_basic/automation/terraform/azure/ch1_iam`
  - GCP: `cloud_basic/automation/terraform/gcp/ch1_iam`
- 학습 목표
  - 최소 권한 원칙에 따른 사용자/그룹/역할 설계, 서비스 계정/권한 경계 실습
  - 비용관리자와 IT 관리자 권한 분리 검증
- 검증/제출
  - MFA/정책 증빙, 허용/거부 테스트 결과, 역할 분리 스크린샷

---

## Day 2 · Chapter 2: VM과 웹 서비스 배포

- 본문: 🔗 [Chapter2_VM.md](mdc:mcp_knowledge_base/cloud_basic/Chapter2_VM.md)
- 자동화 스크립트(선택)
  - AWS: 🔗 [ch2_vm.sh](mdc:mcp_knowledge_base/cloud_basic/automation/cli/aws/ch2_vm.sh)
  - Azure: 🔗 [ch2_vm.sh](mdc:mcp_knowledge_base/cloud_basic/automation/cli/azure/ch2_vm.sh)
  - GCP: 🔗 [ch2_vm.sh](mdc:mcp_knowledge_base/cloud_basic/automation/cli/gcp/ch2_vm.sh)
- Terraform 예제(선택)
  - AWS: `cloud_basic/automation/terraform/aws/ch2_vm`
  - Azure: `cloud_basic/automation/terraform/azure/ch2_vm`
  - GCP: `cloud_basic/automation/terraform/gcp/ch2_vm`
- 학습 목표
  - 단일 VM 웹 서버 → 고가용성(오토스케일+로드밸런서) 전환 흐름 이해
  - 보안/비용 기본 체크(SSH 제한, 작은 타입/스케줄)
- 검증/제출
  - 웹 서비스 접근 스크린샷, 오토스케일 정책/헬스체크 결과

---

## Day 3 · Chapter 3: 스토리지와 정적 웹/아카이빙

- 본문: 🔗 [Chapter3_Storage.md](mdc:mcp_knowledge_base/cloud_basic/Chapter3_Storage.md)
- 자동화 스크립트(선택)
  - AWS: 🔗 [ch3_storage.sh](mdc:mcp_knowledge_base/cloud_basic/automation/cli/aws/ch3_storage.sh)
  - Azure: 🔗 [ch3_storage.sh](mdc:mcp_knowledge_base/cloud_basic/automation/cli/azure/ch3_storage.sh)
  - GCP: 🔗 [ch3_storage.sh](mdc:mcp_knowledge_base/cloud_basic/automation/cli/gcp/ch3_storage.sh)
- Terraform 예제(선택)
  - AWS: `cloud_basic/automation/terraform/aws/ch3_storage`
  - Azure: `cloud_basic/automation/terraform/azure/ch3_storage`
  - GCP: `cloud_basic/automation/terraform/gcp/ch3_storage`
- 학습 목표
  - 정적 웹 호스팅 보안 공개와 라이프사이클/버전관리/아카이빙 실습
  - 액세스 로그, 암호화/전송 보호, 퍼블릭 최소화 원칙
- 검증/제출
  - 정적 사이트 공개 확인, 라이프사이클/버전 설정 증빙

---

## Day 4 · Chapter 4: 네트워크 & DNS

- 본문: 🔗 [Chapter4_Network_DNS.md](mdc:mcp_knowledge_base/cloud_basic/Chapter4_Network_DNS.md)
- 자동화 스크립트(선택)
  - AWS: 🔗 [ch4_network.sh](mdc:mcp_knowledge_base/cloud_basic/automation/cli/aws/ch4_network.sh)
  - Azure: 🔗 [ch4_network.sh](mdc:mcp_knowledge_base/cloud_basic/automation/cli/azure/ch4_network.sh)
  - GCP: 🔗 [ch4_network.sh](mdc:mcp_knowledge_base/cloud_basic/automation/cli/gcp/ch4_network.sh)
- Terraform 예제(선택)
  - AWS: `cloud_basic/automation/terraform/aws/ch4_network`
  - Azure: `cloud_basic/automation/terraform/azure/ch4_network`
  - GCP: `cloud_basic/automation/terraform/gcp/ch4_network`
- 학습 목표
  - 퍼블릭/프라이빗 분리, NAT, L4/L7 LB, DNS 연결 구성
  - 인바운드 최소/소스 제한, 모니터링/알림
- 검증/제출
  - LB 헬스체크 OK, DNS 레코드 유효성 확인

---

## 자동화 · 검증 · 운영

- 예산 스크립트
  - AWS: 🔗 [aws_budget.sh](mdc:mcp_knowledge_base/cloud_basic/automation/cli/budget/aws_budget.sh)
  - GCP: 🔗 [gcp_budget.sh](mdc:mcp_knowledge_base/cloud_basic/automation/cli/budget/gcp_budget.sh)
  - Azure: 🔗 [azure_budget.sh](mdc:mcp_knowledge_base/cloud_basic/automation/cli/budget/azure_budget.sh)
- Terraform 가드(권장)
  - 🔗 [guard.sh](mdc:mcp_knowledge_base/cloud_basic/automation/terraform/guard.sh) 로 `ROLE=cost-manager` 실행 차단
- 시나리오 종합 가이드
  - 🔗 [실습_시나리오.md](mdc:mcp_knowledge_base/cloud_basic/실습_시나리오.md)

---

## 최종 제출물(요약)

- 아키텍처/구성 다이어그램(Chapter 반영)
- 계정 등록/역할 분리/예산 설정 증빙(체크리스트 포함)
- 각 Chapter 결과(스크린샷/명령/설정 요약)
- 개선 포인트 3가지 이상(보안/비용/운영)

