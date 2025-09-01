#!/bin/bash

# AWS 서버리스 투자 제안 심사 시스템 실습 자동화 스크립트
# 실습4: AWS 서버리스 투자 제안 심사 시스템

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
    PROJECT_NAME="investment-proposal-system-$UNIQUE_SUFFIX"
    BUCKET_NAME="investment-proposals-docs-$UNIQUE_SUFFIX"
    TABLE_NAME="InvestmentProposals-$UNIQUE_SUFFIX"
    LOCATION="ap-northeast-2"
    LAMBDA_RUNTIME="python3.9"
fi

# AWS CLI 설치 확인
check_aws_cli() {
    log_info "AWS CLI 설치 상태를 확인합니다..."
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI가 설치되지 않았습니다."
        log_info "설치 방법:"
        log_info "Windows: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html"
        log_info "macOS: brew install awscli"
        log_info "Ubuntu: sudo apt install awscli"
        exit 1
    fi
    log_success "AWS CLI가 설치되어 있습니다."
}

# AWS 로그인 확인
check_aws_login() {
    log_info "AWS 로그인 상태를 확인합니다..."
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS에 로그인되지 않았습니다."
        log_info "다음 명령어로 로그인하세요: aws configure"
        exit 1
    fi
    log_success "AWS에 로그인되어 있습니다."
}

# 1단계: AWS 환경 준비
setup_aws_environment() {
    log_info "=== 1단계: AWS 환경 준비 ==="
    
    # AWS 계정 ID 확인
    log_info "AWS 계정 ID를 확인합니다..."
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    echo "Account ID: $ACCOUNT_ID"
    
    # 리전 설정
    log_info "리전을 설정합니다: $LOCATION"
    aws configure set region "$LOCATION"
    
    # 현재 리전 확인
    log_info "현재 리전을 확인합니다..."
    aws configure get region
    
    log_success "AWS 환경 준비가 완료되었습니다."
}

# 2단계: DynamoDB 테이블 생성
create_dynamodb_table() {
    log_info "=== 2단계: DynamoDB 테이블 생성 ==="
    
    # DynamoDB 테이블 존재 여부 확인
    log_info "DynamoDB 테이블 존재 여부를 확인합니다: $TABLE_NAME"
    if aws dynamodb describe-table --table-name "$TABLE_NAME" &> /dev/null; then
        log_warning "DynamoDB 테이블이 이미 존재합니다: $TABLE_NAME"
        log_info "기존 테이블을 사용합니다."
    else
        # DynamoDB 테이블 정의 JSON 파일 생성
        log_info "DynamoDB 테이블 정의를 생성합니다..."
        cat > dynamodb-table.json << 'EOF'
{
  "TableName": "TABLE_NAME_PLACEHOLDER",
  "KeySchema": [
    {
      "AttributeName": "proposal_id",
      "KeyType": "HASH"
    }
  ],
  "AttributeDefinitions": [
    {
      "AttributeName": "proposal_id",
      "AttributeType": "S"
    },
    {
      "AttributeName": "status",
      "AttributeType": "S"
    },
    {
      "AttributeName": "created_date",
      "AttributeType": "S"
    }
  ],
  "GlobalSecondaryIndexes": [
    {
      "IndexName": "StatusIndex",
      "KeySchema": [
        {
          "AttributeName": "status",
          "KeyType": "HASH"
        },
        {
          "AttributeName": "created_date",
          "KeyType": "RANGE"
        }
      ],
      "Projection": {
        "ProjectionType": "ALL"
      },
      "ProvisionedThroughput": {
        "ReadCapacityUnits": 5,
        "WriteCapacityUnits": 5
      }
    }
  ],
  "ProvisionedThroughput": {
    "ReadCapacityUnits": 5,
    "WriteCapacityUnits": 5
  }
}
EOF
        
        # 테이블 이름 치환
        sed -i "s/TABLE_NAME_PLACEHOLDER/$TABLE_NAME/g" dynamodb-table.json
        
        # DynamoDB 테이블 생성
        log_info "DynamoDB 테이블을 생성합니다: $TABLE_NAME"
        aws dynamodb create-table --cli-input-json file://dynamodb-table.json
    fi
    
    # 테이블 상태 확인
    log_info "테이블 상태를 확인합니다..."
    aws dynamodb describe-table --table-name "$TABLE_NAME" --query 'Table.TableStatus'
    
    # 테이블이 활성화될 때까지 대기
    log_info "테이블이 활성화될 때까지 대기합니다..."
    aws dynamodb wait table-exists --table-name "$TABLE_NAME"
    
    log_success "DynamoDB 테이블 생성이 완료되었습니다."
}

