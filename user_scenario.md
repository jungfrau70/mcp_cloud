MCP 서버(AWS·GCP AI Agent 기반 IaaS/PaaS 배포 관리)의 **사용자 시나리오**


---

## 1. 사전 준비

* MCP 서버(FastAPI 백엔드)는 Docker로 빌드되어 쿠버네티스 또는 VM 위에 배포됨
* AWS/GCP 인증 정보는 서버 환경변수 또는 Vault에 저장

---

## 2. 배포 코드 준비

* AI Agent와 대화하면 모듈작성
* 모듈 구조와 변수 타입이 맞는지 검증
* 필요 시 사용자에게 “리전 변경 권고” 같은 피드백 제공
* **인프라팀**이 GitHub 저장소에 `terraform/modules` 폴더에 AWS, GCP 모듈을 등록

---

## 3. 신규 인프라 배포 요청

**주체:** 서비스 개발팀 또는 AI Agent
**흐름:**

1. 사용자가 MCP API(`/deployments`)를 호출

   ```json
   {
     "name": "dev-vpc",
     "cloud": "aws",
     "module": "aws_vpc",
     "vars": { "region": "us-east-1" }
   }
   ```
2. MCP 서버는 DB에 신규 배포 요청을 기록 (`status = created`)

---

## 3. AI Agent 사전 검증

* AI Agent가 요청 파라미터를 분석
* 모듈 구조와 변수 타입이 맞는지 검증
* 필요 시 사용자에게 “리전 변경 권고” 같은 피드백 제공

---

## 4. Terraform Plan 실행

**주체:** MCP 서버

1. `/deployments/{id}/plan` 호출 시 `terraform_runner`가 해당 모듈 복사 후 `terraform plan` 수행
2. 결과를 DB와 API 응답에 저장
3. 상태를 `planned`로 변경
4. AI Agent가 Plan 결과를 읽고 예상 변경 사항 요약, 위험 요소 설명

---

## 5. 승인 프로세스

**주체:** 인프라 관리자

* `/deployments/{id}/approve` 호출로 상태를 `awaiting_approval`로 변경
* AI Agent가 Slack/Teams에 “이 배포 승인하시겠습니까?” 알림 발송

---

## 6. Terraform Apply 실행

1. 승인 후 `/deployments/{id}/apply` 호출
2. `terraform_runner`가 `terraform apply -auto-approve` 실행
3. 실행 로그를 DB에 기록
4. 성공 시 상태를 `applied`, 실패 시 `failed`로 변경
5. AI Agent가 최종 리소스 ID, 네트워크 정보 등을 요약 보고

---

## 7. 사후 관리

* MCP API로 현재 배포 현황 조회 가능 (`GET /deployments/{id}`)
* AI Agent가 정기적으로 리소스 상태 모니터링 및 비용 보고
* 필요 시 `/destroy` API로 삭제 지원 (미구현 시 추후 추가)

---

## 8. 예시 시나리오 요약

```
[개발자] → API 요청 → [MCP 서버] → Terraform Plan → [AI Agent] 검증·리뷰
  → 관리자 승인 → Terraform Apply → 상태 보고 → 사후 모니터링
```

---


