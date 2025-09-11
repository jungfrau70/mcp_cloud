# 클라우드 실무력 강화! AWS & GCP 활용법 - 통합 인덱스

<details>
<summary>📋 목차</summary>

1. [🎯 전체 과정 개요](#전체-과정-개요)
2. [📚 과정별 상세 정보](#과정별-상세-정보)
3. [🔗 과정 간 연계성](#과정-간-연계성)
4. [🛠️ 실습 환경 및 도구](#실습-환경-및-도구)
5. [📋 학습 경로 및 체크리스트](#학습-경로-및-체크리스트)
6. [📚 참고 자료 및 리소스](#참고-자료-및-리소스)

</details>

---

## 🎯 전체 과정 개요 {#전체-과정-개요}

<details>
<summary>📖 3단계 과정 구조</summary>

### 과정 구성
| 과정 | 일정 | 대상 | 주요 내용 | 선수 요구사항 |
|------|------|------|-----------|---------------|
| **Cloud Basic** | 2일 | 클라우드 입문자 | AWS/GCP 기초 서비스, IAM, VM, 스토리지, 네트워크 | IT 기초 지식 |
| **Cloud Master** | 3일 | Basic 수료자 | Docker, Git/GitHub, CI/CD, VM 배포, 로드 밸런싱, 모니터링 | Cloud Basic 수료 |
| **Cloud Container** | 2일 | Master 수료자 | K8s, ECS, Fargate, 고가용성 아키텍처 | Cloud Master 수료 |

### 학습 경로
```
Cloud Basic (2일) → Cloud Master (3일) → Cloud Container (2일)
     ↓                    ↓                        ↓
기초 서비스 실습    →   Docker/Git/CI/CD/VM    →   K8s/ECS/Fargate
```

</details>

---

## 📚 과정별 상세 정보 {#과정별-상세-정보}

<details>
<summary>📖 Cloud Basic - 클라우드 기초</summary>

### 과정 개요
- **교육명**: 클라우드 실무력 강화! AWS & GCP 활용법(기초)
- **교육일정**: 9/2(수) ~ 9/3(목)
- **교육시간**: 9:00 ~ 17:00 (7시간/일)
- **교육방식**: 오프라인
- **실습 환경**: AWS Free Tier + GCP Free Tier ($300 크레딧)

### 주요 내용
1. **클라우드 개념 및 계정 생성** (30분)
2. **IAM 기초 실습** (45분)
3. **가상머신 서비스 기초** (60분)
4. **스토리지 서비스 기초** (45분)

### 실습 자료
- 🔗 [1일차 실습 가이드](cloud_basic/textbook/Day1/README)
- 🔗 [2일차 실습 가이드](cloud_basic/textbook/Day2/README)
- 🔗 [AWS 기초 실습](cloud_basic/textbook/Day1/practice/aws_basic_practice)
- 🔗 [GCP 기초 실습](cloud_basic/textbook/Day1/practice/gcp_basic_practice)
- 🔗 [통합 실습 가이드](cloud_basic/textbook/Day1/practice/실습1_aws_gcp)

</details>


<details>
<summary>📖 Cloud Master - 마스터 과정</summary>

### 과정 개요
- **교육명**: 클라우드 실무력 강화! AWS & GCP 활용법(마스터)
- **교육일정**: 9/22(월) ~ 9/24(수)
- **교육시간**: 9:00 ~ 17:00 (7시간/일)
- **교육방식**: 온라인
- **실습 환경**: AWS Free Tier + GCP Free Tier ($300 크레딧) + GitHub Free

### 주요 내용
1. **Docker 기초 및 Dockerfile 최적화** (120분)
2. **GitHub Actions CI/CD 파이프라인** (150분)
3. **VM 기반 컨테이너 배포** (120분)
4. **완전 자동화된 VM 배포 파이프라인** (90분)

### 실습 자료
- 🔗 [1일차 실습 가이드](cloud_master/textbook/Day1/README)
- 🔗 [2일차 실습 가이드](cloud_master/textbook/Day2/README)
- 🔗 [Docker 고급 실습](cloud_master/textbook/Day1/docker-advanced-guide)
- 🔗 [GitHub Actions 고급 실습](cloud_master/textbook/Day1/github-actions-guide)
- 🔗 [VM 배포 자동화](cloud_master/textbook/Day1/aws-gcp-deployment-guide)

</details>

<details>
<summary>📖 Cloud Container - 컨테이너 심화</summary>

### 과정 개요
- **교육명**: 클라우드 실무력 강화! AWS & GCP 활용법(컨테이너 심화)
- **교육일정**: 10/1(수) ~ 10/2(목)
- **교육시간**: 9:00 ~ 17:00 (7시간/일)
- **교육방식**: 오프라인
- **실습 환경**: AWS Free Tier + GCP Free Tier ($300 크레딧) + GitHub Free

### 주요 내용
1. **Kubernetes 고급 아키텍처** (150분)
2. **컨테이너 오케스트레이션 고급 기법** (150분)
3. **AWS ECS 및 Fargate 심화** (120분)
4. **고급 CI/CD 파이프라인** (90분)

### 실습 자료
- 🔗 [1일차 실습 가이드](cloud_container/textbook/Day1/README)
- 🔗 [2일차 실습 가이드](cloud_container/textbook/Day2/README)
- 🔗 [Kubernetes 기초 실습](cloud_container/textbook/Day1/practice/kubernetes-basics)
- 🔗 [컨테이너 기초 실습](cloud_container/textbook/Day1/practice/container-basics)
- 🔗 [고가용성 아키텍처 실습](cloud_container/textbook/Day2/practice/high-availability-architecture)

</details>

---

## 🔗 과정 간 연계성 {#과정-간-연계성}

<details>
<summary>📖 학습 경로</summary>

### 단계별 학습 경로
```
Cloud Basic (2일)
    ↓
    ├── AWS/GCP 기초 서비스 실습
    ├── IAM 사용자 및 권한 관리
    ├── EC2/Compute Engine 인스턴스 생성
    └── S3/Cloud Storage 버킷 관리
    ↓
Cloud Master (3일)
    ↓
    ├── Docker 컨테이너 기술
    ├── Git/GitHub 버전 관리
    ├── GitHub Actions CI/CD
    ├── VM 기반 웹 애플리케이션 배포
    ├── Docker 고급 기술 및 최적화
    ├── VM 기반 컨테이너 배포 자동화
    └── 로드 밸런싱 및 모니터링
    ↓
Cloud Container (2일)
    ↓
    ├── Kubernetes 클러스터 아키텍처
    ├── GKE 클러스터 관리
    ├── ECS/Fargate 서버리스 컨테이너
    └── 고가용성 아키텍처 설계
```

</details>

<details>
<summary>📖 선수 요구사항 체크리스트</summary>

### Cloud Basic
- [ ] IT 기초 지식 (OS, 네트워크 기본 이해)
- [ ] Linux 기본 명령어 경험 권장
- [ ] 웹 브라우저 사용 가능

### Cloud Master
- [ ] Cloud Basic 과정 수료
- [ ] AWS/GCP 기초 서비스 실습 완료
- [ ] 기본적인 명령줄 사용 경험

### Cloud Container
- [ ] Cloud Master 과정 수료
- [ ] CI/CD, VM 기반 컨테이너 배포 완료
- [ ] 고급 컨테이너 오케스트레이션 학습 준비

</details>

---

## 🛠️ 실습 환경 및 도구 {#실습-환경-및-도구}

<details>
<summary>📋 공통 도구</summary>

### 필수 도구
- **웹 브라우저**: Chrome, Firefox, Safari 등
- **터미널/명령 프롬프트**: CLI 명령어 실행용
- **SSH 클라이언트**: 가상머신 접속용
- **VS Code**: 코드 편집 (권장)

### 클라우드 도구
- **AWS CLI**: AWS 서비스 관리
- **gcloud CLI**: Google Cloud 서비스 관리
- **Docker**: 컨테이너 이미지 빌드 및 실행
- **kubectl**: Kubernetes 클러스터 관리

</details>

<details>
<summary>📋 계정 및 환경</summary>

### 필수 계정
- **AWS 계정**: Free Tier 계정
- **GCP 계정**: $300 크레딧 활성화
- **GitHub 계정**: 저장소 관리 및 Actions 사용
- **Docker Hub 계정**: 컨테이너 이미지 저장소

### 실습 환경
- **로컬 환경**: Docker, Git, CLI 도구
- **클라우드 환경**: AWS, GCP 서비스
- **협업 환경**: GitHub, Docker Hub

</details>

---

## 📋 학습 경로 및 체크리스트 {#학습-경로-및-체크리스트}

<details>
<summary>📖 전체 학습 체크리스트</summary>

### Cloud Basic 체크리스트
- [ ] AWS 계정 생성 및 기본 설정
- [ ] GCP 계정 생성 및 기본 설정
- [ ] IAM 사용자 및 권한 관리
- [ ] EC2/Compute Engine 인스턴스 생성
- [ ] S3/Cloud Storage 버킷 생성 및 관리
- [ ] 네트워킹 기본 개념 이해
- [ ] 보안 그룹 및 방화벽 설정

### Cloud Master 체크리스트
- [ ] Docker 컨테이너 기본 사용법
- [ ] Dockerfile 작성 및 이미지 빌드
- [ ] Git/GitHub 버전 관리
- [ ] GitHub Actions CI/CD 파이프라인
- [ ] VM 기반 웹 애플리케이션 배포
- [ ] Docker 고급 기술 및 최적화
- [ ] 멀티스테이지 빌드 및 Docker Compose
- [ ] GitHub Actions 고급 워크플로우
- [ ] 환경별 배포 전략
- [ ] VM 기반 컨테이너 배포 자동화
- [ ] 로드 밸런싱 및 Auto Scaling
- [ ] 모니터링 및 로깅 시스템

### Cloud Container 체크리스트
- [ ] Kubernetes 클러스터 아키텍처 이해
- [ ] GKE 클러스터 생성 및 관리
- [ ] Deployment, Service, Ingress 설정
- [ ] ConfigMap, Secret, PersistentVolume 관리
- [ ] ECS 클러스터 구성 및 태스크 정의
- [ ] Fargate 서버리스 컨테이너 실행
- [ ] GitOps 기반 배포 자동화

</details>

<details>
<summary>📖 실무 적용 체크리스트</summary>

### 프로젝트 적용
- [ ] 자신의 프로젝트에 클라우드 서비스 적용
- [ ] CI/CD 파이프라인 구축
- [ ] 컨테이너화 및 오케스트레이션
- [ ] 모니터링 및 로깅 시스템 구축
- [ ] 보안 정책 및 컴플라이언스 적용

### 고급 기능
- [ ] 마이크로서비스 아키텍처 설계
- [ ] 서비스 메시 구현
- [ ] 자동 스케일링 및 로드 밸런싱
- [ ] 재해 복구 및 백업 전략
- [ ] 비용 최적화 및 성능 튜닝

</details>

---

## 📚 참고 자료 및 리소스 {#참고-자료-및-리소스}

<details>
<summary>📖 공식 문서</summary>

### AWS 공식 문서
- [AWS 공식 문서](https://docs.aws.amazon.com/)
- [AWS CLI 공식 문서](https://docs.aws.amazon.com/cli/)
- [AWS EC2 공식 문서](https://docs.aws.amazon.com/ec2/)
- [AWS ECS 공식 문서](https://docs.aws.amazon.com/ecs/)
- [AWS Fargate 공식 문서](https://docs.aws.amazon.com/fargate/)

### GCP 공식 문서
- [GCP 공식 문서](https://cloud.google.com/docs)
- [gcloud CLI 공식 문서](https://cloud.google.com/sdk/docs)
- [GCP Compute Engine 공식 문서](https://cloud.google.com/compute/docs)
- [GKE 공식 문서](https://cloud.google.com/kubernetes-engine/docs)

### 기타 공식 문서
- [Docker 공식 문서](https://docs.docker.com/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)

</details>

<details>
<summary>📖 유용한 리소스</summary>

### 학습 자료
- [AWS Free Tier](https://aws.amazon.com/free/)
- [GCP Free Tier](https://cloud.google.com/free)
- [Docker Hub](https://hub.docker.com/)
- [GitHub Marketplace](https://github.com/marketplace?type=actions)

### 샘플 프로젝트
- [AWS 샘플 프로젝트](https://github.com/aws-samples)
- [GCP 샘플 프로젝트](https://github.com/GoogleCloudPlatform)
- [Docker 샘플 프로젝트](https://github.com/docker/awesome-compose)
- [Kubernetes 샘플 프로젝트](https://github.com/kubernetes/examples)

### 도구 및 유틸리티
- [AWS CLI](https://aws.amazon.com/cli/)
- [gcloud CLI](https://cloud.google.com/sdk/docs)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)

</details>

<details>
<summary>📖 커뮤니티 및 지원</summary>

### 커뮤니티
- [AWS 한국 사용자 그룹](https://www.meetup.com/awskrug/)
- [GCP 한국 사용자 그룹](https://www.meetup.com/gcp-korea/)
- [Kubernetes 한국 사용자 그룹](https://www.meetup.com/kubernetes-korea/)
- [Docker 한국 사용자 그룹](https://www.meetup.com/docker-korea/)

### 지원 및 문의
- [AWS 지원](https://aws.amazon.com/support/)
- [GCP 지원](https://cloud.google.com/support/)
- [GitHub 지원](https://support.github.com/)
- [Docker 지원](https://www.docker.com/support/)

</details>

---

## 🎉 시작하기

<details>
<summary>📖 첫 번째 단계</summary>

### 1. 환경 준비
1. **계정 생성**: AWS, GCP, GitHub, Docker Hub 계정 생성
2. **도구 설치**: CLI 도구, Docker, VS Code 설치
3. **환경 설정**: 각 계정의 CLI 설정 및 인증

### 2. Cloud Basic 시작
1. **과정 상세 확인**: [Cloud Basic 과정 상세](cloud_basic/과정상세)
2. **실습 가이드 확인**: [1일차 실습 가이드](cloud_basic/textbook/Day1/README)
3. **실습 시작**: AWS/GCP 기초 서비스 실습

### 3. 학습 진행
1. **단계별 학습**: 각 과정을 순서대로 학습
2. **실습 완료**: 각 실습을 완료하고 체크리스트 확인
3. **다음 단계**: 다음 과정으로 진행

</details>

<details>
<summary>📖 도움이 필요하신가요?</summary>

### 자주 묻는 질문
- **Q: 어떤 과정부터 시작해야 하나요?**
  - A: Cloud Basic부터 시작하세요. 클라우드 경험이 없으시다면 반드시 기초 과정부터 시작하는 것을 권장합니다.

- **Q: 실습 환경을 어떻게 준비하나요?**
  - A: 각 과정의 "실습 환경 준비" 섹션을 참고하세요. AWS Free Tier와 GCP Free Tier를 활용하면 비용 없이 실습할 수 있습니다.

- **Q: 과정을 건너뛸 수 있나요?**
  - A: 각 과정은 이전 과정의 내용을 기반으로 구성되어 있으므로, 순서대로 학습하는 것을 권장합니다.

- **Q: 실습 중 문제가 발생하면 어떻게 하나요?**
  - A: 각 과정의 "문제 해결 및 참고 자료" 섹션을 참고하세요. 자주 발생하는 문제와 해결 방법이 정리되어 있습니다.

### 추가 지원
- **이메일 문의**: cloud-training@example.com
- **슬랙 채널**: #cloud-training-support
- **오피스 아워**: 매주 화요일, 목요일 14:00-16:00

</details>

---

**🎯 이제 클라우드 실무력 강화 과정을 시작할 준비가 되었습니다! Cloud Basic부터 차근차근 학습해보세요.**