# 3단계: S3 버킷 생성
create_s3_bucket() {
    log_info "=== 3단계: S3 버킷 생성 ==="
    
    # S3 버킷 존재 여부 확인
    log_info "S3 버킷 존재 여부를 확인합니다: $BUCKET_NAME"
    if aws s3 ls "s3://$BUCKET_NAME" &> /dev/null; then
        log_warning "S3 버킷이 이미 존재합니다: $BUCKET_NAME"
        log_info "기존 버킷을 사용합니다."
    else
        # S3 버킷 생성
        log_info "S3 버킷을 생성합니다: $BUCKET_NAME"
        aws s3 mb "s3://$BUCKET_NAME" --region "$LOCATION"
    fi
    
    # 버킷 목록 확인
    log_info "버킷 목록을 확인합니다..."
    aws s3 ls
    
    # 버킷 정책 존재 여부 확인
    log_info "버킷 정책 존재 여부를 확인합니다..."
    if aws s3api get-bucket-policy --bucket "$BUCKET_NAME" &> /dev/null; then
        log_warning "버킷 정책이 이미 설정되어 있습니다."
    else
        # 버킷 정책 설정
        log_info "버킷 정책을 설정합니다..."
        cat > bucket-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowLambdaAccess",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::BUCKET_NAME_PLACEHOLDER/*"
    }
  ]
}
EOF
        
        # BUCKET_NAME 치환
        sed -i "s/BUCKET_NAME_PLACEHOLDER/$BUCKET_NAME/g" bucket-policy.json
        
        # 정책 적용
        aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy file://bucket-policy.json
    fi
    
    log_success "S3 버킷 생성이 완료되었습니다."
}

# 4단계: Lambda 함수 개발
create_lambda_functions() {
    log_info "=== 4단계: Lambda 함수 개발 ==="
    
    # 작업 디렉토리 생성
    if [ ! -d "lambda-functions" ]; then
        mkdir -p lambda-functions
    fi
    cd lambda-functions
    
    # 제안 업로드 Lambda 함수 존재 여부 확인
    if [ -f "proposal_upload.py" ]; then
        log_warning "proposal_upload.py 파일이 이미 존재합니다."
        log_info "기존 파일을 사용합니다."
    else
        # 제안 업로드 Lambda 함수 생성
        log_info "제안 업로드 Lambda 함수를 생성합니다..."
        cat > proposal_upload.py << 'EOF'
import json
import boto3
import uuid
from datetime import datetime
import base64

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')
table = dynamodb.Table('TABLE_NAME_PLACEHOLDER')

def lambda_handler(event, context):
    try:
        # 요청 본문 파싱
        body = json.loads(event['body'])
        
        # 제안 ID 생성
        proposal_id = str(uuid.uuid4())
        
        # 제안 데이터 준비
        proposal_data = {
            'proposal_id': proposal_id,
            'company_name': body.get('company_name'),
            'investment_amount': body.get('investment_amount'),
            'business_description': body.get('business_description'),
            'expected_return': body.get('expected_return'),
            'risk_level': body.get('risk_level'),
            'status': 'PENDING',
            'created_date': datetime.now().isoformat(),
            'updated_date': datetime.now().isoformat()
        }
        
        # DynamoDB에 저장
        table.put_item(Item=proposal_data)
        
        # S3에 문서 저장 (있는 경우)
        if 'document' in body:
            document_content = base64.b64decode(body['document'])
            s3.put_object(
                Bucket='BUCKET_NAME_PLACEHOLDER',
                Key=f'documents/{proposal_id}.pdf',
                Body=document_content
            )
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Investment proposal uploaded successfully',
                'proposal_id': proposal_id
            })
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e)
            })
        }
