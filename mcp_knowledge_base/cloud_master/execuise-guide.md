Cloud Master 과정 실습을 위한 자료 안내를 드리겠습니다! 🚀

## 📚 Cloud Master 과정 실습 자료 가이드

### 1. **메인 학습 경로** (필수)
```
mcp_knowledge_base/cloud_master/learning-path.md
```
- 전체 과정 개요 및 학습 순서
- 각 Day별 학습 목표와 실습 가이드
- 실습 환경 준비 방법

### 2. **Day별 실습 자료**

#### **Day 1: VM 배포 및 기본 실습**
```
mcp_knowledge_base/cloud_master/textbook/Day1/README.md
```
- AWS EC2, GCP Compute Engine 실습
- Docker 컨테이너 실습
- 기본 클라우드 서비스 이해

#### **Day 2: Kubernetes 및 컨테이너 오케스트레이션**
```
mcp_knowledge_base/cloud_master/textbook/Day2/README.md
```
- Kubernetes 클러스터 구축
- Pod, Service, Deployment 실습
- 애플리케이션 배포 및 관리

#### **Day 3: 모니터링, 로드밸런싱, 비용 최적화**
```
mcp_knowledge_base/cloud_master/textbook/Day3/README.md
```
- Prometheus, Grafana 모니터링 스택
- 로드밸런서 설정
- 비용 최적화 실습

### 3. **자동화 스크립트** (실습 지원)

#### **환경 설정 스크립트**
```
mcp_knowledge_base/cloud_master/repos/cloud-scripts/README.md
```
- AWS/GCP 환경 자동 설정
- 리소스 생성 및 관리 자동화
- 실습 환경 정리 자동화

#### **통합 자동화 스크립트**
```
mcp_knowledge_base/cloud_master/repos/cloud-scripts/integrated-automation.sh
```
- 전체 과정 통합 자동화
- CI/CD 파이프라인 설정
- 모니터링 및 비용 최적화 자동화

### 4. **실습 샘플 코드**
```
mcp_knowledge_base/cloud_master/repos/samples/
├── day1/          # Day 1 실습 샘플
├── day2/          # Day 2 실습 샘플
└── day3/          # Day 3 실습 샘플
```

### 5. **AI 기반 학습 지원** (선택사항)

#### **학습 진도 추적**
```
mcp_knowledge_base/cloud_master/repos/cloud-scripts/learning-progress-tracker.sh
```
- 실시간 학습 진도 추적
- 개인화된 학습 분석
- 상세 진도 리포트 생성

#### **AI 학습 분석**
```
mcp_knowledge_base/cloud_master/repos/cloud-scripts/ai-learning-analyzer.sh
```
- AI 기반 학습 패턴 분석
- 개인화된 추천사항 생성
- 학습 경로 최적화

### 6. **실습 시작 순서**

#### **1단계: 환경 준비**
```bash
# 1. 학습 경로 확인
cat mcp_knowledge_base/cloud_master/learning-path.md

# 2. 환경 설정 스크립트 실행
cd mcp_knowledge_base/cloud_master/repos/cloud-scripts
./aws-setup-helper.sh
./gcp-setup-helper.sh
```

#### **2단계: Day별 실습 진행**
```bash
# Day 1 실습
cat mcp_knowledge_base/cloud_master/textbook/Day1/README.md

# Day 2 실습  
cat mcp_knowledge_base/cloud_master/textbook/Day2/README.md

# Day 3 실습
cat mcp_knowledge_base/cloud_master/textbook/Day3/README.md
```

#### **3단계: 자동화 스크립트 활용**
```bash
# 통합 자동화 실행
./integrated-automation.sh aws --full-deploy

# 학습 진도 추적
./learning-progress-tracker.sh --start-session
```

### 7. **추가 참고 자료**

#### **설치 가이드**
```
mcp_knowledge_base/cloud_master/repos/install/
```
- AWS CLI, GCP CLI 설치
- Docker, Kubernetes 설치
- 기타 필수 도구 설치

#### **프레젠테이션 자료**
```
mcp_knowledge_base/cloud_master/presentation/
```
- 과정 개요 프레젠테이션
- 실습 가이드 PDF
- 교재 자료

### 8. **실습 팁**

#### ** 실습 전 체크리스트**
- [ ] AWS 계정 및 GCP 계정 준비
- [ ] AWS CLI, GCP CLI 설치 및 설정
- [ ] Docker 설치 및 실행
- [ ] Kubernetes 환경 준비

#### ** 실습 중 주의사항**
- 각 Day별 실습을 순서대로 진행
- 실습 후 리소스 정리 필수
- 비용 모니터링 및 예산 관리
- 오류 발생 시 로그 확인

#### ** 실습 완료 후**
- 학습 진도 리포트 생성
- 실습 결과 정리 및 문서화
- 다음 단계 학습 계획 수립

이 자료들을 참고하여 Cloud Master 과정 실습을 진행하시면 됩니다! 🎯✨