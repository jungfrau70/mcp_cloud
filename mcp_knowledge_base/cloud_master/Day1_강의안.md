# Cloud Master - 1일차 수업 진행 기록

> 📋 **수업 일시**: 2024년 9월 22일 ["월"] 9:00~17:00  
> 📋 **수업 방식**: 온라인 실습 중심  
> 📋 **수업 결과**: ✅ 성공적으로 완료
> 📋 **참고 코드**: https://github.com/jungfrau70/cloud-master.git

---

## 🕘 1교시: WSL 구성 및 Utility 설치 [9:00~10:05]

### ✅ 완료된 작업
1. **Windows 기능 활성화**
   - Windows Subsystem for Linux [WSL] 활성화
   - Virtual Machine Platform 활성화

2. **WSL[Ubuntu] 설치**
   - WSL2 기반 Ubuntu 설치
   - 참조: `cloud_master/repos/cloud-scripts/wsl-install.md`

3. **필수 도구 설치**
   - 실행: `cloud_master/repos/install/install-all-wsl.sh`
   - Docker, Git, AWS CLI, GCP CLI 설치 완료

### 📊 수업 결과
- **성공률**: 100% ["모든 학습자 WSL 환경 구축 완료"]
- **소요 시간**: 65분 ["예상 65분"]
- **주요 이슈**: 없음
- **테스트 결과**: 기본 환경 검증 완료

---

## 🕘 2교시: AWS & GCP Setup [10:20~10:55]

### ✅ 완료된 작업
1. **AWS 설정**
   - `aws configure` 실행
   - Access Key, Secret Key, Region 설정 완료

2. **GCP 설정**
   - `gcloud auth login` 실행
   - `gcloud config set project [project-id]` 실행

3. **설정 도우미 스크립트 실행**
   - `cloud_master/repos/cloud-scripts/gcp-setup-helper.sh`
   - `cloud_master/repos/cloud-scripts/aws-setup-helper.sh`

### 📊 수업 결과
- **성공률**: 100% ["모든 학습자 클라우드 계정 연동 완료"]
- **소요 시간**: 35분 ["예상 35분"]
- **주요 이슈**: 없음

---

## 🕘 3교시: VM 생성 [11:10~12:00]

### ✅ 완료된 작업
1. **AWS EC2 인스턴스 생성**
   - 실행: `cloud_master/repos/cloud-scripts/eks-cluster-create.sh`
   - t2.micro 인스턴스 생성 완료

2. **GCP Compute Engine 인스턴스 생성**
   - 실행: `cloud_master/repos/cloud-scripts/gcp-compute-create.sh`
   - e2-micro 인스턴스 생성 완료

### 📊 수업 결과
- **성공률**: 100% ["모든 학습자 VM 생성 완료"]
- **소요 시간**: 50분 ["예상 50분"]
- **주요 이슈**: 없음

---

## 🍽️ 점심 시간 [12:00~13:00]

---

## 🕘 4교시: Docker & Dockerfile 기초 이론 [13:00~14:00]

### 📚 이론 학습 ["60분"]
#### Docker 개념 및 핵심 원리
- **컨테이너화**: 애플리케이션과 의존성을 하나의 패키지로 묶기
- **가상화 vs 컨테이너**: 하이퍼바이저 vs OS 레벨 가상화
- **Docker 아키텍처**: Docker Engine, Images, Containers, Registry
- **이미지 vs 컨테이너**: 템플릿 vs 실행 인스턴스

#### Dockerfile 핵심 개념
- **레이어드 파일시스템**: 각 명령어가 새로운 레이어 생성
- **캐싱 메커니즘**: 변경되지 않은 레이어는 재사용
- **멀티스테이지 빌드**: 빌드 도구와 런타임 환경 분리
- **베이스 이미지 선택**: Alpine, Ubuntu, Node.js 공식 이미지

#### Dockerfile 작성 기초
```dockerfile
# 1. 베이스 이미지 선택
FROM node:18-alpine

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. 의존성 파일 복사
COPY package*.json ./

# 4. 의존성 설치
RUN npm install

# 5. 애플리케이션 코드 복사
COPY . .

# 6. 포트 노출
EXPOSE 3000

# 7. 실행 명령어
CMD ["node", "app.js"]
```