EOF
        
        # 테이블 이름과 버킷 이름 치환
        sed -i "s/TABLE_NAME_PLACEHOLDER/$TABLE_NAME/g" proposal_upload.py
        sed -i "s/BUCKET_NAME_PLACEHOLDER/$BUCKET_NAME/g" proposal_upload.py
    fi
    
    # 제안 분석 Lambda 함수 존재 여부 확인
    if [ -f "proposal_analysis.py" ]; then
        log_warning "proposal_analysis.py 파일이 이미 존재합니다."
        log_info "기존 파일을 사용합니다."
    else
        # 제안 분석 Lambda 함수 생성
        log_info "제안 분석 Lambda 함수를 생성합니다..."
        cat > proposal_analysis.py << 'EOF'
import json
import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('TABLE_NAME_PLACEHOLDER')

def lambda_handler(event, context):
    try:
        # 제안 ID 추출
        proposal_id = event['proposal_id']
        
        # DynamoDB에서 제안 데이터 조회
        response = table.get_item(Key={'proposal_id': proposal_id})
        proposal = response['Item']
        
        # 분석 로직
        analysis_result = analyze_proposal(proposal)
        
        # 분석 결과 저장
        table.update_item(
            Key={'proposal_id': proposal_id},
            UpdateExpression='SET analysis_result = :result, updated_date = :date',
            ExpressionAttributeValues={
                ':result': analysis_result,
                ':date': datetime.now().isoformat()
            }
        )
        
        return {
            'proposal_id': proposal_id,
            'analysis_result': analysis_result
        }
        
    except Exception as e:
        raise Exception(f"Analysis failed: {str(e)}")

def analyze_proposal(proposal):
    # 간단한 분석 로직
    investment_amount = float(proposal['investment_amount'])
    expected_return = float(proposal['expected_return'])
    risk_level = proposal['risk_level']
    
    # 위험도별 승인 기준
    risk_thresholds = {
        'LOW': 0.05,
        'MEDIUM': 0.10,
        'HIGH': 0.15
    }
    
    threshold = risk_thresholds.get(risk_level, 0.10)
    roi = expected_return / investment_amount
    
    if roi >= threshold:
        return {
            'status': 'APPROVED',
            'score': min(100, int(roi * 1000)),
            'reason': f'ROI {roi:.2%} meets threshold {threshold:.2%}'
        }
    else:
        return {
            'status': 'REJECTED',
            'score': max(0, int(roi * 1000)),
            'reason': f'ROI {roi:.2%} below threshold {threshold:.2%}'
        }
EOF
        
        # 테이블 이름 치환
        sed -i "s/TABLE_NAME_PLACEHOLDER/$TABLE_NAME/g" proposal_analysis.py
    fi
    
    # 알림 Lambda 함수 존재 여부 확인
    if [ -f "notification.py" ]; then
        log_warning "notification.py 파일이 이미 존재합니다."
        log_info "기존 파일을 사용합니다."
    else
        # 알림 Lambda 함수 생성
        log_info "알림 Lambda 함수를 생성합니다..."
        cat > notification.py << 'EOF'
import json
import boto3

sns = boto3.client('sns')

def lambda_handler(event, context):
    try:
        # 알림 메시지 생성
        proposal_id = event['proposal_id']
        analysis_result = event['analysis_result']
        
        message = f"""
Investment Proposal Review Complete
        
Proposal ID: {proposal_id}
Status: {analysis_result['status']}
Score: {analysis_result['score']}/100
Reason: {analysis_result['reason']}
        
Review completed at: {event.get('timestamp', 'N/A')}
        """
        
        # SNS 토픽으로 알림 발송
        response = sns.publish(
            TopicArn=event['topic_arn'],
            Subject=f'Investment Proposal Review - {analysis_result["status"]}',
            Message=message
        )
        
        return {
            'message': 'Notification sent successfully',
            'message_id': response['MessageId']
        }
        
    except Exception as e:
        raise Exception(f"Notification failed: {str(e)}")
