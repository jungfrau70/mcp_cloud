#!/bin/bash

# BigQuery 서버리스 분석 실습 자동화 스크립트
# 실습3: BigQuery 서버리스 분석

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
    local length=${1:-8}
    cat /dev/urandom | tr -dc 'a-z0-9' | fold -w $length | head -n 1
}

# 고유 식별자 생성
UNIQUE_SUFFIX=$(generate_random_string 8)
log_info "고유 식별자 생성: $UNIQUE_SUFFIX"

# 환경 변수 로드
if [ -f ".env" ]; then
    source .env
    log_info "환경 변수를 로드했습니다."
else
    log_warning ".env 파일이 없습니다. 기본값을 사용합니다."
    # 기본값 설정 (고유 식별자 추가)
    PROJECT_ID="my-static-website-$UNIQUE_SUFFIX"
    DATASET_ID="sales_analytics_$UNIQUE_SUFFIX"
    TABLE_NAME="sales"
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

# BigQuery CLI 설치 확인
check_bq() {
    log_info "BigQuery CLI 설치 상태를 확인합니다..."
    if ! command -v bq &> /dev/null; then
        log_error "BigQuery CLI가 설치되지 않았습니다."
        log_info "Google Cloud SDK와 함께 설치됩니다."
        exit 1
    fi
    log_success "BigQuery CLI가 설치되어 있습니다."
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
    
    # 프로젝트 설정
    log_info "프로젝트를 설정합니다: $PROJECT_ID"
    gcloud config set project "$PROJECT_ID"
    
    # 프로젝트 확인
    log_info "현재 프로젝트를 확인합니다..."
    gcloud config get-value project
    
    # BigQuery API 활성화
    log_info "BigQuery API를 활성화합니다..."
    gcloud services enable bigquery.googleapis.com
    
    # BigQuery API 상태 확인
    log_info "BigQuery API 상태를 확인합니다..."
    gcloud services list --enabled --filter="name:bigquery.googleapis.com"
    
    log_success "GCP 환경 준비가 완료되었습니다."
}

# 2단계: BigQuery 데이터셋 생성
create_dataset() {
    log_info "=== 2단계: BigQuery 데이터셋 생성 ==="
    
    # 데이터셋 생성
    log_info "BigQuery 데이터셋을 생성합니다: $DATASET_ID"
    bq mk --location="$LOCATION" "$DATASET_ID"
    
    # 데이터셋 목록 확인
    log_info "데이터셋 목록을 확인합니다..."
    bq ls
    
    # 데이터셋 세부 정보 확인
    log_info "데이터셋 세부 정보를 확인합니다..."
    bq show "$DATASET_ID"
    
    log_success "BigQuery 데이터셋 생성이 완료되었습니다."
}

# 3단계: 샘플 데이터 준비
prepare_sample_data() {
    log_info "=== 3단계: 샘플 데이터 준비 ==="
    
    # 샘플 판매 데이터 CSV 파일 생성
    log_info "샘플 판매 데이터 CSV 파일을 생성합니다..."
    cat > sales_data.csv << 'EOF'
order_id,customer_id,product_id,quantity,unit_price,order_date,region
ORD001,CUST001,PROD001,2,15000.0,2024-01-15,Seoul
ORD002,CUST002,PROD002,1,25000.0,2024-01-16,Busan
ORD003,CUST001,PROD003,3,8000.0,2024-01-17,Seoul
ORD004,CUST003,PROD001,1,15000.0,2024-01-18,Incheon
ORD005,CUST002,PROD004,2,12000.0,2024-01-19,Busan
ORD006,CUST004,PROD002,1,25000.0,2024-01-20,Daegu
ORD007,CUST001,PROD005,4,5000.0,2024-01-21,Seoul
ORD008,CUST003,PROD003,2,8000.0,2024-01-22,Incheon
ORD009,CUST005,PROD001,1,15000.0,2024-01-23,Daejeon
ORD010,CUST002,PROD004,3,12000.0,2024-01-24,Busan
EOF
    
    # 파일 확인
    log_info "생성된 파일을 확인합니다..."
    head -5 sales_data.csv
    
    log_success "샘플 데이터 준비가 완료되었습니다."
}

