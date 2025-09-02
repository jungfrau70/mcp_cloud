#!/bin/bash

# GCP 정적 웹사이트 배포 실습 자동화 스크립트
# 실습2: GCP Cloud Storage 정적 웹사이트 배포
# v2: 프로젝트 존재 여부 확인 및 사용 로직 추가

set -e  # 오류 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 랜덤 문자열 생성 함수
generate_random_string() {
    local length=${1:-6}
    cat /dev/urandom | tr -dc 'a-z0-9' | fold -w $length | head -n 1
}

# 고유 식별자 생성
UNIQUE_SUFFIX=$(generate_random_string 6)
log_info "고유 식별자 생성: $UNIQUE_SUFFIX"

# 환경 변수 로드
if [ -f "실습2_gcp_static_website.env" ]; then
    source 실습2_gcp_static_website.env
    log_info "환경 변수를 로드했습니다."
else
    log_warning ".env 파일이 없습니다. 기본값을 사용합니다."
    # 기본값 설정 (고유 식별자 추가)
    PROJECT_ID="static-website-2-$UNIQUE_SUFFIX"
    BUCKET_NAME="my-static-website-bucket-$UNIQUE_SUFFIX"
    LOCATION="asia-northeast3"
fi

# Google Cloud SDK 설치 확인
check_gcloud() {
    log_info "Google Cloud SDK 설치 상태를 확인합니다..."
    if ! command -v gcloud &> /dev/null; then
        log_error "Google Cloud SDK가 설치되지 않았습니다."
        log_info "설치 방법:"
        log_info "Windows: https://cloud.google.com/sdk/docs/install"
        log_info "macOS: brew install google-cloud-sdk"
        log_info "Ubuntu: curl https://sdk.cloud.google.com | bash"
        exit 1
    fi
    log_success "Google Cloud SDK가 설치되어 있습니다."
}

# Google Cloud 로그인 확인
check_gcloud_login() {
    log_info "Google Cloud 로그인 상태를 확인합니다..."
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        log_error "Google Cloud에 로그인되지 않았습니다."
        log_info "다음 명령어로 로그인하세요: gcloud auth login"
        exit 1
    fi
    log_success "Google Cloud에 로그인되어 있습니다."
}

# 1단계: GCP 환경 준비
setup_gcp_environment() {
    log_info "=== 1단계: GCP 환경 준비 ==="
    
    # 프로젝트 존재 여부 확인
    log_info "GCP 프로젝트 존재 여부를 확인합니다: $PROJECT_ID"
    if gcloud projects describe "$PROJECT_ID" &> /dev/null; then
        log_warning "GCP 프로젝트가 이미 존재합니다: $PROJECT_ID"
        log_info "기존 프로젝트를 사용합니다."
    else
        # 프로젝트 생성
        log_info "GCP 프로젝트를 생성합니다: $PROJECT_ID"
        gcloud projects create "$PROJECT_ID" --name="My Static Website"
    fi
    
    # 프로젝트 설정
    log_info "프로젝트를 설정합니다..."
    gcloud config set project "$PROJECT_ID"
    
    # 프로젝트 확인
    log_info "현재 프로젝트를 확인합니다..."
    gcloud config get-value project
    
    # Cloud Storage API 활성화 상태 확인
    log_info "Cloud Storage API 활성화 상태를 확인합니다..."
    if gcloud services list --enabled --filter="name:storage.googleapis.com" | grep -q "storage.googleapis.com"; then
        log_warning "Cloud Storage API가 이미 활성화되어 있습니다."
    else
        # Cloud Storage API 활성화
        log_info "Cloud Storage API를 활성화합니다..."
        gcloud services enable storage.googleapis.com
    fi
    
    log_success "GCP 환경 준비가 완료되었습니다."
}

# 2단계: Cloud Storage 버킷 생성
create_storage_bucket() {
    log_info "=== 2단계: Cloud Storage 버킷 생성 ==="
    
    # 버킷 존재 여부 확인
    log_info "Cloud Storage 버킷 존재 여부를 확인합니다: $BUCKET_NAME"
    if gsutil ls "gs://$BUCKET_NAME" &> /dev/null; then
        log_warning "Cloud Storage 버킷이 이미 존재합니다: $BUCKET_NAME"
        log_info "기존 버킷을 사용합니다."
    else
        # 버킷 생성
        log_info "Cloud Storage 버킷을 생성합니다: $BUCKET_NAME"
        gsutil mb -l "$LOCATION" "gs://$BUCKET_NAME"
    fi
    
    # 버킷 목록 확인
    log_info "버킷 목록을 확인합니다..."
    gsutil ls
    
    # 버킷 세부 정보 확인
    log_info "버킷 세부 정보를 확인합니다..."
    gsutil ls -L "gs://$BUCKET_NAME"
    
    log_success "Cloud Storage 버킷 생성이 완료되었습니다."
}

