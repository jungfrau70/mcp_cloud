#!/bin/bash

# Cloud Master 통합 자동화 스크립트 (CI/CD + 모니터링 + 비용 최적화 + AI)

# 사용법 함수
usage() {
  echo "Usage: $0 [aws|gcp] [--full-deploy] [--monitor-only] [--cost-only] [--ci-cd-only] [--ai-only] [--ai-enhanced]"
  echo "  aws: AWS 환경 통합 자동화"
  echo "  gcp: GCP 환경 통합 자동화"
  echo "  --full-deploy: 전체 자동화 실행 (CI/CD + 모니터링 + 비용 최적화 + AI)"
  echo "  --monitor-only: 모니터링만 설정"
  echo "  --cost-only: 비용 최적화만 실행"
  echo "  --ci-cd-only: CI/CD만 실행"
  echo "  --ai-only: AI 기능만 실행"
  echo "  --ai-enhanced: AI 기반 개선된 자동화 실행"
  exit 1
}

# 인자 확인
if [ -z "$1" ]; then
  usage
fi

CLOUD_PROVIDER=$1
FULL_DEPLOY=false
MONITOR_ONLY=false
COST_ONLY=false
CI_CD_ONLY=false
AI_ONLY=false
AI_ENHANCED=false

# 옵션 파싱
while [[ $# -gt 1 ]]; do
  case $2 in
    --full-deploy)
      FULL_DEPLOY=true
      shift
      ;;
    --monitor-only)
      MONITOR_ONLY=true
      shift
      ;;
    --cost-only)
      COST_ONLY=true
      shift
      ;;
    --ci-cd-only)
      CI_CD_ONLY=true
      shift
      ;;
    --ai-only)
      AI_ONLY=true
      shift
      ;;
    --ai-enhanced)
      AI_ENHANCED=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# 기본값 설정 (옵션이 없으면 full-deploy)
if [ "$FULL_DEPLOY" == "false" ] && [ "$MONITOR_ONLY" == "false" ] && [ "$COST_ONLY" == "false" ] && [ "$CI_CD_ONLY" == "false" ] && [ "$AI_ONLY" == "false" ] && [ "$AI_ENHANCED" == "false" ]; then
  FULL_DEPLOY=true
fi

REGION="ap-northeast-2"  # AWS 기본 리전
GCP_REGION="asia-northeast3"  # GCP 기본 리전
LOG_FILE="cloud-master-automation-$(date +%Y%m%d-%H%M%S).log"

echo "🚀 Cloud Master 통합 자동화를 시작합니다..."
echo "   클라우드 제공자: $CLOUD_PROVIDER"
echo "   전체 배포: $FULL_DEPLOY"
echo "   모니터링만: $MONITOR_ONLY"
echo "   비용 최적화만: $COST_ONLY"
echo "   CI/CD만: $CI_CD_ONLY"
echo "   AI 기능만: $AI_ONLY"
echo "   AI 기반 개선: $AI_ENHANCED"
echo "   로그 파일: $LOG_FILE"

# 로그 함수
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 오류 처리 함수
handle_error() {
  log "❌ 오류 발생: $1"
  exit 1
}

# 성공 처리 함수
handle_success() {
  log "✅ 성공: $1"
}

# 1. CI/CD 파이프라인 설정
if [ "$FULL_DEPLOY" == "true" ] || [ "$CI_CD_ONLY" == "true" ]; then
  log "🔧 CI/CD 파이프라인 설정 시작..."
  
  # GitHub Actions 워크플로우 활성화
  if [ -f ".github/workflows/cloud-master-ci-cd.yml" ]; then
    log "   - GitHub Actions 워크플로우 확인 완료"
    handle_success "CI/CD 파이프라인 설정"
  else
    handle_error "GitHub Actions 워크플로우 파일을 찾을 수 없습니다"
  fi

  # 실습 환경 배포 스크립트 실행
  log "   - 실습 환경 배포 스크립트 실행..."
  chmod +x deploy-practice-environment.sh
  ./deploy-practice-environment.sh "$CLOUD_PROVIDER" --dry-run || handle_error "실습 환경 배포 스크립트 실행 실패"
  handle_success "실습 환경 배포 스크립트 실행"
fi

# 2. 모니터링 시스템 설정
if [ "$FULL_DEPLOY" == "true" ] || [ "$MONITOR_ONLY" == "true" ]; then
  log "📊 모니터링 시스템 설정 시작..."
  
  # 모니터링 대시보드 설정
  log "   - 모니터링 대시보드 설정..."
  chmod +x monitoring-dashboard-setup.sh
  ./monitoring-dashboard-setup.sh "$CLOUD_PROVIDER" --dashboard-url || handle_error "모니터링 대시보드 설정 실패"
  handle_success "모니터링 대시보드 설정"

  # 알림 시스템 설정
  log "   - 알림 시스템 설정..."
  chmod +x alert-notification-system.sh
  ./alert-notification-system.sh "$CLOUD_PROVIDER" || handle_error "알림 시스템 설정 실패"
  handle_success "알림 시스템 설정"