EOF
    fi
    
    # Lambda 함수 배포 패키지 존재 여부 확인
    if [ -f "proposal_upload.zip" ] && [ -f "proposal_analysis.zip" ] && [ -f "notification.zip" ]; then
        log_warning "Lambda 함수 배포 패키지가 이미 존재합니다."
        log_info "기존 패키지를 사용합니다."
    else
        # Lambda 함수 배포 패키지 생성
        log_info "Lambda 함수 배포 패키지를 생성합니다..."
        zip -r proposal_upload.zip proposal_upload.py
        zip -r proposal_analysis.zip proposal_analysis.py
        zip -r notification.zip notification.py
    fi
    
    cd ..
    
    log_success "Lambda 함수 개발이 완료되었습니다."
}

# 5단계: Lambda 함수 배포
deploy_lambda_functions() {
    log_info "=== 5단계: Lambda 함수 배포 ==="
    
    # IAM 역할 존재 여부 확인
    ROLE_NAME="lambda-execution-role-$UNIQUE_SUFFIX"
    log_info "IAM 역할 존재 여부를 확인합니다: $ROLE_NAME"
    if aws iam get-role --role-name "$ROLE_NAME" &> /dev/null; then
        log_warning "IAM 역할이 이미 존재합니다: $ROLE_NAME"
        log_info "기존 역할을 사용합니다."
    else
        # IAM 역할 생성 (Lambda 실행 역할)
        log_info "Lambda 실행 역할을 생성합니다..."
        cat > lambda-execution-role-trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
        
        # 역할 생성 (고유 식별자 추가)
        aws iam create-role \
            --role-name "$ROLE_NAME" \
            --assume-role-policy-document file://lambda-execution-role-trust-policy.json
        
        # 기본 Lambda 실행 정책 연결
        aws iam attach-role-policy \
            --role-name "$ROLE_NAME" \
            --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
        
        # DynamoDB 정책 연결
        aws iam attach-role-policy \
            --role-name "$ROLE_NAME" \
            --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess
        
        # S3 정책 연결
        aws iam attach-role-policy \
            --role-name "$ROLE_NAME" \
            --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
        
        # SNS 정책 연결
        aws iam attach-role-policy \
            --role-name "$ROLE_NAME" \
            --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess
        
        # 역할이 전파될 때까지 대기
        sleep 10
    fi
    
    # Lambda 함수 존재 여부 확인 및 생성
    FUNCTION_NAME_UPLOAD="proposal-upload-$UNIQUE_SUFFIX"
    log_info "Lambda 함수 존재 여부를 확인합니다: $FUNCTION_NAME_UPLOAD"
    if aws lambda get-function --function-name "$FUNCTION_NAME_UPLOAD" &> /dev/null; then
        log_warning "Lambda 함수가 이미 존재합니다: $FUNCTION_NAME_UPLOAD"
        log_info "기존 함수를 사용합니다."
    else
        # Lambda 함수 생성 (고유 식별자 추가)
        log_info "Lambda 함수를 생성합니다..."
        aws lambda create-function \
            --function-name "$FUNCTION_NAME_UPLOAD" \
            --runtime "$LAMBDA_RUNTIME" \
            --role "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/$ROLE_NAME" \
            --handler proposal_upload.lambda_handler \
            --zip-file fileb://lambda-functions/proposal_upload.zip \
            --timeout 30 \
            --memory-size 256
    fi
    
    FUNCTION_NAME_ANALYSIS="proposal-analysis-$UNIQUE_SUFFIX"
    if aws lambda get-function --function-name "$FUNCTION_NAME_ANALYSIS" &> /dev/null; then
        log_warning "Lambda 함수가 이미 존재합니다: $FUNCTION_NAME_ANALYSIS"
    else
        aws lambda create-function \
            --function-name "$FUNCTION_NAME_ANALYSIS" \
            --runtime "$LAMBDA_RUNTIME" \
            --role "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/$ROLE_NAME" \
            --handler proposal_analysis.lambda_handler \
            --zip-file fileb://lambda-functions/proposal_analysis.zip \
            --timeout 30 \
            --memory-size 256
    fi
    
    FUNCTION_NAME_NOTIFICATION="notification-$UNIQUE_SUFFIX"
    if aws lambda get-function --function-name "$FUNCTION_NAME_NOTIFICATION" &> /dev/null; then
        log_warning "Lambda 함수가 이미 존재합니다: $FUNCTION_NAME_NOTIFICATION"
    else
        aws lambda create-function \
            --function-name "$FUNCTION_NAME_NOTIFICATION" \
            --runtime "$LAMBDA_RUNTIME" \
            --role "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/$ROLE_NAME" \
            --handler notification.lambda_handler \
            --zip-file fileb://lambda-functions/notification.zip \
            --timeout 30 \
            --memory-size 256
    fi
    
    log_success "Lambda 함수 배포가 완료되었습니다."
}

