# 🔒 보안 가이드

## ⚠️ 중요 보안 경고

이 교육 자료에는 민감한 정보가 포함될 수 있습니다. 다음 보안 가이드를 반드시 준수하세요.

## 🚨 민감정보 보호 규칙

### 1. 환경 파일 관리
- **절대 금지**: 실제 AWS/GCP 자격 증명을 코드에 하드코딩
- **권장 방법**: 환경 변수 또는 시크릿 관리 시스템 사용
- **템플릿 사용**: `.template.env` 파일을 복사하여 사용

### 2. Git 보안
```bash
# 민감한 파일을 Git에서 제외
echo "*.env" >> .gitignore
echo "*.pem" >> .gitignore
echo "*-key.json" >> .gitignore
echo "id_rsa*" >> .gitignore
echo "id_ed25519*" >> .gitignore

# 이미 커밋된 민감정보 제거
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch *.env *.pem *-key.json' \
  --prune-empty --tag-name-filter cat -- --all
```

### 3. SSH 키 보안
```bash
# SSH 키 파일 권한 설정
chmod 400 your-ssh-key.pem
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# SSH 키 생성 (안전한 방법)
ssh-keygen -t ed25519 -C "your-email@example.com"
```

### 4. IP 주소 보안
```bash
# 공개 IP 주소 템플릿화
export PUBLIC_IP="YOUR_PUBLIC_IP"
export PRIVATE_IP="YOUR_PRIVATE_IP"

# 클라우드 리소스 ID 템플릿화
export EC2_INSTANCE_ID="YOUR_INSTANCE_ID"
export SECURITY_GROUP_ID="YOUR_SECURITY_GROUP_ID"
export VPC_ID="YOUR_VPC_ID"
```

### 3. 환경 변수 설정
```bash
# AWS 자격 증명
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-northeast-2"

# GCP 자격 증명
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account.json"
export GOOGLE_CLOUD_PROJECT="your-project-id"
```

## 🛡️ 보안 모범 사례

### AWS 보안
1. **IAM 역할 사용**: EC2 인스턴스에 IAM 역할 할당
2. **최소 권한 원칙**: 필요한 최소한의 권한만 부여
3. **자격 증명 로테이션**: 정기적으로 액세스 키 교체
4. **MFA 활성화**: 다중 인증 요인 사용

### GCP 보안
1. **서비스 계정**: 사용자 계정 대신 서비스 계정 사용
2. **Workload Identity**: GKE에서 Workload Identity 사용
3. **Application Default Credentials**: ADC 사용 권장
4. **키 로테이션**: 서비스 계정 키 정기 교체

### Kubernetes 보안
1. **시크릿 관리**: Kubernetes Secret 객체 사용
2. **RBAC 설정**: 역할 기반 접근 제어 구성
3. **네트워크 정책**: Pod 간 통신 제한
4. **이미지 보안**: 신뢰할 수 있는 컨테이너 이미지 사용

## 🔍 보안 검사 체크리스트

### 코드 검토 시 확인사항
- [ ] 하드코딩된 비밀번호 제거
- [ ] 실제 계정 정보 제거
- [ ] SSH 키 파일 보호
- [ ] 환경 변수 사용 확인
- [ ] .gitignore 설정 확인
- [ ] SSH 키 참조를 템플릿으로 교체
- [ ] 실제 IP 주소를 변수로 교체
- [ ] 공개 IP 주소 비식별화
- [ ] 인스턴스 ID 템플릿화
- [ ] 보안 그룹 ID 템플릿화

### 배포 전 보안 검사
- [ ] 민감정보 스캔 실행
- [ ] 시크릿 관리 시스템 연동
- [ ] 접근 권한 검토
- [ ] 로그 모니터링 설정
- [ ] 백업 및 복구 계획 수립

## 🚨 사고 대응 절차

### 자격 증명 노출 시
1. **즉시 비활성화**: 노출된 자격 증명 즉시 비활성화
2. **새 자격 증명 생성**: 새로운 자격 증명 생성
3. **접근 로그 검토**: 비정상적인 접근 확인
4. **보안 팀 알림**: 보안 사고 보고

### 코드 저장소 보안
1. **히스토리 정리**: 민감정보가 포함된 커밋 제거
2. **강제 푸시**: 정리된 히스토리로 강제 푸시
3. **협업자 알림**: 팀원들에게 새 저장소 사용 안내

## 📚 추가 보안 리소스

### AWS 보안
- [AWS 보안 모범 사례](https://aws.amazon.com/security/security-resources/)
- [IAM 모범 사례](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

### GCP 보안
- [GCP 보안 모범 사례](https://cloud.google.com/security/best-practices)
- [IAM 및 보안](https://cloud.google.com/iam/docs/security-best-practices)

### Kubernetes 보안
- [Kubernetes 보안 모범 사례](https://kubernetes.io/docs/concepts/security/)
- [시크릿 관리](https://kubernetes.io/docs/concepts/configuration/secret/)

## 📞 보안 문의

보안 관련 문의사항이 있으시면 다음으로 연락하세요:
- 이메일: security@example.com
- 내부 보안팀: #security-support

---

**⚠️ 이 가이드를 준수하지 않아 발생하는 보안 사고에 대해서는 개인 책임을 지게 됩니다.**
