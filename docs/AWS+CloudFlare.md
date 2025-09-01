좋아요! 앞서 만든 AWS 리소스들을 **변수**로 정리하고, 해당 변수를 사용해서 AWS CLI 명령어를 다시 구성해드릴게요. 이렇게 하면 반복 사용이나 스크립트화에 더 용이해집니다.

---

## ✅ 변수 목록 (bash shell 기준)

```bash
### 리전 및 네트워크 설정
REGION="ap-northeast-2"
VPC_CIDR="10.1.0.0/16"
SUBNET_CIDR="10.1.1.0/24"
AZ="ap-northeast-2a"

### 키페어 이름
KEY_NAME="my-key"
KEY_FILE="$KEY_NAME.pem"


### 태그 이름
VPC_NAME="MyVPC"
SUBNET_NAME="PublicSubnet"
IGW_NAME="MyIGW"
ROUTE_TABLE_NAME="PublicRouteTable"
SECURITY_GROUP_NAME="MySecurityGroup"
INSTANCE_NAME="MyDockerVM"
```

---

## ✅ 리소스 생성 스크립트 (변수 기반)

### 1️⃣ VPC 생성

```bash
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --region $REGION \
  --query 'Vpc.VpcId' \
  --output text)

aws ec2 create-tags \
  --resources $VPC_ID \
  --tags Key=Name,Value=$VPC_NAME \
  --region $REGION
```

---

### 2️⃣ 서브넷 생성

```bash
SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_CIDR \
  --availability-zone $AZ \
  --region $REGION \
  --query 'Subnet.SubnetId' \
  --output text)

aws ec2 create-tags \
  --resources $SUBNET_ID \
  --tags Key=Name,Value=$SUBNET_NAME \
  --region $REGION
```

---

### 3️⃣ 인터넷 게이트웨이 생성 및 연결

```bash
IGW_ID=$(aws ec2 create-internet-gateway \
  --region $REGION \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

aws ec2 create-tags \
  --resources $IGW_ID \
  --tags Key=Name,Value=$IGW_NAME \
  --region $REGION

aws ec2 attach-internet-gateway \
  --vpc-id $VPC_ID \
  --internet-gateway-id $IGW_ID \
  --region $REGION
```

---

### 4️⃣ 라우팅 테이블 생성 및 연결

```bash
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --region $REGION \
  --query 'RouteTable.RouteTableId' \
  --output text)

aws ec2 create-tags \
  --resources $ROUTE_TABLE_ID \
  --tags Key=Name,Value=$ROUTE_TABLE_NAME \
  --region $REGION

aws ec2 create-route \
  --route-table-id $ROUTE_TABLE_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID \
  --region $REGION

aws ec2 associate-route-table \
  --route-table-id $ROUTE_TABLE_ID \
  --subnet-id $SUBNET_ID \
  --region $REGION
```

---

### 5️⃣ 보안 그룹 생성 및 포트 허용

```bash
SG_ID=$(aws ec2 create-security-group \
  --group-name $SECURITY_GROUP_NAME \
  --description "Allow SSH and HTTP" \
  --vpc-id $VPC_ID \
  --region $REGION \
  --query 'GroupId' \
  --output text)

# SSH (22) 허용
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region $REGION

# App 포트 (예: 8080) 허용 — Cloudflare Tunnel 사용 시엔 나중에 닫아도 됨
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 8080 \
  --cidr 0.0.0.0/0 \
  --region $REGION
```

---

### 6️⃣ 키페어어 생성

```bash
aws ec2 create-key-pair \
  --key-name "$KEY_NAME" \
  --key-type rsa \
  --key-format pem \
  --region "$REGION" \
  --query 'KeyMaterial' \
  --output text > "$KEY_FILE"
```
---

### 6️⃣ EC2 인스턴스 생성

```bash
AMI_ID="ami-0ae2c887094315bed"  # Ubuntu 23.08 (2025년 기준 서울 리전)

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type t3.micro \
  --key-name $KEY_NAME \
  --security-group-ids $SG_ID \
  --subnet-id $SUBNET_ID \
  --associate-public-ip-address \
  --region $REGION \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
  --query 'Instances[0].InstanceId' \
  --output text)

# 퍼블릭 IP 가져오기
EC2_PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --region $REGION \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)
```

---

## ✅ 결과 확인

```bash
echo "VPC_ID: $VPC_ID"
echo "SUBNET_ID: $SUBNET_ID"
echo "IGW_ID: $IGW_ID"
echo "ROUTE_TABLE_ID: $ROUTE_TABLE_ID"
echo "SG_ID: $SG_ID"
echo "INSTANCE_ID: $INSTANCE_ID"
echo "EC2_PUBLIC_IP: $EC2_PUBLIC_IP"
```

---

### 사용자 ###
username: ec2-user