# 6단계: API Gateway 설정
setup_api_gateway() {
    log_info "=== 6단계: API Gateway 설정 ==="
    
    # REST API 생성 (고유 식별자 추가)
    log_info "REST API를 생성합니다..."
    API_NAME="Investment Proposals API-$UNIQUE_SUFFIX"
    API_ID=$(aws apigateway create-rest-api \
        --name "$API_NAME" \
        --description "투자 제안 심사 시스템 API" \
        --query 'id' --output text)
    
    # 루트 리소스 ID 가져오기
    ROOT_ID=$(aws apigateway get-resources \
        --rest-api-id "$API_ID" \
        --query 'items[?path==`/`].id' --output text)
    
    # /proposals 리소스 생성
    PROPOSALS_ID=$(aws apigateway create-resource \
        --rest-api-id "$API_ID" \
        --parent-id "$ROOT_ID" \
        --path-part "proposals" \
        --query 'id' --output text)
    
    # POST 메서드 생성
    aws apigateway put-method \
        --rest-api-id "$API_ID" \
        --resource-id "$PROPOSALS_ID" \
        --http-method POST \
        --authorization-type NONE
    
    # Lambda 함수 연동
    aws apigateway put-integration \
        --rest-api-id "$API_ID" \
        --resource-id "$PROPOSALS_ID" \
        --http-method POST \
        --type AWS_PROXY \
        --integration-http-method POST \
        --uri "arn:aws:apigateway:ap-northeast-2:lambda:path/2015-03-31/functions/arn:aws:lambda:ap-northeast-2:$(aws sts get-caller-identity --query Account --output text):function:proposal-upload-$UNIQUE_SUFFIX/invocations"
    
    # Lambda 함수에 API Gateway 권한 부여
    aws lambda add-permission \
        --function-name "proposal-upload-$UNIQUE_SUFFIX" \
        --statement-id apigateway-invoke \
        --action lambda:InvokeFunction \
        --principal apigateway.amazonaws.com \
        --source-arn "arn:aws:execute-api:ap-northeast-2:$(aws sts get-caller-identity --query Account --output text):$API_ID/*/*"
    
    # 배포 생성
    aws apigateway create-deployment \
        --rest-api-id "$API_ID" \
        --stage-name prod
    
    # API URL 출력
    echo "API URL: https://$API_ID.execute-api.ap-northeast-2.amazonaws.com/prod/proposals"
    
    log_success "API Gateway 설정이 완료되었습니다."
}

# 7단계: SNS 토픽 생성
create_sns_topics() {
    log_info "=== 7단계: SNS 토픽 생성 ==="
    
    # 승인 알림 토픽 생성 (고유 식별자 추가)
    log_info "승인 알림 토픽을 생성합니다..."
    APPROVAL_TOPIC_NAME="investment-approvals-$UNIQUE_SUFFIX"
    APPROVAL_TOPIC_ARN=$(aws sns create-topic \
        --name "$APPROVAL_TOPIC_NAME" \
        --query 'TopicArn' --output text)
    
    # 거부 알림 토픽 생성 (고유 식별자 추가)
    log_info "거부 알림 토픽을 생성합니다..."
    REJECTION_TOPIC_NAME="investment-rejections-$UNIQUE_SUFFIX"
    REJECTION_TOPIC_ARN=$(aws sns create-topic \
        --name "$REJECTION_TOPIC_NAME" \
        --query 'TopicArn' --output text)
    
    # 토픽 목록 확인
    log_info "토픽 목록을 확인합니다..."
    aws sns list-topics
    
    log_success "SNS 토픽 생성이 완료되었습니다."
}