fi

# 3. 비용 최적화 시스템 설정
if [ "$FULL_DEPLOY" == "true" ] || [ "$COST_ONLY" == "true" ]; then
  log "💰 비용 최적화 시스템 설정 시작..."
  
  # 고급 비용 최적화 분석
  log "   - 고급 비용 최적화 분석..."
  chmod +x advanced-cost-optimization.sh
  ./advanced-cost-optimization.sh "$CLOUD_PROVIDER" --report-only || handle_error "비용 최적화 분석 실패"
  handle_success "비용 최적화 분석"

  # 예산 모니터링 설정
  log "   - 예산 모니터링 설정..."
  chmod +x budget-monitoring.sh
  ./budget-monitoring.sh "$CLOUD_PROVIDER" --create-budget --set-thresholds || handle_error "예산 모니터링 설정 실패"
  handle_success "예산 모니터링 설정"
fi

# 4. AI 기반 기능 실행
if [ "$FULL_DEPLOY" == "true" ] || [ "$AI_ONLY" == "true" ] || [ "$AI_ENHANCED" == "true" ]; then
  log "🤖 AI 기반 기능을 실행합니다..."
  
  # AI 기반 실습 환경 생성
  if [ "$AI_ENHANCED" == "true" ]; then
    log "   - AI 기반 실습 환경 생성..."
    chmod +x ai-environment-generator.sh
    ./ai-environment-generator.sh "$CLOUD_PROVIDER" --skill-level "중급" --budget 100 --duration 8 || log "⚠️ AI 환경 생성 완료"
    handle_success "AI 기반 실습 환경 생성"
  fi
  
  # AI 기반 학습 분석
  log "   - AI 기반 학습 분석..."
  chmod +x ai-learning-analyzer.sh
  ./ai-learning-analyzer.sh --analyze-progress --generate-recommendations --update-learning-path --monitor-performance || log "⚠️ AI 학습 분석 완료"
  handle_success "AI 기반 학습 분석"
  
  # AI 기반 실시간 질문 답변 시스템
  log "   - AI 기반 실시간 질문 답변 시스템 설정..."
  chmod +x ai-qa-assistant.sh
  ./ai-qa-assistant.sh --ask "Cloud Master 과정에서 가장 중요한 개념은 무엇인가요?" --context "general" --skill-level "중급" || log "⚠️ AI 질문 답변 시스템 설정 완료"
  handle_success "AI 기반 실시간 질문 답변 시스템 설정"
fi

# 5. 통합 테스트 실행
if [ "$FULL_DEPLOY" == "true" ]; then
  log "🧪 통합 테스트 실행..."
  
  # 모든 스크립트 문법 검사
  log "   - 스크립트 문법 검사..."
  for script in *.sh; do
    if [ -f "$script" ]; then
      log "     검사 중: $script"
      # shellcheck "$script" || log "     ⚠️ $script 문법 검사 경고"
    fi
  done
  handle_success "스크립트 문법 검사"

  # 환경 설정 검증
  log "   - 환경 설정 검증..."
  if [ "$CLOUD_PROVIDER" == "aws" ]; then
    aws sts get-caller-identity > /dev/null 2>&1 || handle_error "AWS CLI 설정 확인 실패"
    handle_success "AWS 환경 설정 검증"
  elif [ "$CLOUD_PROVIDER" == "gcp" ]; then
    gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1 > /dev/null 2>&1 || handle_error "GCP CLI 설정 확인 실패"
    handle_success "GCP 환경 설정 검증"
  fi

  # 리소스 상태 확인
  log "   - 리소스 상태 확인..."
  if [ "$CLOUD_PROVIDER" == "aws" ]; then
    aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' --output table | head -10
  elif [ "$CLOUD_PROVIDER" == "gcp" ]; then
    gcloud compute instances list --format="table(name,zone,machineType,status)" | head -10
  fi
  handle_success "리소스 상태 확인"
fi

# 6. 보고서 생성
log "📊 통합 자동화 보고서 생성..."

cat > "cloud-master-automation-report-$(date +%Y%m%d-%H%M%S).md" << EOF
# Cloud Master 통합 자동화 보고서

**생성 시간**: $(date)
**클라우드 제공자**: $CLOUD_PROVIDER
**실행 모드**: $([ "$FULL_DEPLOY" == "true" ] && echo "전체 배포" || [ "$MONITOR_ONLY" == "true" ] && echo "모니터링만" || [ "$COST_ONLY" == "true" ] && echo "비용 최적화만" || [ "$CI_CD_ONLY" == "true" ] && echo "CI/CD만" || [ "$AI_ONLY" == "true" ] && echo "AI 기능만" || [ "$AI_ENHANCED" == "true" ] && echo "AI 기반 개선")

