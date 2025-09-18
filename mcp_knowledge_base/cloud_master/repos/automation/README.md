# Cloud Master 실습 자동화 가이드

## 📚 개요

이 디렉토리는 Cloud Master 과정의 실습을 자동화하는 스크립트들을 포함합니다. 각 일차별로 체계적인 실습을 진행할 수 있으며, 재수행 시에도 안전하게 동작하도록 설계되었습니다.

## 🛠️ 자동화 스크립트 목록

### 1일차: Docker & GitHub Actions
- **`day1/docker-practice-automation.sh`**: Docker 기초 실습 자동화
- **`day1/github-actions-automation.sh`**: GitHub Actions CI/CD 파이프라인 실습 자동화

### 2일차: Kubernetes
- **`day2/kubernetes-practice-automation.sh`**: Kubernetes 클러스터 관리 및 애플리케이션 배포 실습 자동화

### 3일차: 모니터링
- **`day3/monitoring-practice-automation.sh`**: 모니터링 및 로깅 시스템 실습 자동화

### 통합 실습
- **`integrated-practice-automation.sh`**: 전체 과정 통합 실습 자동화

## 🚀 사용 방법

### 개별 일차 실습 실행

```bash
# 1일차: Docker & GitHub Actions
chmod +x mcp_knowledge_base/cloud_master/automation/day1/docker-practice-automation.sh
./mcp_knowledge_base/cloud_master/automation/day1/docker-practice-automation.sh

# 2일차: Kubernetes
chmod +x mcp_knowledge_base/cloud_master/automation/day2/kubernetes-practice-automation.sh
./mcp_knowledge_base/cloud_master/automation/day2/kubernetes-practice-automation.sh

# 3일차: 모니터링
chmod +x mcp_knowledge_base/cloud_master/automation/day3/monitoring-practice-automation.sh
./mcp_knowledge_base/cloud_master/automation/day3/monitoring-practice-automation.sh
```

### 통합 실습 실행

```bash
# 전체 과정 통합 실습
chmod +x mcp_knowledge_base/cloud_master/automation/integrated-practice-automation.sh
./mcp_knowledge_base/cloud_master/automation/integrated-practice-automation.sh all

# 특정 일차만 실행
./mcp_knowledge_base/cloud_master/automation/integrated-practice-automation.sh 1  # 1일차만
./mcp_knowledge_base/cloud_master/automation/integrated-practice-automation.sh 2  # 2일차만
./mcp_knowledge_base/cloud_master/automation/integrated-practice-automation.sh 3  # 3일차만
```

## 🔧 재수행 방지 기능

모든 스크립트는 재수행 시 안전하게 동작하도록 다음과 같은 기능을 포함합니다:

### 1. 리소스 존재 확인
- **Docker**: 이미지, 컨테이너, 볼륨 존재 여부 확인
- **Kubernetes**: 네임스페이스, Pod, Deployment, Service 존재 여부 확인
- **AWS**: 대시보드, 로그 그룹, 로그 스트림 존재 여부 확인

### 2. 기존 리소스 정리
- 실행 전 기존 리소스 자동 정리
- 충돌 방지를 위한 안전한 삭제

### 3. 상태 확인 및 대기
- 리소스 생성 후 상태 확인
- 적절한 대기 시간으로 안정성 보장

### 4. 오류 처리
- 명령어 실행 실패 시 적절한 오류 메시지
- 스크립트 중단 방지

## 📋 사전 요구사항

### 공통 요구사항
- **Docker**: Docker Engine 설치 및 실행
- **Git**: 버전 관리 시스템
- **curl**: HTTP 클라이언트
- **jq**: JSON 처리 도구

### 1일차 추가 요구사항
- **Node.js**: JavaScript 런타임 (18.x 이상)
- **npm**: Node.js 패키지 매니저

### 2일차 추가 요구사항
- **kubectl**: Kubernetes 클라이언트
- **Minikube**: 로컬 Kubernetes 클러스터