# 8단계: Step Functions 워크플로우
create_step_functions() {
    log_info "=== 8단계: Step Functions 워크플로우 ==="
    
    # Step Functions 실행 역할 생성
    log_info "Step Functions 실행 역할을 생성합니다..."
    cat > stepfunctions-execution-role-trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
    
    # 역할 생성 (고유 식별자 추가)
    STEP_ROLE_NAME="StepFunctionsExecutionRole-$UNIQUE_SUFFIX"
    aws iam create-role \
        --role-name "$STEP_ROLE_NAME" \
        --assume-role-policy-document file://stepfunctions-execution-role-trust-policy.json
    
    # Step Functions 실행 정책 연결
    aws iam attach-role-policy \
        --role-name "$STEP_ROLE_NAME" \
        --policy-arn arn:aws:iam::aws:policy/service-role/AWSStepFunctionsExecutionRole
    
    # Lambda 호출 정책 추가
    cat > lambda-invoke-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "arn:aws:lambda:ap-northeast-2:ACCOUNT_ID:function:proposal-analysis-UNIQUE_SUFFIX",
        "arn:aws:lambda:ap-northeast-2:ACCOUNT_ID:function:notification-UNIQUE_SUFFIX"
      ]
    }
  ]
}
EOF
    
    # ACCOUNT_ID와 UNIQUE_SUFFIX 치환
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    sed -i "s/ACCOUNT_ID/$ACCOUNT_ID/g" lambda-invoke-policy.json
    sed -i "s/UNIQUE_SUFFIX/$UNIQUE_SUFFIX/g" lambda-invoke-policy.json
    
    # 정책 생성 및 연결
    aws iam put-role-policy \
        --role-name "$STEP_ROLE_NAME" \
        --policy-name LambdaInvokePolicy \
        --policy-document file://lambda-invoke-policy.json
    
    # 상태 머신 정의
    log_info "상태 머신을 정의합니다..."
    cat > state-machine-definition.json << 'EOF'
{
  "Comment": "Investment Proposal Review Workflow",
  "StartAt": "AnalyzeProposal",
  "States": {
    "AnalyzeProposal": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:ap-northeast-2:ACCOUNT_ID:function:proposal-analysis-UNIQUE_SUFFIX",
      "Next": "CheckAnalysisResult",
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "Next": "HandleError"
        }
      ]
    },
    "CheckAnalysisResult": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.analysis_result.status",
          "StringEquals": "APPROVED",
          "Next": "SendApprovalNotification"
        },
        {
          "Variable": "$.analysis_result.status",
          "StringEquals": "REJECTED",
          "Next": "SendRejectionNotification"
        }
      ],
      "Default": "HandleError"
    },
    "SendApprovalNotification": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:ap-northeast-2:ACCOUNT_ID:function:notification-UNIQUE_SUFFIX",
      "Parameters": {
        "proposal_id.$": "$.proposal_id",
        "analysis_result.$": "$.analysis_result",
        "topic_arn": "arn:aws:sns:ap-northeast-2:ACCOUNT_ID:investment-approvals-UNIQUE_SUFFIX",
        "timestamp.$": "$$.State.EnteredTime"
      },
      "End": true
    },
    "SendRejectionNotification": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:ap-northeast-2:ACCOUNT_ID:function:notification-UNIQUE_SUFFIX",
      "Parameters": {
        "proposal_id.$": "$.proposal_id",
        "analysis_result.$": "$.analysis_result",
        "topic_arn": "arn:aws:sns:ap-northeast-2:ACCOUNT_ID:investment-rejections-UNIQUE_SUFFIX",
        "timestamp.$": "$$.State.EnteredTime"
      },
      "End": true
    },
    "HandleError": {
      "Type": "Fail",
      "Cause": "Investment proposal review failed",
      "Error": "ReviewError"
    }
  }
}
EOF
    
    # ACCOUNT_ID와 UNIQUE_SUFFIX 치환
    sed -i "s/ACCOUNT_ID/$ACCOUNT_ID/g" state-machine-definition.json
    sed -i "s/UNIQUE_SUFFIX/$UNIQUE_SUFFIX/g" state-machine-definition.json
    
    # 상태 머신 생성 (고유 식별자 추가)
    aws stepfunctions create-state-machine \
        --name "InvestmentProposalReview-$UNIQUE_SUFFIX" \
        --definition file://state-machine-definition.json \
        --role-arn "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/$STEP_ROLE_NAME"
    
    log_success "Step Functions 워크플로우 생성이 완료되었습니다."
}

