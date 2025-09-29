#!/bin/bash

# GitHub Actions Helper 모듈
# 역할: GitHub Actions CI/CD 파이프라인 관련 작업 실행 (워크플로우 생성, 테스트, 배포)
# 
# 사용법:
#   ./github-actions-helper.sh --action <액션> [옵션]

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
GitHub Actions Helper 모듈

사용법:
  $0 --action <액션> [옵션]

액션:
  create-workflow      # CI/CD 워크플로우 생성
  setup-secrets        # GitHub Secrets 설정
  test-pipeline        # 파이프라인 테스트
  deploy-app           # 애플리케이션 배포
  cleanup              # 리소스 정리
  status               # 파이프라인 상태 확인

옵션:
  --repository <repo>  # GitHub 저장소 (owner/repo)
  --branch <branch>    # 브랜치 이름 (기본값: main)
  --workflow <name>    # 워크플로우 파일명
  --environment <env>  # 배포 환경 (dev, staging, prod)
  --region <region>    # AWS 리전 (기본값: 환경변수)
  --help, -h           # 도움말 표시

예시:
  $0 --action create-workflow --repository myorg/myapp
  $0 --action setup-secrets --repository myorg/myapp
  $0 --action test-pipeline --repository myorg/myapp
  $0 --action deploy-app --repository myorg/myapp --environment prod
  $0 --action status --repository myorg/myapp
  $0 --action cleanup --repository myorg/myapp
EOF
}

# =============================================================================
# 액션별 상세 사용법 함수
# =============================================================================
show_action_help() {
    local action="$1"
    
    case "$action" in
        "create-workflow")
            cat << EOF
CREATE-WORKFLOW 액션 상세 사용법:

기능:
  - GitHub Actions CI/CD 워크플로우 생성
  - 자동화된 테스트, 빌드, 배포 파이프라인 설정
  - 멀티 환경 지원 (dev, staging, prod)

사용법:
  $0 --action create-workflow [옵션]

옵션:
  --repository <repo>  # GitHub 저장소 (owner/repo)
  --branch <branch>    # 브랜치 이름 (기본값: main)
  --workflow <name>    # 워크플로우 파일명 (기본값: ci-cd.yml)
  --environment <env>  # 배포 환경 (dev, staging, prod)

예시:
  $0 --action create-workflow --repository myorg/myapp
  $0 --action create-workflow --repository myorg/myapp --branch develop
  $0 --action create-workflow --repository myorg/myapp --workflow deploy.yml

생성되는 워크플로우:
  - 자동 테스트 실행
  - Docker 이미지 빌드
  - 보안 스캔
  - 멀티 환경 배포
  - 알림 설정

진행 상황:
  - 워크플로우 파일 생성
  - GitHub 저장소에 푸시
  - 워크플로우 활성화
  - 테스트 실행
EOF
            ;;
        "setup-secrets")
            cat << EOF
SETUP-SECRETS 액션 상세 사용법:

기능:
  - GitHub Secrets 설정
  - AWS 자격 증명 설정
  - 환경별 설정 관리

사용법:
  $0 --action setup-secrets [옵션]

옵션:
  --repository <repo>  # GitHub 저장소 (owner/repo)
  --environment <env>  # 배포 환경 (dev, staging, prod)

예시:
  $0 --action setup-secrets --repository myorg/myapp
  $0 --action setup-secrets --repository myorg/myapp --environment prod

설정되는 Secrets:
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
  - AWS_REGION
  - DOCKER_USERNAME
  - DOCKER_PASSWORD
  - SLACK_WEBHOOK_URL

진행 상황:
  - AWS 자격 증명 확인
  - GitHub Secrets 설정
  - 환경별 설정 적용
  - 설정 검증
EOF
            ;;
        "test-pipeline")
            cat << EOF
TEST-PIPELINE 액션 상세 사용법:

기능:
  - CI/CD 파이프라인 테스트
  - 워크플로우 실행 확인
  - 배포 프로세스 검증

사용법:
  $0 --action test-pipeline [옵션]

