# Cloud Master Day3 - 고가용성 및 확장성 아키텍처

## 📁 디렉토리 구조

```
day3/
├── automation/          # 자동화 스크립트
│   ├── 01-aws-loadbalancing.sh
│   ├── 02-gcp-loadbalancing.sh
│   ├── 03-monitoring-stack.sh
│   ├── 04-autoscaling.sh
│   ├── 05-cost-optimization.sh
│   ├── 06-integration-test.sh
│   ├── create-git-repo.sh
│   └── vm-setup.sh
├── guides/              # 가이드 문서
│   ├── wsl-to-vm-setup.md
│   ├── port-conflict-resolution.md
│   └── troubleshooting.md
├── samples/             # 실습 샘플 코드
│   ├── cloud-master-day3/
│   ├── cloud-master-day3-aws-vm/
│   ├── cloud-master-day3-existing-vm/
│   ├── cloud-master-day3-smooth/
│   └── cloud-master-day3-vm/
├── docs/                # 문서 및 보고서
│   ├── cost-reports/
│   ├── architecture-diagrams/
│   └── system-requirements.md
└── scripts/             # 유틸리티 스크립트
    ├── environment-check.sh
    ├── resource-cleanup.sh
    └── backup-scripts.sh
```

## 🎯 학습 목표

### 핵심 목표
- **기존 VM 활용**: Day1, Day2에서 배포된 VM을 활용한 로드밸런싱
- **로드밸런싱**: AWS ALB + GCP Cloud Load Balancing 구축
- **모니터링**: Prometheus + Grafana 통합 모니터링 스택
- **비용 최적화**: 클라우드 리소스 최적화 및 분석
- **자동화**: 실습 자동화 스크립트를 통한 효율적 학습

## 🚀 빠른 시작

### 1단계: WSL에서 Git Repository 생성
```bash
cd automation/
./create-git-repo.sh
```

### 2단계: Cloud VM에서 실습 실행
```bash
# VM 접속
ssh -i ~/.ssh/cloud-master-key.pem ubuntu@[VM_IP]

# 환경 설정
curl -O https://raw.githubusercontent.com/[사용자명]/cloud-master-day3-practice/main/vm-setup.sh
chmod +x vm-setup.sh
./vm-setup.sh

# 실습 시작
./01-aws-loadbalancing.sh setup
```

## 📚 상세 가이드

- [WSL → Cloud VM 설정 가이드](guides/wsl-to-vm-setup.md)
- [포트 충돌 해결 가이드](guides/port-conflict-resolution.md)
- [문제 해결 가이드](guides/troubleshooting.md)

## 🔧 자동화 스크립트

### 주요 스크립트
- **01-aws-loadbalancing.sh**: AWS 로드밸런싱 설정
- **02-gcp-loadbalancing.sh**: GCP 로드밸런싱 설정
- **03-monitoring-stack.sh**: 모니터링 스택 구축
- **04-autoscaling.sh**: 자동 스케일링 설정
- **05-cost-optimization.sh**: 비용 최적화 분석
- **06-integration-test.sh**: 통합 테스트 실행

### 유틸리티 스크립트
- **create-git-repo.sh**: Git Repository 자동 생성 (WSL용)
- **vm-setup.sh**: VM 환경 자동 설정 (Cloud VM용)

## 📊 실습 결과

실습 완료 후 생성되는 결과물:
- 로드밸런서 설정 및 테스트 결과
- 모니터링 대시보드 스크린샷
- 비용 분석 보고서
- 성능 테스트 결과

## ⚠️ 주의사항

- 실습 완료 후 반드시 리소스 정리를 수행하세요
- 비용 모니터링을 위해 정기적으로 리소스를 확인하세요
- AWS/GCP 계정 설정이 필요합니다
- Day2 모니터링 스택과 포트 충돌이 발생할 수 있습니다

## 🔗 관련 링크

- [Cloud Master 전체 과정](../README.md)
- [Day1: 기본 배포](../automation/day1/)
- [Day2: 다중 서비스 환경](../automation/day2/)
- [강의안 문서](../../Day3_강의안.md)
