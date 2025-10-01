알겠습니다 👍 요청하신 내용을 하나의 **마크다운(Markdown) 문서**로 깔끔하게 정리해 드릴게요.

---

# Google Cloud SDK 설치 가이드 (Ubuntu/WSL)

## 1. Google Cloud SDK란?

`google-cloud-sdk`는 **Google Cloud Platform(GCP)을 CLI에서 관리할 수 있는 공식 도구 모음**입니다.
주요 구성 요소:

* **gcloud** : GCP 리소스 관리 (VM, IAM, Kubernetes 등)
* **gsutil** : Cloud Storage(GCS) 관리
* **bq** : BigQuery 관리 및 쿼리 실행

---

## 2. 설치 방법

### 🔹 방법 1: APT 저장소를 통한 설치

1. **필수 도구 설치**

```bash
sudo apt-get install apt-transport-https ca-certificates gnupg curl -y
```

2. **Google Cloud 공개 키 등록**

```bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
```

3. **저장소 추가**

```bash
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
 | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
```

4. **SDK 설치**

```bash
sudo apt-get update
sudo apt-get install google-cloud-sdk -y
```

5. **추가 패키지 (옵션)**

```bash
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin google-cloud-sdk-kubectl-oidc -y
```

---

### 🔹 방법 2: tar.gz 파일 수동 설치

APT 저장소 사용이 어려울 때 tar.gz로 직접 설치합니다.

1. **필수 패키지 설치**

```bash
sudo apt-get update
sudo apt-get install curl unzip -y
```

2. **SDK 다운로드**

```bash
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-473.0.0-linux-x86_64.tar.gz
```

3. **압축 해제**

```bash
tar -xf google-cloud-cli-473.0.0-linux-x86_64.tar.gz
```

4. **설치 실행**

```bash
./google-cloud-sdk/install.sh
```

5. **환경 변수 적용**

```bash
exec -l $SHELL
```

---

## 3. 초기 설정

설치 후 계정 및 프로젝트를 설정합니다.

```bash
gcloud init
```

* Google 계정 로그인
* 기본 프로젝트 선택
* 리전/존 지정

---

## 4. 설치 확인

```bash
gcloud version
```

출력 예시:

```
Google Cloud SDK 473.0.0
bq 2.0.92
gsutil 5.23
```

---

✅ 이제 `gcloud`, `gsutil`, `bq` 명령어를 자유롭게 사용할 수 있습니다.

---

혹시 이 문서를 **GitHub README.md 스타일**로 더 보기 좋게 다듬어드릴까요, 아니면 내부용 매뉴얼처럼 간결하게 유지할까요?
