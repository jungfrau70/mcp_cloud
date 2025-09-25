# kubectl Context 설정 및 변경 가이드

## 🎯 개요

kubectl context는 Kubernetes 클러스터에 접근하기 위한 설정 정보를 포함합니다. 여러 클러스터를 관리할 때 context를 적절히 설정하고 변경하는 것이 중요합니다.

## 📋 현재 Context 확인

### 1. 현재 활성 Context 확인
```bash
kubectl config current-context
```

### 2. 모든 Context 목록 확인
```bash
kubectl config get-contexts
```

### 3. 상세 Context 정보 확인
```bash
kubectl config view
```

## 🔄 Context 변경 방법

### 1. Context 전환
```bash
# 특정 context로 전환
kubectl config use-context <context-name>

# 예시: GKE 클러스터로 전환
kubectl config use-context gke_cloud-deployment-471606_asia-northeast3-a_cloud-master-cluster
```

### 2. Context 이름 변경
```bash
# context 이름 변경
kubectl config rename-context <old-name> <new-name>

# 예시: 긴 이름을 짧게 변경
kubectl config rename-context gke_cloud-deployment-471606_asia-northeast3-a_cloud-master-cluster gke-cloud-master
```

## 🛠️ GKE 클러스터 Context 설정

### 1. GKE 클러스터 자격 증명 가져오기
```bash
# GKE 클러스터 자격 증명 설정
gcloud container clusters get-credentials <cluster-name> \
    --zone <zone> \
    --project <project-id>

# 예시
gcloud container clusters get-credentials cloud-master-cluster \
    --zone asia-northeast3-a \
    --project cloud-deployment-471606
```

### 2. gke-gcloud-auth-plugin 설치 ["필요한 경우"]
```bash
# Windows 환경
curl -LO "https://storage.googleapis.com/gke-release/gke-gcloud-auth-plugin/v0.5.3/windows/amd64/gke-gcloud-auth-plugin.exe"
mkdir -p "$HOME/.local/bin"
mv gke-gcloud-auth-plugin.exe "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/gke-gcloud-auth-plugin.exe"

# Linux/macOS 환경
gcloud components install gke-gcloud-auth-plugin
```

### 3. PATH 설정 [Windows]
```bash
# 현재 세션에서 PATH 설정
set PATH=%USERPROFILE%\.local\bin;%PATH%

# 영구적으로 PATH 설정하려면 시스템 환경 변수에 추가
```

## 🔧 Context 문제 해결

### 1. gke-gcloud-auth-plugin 오류 해결
```bash
# 오류: gke-gcloud-auth-plugin not found
# 해결 방법 1: gcloud components로 설치 ["관리자 권한 필요"]
# Google Cloud SDK Shell을 관리자 권한으로 실행 후:
gcloud components install gke-gcloud-auth-plugin

# 해결 방법 2: 수동 다운로드 및 설치 [Windows]
# 1. 플러그인 다운로드
curl -LO "https://storage.googleapis.com/gke-release/gke-gcloud-auth-plugin/v0.5.3/windows/amd64/gke-gcloud-auth-plugin.exe"

# 2. 로컬 bin 디렉토리 생성
mkdir "%USERPROFILE%\.local\bin"

# 3. 플러그인 이동
move gke-gcloud-auth-plugin.exe "%USERPROFILE%\.local\bin\"

# 4. PATH에 추가
set PATH=%USERPROFILE%\.local\bin;%PATH%

# 5. 영구적으로 PATH에 추가하려면 시스템 환경 변수에 추가

# 해결 방법 2-1: WSL 환경에서 설치
# WSL에서는 Linux용 플러그인을 사용
curl -LO "https://storage.googleapis.com/gke-release/gke-gcloud-auth-plugin/v0.5.3/linux/amd64/gke-gcloud-auth-plugin"

# 실행 권한 부여
chmod +x gke-gcloud-auth-plugin

# 로컬 bin 디렉토리 생성
mkdir -p ~/.local/bin

# 플러그인 이동
mv gke-gcloud-auth-plugin ~/.local/bin/

# PATH에 추가 [WSL]
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 또는 ~/.profile에 추가
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile

# 해결 방법 3: gcloud auth application-default login 실행
gcloud auth application-default login
```

### 2. 인증 오류 해결
```bash
# GCP 인증 확인
gcloud auth list

# Application Default Credentials 설정
gcloud auth application-default login

# 클러스터 자격 증명 다시 가져오기
gcloud container clusters get-credentials <cluster-name> --zone <zone> --project <project-id>
```