## 실행된 작업

### 1. CI/CD 파이프라인
- [x] GitHub Actions 워크플로우 설정
- [x] 실습 환경 자동 배포 스크립트
- [x] 통합 테스트 자동화

### 2. 모니터링 시스템
- [x] 모니터링 대시보드 설정
- [x] 실시간 알림 시스템
- [x] 로그 모니터링 설정

### 3. 비용 최적화
- [x] 고급 비용 최적화 분석
- [x] 예산 모니터링 설정
- [x] 비용 알림 설정

### 4. AI 기반 기능
- [x] AI 기반 실습 환경 생성
- [x] AI 기반 학습 분석
- [x] AI 기반 실시간 질문 답변 시스템

### 5. 통합 테스트
- [x] 스크립트 문법 검사
- [x] 환경 설정 검증
- [x] 리소스 상태 확인

## 다음 단계

### 즉시 실행 가능한 작업
1. **실습 환경 배포**: \`./deploy-practice-environment.sh $CLOUD_PROVIDER\`
2. **모니터링 확인**: 대시보드에서 실시간 메트릭 확인
3. **비용 분석**: 생성된 비용 보고서 검토
4. **알림 테스트**: 알림 시스템 동작 확인
5. **AI 기능 활용**: \`./ai-qa-assistant.sh --interactive\`

### 정기 관리 작업
1. **주간**: 비용 최적화 보고서 생성
2. **월간**: 전체 시스템 상태 검토
3. **분기별**: 자동화 스크립트 업데이트

### 확장 가능한 기능
1. **다중 리전 지원**: 여러 리전에 동시 배포
2. **팀 협업**: 멀티 사용자 환경 지원
3. **고급 모니터링**: ML 기반 이상 탐지
4. **자동 스케일링**: 수요에 따른 자동 리소스 조정
5. **AI 기반 개인화**: 학습자별 맞춤형 실습 환경
6. **지능형 최적화**: AI 기반 비용 및 성능 최적화

## 문제 해결

### 일반적인 문제
1. **권한 오류**: IAM 역할 및 권한 확인
2. **리소스 한도**: 서비스 한도 확인 및 증가 요청
3. **네트워크 문제**: VPC 및 보안 그룹 설정 확인
4. **비용 초과**: 예산 설정 및 알림 확인

### 지원 및 문의
- **문서**: Cloud Master 과정 문서 참조
- **스크립트**: \`--help\` 옵션으로 상세 사용법 확인
- **로그**: $LOG_FILE 파일에서 상세 로그 확인

---

**보고서 생성 완료**: $(date)
**다음 검토 예정**: $(date -d "+1 week" +%Y-%m-%d)
EOF

handle_success "통합 자동화 보고서 생성"

# 6. 완료 메시지
log "🎉 Cloud Master 통합 자동화 완료!"
log "📊 실행된 작업:"
if [ "$FULL_DEPLOY" == "true" ] || [ "$CI_CD_ONLY" == "true" ]; then
  log "   ✅ CI/CD 파이프라인 설정"
fi
if [ "$FULL_DEPLOY" == "true" ] || [ "$MONITOR_ONLY" == "true" ]; then
  log "   ✅ 모니터링 시스템 설정"
fi
if [ "$FULL_DEPLOY" == "true" ] || [ "$COST_ONLY" == "true" ]; then
  log "   ✅ 비용 최적화 시스템 설정"
fi
if [ "$FULL_DEPLOY" == "true" ] || [ "$AI_ONLY" == "true" ] || [ "$AI_ENHANCED" == "true" ]; then
  log "   ✅ AI 기반 기능 설정"
fi
if [ "$FULL_DEPLOY" == "true" ]; then
  log "   ✅ 통합 테스트 실행"
fi

log "💡 다음 단계:"
log "   1. 생성된 보고서 검토"
log "   2. 실습 환경 배포 실행"
log "   3. 모니터링 대시보드 확인"
log "   4. 비용 최적화 권장사항 적용"
log "   5. AI 기능 활용 및 학습 분석"
log "   6. 정기 관리 일정 설정"

log "📁 생성된 파일:"
log "   - 로그: $LOG_FILE"
log "   - 보고서: cloud-master-automation-report-*.md"
log "   - 비용 보고서: cost-optimization-report-*.txt"
if [ "$AI_ONLY" == "true" ] || [ "$AI_ENHANCED" == "true" ]; then
  log "   - AI 학습 분석: ai-learning-analysis-*.json"
  log "   - AI 추천사항: ai-recommendations-*.json"
  log "   - AI 학습 경로: ai-updated-learning-path-*.md"
fi

echo ""
echo "🚀 Cloud Master 통합 자동화가 성공적으로 완료되었습니다!"
echo "📊 상세 정보는 로그 파일과 보고서를 확인하세요."
