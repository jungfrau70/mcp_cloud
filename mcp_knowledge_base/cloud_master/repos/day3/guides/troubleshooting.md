# 문제 해결 가이드

## 🚨 일반적인 문제 및 해결 방법

### 1. SSH 접속 문제

#### 문제: Permission denied (publickey)
```bash
# 오류 메시지
Permission denied (publickey)
```

#### 해결 방법
```bash
# SSH 키 권한 확인 및 수정
chmod 600 ~/.ssh/cloud-master-key.pem

# SSH 키 형식 확인
file ~/.ssh/cloud-master-key.pem

# SSH 접속 테스트
ssh -i ~/.ssh/cloud-master-key.pem -v ubuntu@[VM_IP]
```

#### 추가 확인사항
- SSH 키가 올바른 형식인지 확인
- VM의 보안 그룹에서 SSH 포트(22)가 개방되어 있는지 확인
- 사용자명이 올바른지 확인 (ubuntu, ec2-user 등)

### 2. Docker 권한 문제

#### 문제: Permission denied while trying to connect to Docker daemon
```bash
# 오류 메시지
permission denied while trying to connect to Docker daemon socket
```

#### 해결 방법
```bash
# 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# 현재 세션에서 그룹 변경사항 적용
newgrp docker

# 또는 새 터미널에서 다시 접속
exit
ssh -i ~/.ssh/cloud-master-key.pem ubuntu@[VM_IP]
```

#### 확인 방법
```bash
# Docker 명령어 테스트
docker --version
docker ps

# 그룹 멤버십 확인
groups $USER
```

### 3. AWS CLI 설정 문제

#### 문제: Unable to locate credentials
```bash
# 오류 메시지
Unable to locate credentials. You can configure credentials by running "aws configure"
```

#### 해결 방법
```bash
# AWS CLI 설정
aws configure

# 또는 환경 변수 설정
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-west-2

# 설정 확인
aws sts get-caller-identity
```

#### IAM 권한 확인
필요한 최소 권한:
- EC2FullAccess
- ELBFullAccess
- IAMReadOnlyAccess
- CloudWatchFullAccess

### 4. GCP CLI 설정 문제

#### 문제: gcloud command not found
```bash
# 오류 메시지
gcloud: command not found
```

#### 해결 방법
```bash
# GCP CLI 설치
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# 또는 수동 설치
wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-XXX.0.0-linux-x86_64.tar.gz
tar -xzf google-cloud-sdk-XXX.0.0-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh
```

#### 인증 설정
```bash
# GCP 인증
gcloud auth login

# 프로젝트 설정
gcloud config set project [PROJECT_ID]

# 설정 확인
gcloud auth list
gcloud config list
```

### 5. 포트 충돌 문제

#### 문제: Port already in use
```bash
# 오류 메시지
bind: address already in use
```

#### 해결 방법
```bash
# 포트 사용 프로세스 확인
sudo netstat -tulpn | grep :9090

# 프로세스 종료
sudo kill -9 [PID]

# 또는 Day2 모니터링 스택 중지
cd /path/to/day2/project
docker-compose down
```

### 6. 메모리 부족 문제

#### 문제: Out of memory
```bash
# 오류 메시지
Cannot start service elasticsearch: OCI runtime create failed
```

#### 해결 방법
```bash
# 메모리 사용량 확인
free -h
docker stats

# Elasticsearch 메모리 설정 조정
export ES_JAVA_OPTS="-Xms256m -Xmx256m"

# 또는 Docker Compose에서 설정
environment:
  - "ES_JAVA_OPTS=-Xms256m -Xmx256m"
```

### 7. 네트워크 연결 문제

#### 문제: Connection refused
```bash
# 오류 메시지
curl: (7) Failed to connect to localhost port 9090: Connection refused
```

#### 해결 방법
```bash
# 서비스 상태 확인
docker ps
docker logs [container_name]

# 포트 바인딩 확인
docker port [container_name]

# 방화벽 확인
sudo ufw status
sudo iptables -L
```

### 8. Git 인증 문제

#### 문제: Authentication failed
```bash
# 오류 메시지
remote: Support for password authentication was removed
```

#### 해결 방법
```bash
# SSH 키 생성
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# SSH 키를 GitHub에 추가
cat ~/.ssh/id_rsa.pub

# SSH 연결 테스트
ssh -T git@github.com
```

## 🔍 진단 도구

### 시스템 상태 확인
```bash
# 시스템 리소스 확인
htop
df -h
free -h

# Docker 상태 확인
docker system df
docker system prune -f

# 네트워크 상태 확인
netstat -tulpn
ss -tulpn
```

### 로그 확인
```bash
# 실습 스크립트 로그
tail -f ~/cloud-master-workspace/logs/*.log

# Docker 컨테이너 로그
docker logs [container_name] -f

# 시스템 로그
sudo journalctl -u docker -f
```

### 네트워크 진단
```bash
# 포트 연결 테스트
telnet localhost 9090
nc -zv localhost 9090

# DNS 확인
nslookup google.com
dig google.com

# 라우팅 확인
traceroute google.com
```

## 🛠️ 복구 방법

### 전체 환경 재설정
```bash
# 1. 모든 컨테이너 중지 및 제거
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

# 2. 모든 볼륨 제거
docker volume prune -f

# 3. 모든 네트워크 제거
docker network prune -f

# 4. 시스템 정리
docker system prune -a -f

# 5. 실습 재시작
./01-aws-loadbalancing.sh setup
```

### 특정 서비스 재시작
```bash
# 모니터링 스택 재시작
./03-monitoring-stack.sh cleanup
./03-monitoring-stack.sh setup
./03-monitoring-stack.sh start

# 로드밸런싱 재설정
./01-aws-loadbalancing.sh cleanup
./01-aws-loadbalancing.sh setup
```

## 📞 지원 요청

### 문제 보고 시 포함할 정보
1. **오류 메시지**: 전체 오류 메시지 복사
2. **시스템 정보**: OS, Docker 버전, 메모리/CPU 사용량
3. **실행 환경**: WSL/VM, AWS/GCP 리전
4. **실행 단계**: 어느 단계에서 문제가 발생했는지
5. **로그 파일**: 관련 로그 파일 첨부

### 로그 수집
```bash
# 시스템 정보 수집
uname -a > system-info.txt
docker version >> system-info.txt
free -h >> system-info.txt

# 실습 로그 수집
cp -r ~/cloud-master-workspace/logs/ ./logs-backup/

# Docker 로그 수집
docker logs [container_name] > container-logs.txt
```

## 📚 추가 자료

- [WSL → Cloud VM 설정 가이드](wsl-to-vm-setup.md)
- [포트 충돌 해결 가이드](port-conflict-resolution.md)
- [Docker 공식 문서](https://docs.docker.com/)
- [AWS CLI 사용 가이드](https://docs.aws.amazon.com/cli/)
- [GCP CLI 사용 가이드](https://cloud.google.com/sdk/docs)