#### Docker 명령어 기초
```bash
# 이미지 관리
docker build -t myapp:latest .          # 이미지 빌드
docker images                           # 이미지 목록
docker rmi myapp:latest                 # 이미지 삭제

# 컨테이너 관리
docker run -d -p 3000:3000 myapp:latest # 컨테이너 실행
docker ps                               # 실행 중인 컨테이너
docker logs <container_id>              # 로그 확인
docker stop <container_id>              # 컨테이너 중지
docker rm <container_id>                # 컨테이너 삭제

# Docker Hub 관리
docker login                            # Docker Hub 로그인
docker push myapp:latest                # 이미지 푸시
docker pull myapp:latest                # 이미지 풀
```

### 📊 예상 결과
- **성공률**: 100% ["이론 학습"]
- **소요 시간**: 60분
- **주요 학습**: Docker 기본 개념, Dockerfile 작성법

---

## 🕘 5교시: GitHub Actions 배포 실습 [14:00~17:00]

### ✅ 완료된 작업
1. **GitHub 저장소 준비**
   - `https://github.com/jungfrau70/github-actions-demo.git` Fork
   - 개인 계정으로 저장소 복사 완료

2. **로컬 환경 설정**
   - `mkdir work && git clone https://github.com/[github-userid]/github-actions-demo.git`
   - 로컬 작업 디렉토리 구성 완료

3. **🔑 중요: Repository Secrets 설정**
   - **기존 교재 방식**: 환경파일[.env] 사용
   - **실제 수업 방식**: **Repository Secrets** 사용 ✅
   - 설정 위치: `https://github.com/[github-userid]/github-actions-demo/settings/secrets/actions`
   - 설정된 Secrets:
     - `DOCKER_USERNAME`: Docker Hub 사용자명
     - `DOCKER_PASSWORD`: Docker Hub Personal Access Token
     - `GCP_VM_HOST`: GCP VM 공인 IP
     - `GCP_VM_SSH_KEY`: GCP VM SSH 개인키 ["OpenSSH 형식"]
     - `GCP_VM_USERNAME`: GCP VM 사용자명
     - `AWS_VM_HOST`: AWS VM 공인 IP
     - `AWS_VM_SSH_KEY`: AWS VM SSH 개인키 [".pem 파일"]
     - `AWS_VM_USERNAME`: AWS VM 사용자명

4. **GitHub Actions 실행**
   - `git add . && git commit -m "Initial setup"`
   - `git push origin main`
   - GitHub Actions 탭에서 배포 상태 확인

5. **배포 결과 확인**
   - AWS VM: `http://["AWS-공인IP"]:3000` ✅
   - GCP VM: `http://["GCP-공인IP"]:3000` ✅

### 📊 수업 결과
- **성공률**: 100% ["모든 학습자 자동 배포 성공"]
- **소요 시간**: 240분 ["예상 240분"]
- **주요 발견사항**: 
  - ✅ **Repository Secrets 방식이 환경파일보다 안전하고 효과적**
  - ✅ **모든 학습자가 성공적으로 배포 완료**
  - ✅ **실제 운영 환경과 동일한 방식으로 진행**

---

## 🎯 1일차 수업 성과

### ✅ 달성한 학습 목표
- [x] WSL 환경 구축 및 개발 도구 설치
- [x] AWS/GCP 클라우드 계정 연동
- [x] 멀티 클라우드 VM 인스턴스 생성
- [x] Docker & Dockerfile 기초 이론 학습
- [x] GitHub Actions CI/CD 파이프라인 구축
- [x] Repository Secrets를 활용한 보안 설정
- [x] 자동화된 Docker 이미지 빌드 및 배포
- [x] 멀티 클라우드 환경에서의 애플리케이션 배포

### 🔍 주요 학습 포인트
1. **Repository Secrets의 중요성**: 환경파일보다 안전하고 관리하기 쉬움
2. **멀티 클라우드 전략**: AWS와 GCP 동시 활용의 장점
3. **자동화의 위력**: 한 번의 git push로 전체 배포 파이프라인 실행
4. **실무 연계성**: 실제 운영 환경과 동일한 방식으로 실습

### 📈 다음 수업 준비사항
- [ ] Day2: 고급 CI/CD 및 VM 기반 컨테이너 배포
- [ ] Day3: 로드 밸런싱, 모니터링, 비용 최적화
- [ ] Repository Secrets 설정 방법 문서화 필요