### 3일차 추가 요구사항
- **Docker Compose**: 멀티 컨테이너 애플리케이션 관리
- **AWS CLI**: AWS 명령줄 인터페이스 (선택사항)

## 🎯 실습 내용

### 1일차: Docker & GitHub Actions
- Docker 설치 및 기본 명령어
- 컨테이너 실행 및 관리
- 볼륨 마운트 실습
- Dockerfile 작성 및 이미지 빌드
- GitHub Actions 워크플로우 생성
- CI/CD 파이프라인 구축

### 2일차: Kubernetes
- Minikube 클러스터 설정
- Pod, Deployment, Service 관리
- ConfigMap과 Secret 활용
- 스케일링 및 롤아웃
- 고급 kubectl 명령어
- 모니터링 및 디버깅

### 3일차: 모니터링
- Prometheus & Grafana 스택
- CloudWatch 대시보드 및 메트릭
- ELK Stack 로그 수집 및 분석
- 애플리케이션 모니터링
- 알림 설정 및 관리
- 성능 모니터링

## 🔍 문제 해결

### 일반적인 문제

#### Docker 관련
```bash
# Docker 서비스 상태 확인
sudo systemctl status docker

# Docker 서비스 시작
sudo systemctl start docker

# Docker 권한 문제 해결
sudo usermod -aG docker $USER
```

#### Kubernetes 관련
```bash
# Minikube 상태 확인
minikube status

# Minikube 재시작
minikube stop
minikube start

# kubectl 설정 확인
kubectl config current-context
```

#### 모니터링 관련
```bash
# Docker Compose 서비스 상태 확인
docker-compose ps

# 서비스 로그 확인
docker-compose logs [service-name]

# 서비스 재시작
docker-compose restart [service-name]
```

### 로그 확인

각 스크립트는 상세한 로그를 제공합니다:
- **INFO**: 일반적인 정보
- **SUCCESS**: 성공적인 작업
- **WARNING**: 주의가 필요한 상황
- **ERROR**: 오류 발생

## 📊 실습 결과

### 생성되는 리소스

#### Docker
- 컨테이너: `my-nginx`, `nginx-volume`, `my-web-app`
- 이미지: `my-web-app`
- 볼륨: `~/nginx-html`

#### Kubernetes
- 네임스페이스: `k8s-practice`
- Pod: `nginx-pod`, `config-pod`
- Deployment: `nginx-deployment`
- Service: `nginx-deployment`

#### 모니터링
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin123)
- Elasticsearch: http://localhost:9200
- Kibana: http://localhost:5601
- AlertManager: http://localhost:9093

### 접속 정보

#### 웹 서비스
- Nginx 기본: http://localhost:8080
- 볼륨 마운트: http://localhost:8081
- 커스텀 앱: http://localhost:8082
- 통합 앱: http://localhost:3000

#### 모니터링 서비스
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000
- Elasticsearch: http://localhost:9200
- Kibana: http://localhost:5601

## 🧹 정리

### 자동 정리
각 스크립트는 실행 후 자동으로 정리 옵션을 제공합니다.

### 수동 정리
```bash
# Docker 리소스 정리
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true
docker rmi $(docker images -q) 2>/dev/null || true

# Kubernetes 리소스 정리
kubectl delete namespace k8s-practice 2>/dev/null || true

# 모니터링 스택 정리
docker-compose down -v 2>/dev/null || true
```

## 📚 추가 학습 자료

- [Docker 공식 문서](https:///docs.docker.com/)
- [Kubernetes 공식 문서](https:///kubernetes.io/docs/)
- [Prometheus 공식 문서](https:///prometheus.io/docs/)
- [Grafana 공식 문서](https:///grafana.com/docs/)
- [GitHub Actions 공식 문서](https:///docs.github.com/en/actions)

## 🤝 기여하기

스크립트 개선이나 새로운 기능 추가에 기여하고 싶으시다면:

1. 이슈 생성
2. 포크 후 브랜치 생성
3. 변경사항 커밋
4. Pull Request 생성

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.