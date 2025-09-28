#!/bin/bash

# CI/CD Pipeline Helper 모듈
# 역할: GitHub Actions CI/CD 파이프라인 관련 작업 실행
# 
# 사용법:
#   ./cicd-pipeline-helper.sh --action <액션> --provider <프로바이더>

# =============================================================================
# 환경 설정 로드
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 공통 환경 설정 로드
if [ -f "$SCRIPT_DIR/common-environment.env" ]; then
    source "$SCRIPT_DIR/common-environment.env"
else
    echo "ERROR: 공통 환경 설정 파일을 찾을 수 없습니다"
    exit 1
fi

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
CI/CD Pipeline Helper 모듈

사용법:
  $0 --action <액션> [옵션]

액션:
  pipeline-create          # CI/CD 파이프라인 생성
  pipeline-delete          # CI/CD 파이프라인 삭제
  pipeline-status          # 파이프라인 상태 확인
  workflow-test            # 워크플로우 테스트
  deployment               # 배포 실행
  cleanup                  # 전체 정리

옵션:
  --provider <provider>    # 클라우드 프로바이더 (기본값: aws)
  --repository <repo>      # GitHub 저장소 (기본값: 환경변수)
  --branch <branch>        # 브랜치 (기본값: main)
  --help, -h              # 도움말 표시

예시:
  $0 --action pipeline-create
  $0 --action pipeline-status --repository my-repo
  $0 --action deployment --provider aws
EOF
}

# =============================================================================
# 환경 검증
# =============================================================================
validate_environment() {
    log_step "CI/CD 환경 검증 중..."
    
    # GitHub CLI 확인
    if ! check_command "gh"; then
        log_error "GitHub CLI가 설치되지 않았습니다."
        return 1
    fi
    
    # Git 확인
    if ! check_command "git"; then
        log_error "Git이 설치되지 않았습니다."
        return 1
    fi
    
    # GitHub 인증 확인
    if ! gh auth status &> /dev/null; then
        log_error "GitHub 인증이 설정되지 않았습니다."
        return 1
    fi
    
    # 프로바이더별 도구 확인
    case "$provider" in
        "aws")
            if ! check_command "aws"; then
                log_error "AWS CLI가 설치되지 않았습니다."
                return 1
            fi
            if ! aws sts get-caller-identity &> /dev/null; then
                log_error "AWS 자격 증명이 설정되지 않았습니다."
                return 1
            fi
            ;;
        "gcp")
            if ! check_command "gcloud"; then
                log_error "gcloud CLI가 설치되지 않았습니다."
                return 1
            fi
            if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
                log_error "GCP 자격 증명이 설정되지 않았습니다."
                return 1
            fi
            ;;
    esac
    
    log_success "CI/CD 환경 검증 완료"
    return 0
}