# 4단계: 테이블 생성 및 데이터 업로드
create_table_and_upload() {
    log_info "=== 4단계: 테이블 생성 및 데이터 업로드 ==="
    
    # 테이블 생성 및 데이터 업로드
    log_info "테이블을 생성하고 데이터를 업로드합니다..."
    bq load \
        --source_format=CSV \
        --autodetect \
        "$DATASET_ID.$TABLE_NAME" \
        sales_data.csv
    
    # 테이블 확인
    log_info "테이블을 확인합니다..."
    bq show "$DATASET_ID.$TABLE_NAME"
    
    # 데이터 확인
    log_info "데이터를 확인합니다..."
    bq query --use_legacy_sql=false \
        "SELECT * FROM $DATASET_ID.$TABLE_NAME LIMIT 5"
    
    log_success "테이블 생성 및 데이터 업로드가 완료되었습니다."
}

# 5단계: 기본 쿼리 실행
run_basic_queries() {
    log_info "=== 5단계: 기본 쿼리 실행 ==="
    
    # 지역별 매출 분석
    log_info "지역별 매출 분석을 실행합니다..."
    bq query --use_legacy_sql=false "
    SELECT 
        region,
        COUNT(*) as order_count,
        SUM(quantity * unit_price) as total_sales
    FROM $DATASET_ID.$TABLE_NAME
    GROUP BY region
    ORDER BY total_sales DESC
    "
    
    # 고객별 주문 분석
    log_info "고객별 주문 분석을 실행합니다..."
    bq query --use_legacy_sql=false "
    SELECT 
        customer_id,
        COUNT(*) as order_count,
        SUM(quantity * unit_price) as total_amount,
        AVG(quantity * unit_price) as avg_order_value
    FROM $DATASET_ID.$TABLE_NAME
    GROUP BY customer_id
    ORDER BY total_amount DESC
    LIMIT 10
    "
    
    log_success "기본 쿼리 실행이 완료되었습니다."
}

# 6단계: 고급 분석 쿼리
run_advanced_queries() {
    log_info "=== 6단계: 고급 분석 쿼리 ==="
    
    # 월별 매출 트렌드 분석
    log_info "월별 매출 트렌드 분석을 실행합니다..."
    bq query --use_legacy_sql=false "
    SELECT 
        EXTRACT(MONTH FROM order_date) as month,
        EXTRACT(YEAR FROM order_date) as year,
        COUNT(*) as order_count,
        SUM(quantity * unit_price) as monthly_sales,
        AVG(quantity * unit_price) as avg_order_value
    FROM $DATASET_ID.$TABLE_NAME
    GROUP BY year, month
    ORDER BY year, month
    "
    
    # 상품별 인기도 분석
    log_info "상품별 인기도 분석을 실행합니다..."
    bq query --use_legacy_sql=false "
    SELECT 
        product_id,
        COUNT(*) as order_count,
        SUM(quantity) as total_quantity,
        SUM(quantity * unit_price) as total_revenue,
        AVG(unit_price) as avg_price
    FROM $DATASET_ID.$TABLE_NAME
    GROUP BY product_id
    ORDER BY total_revenue DESC
    "
    
    # 윈도우 함수를 사용한 순위 분석
    log_info "윈도우 함수를 사용한 순위 분석을 실행합니다..."
    bq query --use_legacy_sql=false "
    SELECT 
        customer_id,
        order_id,
        quantity * unit_price as order_amount,
        RANK() OVER (PARTITION BY customer_id ORDER BY quantity * unit_price DESC) as rank_in_customer,
        RANK() OVER (ORDER BY quantity * unit_price DESC) as overall_rank
    FROM $DATASET_ID.$TABLE_NAME
    ORDER BY customer_id, rank_in_customer
    LIMIT 20
    "
    
    log_success "고급 분석 쿼리 실행이 완료되었습니다."
}

# 7단계: 쿼리 성능 모니터링
monitor_query_performance() {
    log_info "=== 7단계: 쿼리 성능 모니터링 ==="
    
    # 쿼리 실행 시간 및 비용 확인 (dry run)
    log_info "쿼리 실행 시간 및 비용을 확인합니다 (dry run)..."
    bq query --use_legacy_sql=false --dry_run "
    SELECT 
        region,
        COUNT(*) as order_count
    FROM $DATASET_ID.$TABLE_NAME
    GROUP BY region
    "
    
    # 쿼리 히스토리 확인
    log_info "쿼리 히스토리를 확인합니다..."
    bq ls --jobs --max_results=10
    
    log_success "쿼리 성능 모니터링이 완료되었습니다."
}