### 3. gcp auth plugin 제거 오류
```bash
# 오류: "The gcp auth plugin has been removed"
# 해결: kubeconfig에서 사용자 설정을 exec plugin으로 변경

# 1. 기존 사용자 삭제
kubectl config delete-user <user-name>

# 2. GKE 클러스터 자격 증명 다시 가져오기
gcloud container clusters get-credentials <cluster-name> --zone <zone> --project <project-id>
```

### 4. 대안: gcloud 명령어 사용
```bash
# kubectl 대신 gcloud 명령어로 클러스터 관리
gcloud container clusters describe <cluster-name> --zone <zone> --project <project-id>

# 클러스터 노드 정보 확인
gcloud container clusters describe <cluster-name> --zone <zone> --project <project-id> --format="table[nodePools[].instanceGroupUrls[].split['/'][-1]:label=NODE_POOL,nodePools[].config.machineType:label=MACHINE_TYPE,nodePools[].initialNodeCount:label=NODE_COUNT]"

# 클러스터 상태 확인
gcloud container clusters list --filter="name:<cluster-name>"
```

### 5. Context 삭제
```bash
# 특정 context 삭제
kubectl config delete-context <context-name>

# 예시
kubectl config delete-context gke_cloud-deployment-471606_asia-northeast3-a_cloud-master-cluster
```

## 📊 Context 관리 모범 사례

### 1. Context 이름 규칙
```bash
# 명확하고 간단한 이름 사용
gke-<project>-<region>-<cluster-name>
aks-<resource-group>-<cluster-name>
local-<cluster-name>
```

### 2. Context 별칭 설정
```bash
# 긴 context 이름을 짧게 변경
kubectl config rename-context gke_cloud-deployment-471606_asia-northeast3-a_cloud-master-cluster gke-prod
kubectl config rename-context aks-dev-admin aks-dev
```

### 3. Context 전환 스크립트
```bash
#!/bin/bash
# context-switch.sh

case $1 in
    "gke")
        kubectl config use-context gke-prod
        echo "Switched to GKE production cluster"
        ;;
    "aks")
        kubectl config use-context aks-dev
        echo "Switched to AKS development cluster"
        ;;
    "local")
        kubectl config use-context local-cluster
        echo "Switched to local cluster"
        ;;
    *)
        echo "Usage: $0 {gke|aks|local}"
        ;;
esac
```

## 🧪 Context 테스트

### 1. 클러스터 연결 테스트
```bash
# 현재 context로 클러스터 연결 테스트
kubectl cluster-info

# 노드 상태 확인
kubectl get nodes

# 네임스페이스 확인
kubectl get namespaces
```

### 2. Context별 리소스 확인
```bash
# 현재 context의 모든 리소스 확인
kubectl get all --all-namespaces

# 특정 context의 리소스 확인
kubectl --context=<context-name> get all --all-namespaces
```

## 🔍 문제 진단

### 1. Context 설정 확인
```bash
# 현재 context 상세 정보
kubectl config view --minify

# 특정 context 상세 정보
kubectl config view --context=<context-name>
```

### 2. 연결 문제 진단
```bash
# 클러스터 엔드포인트 확인
kubectl cluster-info dump | grep -E "[server|endpoint]"

# 인증 정보 확인
kubectl config view --raw
```

### 3. 로그 확인
```bash
# kubectl 디버그 모드
kubectl get nodes -v=6

# 상세 오류 정보 확인
kubectl get nodes --v=8
```

## 📚 유용한 명령어 모음

```bash
# Context 관련 모든 명령어
kubectl config --help

# Context 설정 파일 위치 확인
echo $KUBECONFIG
# 또는
kubectl config view --raw | grep -A 5 "current-context"

# Context 백업
cp ~/.kube/config ~/.kube/config.backup

# Context 복원
cp ~/.kube/config.backup ~/.kube/config
```

## 🚨 주의사항

1. **프로덕션 환경**: 프로덕션 클러스터로 전환하기 전에 현재 context를 확인하세요.
2. **권한 관리**: 각 context의 권한을 적절히 관리하세요.
3. **백업**: 중요한 context 설정은 정기적으로 백업하세요.
4. **보안**: kubeconfig 파일의 권한을 적절히 설정하세요 ["600 권한 권장"].

## 🔗 관련 링크

- ["kubectl 공식 문서"][https://kubernetes.io/docs/reference/kubectl/]
- ["GKE 클러스터 접근 가이드"][https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl]
- ["kubectl context 관리"][https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/]