# =============================================================================
# GitHub Actions 워크플로우 생성
# =============================================================================
create_workflow() {
    local repository="${1:-$GITHUB_REPO}"
    local branch="${2:-main}"
    
    log_header "GitHub Actions 워크플로우 생성"
    
    # 워크플로우 디렉토리 생성
    local workflow_dir=".github/workflows"
    mkdir -p "$workflow_dir"
    
    # CI/CD 워크플로우 파일 생성
    cat > "$workflow_dir/ci-cd-pipeline.yml" << EOF
name: CI/CD Pipeline

on:
  push:
    branches: [ $branch ]
  pull_request:
    branches: [ $branch ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
      
    - name: Build Docker image
      run: |
        docker build -t cloud-intermediate-app .
        
    - name: Run tests
      run: |
        echo "Running tests..."
        # 테스트 실행 로직
        
  build-and-push:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/$branch'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
      
    - name: Login to Container Registry
      if: \${{ env.PROVIDER == 'aws' }}
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: \${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: \${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: \${{ env.AWS_REGION }}
        
    - name: Login to GCP Container Registry
      if: \${{ env.PROVIDER == 'gcp' }}
      uses: google-github-actions/auth@v2
      with:
        credentials_json: \${{ secrets.GCP_SA_KEY }}
        
    - name: Build and push Docker image
      run: |
        docker build -t \${{ env.REGISTRY }}/\${{ env.IMAGE_NAME }}:\${{ github.sha }} .
        docker push \${{ env.REGISTRY }}/\${{ env.IMAGE_NAME }}:\${{ github.sha }}
        
  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/$branch'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Configure AWS credentials
      if: \${{ env.PROVIDER == 'aws' }}
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: \${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: \${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: \${{ env.AWS_REGION }}
        
    - name: Configure GCP credentials
      if: \${{ env.PROVIDER == 'gcp' }}
      uses: google-github-actions/auth@v2
      with:
        credentials_json: \${{ secrets.GCP_SA_KEY }}
        
    - name: Deploy to AWS EKS
      if: \${{ env.PROVIDER == 'aws' }}
      run: |
        aws eks update-kubeconfig --name \${{ env.EKS_CLUSTER_NAME }} --region \${{ env.AWS_REGION }}
        kubectl set image deployment/cloud-intermediate-app app=\${{ env.REGISTRY }}/\${{ env.IMAGE_NAME }}:\${{ github.sha }}
        
    - name: Deploy to GCP GKE
      if: \${{ env.PROVIDER == 'gcp' }}
      run: |
        gcloud container clusters get-credentials \${{ env.GKE_CLUSTER_NAME }} --zone \${{ env.GCP_ZONE }}
        kubectl set image deployment/cloud-intermediate-app app=\${{ env.REGISTRY }}/\${{ env.IMAGE_NAME }}:\${{ github.sha }}
EOF

    log_success "CI/CD 워크플로우 생성 완료: $workflow_dir/ci-cd-pipeline.yml"
    update_progress "workflow-create" "completed" "CI/CD 워크플로우 생성 완료"
}

# =============================================================================
# GitHub 저장소 설정
# =============================================================================
setup_repository() {
    local repository="${1:-$GITHUB_REPO}"
    
    log_header "GitHub 저장소 설정: $repository"
    
    # 저장소 존재 확인
    if ! gh repo view "$repository" &> /dev/null; then
        log_info "GitHub 저장소 생성 중: $repository"
        gh repo create "$repository" --public --clone
    else
        log_info "기존 저장소 사용: $repository"
        update_progress "repo-check" "existing" "기존 저장소 사용: $repository"
    fi
    
    # 저장소 클론 또는 업데이트
    if [ -d "$repository" ]; then
        log_info "저장소 업데이트 중..."
        cd "$repository"
        git pull origin main
    else
        log_info "저장소 클론 중..."
        gh repo clone "$repository"
        cd "$repository"
    fi
    
    # 워크플로우 생성
    create_workflow "$repository"
    
    # 환경 변수 설정
    setup_environment_variables "$repository"
    
    log_success "GitHub 저장소 설정 완료"
    update_progress "repo-setup" "completed" "GitHub 저장소 설정 완료"
}

# =============================================================================
# 환경 변수 설정
# =============================================================================
setup_environment_variables() {
    local repository="${1:-$GITHUB_REPO}"
    
    log_step "GitHub Secrets 설정"
    
    # AWS Secrets 설정
    if [ "$provider" = "aws" ]; then
        gh secret set AWS_ACCESS_KEY_ID --repo "$repository" --body "$AWS_ACCESS_KEY_ID"
        gh secret set AWS_SECRET_ACCESS_KEY --repo "$repository" --body "$AWS_SECRET_ACCESS_KEY"
        gh secret set AWS_REGION --repo "$repository" --body "$AWS_REGION"
        gh secret set EKS_CLUSTER_NAME --repo "$repository" --body "$EKS_CLUSTER_NAME"
        log_success "AWS Secrets 설정 완료"
    fi
    
    # GCP Secrets 설정
    if [ "$provider" = "gcp" ]; then
        gh secret set GCP_SA_KEY --repo "$repository" --body "$GCP_SA_KEY"
        gh secret set GCP_PROJECT_ID --repo "$repository" --body "$GCP_PROJECT_ID"
        gh secret set GCP_REGION --repo "$repository" --body "$GCP_REGION"
        gh secret set GKE_CLUSTER_NAME --repo "$repository" --body "$GKE_CLUSTER_NAME"
        log_success "GCP Secrets 설정 완료"
    fi
    
    update_progress "secrets-setup" "completed" "GitHub Secrets 설정 완료"
}

# =============================================================================
# 파이프라인 상태 확인
# =============================================================================
check_pipeline_status() {
    local repository="${1:-$GITHUB_REPO}"
    
    log_header "CI/CD 파이프라인 상태 확인: $repository"
    
    # 최근 워크플로우 실행 상태 확인
    local runs=$(gh run list --repo "$repository" --limit 5)
    
    if [ -n "$runs" ]; then
        log_info "최근 워크플로우 실행 상태:"
        echo "$runs"
        
        # 최신 실행 상태 확인
        local latest_status=$(gh run list --repo "$repository" --limit 1 --json status,conclusion --jq '.[0].status')
        local latest_conclusion=$(gh run list --repo "$repository" --limit 1 --json status,conclusion --jq '.[0].conclusion')
        
        log_info "최신 실행 상태: $latest_status"
        log_info "최신 실행 결과: $latest_conclusion"
        
        if [ "$latest_status" = "completed" ] && [ "$latest_conclusion" = "success" ]; then
            log_success "✅ 파이프라인이 성공적으로 완료되었습니다"
        elif [ "$latest_status" = "completed" ] && [ "$latest_conclusion" = "failure" ]; then
            log_error "❌ 파이프라인이 실패했습니다"
        else
            log_info "🔄 파이프라인이 실행 중입니다"
        fi
    else
        log_warning "워크플로우 실행 기록이 없습니다"
    fi
    
    update_progress "pipeline-status" "completed" "파이프라인 상태 확인 완료"
}

# =============================================================================
# 워크플로우 테스트
# =============================================================================
test_workflow() {
    local repository="${1:-$GITHUB_REPO}"
    
    log_header "워크플로우 테스트 실행: $repository"
    
    # 테스트용 커밋 생성
    log_info "테스트용 파일 생성 중..."
    echo "# CI/CD Pipeline Test" > test-pipeline.md
    echo "This is a test commit to trigger the CI/CD pipeline." >> test-pipeline.md
    
    # Git 설정
    git config user.name "CI/CD Bot"
    git config user.email "cicd-bot@example.com"
    
    # 커밋 및 푸시
    git add test-pipeline.md
    git commit -m "test: Trigger CI/CD pipeline"
    git push origin main
    
    log_success "테스트 커밋 푸시 완료"
    log_info "GitHub Actions에서 워크플로우 실행을 확인하세요"
    
    update_progress "workflow-test" "completed" "워크플로우 테스트 실행 완료"
}

# =============================================================================
# 배포 실행
# =============================================================================
execute_deployment() {
    local repository="${1:-$GITHUB_REPO}"
    
    log_header "배포 실행: $repository"
    
    # 배포용 태그 생성
    local tag="v$(date +%Y%m%d-%H%M%S)"
    
    log_info "배포 태그 생성: $tag"
    git tag "$tag"
    git push origin "$tag"
    
    # 수동 배포 트리거
    log_info "수동 배포 워크플로우 실행 중..."
    gh workflow run "CI/CD Pipeline" --repo "$repository" --ref main
    
    log_success "배포 실행 완료"
    log_info "GitHub Actions에서 배포 진행 상황을 확인하세요"
    
    update_progress "deployment" "completed" "배포 실행 완료"
}

# =============================================================================
# 전체 정리
# =============================================================================
cleanup_all() {
    log_header "CI/CD 환경 전체 정리"
    
    local repository="${1:-$GITHUB_REPO}"
    
    # 워크플로우 파일 삭제
    if [ -f ".github/workflows/ci-cd-pipeline.yml" ]; then
        rm -f ".github/workflows/ci-cd-pipeline.yml"
        log_info "워크플로우 파일 삭제 완료"
    fi
    
    # 테스트 파일 삭제
    if [ -f "test-pipeline.md" ]; then
        rm -f "test-pipeline.md"
        git add test-pipeline.md
        git commit -m "cleanup: Remove test files"
        git push origin main
        log_info "테스트 파일 정리 완료"
    fi
    
    update_progress "cleanup" "completed" "CI/CD 환경 정리 완료"
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local action=""
    local provider="aws"
    local repository="$GITHUB_REPO"
    local branch="main"
    
    # 인수 파싱
    while [[ $# -gt 0 ]]; do
        case $1 in
            --action)
                action="$2"
                shift 2
                ;;
            --provider)
                provider="$2"
                shift 2
                ;;
            --repository)
                repository="$2"
                shift 2
                ;;
            --branch)
                branch="$2"
                shift 2
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # 액션이 지정되지 않은 경우
    if [ -z "$action" ]; then
        log_error "액션이 지정되지 않았습니다."
        usage
        exit 1
    fi
    
    # 환경 검증
    if ! validate_environment; then
        log_error "환경 검증 실패"
        exit 1
    fi
    
    # 액션 실행
    case "$action" in
        "pipeline-create")
            setup_repository "$repository"
            ;;
        "pipeline-delete")
            cleanup_all "$repository"
            ;;
        "pipeline-status")
            check_pipeline_status "$repository"
            ;;
        "workflow-test")
            test_workflow "$repository"
            ;;
        "deployment")
            execute_deployment "$repository"
            ;;
        "cleanup")
            cleanup_all "$repository"
            ;;
        "cicd-pipeline")
            # 메뉴에서 호출되는 통합 액션
            setup_repository "$repository"
            test_workflow "$repository"
            check_pipeline_status "$repository"
            ;;
        *)
            log_error "알 수 없는 액션: $action"
            usage
            exit 1
            ;;
    esac
    
    # 실행 요약 보고
    generate_summary
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
