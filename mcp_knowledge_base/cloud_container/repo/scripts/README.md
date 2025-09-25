# Cloud Container 실습 스크립트 가이드

Cloud Container 과정을 위한 통합 실습 스크립트 모음입니다.

## 📁 스크립트 구조

```
scripts/
├── README.md                        # 이 파일
├── cloud-container-helper.sh        # 통합 컨테이너 실습 도우미
├── day1-practice-improved.sh        # Day1 실습 ["GKE, CI/CD, 모니터링"]
├── day2-practice-improved.sh        # Day2 실습 ["고가용성, 보안, 성능"]
└── deprecated/                      # 기존 스크립트 ["참고용"]
    ├── cloud-scripts/
    └── textbook-scripts/
```

## 🚀 빠른 시작

### 1. 통합 도우미 실행 ["권장"]
```bash
# 실행 권한 부여
chmod +x cloud-container-helper.sh

# 통합 도우미 실행
./cloud-container-helper.sh
```

### 2. 개별 실습 실행
```bash
# Day1 실습
chmod +x day1-practice-improved.sh
./day1-practice-improved.sh

# Day2 실습
chmod +x day2-practice-improved.sh
./day2-practice-improved.sh
```

## 📋 주요 스크립트 설명

### 🔧 `cloud-container-helper.sh` - 통합 컨테이너 실습 도우미

**기능:**
- 환경 체크 [kubectl, gcloud, docker, helm, git]
- GKE 클러스터 생성 및 관리
- Docker 이미지 빌드 및 푸시
- Kubernetes 배포
- 모니터링 설정 [Prometheus/Grafana]
- 자동 스케일링 설정
- 클러스터 정리

**사용법:**
```bash
./cloud-container-helper.sh
# 메뉴에서 원하는 기능 선택
```

### 📚 `day1-practice-improved.sh` - Day1 실습

**학습 목표:**
- GKE 클러스터 구축
- GitHub Actions CI/CD 파이프라인
- 외부 모니터링 [Prometheus/Grafana]
- 로드밸런싱 [Ingress]
- 자동 스케일링 [HPA]
- 스트레스 테스트

**주요 기능:**
1. **환경 체크**: 필수 도구 및 계정 설정 확인
2. **GKE 클러스터 생성**: 자동 스케일링이 활성화된 클러스터
3. **샘플 애플리케이션 배포**: Hello App 배포 및 서비스 노출
4. **모니터링 스택 설치**: Prometheus + Grafana
5. **HPA 설정**: CPU 기반 자동 스케일링
6. **부하 테스트**: 스케일링 동작 검증
7. **GitHub Actions 워크플로우**: CI/CD 파이프라인 생성

**실행 예시:**
```bash
./day1-practice-improved.sh
# 메뉴에서 "8. 전체 실습 실행" 선택
```

### 🏗️ `day2-practice-improved.sh` - Day2 실습

**학습 목표:**
- 고가용성 아키텍처 [Multi-AZ]
- 고급 모니터링 [Alerting, Logging]
- 보안 강화 [RBAC, Network Policies]
- 성능 최적화 ["VPA, 고급 HPA"]
- 재해 복구 ["Velero 백업"]

**주요 기능:**
1. **Multi-AZ 클러스터**: 3개 존에 걸친 고가용성 클러스터
2. **Pod Anti-Affinity**: 노드/존 간 Pod 분산
3. **고급 모니터링**: ServiceMonitor, Alerting 규칙
4. **보안 강화**: Network Policy, Pod Security Policy, RBAC
5. **성능 최적화**: VPA + 고급 HPA ["CPU/Memory 기반"]
6. **재해 복구**: Velero를 통한 백업 및 복구

**실행 예시:**
```bash
./day2-practice-improved.sh
# 메뉴에서 "8. 전체 실습 실행" 선택
```

## 🛠️ 실습 환경 요구사항

### 필수 도구
- **kubectl**: Kubernetes 클러스터 관리
- **gcloud**: GCP 리소스 관리
- **docker**: 컨테이너 이미지 빌드
- **helm**: Kubernetes 패키지 관리
- **git**: 버전 관리