# 3단계: 웹사이트 설정
setup_website_config() {
    log_info "=== 3단계: 웹사이트 설정 ==="
    
    # 웹사이트 설정 확인
    log_info "웹사이트 설정을 확인합니다..."
    CURRENT_CONFIG=$(gsutil web get "gs://$BUCKET_NAME" 2>/dev/null || echo "")
    
    if [[ "$CURRENT_CONFIG" == *"MainPageSuffix: index.html"* ]] && [[ "$CURRENT_CONFIG" == *"NotFoundPage: 404.html"* ]]; then
        log_warning "웹사이트 설정이 이미 완료되어 있습니다."
    else
        # 웹사이트 설정 적용
        log_info "웹사이트 설정을 적용합니다..."
        gsutil web set -m index.html -e 404.html "gs://$BUCKET_NAME"
    fi
    
    # 웹사이트 설정 확인
    log_info "웹사이트 설정을 확인합니다..."
    gsutil web get "gs://$BUCKET_NAME"
    
    log_success "웹사이트 설정이 완료되었습니다."
}

# 4단계: 정적 웹사이트 파일 생성
create_website_files() {
    log_info "=== 4단계: 정적 웹사이트 파일 생성 ==="
    
    # 작업 디렉토리 생성
    if [ ! -d "static-website" ]; then
        mkdir -p static-website
    fi
    cd static-website
    
    # index.html 존재 여부 확인
    if [ -f "index.html" ]; then
        log_warning "index.html 파일이 이미 존재합니다."
        log_info "기존 파일을 사용합니다."
    else
        # index.html 생성
        log_info "index.html 파일을 생성합니다..."
        cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GCP 정적 웹사이트</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #4285f4;
            text-align: center;
        }
        .feature {
            margin: 20px 0;
            padding: 15px;
            background-color: #f8f9fa;
            border-left: 4px solid #4285f4;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 GCP Cloud Storage 정적 웹사이트</h1>
        
        <div class="feature">
            <h2>✅ 성공적으로 배포되었습니다!</h2>
            <p>이 웹사이트는 Google Cloud Platform의 Cloud Storage를 사용하여 호스팅되고 있습니다.</p>
        </div>

        <div class="feature">
            <h3>🔧 사용된 기술</h3>
            <ul>
                <li>Google Cloud Storage</li>
                <li>정적 웹사이트 호스팅</li>
                <li>HTML5 & CSS3</li>
            </ul>
        </div>

        <div class="feature">
            <h3>📊 배포 정보</h3>
            <p><strong>버킷:</strong> BUCKET_NAME_PLACEHOLDER</p>
            <p><strong>리전:</strong> asia-northeast3 (Seoul)</p>
            <p><strong>고유 ID:</strong> UNIQUE_ID_PLACEHOLDER</p>
            <p><strong>배포 시간:</strong> <span id="deploy-time"></span></p>
        </div>
    </div>

    <script>
        document.getElementById('deploy-time').textContent = new Date().toLocaleString('ko-KR');
    </script>
</body>
</html>
EOF
        
        # BUCKET_NAME과 UNIQUE_ID 치환
        sed -i "s/BUCKET_NAME_PLACEHOLDER/$BUCKET_NAME/g" index.html
        sed -i "s/UNIQUE_ID_PLACEHOLDER/$UNIQUE_SUFFIX/g" index.html
    fi
    
    # 404.html 존재 여부 확인
    if [ -f "404.html" ]; then
        log_warning "404.html 파일이 이미 존재합니다."
        log_info "기존 파일을 사용합니다."
    else
        # 404.html 생성
        log_info "404.html 파일을 생성합니다..."
        cat > 404.html << 'EOF'
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>페이지를 찾을 수 없습니다</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
            background-color: #f5f5f5;
        }
        .error-container {
            background-color: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            max-width: 500px;
            margin: 0 auto;
        }
        h1 {
            color: #ea4335;
            font-size: 3em;
            margin-bottom: 20px;
        }
        .back-link {
            margin-top: 30px;
        }
        .back-link a {
            color: #4285f4;
            text-decoration: none;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <h1>404</h1>
        <h2>페이지를 찾을 수 없습니다</h2>
        <p>요청하신 페이지가 존재하지 않거나 이동되었을 수 있습니다.</p>
        <div class="back-link">
            <a href="/">홈으로 돌아가기</a>
        </div>
    </div>
</body>
</html>
EOF
    fi
    
    # 파일 확인
    log_info "생성된 파일을 확인합니다..."
    ls -la
    
    cd ..
    
    log_success "정적 웹사이트 파일 생성이 완료되었습니다."
}

