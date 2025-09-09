# GCP SSH 키 등록 가이드

GCP에서 SSH 키를 등록하는 방법과 각 방법의 차이점을 설명합니다.

## 🔑 SSH 키 등록 방법

### 1. 프로젝트 메타데이터 (Project-level metadata)

**특징:**
- 프로젝트 전체에 적용
- 해당 프로젝트의 모든 VM에서 사용 가능
- 새로 생성되는 VM에도 자동으로 적용

**명령어:**
```bash
# 프로젝트 메타데이터에 SSH 키 추가
gcloud compute project-info add-metadata --metadata "ssh-keys=USERNAME:PUBLIC_KEY_CONTENT"

# 예시
gcloud compute project-info add-metadata --metadata "ssh-keys=ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ..."
```

**확인 방법:**
```bash
# 프로젝트 메타데이터 확인
gcloud compute project-info describe --format="get(commonInstanceMetadata.items[].key,commonInstanceMetadata.items[].value)"
```

### 2. 인스턴스 메타데이터 (Instance-level metadata)

**특징:**
- 특정 VM 인스턴스에만 적용
- 해당 VM에서만 사용 가능
- 프로젝트 메타데이터보다 우선순위가 높음

**명령어:**
```bash
# 인스턴스 메타데이터에 SSH 키 추가
gcloud compute instances add-metadata INSTANCE_NAME --zone=ZONE --metadata "ssh-keys=USERNAME:PUBLIC_KEY_CONTENT"

# 예시
gcloud compute instances add-metadata cloud-deployment-server --zone=asia-northeast3-a --metadata "ssh-keys=ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ..."
```

**확인 방법:**
```bash
# 인스턴스 메타데이터 확인
gcloud compute instances describe INSTANCE_NAME --zone=ZONE --format="get(metadata.items[].key,metadata.items[].value)"
```

### 3. OS Login

**특징:**
- Google 계정 기반 인증
- IAM 권한과 연동
- 더 안전하고 관리하기 쉬움

**명령어:**
```bash
# OS Login에 SSH 키 추가
gcloud compute os-login ssh-keys add --key-file=PUBLIC_KEY_FILE --project=PROJECT_ID

# 예시
gcloud compute os-login ssh-keys add --key-file=cloud-deployment-key.pub --project=cloud-deployment-2025-12345
```

**확인 방법:**
```bash
# OS Login SSH 키 목록 확인
gcloud compute os-login ssh-keys list --project=PROJECT_ID
```

## 🔄 우선순위

SSH 키는 다음 순서로 확인됩니다:

1. **인스턴스 메타데이터** (최우선)
2. **프로젝트 메타데이터**
3. **OS Login**

## 📋 스크립트에서의 구현

### gcp-compute-create.sh
```bash
# 1. OS Login에 SSH 키 추가
gcloud compute os-login ssh-keys add --key-file "$PUBLIC_KEY_FILE" --project $PROJECT_ID

# 2. 프로젝트 메타데이터에 SSH 키 추가
gcloud compute project-info add-metadata --metadata "ssh-keys=$USER:$SSH_KEY_CONTENT"

# 3. VM 생성 시 인스턴스 메타데이터로 SSH 키 전달
gcloud compute instances create $INSTANCE_NAME \
    --metadata ssh-keys="$USER:$SSH_KEY_CONTENT" \
    ...
```

### gcp-ssh-key-add.sh
```bash
# 기존 인스턴스에 SSH 키 추가
gcloud compute instances add-metadata $INSTANCE_NAME --zone=$ZONE --metadata "ssh-keys=$USER:$SSH_KEY_CONTENT"
```

## 🐛 문제 해결

### SSH 키가 작동하지 않는 경우

1. **메타데이터 확인:**
```bash
# 프로젝트 메타데이터 확인
gcloud compute project-info describe

# 인스턴스 메타데이터 확인
gcloud compute instances describe INSTANCE_NAME --zone=ZONE
```

2. **SSH 키 형식 확인:**
```bash
# SSH 키 유효성 검사
ssh-keygen -l -f PUBLIC_KEY_FILE

# SSH 키 내용 확인
cat PUBLIC_KEY_FILE
```

3. **사용자명 확인:**
```bash
# GCP OS Login 사용자 확인
gcloud config get-value account

# 또는 Ubuntu 기본 사용자 사용
ssh -i PRIVATE_KEY ubuntu@VM_IP
```

### 권한 문제

```bash
# Compute Engine API 활성화 확인
gcloud services list --enabled --filter="name:compute.googleapis.com"

# OS Login API 활성화 확인
gcloud services list --enabled --filter="name:oslogin.googleapis.com"

# 필요시 API 활성화
gcloud services enable compute.googleapis.com
gcloud services enable oslogin.googleapis.com
```

## 💡 권장사항

1. **개발 환경**: 프로젝트 메타데이터 사용 (편리함)
2. **운영 환경**: OS Login 사용 (보안성)
3. **특정 VM**: 인스턴스 메타데이터 사용 (세밀한 제어)

## 📚 참고 자료

- [GCP SSH 키 관리 공식 문서](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys)
- [OS Login 가이드](https://cloud.google.com/compute/docs/oslogin)
- [메타데이터 서버 문서](https://cloud.google.com/compute/docs/metadata)