# 8단계: 데이터 시각화 준비
prepare_visualization() {
    log_info "=== 8단계: 데이터 시각화 준비 ==="
    
    # 쿼리 결과를 JSON으로 내보내기
    log_info "분석 결과를 JSON으로 내보냅니다..."
    bq query --use_legacy_sql=false --format=json "
    SELECT 
        region,
        COUNT(*) as order_count,
        SUM(quantity * unit_price) as total_sales
    FROM $DATASET_ID.$TABLE_NAME
    GROUP BY region
    " > sales_analysis.json
    
    # JSON 파일 확인
    log_info "생성된 JSON 파일을 확인합니다..."
    cat sales_analysis.json
    
    log_success "데이터 시각화 준비가 완료되었습니다."
}

# 9단계: 비용 최적화
optimize_costs() {
    log_info "=== 9단계: 비용 최적화 ==="
    
    # 파티셔닝된 테이블 생성
    log_info "파티셔닝된 테이블을 생성합니다..."
    bq mk --table \
        --schema=sales_schema.json \
        --time_partitioning_type=DAY \
        --time_partitioning_field=order_date \
        "$DATASET_ID.sales_partitioned"
    
    # 클러스터링된 테이블 생성
    log_info "클러스터링된 테이블을 생성합니다..."
    bq mk --table \
        --schema=sales_schema.json \
        --clustering_fields=region,customer_id \
        "$DATASET_ID.sales_clustered"
    
    # 최적화된 쿼리 실행
    log_info "최적화된 쿼리를 실행합니다..."
    bq query --use_legacy_sql=false "
    SELECT 
        region,
        COUNT(*) as order_count
    FROM $DATASET_ID.sales_partitioned
    WHERE order_date >= '2024-01-01'
      AND order_date < '2024-02-01'
    GROUP BY region
    "
    
    log_success "비용 최적화가 완료되었습니다."
}

# 10단계: 머신러닝 모델 생성 (선택사항)
create_ml_model() {
    log_info "=== 10단계: 머신러닝 모델 생성 (선택사항) ==="
    
    # 선형 회귀 모델 생성 (매출 예측)
    log_info "선형 회귀 모델을 생성합니다..."
    bq query --use_legacy_sql=false "
    CREATE OR REPLACE MODEL $DATASET_ID.sales_prediction_model
    OPTIONS(model_type='linear_reg') AS
    SELECT 
        quantity * unit_price as total_amount,
        quantity,
        unit_price,
        EXTRACT(DAYOFWEEK FROM order_date) as day_of_week,
        CASE 
            WHEN region = 'Seoul' THEN 1 ELSE 0 
        END as is_seoul
    FROM $DATASET_ID.$TABLE_NAME
    WHERE order_date >= '2024-01-01'
    "
    
    # 모델 평가
    log_info "모델을 평가합니다..."
    bq query --use_legacy_sql=false "
    SELECT *
    FROM ML.EVALUATE(MODEL $DATASET_ID.sales_prediction_model)
    "
    
    log_success "머신러닝 모델 생성이 완료되었습니다."
}

# 메인 실행 함수
main() {
    log_info "BigQuery 서버리스 분석 실습 자동화를 시작합니다..."
    log_info "고유 식별자: $UNIQUE_SUFFIX"
    
    check_gcloud
    check_bq
    check_gcloud_login
    
    setup_gcp_environment
    create_dataset
    prepare_sample_data
    create_table_and_upload
    run_basic_queries
    run_advanced_queries
    monitor_query_performance
    prepare_visualization
    optimize_costs
    
    # 머신러닝 모델 생성은 선택사항
    read -p "머신러닝 모델을 생성하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_ml_model
    fi
    
    log_success "BigQuery 서버리스 분석 실습 자동화가 완료되었습니다!"
    log_info "생성된 리소스 정보:"
    log_info "- 프로젝트 ID: $PROJECT_ID"
    log_info "- 데이터셋 ID: $DATASET_ID"
    log_info "- 테이블 이름: $TABLE_NAME"
    log_info "- 고유 식별자: $UNIQUE_SUFFIX"
    log_info ""
    log_info "다음 단계:"
    log_info "1. BigQuery 콘솔에서 데이터셋 및 테이블 확인"
    log_info "2. Data Studio/Looker Studio에서 시각화"
    log_info "3. 비용 모니터링 및 최적화"
    log_info "4. 추가 분석 쿼리 실행"
}

# 스크립트 실행
main "$@"
