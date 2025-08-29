## Chapter 4: 네트워크 & DNS (VPC/VNet, Subnet, LB, NAT)

### 개요
네트워크는 인프라의 토대입니다. 본 장에서는 퍼블릭/프라이빗 서브넷 분리, 인터넷/내부 경로, 보안 규칙, DNS 연결을 실습합니다.

### 학습 목표
- 퍼블릭/프라이빗 서브넷과 라우팅 구성
- 로드 밸런서와 헬스체크 설정
- NAT(아웃바운드)와 Bastion/Jumpbox 패턴 적용
- DNS를 통한 도메인 연결

### 실습 1: 네트워크 기초 (플랫폼별)
#### Azure
- VNet(10.1.0.0/16), Subnet(public/private), NSG 규칙 최소 허용
- Bastion 또는 Jumpbox로 프라이빗 VM 접근

#### AWS
- VPC(10.0.0.0/16), Subnet(퍼블릭/프라이빗), IGW + 퍼블릭 라우트, NAT GW + 프라이빗 라우트
- SG 최소 포트(80/443/22 제한), NACL 필요 시 보완

#### GCP
- VPC(custom), Subnet 2개, 방화벽 최소 허용
- Cloud NAT로 프라이빗 아웃바운드 구성

### 실습 2: 로드 밸런서 & DNS
- 각 플랫폼 L4/L7 LB 생성, 백엔드 인스턴스 헬스 체크 통과 확인
- DNS 서비스(Route53/Cloud DNS/Azure DNS)에서 A/AAAA/CNAME 레코드로 연결

### 체크리스트
- 보안: 인바운드 최소/소스 제한, 아웃바운드 제어, 로깅
- 가용성: 멀티 AZ/존, 헬스체크 OK, 장애 전파 억제
- 운영: 태그/라벨, IaC 전환, 모니터링/알림

### 트러블슈팅
- 접속 불가 시: SG/NSG/방화벽 → 라우팅 → 헬스체크 순으로 점검
- DNS 전파 지연: TTL 확인, 레코드 타입/대상 오타 점검

---

## 팀 역할 기반 실습 가이드

### Finance (재무팀)
- NAT GW, LB, 데이터 전송 비용 시각화 및 알림 설정
- 비업무시간 NAT/LB 비용 절감 방안 점검(아키텍처/스케줄)

### IT 운영팀 & DevOps 엔지니어
- VPC/VNet, 서브넷, 보안 정책 IaC 표준화
- 네트워크 변경 PR 리뷰(보안/경로 영향 평가) 및 테스트 환경 자동화
- 중앙 로깅: 플로우 로그/방화벽 로그 수집 대시보드

### 개발팀 (Development)
- 도메인 연결 요구사항 정리 및 레코드 테스트
- 애플리케이션 헬스체크 엔드포인트 제공 및 상태코드 일관성 유지
- 최소 포트/프로토콜 사용 원칙 준수

### 운영팀 (SRE)
- 장애 주도 설계: 단일 장애지점 제거, 멀티AZ/존, DR 시나리오 초안
- 네트워크 연결성/지연/오류율 SLI/SLO 설정
- 네트워크 런북: 포트 차단/라우팅 오류/DNS 오타 대응 절차

### 자동화 실행 경로
- CLI: `cloud_basic/automation/cli/aws/ch4_network.sh`, `cloud_basic/automation/cli/azure/ch4_network.sh`, `cloud_basic/automation/cli/gcp/ch4_network.sh`
- Terraform: `cloud_basic/automation/terraform/aws/ch4_network`, `cloud_basic/automation/terraform/azure/ch4_network`, `cloud_basic/automation/terraform/gcp/ch4_network`
- 참고: `cloud_basic/자동화_사용안내.md`

---
◀ 이전: [Chapter3_Storage.md](Chapter3_Storage.md)