### 클라우드 계정
- **GCP 계정**: Kubernetes Engine API 활성화
- **GitHub 계정**: Actions 권한 ["Day1 실습용"]

### 권한 설정
```bash
# GCP 인증
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# kubectl 설정
gcloud container clusters get-credentials CLUSTER_NAME --region REGION
```

## 📊 실습 진행 순서

### Day1 실습 순서
1. **환경 체크** → 필수 도구 및 계정 확인
2. **GKE 클러스터 생성** → 기본 클러스터 구축
3. **샘플 애플리케이션 배포** → Hello App 배포
4. **모니터링 스택 설치** → Prometheus/Grafana
5. **HPA 설정** → 자동 스케일링 구성
6. **부하 테스트** → 스케일링 동작 검증
7. **GitHub Actions 워크플로우** → CI/CD 파이프라인

### Day2 실습 순서
1. **Multi-AZ 클러스터 생성** → 고가용성 클러스터
2. **Pod Anti-Affinity 설정** → 노드/존 간 분산
3. **고급 모니터링 설정** → ServiceMonitor, Alerting
4. **보안 강화 설정** → Network Policy, RBAC
5. **성능 최적화 설정** → VPA, 고급 HPA
6. **재해 복구 설정** → Velero 백업
7. **통합 테스트** → 전체 시스템 검증

## 🔧 문제 해결

### 일반적인 문제들

#### 1. GCP 인증 오류
```bash
# GCP 재인증
gcloud auth login
gcloud auth application-default login

# 프로젝트 설정 확인
gcloud config get-value project
gcloud config set project YOUR_PROJECT_ID
```

#### 2. kubectl 연결 오류
```bash
# 클러스터 인증 재설정
gcloud container clusters get-credentials CLUSTER_NAME --region REGION

# 클러스터 연결 확인
kubectl cluster-info
```

#### 3. Docker 권한 오류
```bash
# 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# WSL 재시작
exit
# Windows에서 wsl --shutdown 후 다시 시작
```

#### 4. Helm 설치 오류
```bash
# Helm 재설치
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Helm 저장소 업데이트
helm repo update
```

#### 5. 모니터링 접속 오류
```bash
# 포트 포워딩 확인
kubectl port-forward --namespace monitoring svc/prometheus-grafana 3000:80

# Grafana 비밀번호 확인
kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

## 📈 실습 결과 확인

### Day1 실습 결과
- ✅ GKE 클러스터 생성 및 연결
- ✅ 샘플 애플리케이션 배포
- ✅ LoadBalancer 서비스 외부 IP 확인
- ✅ Prometheus/Grafana 모니터링 접속
- ✅ HPA 자동 스케일링 동작
- ✅ GitHub Actions 워크플로우 생성

### Day2 실습 결과
- ✅ Multi-AZ 고가용성 클러스터
- ✅ Pod Anti-Affinity 분산 확인
- ✅ 고급 모니터링 및 Alerting
- ✅ Network Policy 보안 정책
- ✅ VPA + HPA 성능 최적화
- ✅ Velero 백업 시스템

## 🧹 정리 및 비용 관리

### 실습 후 정리
```bash
# Day1 정리
./day1-practice-improved.sh
# 메뉴에서 "9. 정리" 선택

# Day2 정리
./day2-practice-improved.sh
# 메뉴에서 "9. 정리" 선택
```

### 비용 최적화 팁
- 실습 완료 후 즉시 리소스 정리
- GCP 무료 티어 한도 확인
- 불필요한 클러스터 삭제
- 정기적인 리소스 정리

## 📞 지원 및 문의

### 문제 신고
- GitHub Issues를 통해 문제를 신고하세요
- 상세한 오류 메시지와 환경 정보를 포함하세요

### 커뮤니티
- Cloud Container 과정 참여자들과 정보를 공유하세요
- 질문과 답변을 통해 함께 성장하세요

---

**Cloud Container 실습을 성공적으로 완료하세요! 🚀**
