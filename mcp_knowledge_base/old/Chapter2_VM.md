## Chapter 2: 클라우드 가상머신과 웹 서비스 배포

### 개요
VM은 클라우드의 기본 컴퓨팅 유닛입니다. 본 장에서는 Azure/AWS/GCP에서 웹 서버를 배포하고, 로드 밸런싱과 오토스케일링으로 고가용성을 구현합니다.

### 학습 목표
- VM 생성/접속/패키지 설치 자동화
- 로드 밸런서로 트래픽 분산 및 헬스체크 구성
- 지표 기반 오토스케일링 설정

### 기본 실습: 단일 VM에 웹 서버 배포
- 공통: Ubuntu 22.04 LTS, HTTP(80)/SSH(22) 최소 허용
- 검증: 퍼블릭 IP로 "Hello, Cloudy!" 페이지 확인

### 고가용성 아키텍처 (플랫폼별)

#### Azure
- VM 2대(서로 다른 AZ) + Load Balancer(Standard) + Health Probe
- VMSS(Scale set)로 CPU 70% 이상 시 확장, 30% 미만 시 축소
- CLI 스니펫:
```
az vmss create -g rg-lab -n vmss-web --image Ubuntu2204 --upgrade-policy-mode automatic \
  --instance-count 2 --vm-sku Standard_B1s --lb-sku Standard
az monitor autoscale create -g rg-lab -n scale-web --resource "vmss-web" \
  --min-count 2 --max-count 4 --count 2
```

#### AWS
- EC2 2대(AZ 분산) + ALB + Target Group(Health check: HTTP:80)
- Auto Scaling Group: Min=2, Max=4, Desired=2, 정책 기반 스케일링
- CLI 스니펫(개요):
```
aws elbv2 create-load-balancer ...
aws autoscaling create-auto-scaling-group --auto-scaling-group-name web-asg \
  --min-size 2 --max-size 4 --desired-capacity 2 --vpc-zone-identifier <SUBNETS>
```

#### GCP
- e2-micro 2대(서로 다른 존) + HTTP(S) Load Balancer + Backend service Health check
- Managed instance group(MIG) + autoscaler(cpuUtilization)
- CLI 스니펫(개요):
```
gcloud compute instance-templates create web-tpl --machine-type=e2-micro \
  --image-family=ubuntu-2204-lts --image-project=ubuntu-os-cloud
gcloud compute instance-groups managed create web-mig --template=web-tpl --size=2 --zone=asia-northeast3-a
gcloud compute autoscalers create web-as --target-instance-group=web-mig \
  --target-cpu-utilization=0.7 --min-num-replicas=2 --max-num-replicas=4 --zone=asia-northeast3-a
```

### 운영 체크리스트
- 보안: SSH 소스 제한, 키 관리, 패치 자동화
- 가용성: 멀티 AZ/존, 헬스체크 상태 정상
- 비용: 작은 타입/스팟/예약/스케줄 중지
- 모니터링: 지표/로그/알림 규칙 구성

---

## 팀 역할 기반 실습 가이드

### Finance (재무팀)
- 태깅 표준 점검 및 비용 대시보드 생성(Compute/ELB/NAT 등 비용 가시화)
- 스케줄 중지 정책 도입(개발/테스트 VM 근무시간 외 자동 종료)

### IT 운영팀 & DevOps 엔지니어
- Terraform 모듈화: VM/VMSS(ASG/MIG), LB, 보안 규칙을 모듈로 제공
- CI 파이프라인: PR → Plan → 보안스캔 → 승인 → Apply 자동화
- 관측성: 시스템/애플리케이션 메트릭, 로그 수집 및 알림(rule-based) 구성

### 개발팀 (Development)
- 템플릿 사용 배포: 제공된 모듈 변수만으로 웹서비스 배포
- 컨테이너화 고려: Dockerfile/Helm로 이관 계획 수립(선택)
- 기능 검증: 헬스체크 엔드포인트 구현 및 부하 테스트 스크립트 작성

### 운영팀 (SRE)
- 오토스케일 정책 튜닝(CPU/응답시간/큐길이 등 지표)
- 장애 대응 런북: 인스턴스 불량/헬스체크 실패/스케일 실패 대응 절차
- 카나리/블루-그린 전략 초안 수립(선택)

### 자동화 실행 경로
- CLI: `cloud_basic/automation/cli/aws/ch2_vm.sh`, `cloud_basic/automation/cli/azure/ch2_vm.sh`, `cloud_basic/automation/cli/gcp/ch2_vm.sh`
- Terraform: `cloud_basic/automation/terraform/aws/ch2_vm`, `cloud_basic/automation/terraform/azure/ch2_vm`, `cloud_basic/automation/terraform/gcp/ch2_vm`
- 참고: `cloud_basic/자동화_사용안내.md`

---
◀ 이전: [Chapter1_IAM.md](Chapter1_IAM.md) | 다음 ▶: [Chapter3_Storage.md](Chapter3_Storage.md)