옵션:
  --repository <repo>  # GitHub 저장소 (owner/repo)
  --branch <branch>    # 브랜치 이름 (기본값: main)
  --workflow <name>    # 워크플로우 파일명

예시:
  $0 --action test-pipeline --repository myorg/myapp
  $0 --action test-pipeline --repository myorg/myapp --branch develop

테스트되는 기능:
  - 코드 품질 검사
  - 단위 테스트 실행
  - 통합 테스트 실행
  - 보안 스캔
  - 빌드 프로세스

진행 상황:
  - 워크플로우 실행
  - 테스트 결과 확인
  - 오류 분석
  - 보고서 생성
EOF
            ;;
        "deploy-app")
            cat << EOF
DEPLOY-APP 액션 상세 사용법:

기능:
  - 애플리케이션 배포
  - 환경별 배포 설정
  - 배포 상태 모니터링

사용법:
  $0 --action deploy-app [옵션]

옵션:
  --repository <repo>  # GitHub 저장소 (owner/repo)
  --environment <env>  # 배포 환경 (dev, staging, prod)
  --region <region>    # AWS 리전 (기본값: 환경변수)

예시:
  $0 --action deploy-app --repository myorg/myapp --environment dev
  $0 --action deploy-app --repository myorg/myapp --environment prod

배포되는 구성요소:
  - Docker 컨테이너
  - AWS ECS 서비스
  - 로드 밸런서 설정
  - 모니터링 설정

진행 상황:
  - 배포 트리거
  - 배포 상태 확인
  - 헬스 체크
  - 배포 완료 확인
EOF
            ;;
        "cleanup")
            cat << EOF
CLEANUP 액션 상세 사용법:

기능:
  - GitHub Actions 리소스 정리
  - 워크플로우 비활성화
  - 관련 리소스 정리

사용법:
  $0 --action cleanup [옵션]

옵션:
  --repository <repo>  # GitHub 저장소 (owner/repo)
  --workflow <name>    # 정리할 워크플로우 파일명
  --force              # 확인 없이 강제 정리

예시:
  $0 --action cleanup --repository myorg/myapp
  $0 --action cleanup --repository myorg/myapp --force

정리되는 리소스:
  - GitHub Actions 워크플로우
  - GitHub Secrets
  - 관련 리소스

주의사항:
  - 정리된 리소스는 복구할 수 없습니다
  - --force 옵션 사용 시 확인 없이 정리됩니다
EOF
            ;;
        "status")
            cat << EOF
STATUS 액션 상세 사용법:

기능:
  - GitHub Actions 파이프라인 상태 확인
  - 워크플로우 실행 상태 모니터링
  - 배포 상태 확인

사용법:
  $0 --action status [옵션]

옵션:
  --repository <repo>  # GitHub 저장소 (owner/repo)
  --workflow <name>    # 확인할 워크플로우 파일명
  --format <format>    # 출력 형식 (table, json, yaml)

예시:
  $0 --action status --repository myorg/myapp
  $0 --action status --repository myorg/myapp --format json

확인되는 정보:
  - 워크플로우 실행 상태
  - 최근 실행 결과
  - 배포 상태
  - 오류 로그

출력 형식:
  - table: 테이블 형태 (기본값)
  - json: JSON 형태
  - yaml: YAML 형태
EOF
            ;;
        *)
            cat << EOF
알 수 없는 액션: $action

사용 가능한 액션:
  - create-workflow: CI/CD 워크플로우 생성
  - setup-secrets: GitHub Secrets 설정
  - test-pipeline: 파이프라인 테스트
  - deploy-app: 애플리케이션 배포
  - cleanup: 리소스 정리
  - status: 상태 확인

각 액션의 상세 사용법을 보려면:
  $0 --help --action <액션명>
EOF
            ;;
    esac
}

# =============================================================================
# --help 옵션 처리 로직
# =============================================================================
handle_help_option() {
    local action="$1"
    
    if [ -n "$action" ]; then
        show_action_help "$action"
    else
        usage
    fi
    exit 0
}