# 9단계: 테스트 및 모니터링
test_and_monitor() {
    log_info "=== 9단계: 테스트 및 모니터링 ==="
    
    # 테스트 데이터 생성
    log_info "테스트 데이터를 생성합니다..."
    cat > test-proposal.json << 'EOF'
{
  "company_name": "TechStartup Inc.",
  "investment_amount": 1000000,
  "business_description": "AI-powered SaaS platform for small businesses",
  "expected_return": 150000,
  "risk_level": "MEDIUM"
}
EOF
    
    # API 호출 테스트
    log_info "API 호출을 테스트합니다..."
    API_URL="https://$(aws apigateway get-rest-apis --query 'items[?name==`Investment Proposals API-UNIQUE_SUFFIX`].id' --output text).execute-api.ap-northeast-2.amazonaws.com/prod/proposals"
    
    # UNIQUE_SUFFIX 치환
    API_URL=$(echo "$API_URL" | sed "s/UNIQUE_SUFFIX/$UNIQUE_SUFFIX/g")
    
    curl -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d @test-proposal.json
    
    # CloudWatch 대시보드 생성
    log_info "CloudWatch 대시보드를 생성합니다..."
    cat > dashboard-definition.json << 'EOF'
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/Lambda", "Invocations", "FunctionName", "proposal-upload-UNIQUE_SUFFIX"],
          [".", "Invocations", "FunctionName", "proposal-analysis-UNIQUE_SUFFIX"],
          [".", "Invocations", "FunctionName", "notification-UNIQUE_SUFFIX"]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "ap-northeast-2",
        "title": "Lambda Function Invocations"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ApiGateway", "Count", "ApiName", "Investment Proposals API-UNIQUE_SUFFIX"]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "ap-northeast-2",
        "title": "API Gateway Requests"
      }
    }
  ]
}
EOF
    
    # UNIQUE_SUFFIX 치환
    sed -i "s/UNIQUE_SUFFIX/$UNIQUE_SUFFIX/g" dashboard-definition.json
    
    aws cloudwatch put-dashboard \
        --dashboard-name "InvestmentProposalsDashboard-$UNIQUE_SUFFIX" \
        --dashboard-body file://dashboard-definition.json
    
    log_success "테스트 및 모니터링이 완료되었습니다."
}

# 메인 실행 함수
main() {
    log_info "AWS 서버리스 투자 제안 심사 시스템 실습 자동화를 시작합니다..."
    log_info "고유 식별자: $UNIQUE_SUFFIX"
    
    check_aws_cli
    check_aws_login
    
    setup_aws_environment
    create_dynamodb_table
    create_s3_bucket
    create_lambda_functions
    deploy_lambda_functions
    setup_api_gateway
    create_sns_topics
    create_step_functions
    test_and_monitor
    
    log_success "AWS 서버리스 투자 제안 심사 시스템 실습 자동화가 완료되었습니다!"
    log_info "생성된 리소스 정보:"
    log_info "- DynamoDB 테이블: $TABLE_NAME"
    log_info "- S3 버킷: $BUCKET_NAME"
    log_info "- Lambda 함수: proposal-upload-$UNIQUE_SUFFIX, proposal-analysis-$UNIQUE_SUFFIX, notification-$UNIQUE_SUFFIX"
    log_info "- Step Functions: InvestmentProposalReview-$UNIQUE_SUFFIX"
    log_info "- 고유 식별자: $UNIQUE_SUFFIX"
    log_info ""
    log_info "다음 단계:"
    log_info "1. AWS Console에서 생성된 리소스 확인"
    log_info "2. API Gateway URL로 투자 제안 업로드 테스트"
    log_info "3. CloudWatch 대시보드에서 모니터링"
    log_info "4. SNS 알림 확인"
}

# 스크립트 실행
main "$@"
