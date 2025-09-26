# Container 과정 자동화 - 빠른 시작 가이드


## 🚀 빠른 시작

### 1단계: 필수 도구 설치
```bash
# Docker 설치
docker --version

# kubectl 설치
kubectl version --client

# Helm 설치
helm version

# AWS CLI 설치
aws --version

# GCP CLI 설치
gcloud --version
```

### 2단계: 자동화 실행
```bash
python container_course_automation.py
```

### 3단계: 실습 스크립트 실행
```bash
# Day 1 실습
cd automation/day1
chmod +x *.sh
./kubernetes_advanced.sh
./gke_cluster.sh
./ecs_fargate.sh
./advanced_cicd.sh

# Day 2 실습
cd ../day2
chmod +x *.sh
./high_availability.sh
./monitoring.sh
./comprehensive_project.sh
```

## 📋 체크리스트

- [ ] Docker 설치 및 실행
- [ ] kubectl 설치 및 설정
- [ ] Helm 설치
- [ ] AWS CLI 설치 및 인증
- [ ] GCP CLI 설치 및 인증
- [ ] 자동화 스크립트 실행
- [ ] Day 1 실습 완료
- [ ] Day 2 실습 완료

## 🔧 환경 설정

```bash
# GCP 프로젝트 설정
export PROJECT_ID="your-project-id"

# AWS 리전 설정
export AWS_REGION="us-west-2"
```

## 📞 도움말

문제가 있으면 README.md 파일을 참조하세요.


---


### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: ["프로젝트 저장소"][https:///github.com/jungfrau70/aws_gcp.git]

---



<div align="center">

["← 이전: Cloud Container 메인"](README.md) | ["📚 전체 커리큘럼"](curriculum.md) | ["🏠 학습 경로로 돌아가기"](index.md) | ["📋 학습 경로"](learning-path.md)

</div>