# 🔑 SSH 키 보안 템플릿

## ⚠️ SSH 키 보안 가이드

이 템플릿을 사용하여 안전하게 SSH 키를 관리하세요.

## 🛡️ SSH 키 생성 및 관리

### 1. SSH 키 생성
```bash
# Ed25519 키 생성 (권장)
ssh-keygen -t ed25519 -C "your-email@example.com"

# RSA 키 생성 (레거시 지원)
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
```

### 2. SSH 키 권한 설정
```bash
# 개인 키 보호 (소유자만 읽기)
chmod 400 ~/.ssh/id_ed25519
chmod 400 ~/.ssh/id_rsa

# 공개 키 권한 (읽기 가능)
chmod 644 ~/.ssh/id_ed25519.pub
chmod 644 ~/.ssh/id_rsa.pub

# SSH 디렉토리 권한
chmod 700 ~/.ssh
```

### 3. AWS EC2 키 페어 생성
```bash
# AWS CLI로 키 페어 생성
aws ec2 create-key-pair \
    --key-name your-key-name \
    --query 'KeyMaterial' \
    --output text > your-ssh-key.pem

# 키 파일 권한 설정
chmod 400 your-ssh-key.pem
```

### 4. GCP SSH 키 설정
```bash
# GCP에 SSH 키 추가
gcloud compute os-login ssh-keys add \
    --key-file ~/.ssh/id_ed25519.pub \
    --project your-project-id
```

## 🔒 SSH 키 보안 모범 사례

### 1. 키 파일 보호
- **절대 공유 금지**: SSH 개인 키는 절대 다른 사람과 공유하지 마세요
- **안전한 저장**: 키 파일을 암호화된 저장소에 보관
- **백업**: 키 파일의 안전한 백업 보관

### 2. 키 로테이션
```bash
# 정기적인 키 교체 (권장: 6개월마다)
# 1. 새 키 생성
ssh-keygen -t ed25519 -C "new-key-$(date +%Y%m%d)"

# 2. 새 키를 서버에 추가
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@server

# 3. 기존 키 제거
ssh-keygen -R server-ip
```

### 3. SSH 설정 강화
```bash
# ~/.ssh/config 파일 설정
Host *
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
    Compression yes

# 특정 서버 설정
Host production-server
    HostName your-server-ip
    User ec2-user
    IdentityFile ~/.ssh/your-production-key.pem
    Port 22
    StrictHostKeyChecking yes
```

## 🚨 보안 경고

### 절대 금지사항
- ❌ SSH 키를 Git 저장소에 커밋
- ❌ SSH 키를 이메일이나 메신저로 전송
- ❌ SSH 키를 공개 저장소에 업로드
- ❌ SSH 키를 화면에 표시

### 권장사항
- ✅ SSH 키를 .gitignore에 추가
- ✅ SSH 키를 암호화하여 저장
- ✅ 정기적인 키 로테이션
- ✅ SSH 키 사용 로그 모니터링

## 📋 SSH 키 체크리스트

### 생성 시
- [ ] 강력한 패스프레이즈 설정
- [ ] 적절한 키 타입 선택 (Ed25519 권장)
- [ ] 키 파일 권한 올바르게 설정
- [ ] 백업 생성

### 사용 시
- [ ] SSH 키를 안전한 위치에 보관
- [ ] 불필요한 키 파일 정리
- [ ] SSH 접속 로그 모니터링
- [ ] 정기적인 키 교체

### 보안 점검
- [ ] 키 파일 권한 확인 (400)
- [ ] SSH 디렉토리 권한 확인 (700)
- [ ] 사용하지 않는 키 파일 제거
- [ ] SSH 설정 파일 보안 검토

## 🔧 문제 해결

### SSH 키 권한 오류
```bash
# 권한 오류 시
chmod 400 ~/.ssh/id_ed25519
chmod 700 ~/.ssh
```

### SSH 연결 실패
```bash
# SSH 연결 디버깅
ssh -v user@server
ssh -vv user@server  # 더 자세한 디버그 정보
```

### 키 파일 찾을 수 없음
```bash
# SSH 키 파일 위치 확인
ls -la ~/.ssh/
ssh-add -l  # 로드된 키 확인
```

## 📚 추가 리소스

- [SSH 키 관리 모범 사례](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [AWS EC2 키 페어 관리](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
- [GCP SSH 키 관리](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys)

---

**⚠️ 이 템플릿을 사용하여 SSH 키를 안전하게 관리하세요.**