# =============================================================================
# 환경 검증
# =============================================================================
validate_environment() {
    log_step "GitHub Actions 환경 검증 중..."
    
    # Git 설치 확인
    if ! check_command "git"; then
        log_error "Git이 설치되지 않았습니다."
        return 1
    fi
    
    # GitHub CLI 설치 확인
    if ! check_command "gh"; then
        log_warning "GitHub CLI가 설치되지 않았습니다. 수동 설정이 필요할 수 있습니다."
    fi
    
    # AWS CLI 설치 확인
    if ! check_command "aws"; then
        log_error "AWS CLI가 설치되지 않았습니다."
        return 1
    fi
    
    # AWS 자격 증명 확인
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS 자격 증명이 설정되지 않았습니다."
        return 1
    fi
    
    log_success "GitHub Actions 환경 검증 완료"
    return 0
}

# =============================================================================
# CI/CD 워크플로우 생성
# =============================================================================
create_workflow() {
    local repository="$1"
    local branch="${2:-main}"
    local workflow_name="${3:-ci-cd.yml}"
    local environment="${4:-dev}"
    
    log_header "CI/CD 워크플로우 생성"
    
    if [ -z "$repository" ]; then
        log_error "저장소가 지정되지 않았습니다."
        return 1
    fi
    
    log_info "워크플로우 생성 중... (저장소: $repository, 브랜치: $branch)"
    update_progress "create-workflow" "started" "CI/CD 워크플로우 생성 시작"
    
    # 워크플로우 디렉토리 생성
    local workflow_dir="/tmp/.github/workflows"
    mkdir -p "$workflow_dir"
    
    # CI/CD 워크플로우 파일 생성
    cat > "$workflow_dir/$workflow_name" << EOF
name: CI/CD Pipeline

on:
  push:
    branches: [ $branch ]
  pull_request:
    branches: [ $branch ]

env:
  AWS_REGION: $AWS_REGION
  ECR_REPOSITORY: $repository
  ECS_SERVICE: $repository
  ECS_CLUSTER: $repository-cluster
  ECS_TASK_DEFINITION: $repository-task-definition

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Run linting
        run: npm run lint

      - name: Run security audit
        run: npm audit --audit-level moderate

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: \${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: \${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: \${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build, tag, and push image to Amazon ECR
        id: build-image
        env:
          ECR_REGISTRY: \${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: \${{ github.sha }}
        run: |
          docker build -t \$ECR_REGISTRY/\$ECR_REPOSITORY:\$IMAGE_TAG .
          docker push \$ECR_REGISTRY/\$ECR_REPOSITORY:\$IMAGE_TAG
          echo "image=\$ECR_REGISTRY/\$ECR_REPOSITORY:\$IMAGE_TAG" >> \$GITHUB_OUTPUT

      - name: Download task definition
        run: |
          aws ecs describe-task-definition --task-definition \$ECS_TASK_DEFINITION --query taskDefinition > task-definition.json

      - name: Fill in the new image ID in the Amazon ECS task definition
        id: task-def
        uses: aws-actions/amazon-ecs-render-task-definition@v1
        with:
          task-definition: task-definition.json
          container-name: \$ECS_SERVICE
          image: \${{ steps.build-image.outputs.image }}

      - name: Deploy Amazon ECS task definition
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: \${{ steps.task-def.outputs.task-definition }}
          service: \$ECS_SERVICE
          cluster: \$ECS_CLUSTER
          wait-for-service-stability: true

  notify:
    needs: [test, build]
    runs-on: ubuntu-latest
    if: always()
    steps:
      - name: Notify deployment status
        uses: 8398a7/action-slack@v3
        with:
          status: \${{ job.status }}
          channel: '#deployments'
          webhook_url: \${{ secrets.SLACK_WEBHOOK_URL }}
        if: always()
EOF
    
    # 워크플로우를 GitHub 저장소에 푸시
    if [ -d "/tmp/.github" ]; then
        # 로컬 저장소 클론 (GitHub CLI 사용)
        if command -v gh &> /dev/null; then
            local repo_dir="/tmp/$repository"
            if [ -d "$repo_dir" ]; then
                rm -rf "$repo_dir"
            fi
            
            if gh repo clone "$repository" "$repo_dir"; then
                # .github 디렉토리 복사
                cp -r /tmp/.github "$repo_dir/"
                
                # 변경사항 커밋 및 푸시
                cd "$repo_dir"
                git add .
                git commit -m "Add CI/CD workflow"
                git push origin "$branch"
                
                log_success "워크플로우가 GitHub 저장소에 추가되었습니다"
                update_progress "create-workflow" "completed" "CI/CD 워크플로우 생성 완료"
                
                # 정리
                rm -rf "$repo_dir"
                rm -rf /tmp/.github
                
                return 0
            else
                log_error "GitHub 저장소 클론 실패"
                update_progress "create-workflow" "failed" "GitHub 저장소 클론 실패"
                return 1
            fi
        else
            log_warning "GitHub CLI가 설치되지 않았습니다. 워크플로우 파일을 수동으로 추가하세요:"
            log_info "워크플로우 파일 위치: $workflow_dir/$workflow_name"
            update_progress "create-workflow" "completed" "워크플로우 파일 생성 완료 (수동 추가 필요)"
            return 0
        fi
    else
        log_error "워크플로우 파일 생성 실패"
        update_progress "create-workflow" "failed" "워크플로우 파일 생성 실패"
        return 1
    fi
}

# =============================================================================
# GitHub Secrets 설정
# =============================================================================
setup_secrets() {
    local repository="$1"
    local environment="${2:-dev}"
    
    log_header "GitHub Secrets 설정"
    
    if [ -z "$repository" ]; then
        log_error "저장소가 지정되지 않았습니다."
        return 1
    fi
    
    log_info "GitHub Secrets 설정 중... (저장소: $repository, 환경: $environment)"
    update_progress "setup-secrets" "started" "GitHub Secrets 설정 시작"
    
    # AWS 자격 증명 확인
    local aws_access_key_id
    local aws_secret_access_key
    local aws_region
    
    aws_access_key_id=$(aws configure get aws_access_key_id)
    aws_secret_access_key=$(aws configure get aws_secret_access_key)
    aws_region=$(aws configure get region)
    
    if [ -z "$aws_access_key_id" ] || [ -z "$aws_secret_access_key" ]; then
        log_error "AWS 자격 증명을 찾을 수 없습니다."
        return 1
    fi
    
    # GitHub CLI를 사용하여 Secrets 설정
    if command -v gh &> /dev/null; then
        # AWS 자격 증명 설정
        if echo "$aws_access_key_id" | gh secret set AWS_ACCESS_KEY_ID --repo "$repository"; then
            log_success "AWS_ACCESS_KEY_ID 설정 완료"
        else
            log_error "AWS_ACCESS_KEY_ID 설정 실패"
            return 1
        fi
        
        if echo "$aws_secret_access_key" | gh secret set AWS_SECRET_ACCESS_KEY --repo "$repository"; then
            log_success "AWS_SECRET_ACCESS_KEY 설정 완료"
        else
            log_error "AWS_SECRET_ACCESS_KEY 설정 실패"
            return 1
        fi
        
        if echo "$aws_region" | gh secret set AWS_REGION --repo "$repository"; then
            log_success "AWS_REGION 설정 완료"
        else
            log_error "AWS_REGION 설정 실패"
            return 1
        fi
        
        # Docker Hub 자격 증명 설정 (선택사항)
        if [ -n "$DOCKER_USERNAME" ] && [ -n "$DOCKER_PASSWORD" ]; then
            if echo "$DOCKER_USERNAME" | gh secret set DOCKER_USERNAME --repo "$repository"; then
                log_success "DOCKER_USERNAME 설정 완료"
            fi
            
            if echo "$DOCKER_PASSWORD" | gh secret set DOCKER_PASSWORD --repo "$repository"; then
                log_success "DOCKER_PASSWORD 설정 완료"
            fi
        fi
        
        # Slack 웹훅 URL 설정 (선택사항)
        if [ -n "$SLACK_WEBHOOK_URL" ]; then
            if echo "$SLACK_WEBHOOK_URL" | gh secret set SLACK_WEBHOOK_URL --repo "$repository"; then
                log_success "SLACK_WEBHOOK_URL 설정 완료"
            fi
        fi
        
        log_success "GitHub Secrets 설정 완료"
        update_progress "setup-secrets" "completed" "GitHub Secrets 설정 완료"
        
        return 0
    else
        log_warning "GitHub CLI가 설치되지 않았습니다. 수동으로 Secrets를 설정하세요:"
        log_info "필요한 Secrets:"
        log_info "  - AWS_ACCESS_KEY_ID: $aws_access_key_id"
        log_info "  - AWS_SECRET_ACCESS_KEY: [HIDDEN]"
        log_info "  - AWS_REGION: $aws_region"
        
        update_progress "setup-secrets" "completed" "GitHub Secrets 설정 완료 (수동 설정 필요)"
        return 0
    fi
}

# =============================================================================
# 파이프라인 테스트
# =============================================================================
test_pipeline() {
    local repository="$1"
    local branch="${2:-main}"
    local workflow_name="${3:-ci-cd.yml}"
    
    log_header "파이프라인 테스트"
    
    if [ -z "$repository" ]; then
        log_error "저장소가 지정되지 않았습니다."
        return 1
    fi
    
    log_info "파이프라인 테스트 중... (저장소: $repository, 브랜치: $branch)"
    update_progress "test-pipeline" "started" "파이프라인 테스트 시작"
    
    # GitHub CLI를 사용하여 워크플로우 실행
    if command -v gh &> /dev/null; then
        # 워크플로우 실행
        if gh workflow run "$workflow_name" --repo "$repository" --ref "$branch"; then
            log_success "워크플로우 실행 시작"
            
            # 워크플로우 실행 상태 확인
            log_info "워크플로우 실행 상태 확인 중..."
            local run_id
            run_id=$(gh run list --repo "$repository" --limit 1 --json databaseId --jq '.[0].databaseId')
            
            if [ -n "$run_id" ]; then
                log_info "실행 ID: $run_id"
                
                # 워크플로우 실행 완료 대기
                log_info "워크플로우 실행 완료 대기 중..."
                if gh run watch "$run_id" --repo "$repository"; then
                    log_success "워크플로우 실행 완료"
                    update_progress "test-pipeline" "completed" "파이프라인 테스트 완료"
                    return 0
                else
                    log_error "워크플로우 실행 실패"
                    update_progress "test-pipeline" "failed" "파이프라인 테스트 실패"
                    return 1
                fi
            else
                log_error "워크플로우 실행 ID를 찾을 수 없습니다"
                update_progress "test-pipeline" "failed" "워크플로우 실행 ID 찾기 실패"
                return 1
            fi
        else
            log_error "워크플로우 실행 실패"
            update_progress "test-pipeline" "failed" "워크플로우 실행 실패"
            return 1
        fi
    else
        log_warning "GitHub CLI가 설치되지 않았습니다. 수동으로 워크플로우를 실행하세요:"
        log_info "GitHub 저장소: https://github.com/$repository/actions"
        update_progress "test-pipeline" "completed" "파이프라인 테스트 완료 (수동 실행 필요)"
        return 0
    fi
}

# =============================================================================
# 애플리케이션 배포
# =============================================================================
deploy_app() {
    local repository="$1"
    local environment="${2:-dev}"
    local region="${3:-$AWS_REGION}"
    
    log_header "애플리케이션 배포"
    
    if [ -z "$repository" ]; then
        log_error "저장소가 지정되지 않았습니다."
        return 1
    fi
    
    log_info "애플리케이션 배포 중... (저장소: $repository, 환경: $environment, 리전: $region)"
    update_progress "deploy-app" "started" "애플리케이션 배포 시작"
    
    # ECS 클러스터 확인
    local cluster_name="$repository-cluster"
    if ! aws ecs describe-clusters --clusters "$cluster_name" --region "$region" &> /dev/null; then
        log_info "ECS 클러스터 생성 중..."
        if aws ecs create-cluster --cluster-name "$cluster_name" --region "$region"; then
            log_success "ECS 클러스터 생성 완료: $cluster_name"
        else
            log_error "ECS 클러스터 생성 실패"
            update_progress "deploy-app" "failed" "ECS 클러스터 생성 실패"
            return 1
        fi
    fi
    
    # ECR 저장소 확인
    local ecr_repository="$repository"
    if ! aws ecr describe-repositories --repository-names "$ecr_repository" --region "$region" &> /dev/null; then
        log_info "ECR 저장소 생성 중..."
        if aws ecr create-repository --repository-name "$ecr_repository" --region "$region"; then
            log_success "ECR 저장소 생성 완료: $ecr_repository"
        else
            log_error "ECR 저장소 생성 실패"
            update_progress "deploy-app" "failed" "ECR 저장소 생성 실패"
            return 1
        fi
    fi
    
    # GitHub Actions 워크플로우 실행
    if command -v gh &> /dev/null; then
        log_info "GitHub Actions 워크플로우 실행 중..."
        if gh workflow run "ci-cd.yml" --repo "$repository"; then
            log_success "배포 워크플로우 실행 시작"
            
            # 배포 상태 확인
            log_info "배포 상태 확인 중..."
            local run_id
            run_id=$(gh run list --repo "$repository" --limit 1 --json databaseId --jq '.[0].databaseId')
            
            if [ -n "$run_id" ]; then
                log_info "실행 ID: $run_id"
                
                # 워크플로우 실행 완료 대기
                log_info "배포 완료 대기 중..."
                if gh run watch "$run_id" --repo "$repository"; then
                    log_success "애플리케이션 배포 완료"
                    update_progress "deploy-app" "completed" "애플리케이션 배포 완료"
                    return 0
                else
                    log_error "애플리케이션 배포 실패"
                    update_progress "deploy-app" "failed" "애플리케이션 배포 실패"
                    return 1
                fi
            else
                log_error "워크플로우 실행 ID를 찾을 수 없습니다"
                update_progress "deploy-app" "failed" "워크플로우 실행 ID 찾기 실패"
                return 1
            fi
        else
            log_error "워크플로우 실행 실패"
            update_progress "deploy-app" "failed" "워크플로우 실행 실패"
            return 1
        fi
    else
        log_warning "GitHub CLI가 설치되지 않았습니다. 수동으로 배포하세요:"
        log_info "GitHub 저장소: https://github.com/$repository/actions"
        update_progress "deploy-app" "completed" "애플리케이션 배포 완료 (수동 실행 필요)"
        return 0
    fi
}

# =============================================================================
# 리소스 정리
# =============================================================================
cleanup_resources() {
    local repository="$1"
    local workflow_name="${2:-ci-cd.yml}"
    local force="${3:-false}"
    
    log_header "리소스 정리"
    
    if [ -z "$repository" ]; then
        log_error "저장소가 지정되지 않았습니다."
        return 1
    fi
    
    if [ "$force" != "true" ]; then
        log_warning "정리할 저장소: $repository"
        read -p "정말 정리하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "정리가 취소되었습니다."
            return 0
        fi
    fi
    
    log_info "리소스 정리 중... (저장소: $repository)"
    update_progress "cleanup" "started" "리소스 정리 시작"
    
    # ECS 클러스터 정리
    local cluster_name="$repository-cluster"
    if aws ecs describe-clusters --clusters "$cluster_name" &> /dev/null; then
        log_info "ECS 클러스터 정리 중..."
        if aws ecs delete-cluster --cluster "$cluster_name"; then
            log_success "ECS 클러스터 정리 완료: $cluster_name"
        else
            log_warning "ECS 클러스터 정리 실패: $cluster_name"
        fi
    fi
    
    # ECR 저장소 정리
    local ecr_repository="$repository"
    if aws ecr describe-repositories --repository-names "$ecr_repository" &> /dev/null; then
        log_info "ECR 저장소 정리 중..."
        if aws ecr delete-repository --repository-name "$ecr_repository" --force; then
            log_success "ECR 저장소 정리 완료: $ecr_repository"
        else
            log_warning "ECR 저장소 정리 실패: $ecr_repository"
        fi
    fi
    
    # GitHub Actions 워크플로우 비활성화
    if command -v gh &> /dev/null; then
        log_info "GitHub Actions 워크플로우 비활성화 중..."
        if gh workflow disable "$workflow_name" --repo "$repository"; then
            log_success "워크플로우 비활성화 완료: $workflow_name"
        else
            log_warning "워크플로우 비활성화 실패: $workflow_name"
        fi
    fi
    
    log_success "리소스 정리 완료"
    update_progress "cleanup" "completed" "리소스 정리 완료"
    return 0
}

# =============================================================================
# 파이프라인 상태 확인
# =============================================================================
check_pipeline_status() {
    local repository="$1"
    local workflow_name="${2:-ci-cd.yml}"
    local format="${3:-table}"
    
    log_header "파이프라인 상태 확인"
    
    if [ -z "$repository" ]; then
        log_error "저장소가 지정되지 않았습니다."
        return 1
    fi
    
    log_info "파이프라인 상태 확인 중... (저장소: $repository)"
    
    # GitHub CLI를 사용하여 상태 확인
    if command -v gh &> /dev/null; then
        case "$format" in
            "json")
                gh run list --repo "$repository" --workflow "$workflow_name" --json status,conclusion,createdAt,updatedAt,headBranch,headSha
                ;;
            "yaml")
                gh run list --repo "$repository" --workflow "$workflow_name" --json status,conclusion,createdAt,updatedAt,headBranch,headSha | yq eval -P
                ;;
            *)
                gh run list --repo "$repository" --workflow "$workflow_name" --limit 10
                ;;
        esac
        
        # 최근 실행 상태 확인
        local latest_run
        latest_run=$(gh run list --repo "$repository" --workflow "$workflow_name" --limit 1 --json status,conclusion --jq '.[0]')
        
        if [ -n "$latest_run" ]; then
            log_info "최근 실행 상태:"
            echo "$latest_run" | jq -r 'if .status == "completed" then "✅ " + .conclusion else "🔄 " + .status end'
        fi
        
        update_progress "status" "completed" "파이프라인 상태 확인 완료"
        return 0
    else
        log_warning "GitHub CLI가 설치되지 않았습니다. 수동으로 상태를 확인하세요:"
        log_info "GitHub 저장소: https://github.com/$repository/actions"
        update_progress "status" "completed" "파이프라인 상태 확인 완료 (수동 확인 필요)"
        return 0
    fi
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local action=""
    local repository=""
    local branch="main"
    local workflow_name="ci-cd.yml"
    local environment="dev"
    local region="$AWS_REGION"
    local force="false"
    local format="table"
    
    # 인수 파싱
    while [[ $# -gt 0 ]]; do
        case $1 in
            --action)
                action="$2"
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
            --workflow)
                workflow_name="$2"
                shift 2
                ;;
            --environment)
                environment="$2"
                shift 2
                ;;
            --region)
                region="$2"
                shift 2
                ;;
            --force)
                force="true"
                shift
                ;;
            --format)
                format="$2"
                shift 2
                ;;
            --help|-h)
                # --help 옵션 처리
                if [ "$2" = "--action" ] && [ -n "$3" ]; then
                    handle_help_option "$3"
                else
                    usage
                    exit 0
                fi
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
        "create-workflow")
            create_workflow "$repository" "$branch" "$workflow_name" "$environment"
            ;;
        "setup-secrets")
            setup_secrets "$repository" "$environment"
            ;;
        "test-pipeline")
            test_pipeline "$repository" "$branch" "$workflow_name"
            ;;
        "deploy-app")
            deploy_app "$repository" "$environment" "$region"
            ;;
        "cleanup")
            cleanup_resources "$repository" "$workflow_name" "$force"
            ;;
        "status")
            check_pipeline_status "$repository" "$workflow_name" "$format"
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
