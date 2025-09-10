# 4-2. Terraform으로 AWS/GCP 인프라 구축 실습

## 학습 목표
- Terraform을 사용한 실제 인프라 구축
- AWS와 GCP 환경에서의 실습
- 모듈화된 인프라 코드 작성
- 상태 관리 및 협업 워크플로우

---

## 실습 환경 구성

### 프로젝트 구조
```
terraform-practice/
├── aws/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── gcp/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
└── shared/
    └── modules/
        ├── vpc/
        ├── compute/
        └── database/
```

---

## AWS 인프라 구축 실습

### VPC 및 서브넷 구성
```hcl
# aws/main.tf
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "public-${var.availability_zones[count.index]}"
  }
}
```

---

## GCP 인프라 구축 실습

### VPC 및 서브넷 구성
```hcl
# gcp/main.tf
resource "google_compute_network" "vpc" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  count         = length(var.subnets)
  name          = "subnet-${count.index + 1}"
  ip_cidr_range = var.subnets[count.index]
  network       = google_compute_network.vpc.name
  region        = var.region
}
```

---

## 모듈화된 인프라

### 공통 모듈 사용
```hcl
# shared/modules/compute/main.tf
module "aws_compute" {
  source = "../../aws"
  
  instance_type = var.instance_type
  instance_count = var.instance_count
}

module "gcp_compute" {
  source = "../../gcp"
  
  machine_type = var.machine_type
  instance_count = var.instance_count
}
```

---

## 실습 과제

### 기본 실습
1. **AWS VPC 및 EC2 인스턴스 생성**
2. **GCP VPC 및 Compute Engine 인스턴스 생성**
3. **모듈을 사용한 인프라 재사용**

### 고급 실습
1. **멀티 클라우드 환경 구성**
2. **자동화된 배포 파이프라인 구축**
3. **인프라 테스트 및 검증**
