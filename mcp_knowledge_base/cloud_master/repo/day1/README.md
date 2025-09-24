# Cloud Master Day1 - 기본 배포 및 환경 설정

## 📁 디렉토리 구조

```
day1/
├── automation/          # 자동화 스크립트
│   ├── aws-basic-deployment.sh
│   ├── gcp-basic-deployment.sh
│   └── environment-setup.sh
├── samples/             # 실습 샘플 코드
│   ├── my-app/
│   ├── docker-examples/
│   └── cloud-deployment/
├── guides/              # 가이드 문서
│   ├── wsl-setup-guide.md
│   ├── docker-basic-guide.md
│   └── aws-gcp-permissions-setup.md
├── scripts/             # 유틸리티 스크립트
│   ├── install/
│   ├── cloud-scripts/
│   └── environment-check.sh
└── docs/                # 문서 및 보고서
    ├── deployment-results/
    └── troubleshooting-logs/
```

## 🎯 학습 목표

### 핵심 목표
- **기본 배포**: AWS EC2, GCP Compute Engine 기본 배포
- **Docker 기초**: 컨테이너화 및 Docker Compose 활용
- **환경 설정**: WSL, AWS CLI, GCP CLI 환경 구성
- **CI/CD 기초**: GitHub Actions를 통한 자동 배포

## 🚀 빠른 시작

### 1단계: 환경 설정
```bash
cd scripts/install
./install-all-wsl.sh
```

### 2단계: 기본 배포
```bash
cd automation
./aws-basic-deployment.sh
./gcp-basic-deployment.sh
```

### 3단계: 애플리케이션 배포
```bash
cd samples/my-app
docker-compose up -d
```

## 📚 상세 가이드

- [WSL 설정 가이드](guides/wsl-setup-guide.md)
- [Docker 기초 가이드](guides/docker-basic-guide.md)
- [AWS/GCP 권한 설정](guides/aws-gcp-permissions-setup.md)

## 🔧 자동화 스크립트

### 주요 스크립트
- **aws-basic-deployment.sh**: AWS EC2 기본 배포
- **gcp-basic-deployment.sh**: GCP Compute Engine 기본 배포
- **environment-setup.sh**: 개발 환경 자동 설정

### 유틸리티 스크립트
- **install/**: 도구 설치 스크립트
- **cloud-scripts/**: 클라우드 관리 스크립트
- **environment-check.sh**: 환경 진단 도구

## 📊 실습 결과

실습 완료 후 생성되는 결과물:
- AWS EC2 인스턴스 및 보안 그룹
- GCP Compute Engine 인스턴스 및 방화벽 규칙
- Docker 컨테이너 및 이미지
- GitHub Actions 워크플로우

## ⚠️ 주의사항

- AWS/GCP 계정 설정이 필요합니다
- 실습 완료 후 반드시 리소스 정리를 수행하세요
- 비용 모니터링을 위해 정기적으로 리소스를 확인하세요

## 🔗 관련 링크

- [Cloud Master 전체 과정](../README.md)
- [Day2: 다중 서비스 환경](../day2/)
- [Day3: 고가용성 및 확장성](../day3/)
- [강의안 문서](../../Day1_강의안.md)