# 5단계: 파일 업로드
upload_files() {
    log_info "=== 5단계: 파일 업로드 ==="
    
    # 파일 존재 여부 확인
    log_info "업로드된 파일을 확인합니다..."
    UPLOADED_FILES=$(gsutil ls "gs://$BUCKET_NAME/" 2>/dev/null || echo "")
    
    if echo "$UPLOADED_FILES" | grep -q "index.html"; then
        log_warning "index.html이 이미 업로드되어 있습니다."
    else
        # 파일 업로드
        log_info "index.html을 업로드합니다..."
        gsutil cp static-website/index.html "gs://$BUCKET_NAME/"
    fi
    
    if echo "$UPLOADED_FILES" | grep -q "404.html"; then
        log_warning "404.html이 이미 업로드되어 있습니다."
    else
        # 파일 업로드
        log_info "404.html을 업로드합니다..."
        gsutil cp static-website/404.html "gs://$BUCKET_NAME/"
    fi
    
    # 업로드된 파일 확인
    log_info "업로드된 파일을 확인합니다..."
    gsutil ls "gs://$BUCKET_NAME/"
    
    # 파일 권한 확인
    log_info "파일 권한을 확인합니다..."
    gsutil ls -L "gs://$BUCKET_NAME/index.html"
    
    log_success "파일 업로드가 완료되었습니다."
}

# 6단계: 퍼블릭 접근 설정
setup_public_access() {
    log_info "=== 6단계: 퍼블릭 접근 설정 ==="
    
    # 현재 권한 확인
    log_info "현재 버킷 권한을 확인합니다..."
    CURRENT_IAM=$(gsutil iam get "gs://$BUCKET_NAME" 2>/dev/null || echo "")
    
    if echo "$CURRENT_IAM" | grep -q "allUsers" && echo "$CURRENT_IAM" | grep -q "objectViewer"; then
        log_warning "퍼블릭 읽기 권한이 이미 설정되어 있습니다."
    else
        # 버킷에 퍼블릭 읽기 권한 부여
        log_info "버킷에 퍼블릭 읽기 권한을 부여합니다..."
        gsutil iam ch allUsers:objectViewer "gs://$BUCKET_NAME"
    fi
    
    # 권한 확인
    log_info "권한을 확인합니다..."
    gsutil iam get "gs://$BUCKET_NAME"
    
    log_success "퍼블릭 접근 설정이 완료되었습니다."
}

# 7단계: 웹사이트 테스트
test_website() {
    log_info "=== 7단계: 웹사이트 테스트 ==="
    
    # 웹사이트 URL 확인
    log_info "웹사이트 URL을 확인합니다..."
    gsutil web get "gs://$BUCKET_NAME"
    
    # 웹사이트 접속 테스트
    log_info "웹사이트 접속을 테스트합니다..."
    curl -I "http://storage.googleapis.com/$BUCKET_NAME/index.html"
    
    # 웹사이트 내용 확인
    log_info "웹사이트 내용을 확인합니다..."
    curl -s "http://storage.googleapis.com/$BUCKET_NAME/index.html" | head -20
    
    # 404 페이지 테스트
    log_info "404 페이지를 테스트합니다..."
    curl -s "http://storage.googleapis.com/$BUCKET_NAME/nonexistent.html" | head -10
    
    # 웹사이트 성능 테스트
    log_info "웹사이트 성능을 테스트합니다..."
    time curl -s -o /dev/null "http://storage.googleapis.com/$BUCKET_NAME/index.html"
    
    log_success "웹사이트 테스트가 완료되었습니다."
}

# 8단계: 정리 및 모니터링
setup_monitoring() {
    log_info "=== 8단계: 정리 및 모니터링 ==="
    
    # 버킷 사용량 확인
    log_info "버킷 사용량을 확인합니다..."
    gsutil du -sh "gs://$BUCKET_NAME/"
    
    # 버킷 세부 정보
    log_info "버킷 세부 정보를 확인합니다..."
    gsutil ls -L "gs://$BUCKET_NAME/"
    
    # 프로젝트 리소스 확인
    log_info "프로젝트 리소스를 확인합니다..."
    gcloud compute instances list
    gcloud storage buckets list
    
    log_success "모니터링 설정이 완료되었습니다."
}

# 메인 실행 함수
main() {
    log_info "GCP 정적 웹사이트 배포 실습 자동화를 시작합니다..."
    log_info "고유 식별자: $UNIQUE_SUFFIX"
    
    check_gcloud
    check_gcloud_login
    
    setup_gcp_environment
    create_storage_bucket
    setup_website_config
    create_website_files
    upload_files
    setup_public_access
    test_website
    setup_monitoring
    
    log_success "GCP 정적 웹사이트 배포 실습 자동화가 완료되었습니다!"
    log_info "생성된 리소스 정보:"
    log_info "- 프로젝트 ID: $PROJECT_ID"
    log_info "- 버킷 이름: $BUCKET_NAME"
    log_info "- 고유 식별자: $UNIQUE_SUFFIX"
    log_info ""
    log_info "다음 단계:"
    log_info "1. 브라우저에서 웹사이트 접속 확인"
    log_info "2. GCP Console에서 버킷 설정 확인"
    log_info "3. 비용 모니터링 설정 (선택사항)"
    log_info ""
    log_info "웹사이트 URL:"
    log_info "http://storage.googleapis.com/$BUCKET_NAME/index.html"
    log_info "또는"
    log_info "http://$BUCKET_NAME.storage.googleapis.com/index.html"
}

# 스크립트 실행
main "$@"