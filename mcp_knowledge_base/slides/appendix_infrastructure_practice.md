---
marp: true
theme: default
paginate: true
backgroundColor: #fff
backgroundImage: url('https://marp.app/assets/hero-background.svg')
---

# 부록: 인프라 실습 가이드 - Terraform으로 AWS & GCP 인프라 구축

**Day 4: Terraform 기초 및 실습을 위한 종합 실전 가이드**

![인프라 실습](https://images.unsplash.com/photo-1571171637578-41bc2dd41cd2?w=800&h=400&fit=crop)

---

## 📚 **학습 목표**

- Terraform을 사용한 AWS와 GCP 인프라 자동화 실습
- 고가용성 웹 서비스 아키텍처의 실제 구현
- Infrastructure as Code (IaC)의 실무 적용 방법
- 멀티 클라우드 환경에서의 인프라 관리 전략

---

## 🎯 **실습 목표 아키텍처: 고가용성 웹 서비스 구축**

이번 실습에서는 AWS와 GCP에 각각 동일한 형태의 고가용성 웹 서비스 아키텍처를 Terraform을 사용하여 구축합니다. 이 아키텍처는 실제 서비스 운영에 필요한 핵심 구성 요소를 포함하며, 스타트업이 클라우드 환경에서 안정적인 서비스를 제공하기 위한 기반이 됩니다.

### **[다이어그램] 목표 아키텍처: 고가용성 웹 서비스**

```mermaid
graph TD
    subgraph "사용자 (User)"
        U[웹 브라우저 / 모바일 앱]
    end

    subgraph "클라우드 환경 (AWS 또는 GCP)"
        direction TB
        LB(로드 밸런서)

        subgraph "퍼블릭 서브넷 (Public Subnet)"
            direction LR
            W1[웹 서버 1 (VM)]
            W2[웹 서버 2 (VM)]
            W3[... (Auto Scaling)]
        end

        subgraph "프라이빗 서브넷 (Private Subnet)"
            direction LR
            DB_P[(주 데이터베이스)] -- 복제 --> DB_S[(보조 데이터베이스)]
        end

        U --> LB
        LB --> W1 & W2 & W3
        W1 & W2 & W3 --> DB_P

        style U fill:#f9f,stroke:#333,stroke-width:2px
        style LB fill:#27ae60,stroke:#fff,stroke-width:2px,color:#fff
        style DB_P fill:#2980b9,stroke:#fff,stroke-width:2px,color:#fff
        style DB_S fill:#3498db,stroke:#fff,stroke-width:2px,color:#fff
    end
```

**아키텍처 구성 요소:**
*   **네트워크:**
    *   **VPC (Virtual Private Cloud):** 클라우드 내 격리된 가상 네트워크 공간.
    *   **Public Subnet:** 외부 인터넷과 통신이 가능한 서브넷 (웹 서버 위치).
    *   **Private Subnet:** 외부 인터넷과 직접 통신이 불가능한 서브넷 (데이터베이스 위치, 보안 강화).
    *   **Internet Gateway / NAT Gateway:** Public/Private 서브넷의 인터넷 통신 관리.
    *   **Route Table:** 네트워크 트래픽의 경로 지정.
*   **컴퓨팅:**
    *   **Web Server (EC2/Compute Engine VM):** 웹 요청을 처리하는 가상 서버.
    *   **Auto Scaling Group / Managed Instance Group (MIG):** 트래픽에 따라 웹 서버 수를 자동으로 조절하여 가용성 및 확장성 확보.
*   **로드 밸런싱:**
    *   **Application Load Balancer (ALB) / Cloud Load Balancer:** 외부 트래픽을 여러 웹 서버에 분산하여 서비스 부하를 줄이고 고가용성 제공.
*   **데이터베이스:**
    *   **RDS / Cloud SQL:** 관리형 관계형 데이터베이스 서비스 (고가용성 구성).
*   **보안:**
    *   **Security Group / Firewall Rules:** 인스턴스 및 네트워크 레벨에서 트래픽을 제어하는 가상 방화벽.

---

## 🛠️ **실습 환경 준비: IaC를 위한 필수 도구 설치**

Terraform을 사용하여 클라우드 인프라를 코드로 관리하기 위해서는 몇 가지 필수 도구들이 필요합니다. 이 도구들은 클라우드 리소스를 정의하고 배포하며, 클라우드 제공업체와 상호작용하는 데 핵심적인 역할을 합니다.

### **필수 도구 설치 및 설정 확인**

- **Terraform:** HashiCorp에서 개발한 오픈소스 IaC(Infrastructure as Code) 도구입니다. 다양한 클라우드 제공업체(AWS, GCP, Azure 등)의 인프라를 코드로 정의하고 관리할 수 있게 해줍니다.
  - **설치 가이드:** [Terraform 공식 설치 문서](https://developer.hashicorp.com/terraform/downloads)
- **AWS CLI:** Amazon Web Services의 리소스를 명령줄에서 제어하기 위한 공식 도구입니다. Terraform이 AWS 리소스를 프로비저닝할 때 내부적으로 AWS CLI의 인증 정보를 사용합니다.
  - **설치 가이드:** [AWS CLI 공식 설치 문서](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/getting-started-install.html)
- **Google Cloud SDK (gcloud):** Google Cloud Platform의 리소스를 명령줄에서 제어하기 위한 공식 도구입니다. Terraform이 GCP 리소스를 프로비저닝할 때 gcloud의 인증 정보를 활용합니다.
  - **설치 가이드:** [Google Cloud SDK 공식 설치 문서](https://cloud.google.com/sdk/docs/install)

> **지난 시간 복습 및 확인:** Day 2에서 각 CLI 도구의 설치 및 기본 인증 설정을 완료했습니다. 실습을 시작하기 전에 다음 명령어를 통해 `aws configure`와 `gcloud init`이 올바르게 설정되어 있는지 다시 한번 확인하세요.

```bash
# AWS CLI 설정 확인
aws sts get-caller-identity

# GCP CLI 설정 확인
gcloud auth list
gcloud config list
```

![환경 설정](https://images.unsplash.com/photo-1618477388954-7852f32655ec?w=800&h=300&fit=crop)

---

## 🏗️ **AWS 실습: Terraform으로 고가용성 웹 인프라 구축**

AWS 환경에 Terraform을 사용하여 앞서 정의한 고가용성 웹 서비스 아키텍처를 단계별로 구축합니다. 각 단계별로 Terraform 코드와 함께 해당 리소스의 역할 및 중요성을 설명합니다.

### **[흐름도] AWS 고가용성 웹 인프라 구축 순서**

```mermaid
graph TD
    A[VPC 생성] --> B(인터넷 게이트웨이 & 라우팅 설정);
    B --> C{퍼블릭 서브넷 생성 (다중 AZ)};
    C --> D[보안 그룹 설정];
    D --> E(EC2 웹 서버 생성 & Auto Scaling);
    E --> F[ALB (Application Load Balancer) 설정];
    F --> G((인프라 완성));

    style A fill:#FF9900,stroke:#333,stroke-width:2px
    style F fill:#FF9900,stroke:#333,stroke-width:2px
    style G fill:#27ae60,stroke:#fff,stroke-width:2px,color:#fff
```

---

### **1단계: 네트워크(VPC) 구성 (`network.tf`) - 서비스의 기반 마련**

클라우드 인프라의 가장 기본적인 구성 요소는 네트워크입니다. VPC(Virtual Private Cloud)는 클라우드 내에 논리적으로 격리된 나만의 가상 네트워크 공간을 생성하며, 서브넷, 인터넷 게이트웨이, 라우팅 테이블 등을 통해 네트워크 트래픽을 제어합니다.

```hcl
# --- main.tf ---
provider "aws" {
  region = "ap-northeast-2" # 서울 리전
}

# --- network.tf ---
# 1. VPC 생성: 우리만의 격리된 네트워크 공간
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "my-vpc" }
}

# 2. 인터넷 게이트웨이: VPC가 외부 인터넷과 통신하는 관문
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "my-igw" }
}

# 3. 퍼블릭 서브넷: 외부에서 접근 가능한 네트워크 영역
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # EC2에 공인 IP 자동 할당
  tags = { Name = "my-public-subnet" }
}

# 4. 라우팅 테이블: 트래픽을 인터넷 게이트웨이로 보내는 규칙
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0" # 모든 트래픽을
    gateway_id = aws_internet_gateway.main.id # 인터넷 게이트웨이로
  }
  tags = { Name = "my-public-rt" }
}

# 5. 라우팅 테이블과 서브넷 연결
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

---

### **2단계: 보안 및 EC2 인스턴스 구성 (`compute.tf`) - 웹 서버 배포 및 보안 설정**

웹 서버는 사용자 요청을 직접 처리하는 핵심 컴포넌트입니다. EC2 인스턴스를 생성하고, 보안 그룹을 통해 외부로부터의 접근을 제어하여 서비스의 안정성과 보안을 확보합니다.

```hcl
# --- compute.tf ---
# 1. 보안 그룹 (Security Group): EC2 인스턴스의 가상 방화벽
#    인스턴스 레벨에서 인바운드/아웃바운드 트래픽을 제어합니다.
resource "aws_security_group" "web" {
  name   = "web-sg"
  vpc_id = aws_vpc.main.id

  # HTTP (80 포트) 트래픽 허용: 웹 서비스 접근을 위해 필수
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP에서 접근 허용 (실습 목적, 실제 운영에서는 특정 IP 대역으로 제한 권장)
    description = "Allow HTTP traffic from anywhere"
  }
  # SSH (22 포트) 트래픽 허용: 인스턴스 접속 및 관리를 위해 필요
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP에서 접근 허용 (실습 목적, 실제 운영에서는 특정 IP 대역으로 제한 권장)
    description = "Allow SSH traffic from anywhere"
  }
  # 모든 아웃바운드 트래픽 허용: 인스턴스가 외부로 통신할 수 있도록 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # 모든 프로토콜
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP로 통신 허용
    description = "Allow all outbound traffic"
  }
  tags = { Name = "web-sg" }
}

# 2. EC2 인스턴스 생성: 웹 서버 역할 수행
resource "aws_instance" "web" {
  ami                    = "ami-0c7c4e3c6b47be499" # Amazon Linux 2023 AMI (리전별로 다를 수 있음, 최신 AMI 확인 필요)
  instance_type          = "t2.micro"             # 프리 티어 사용 가능한 인스턴스 타입
  subnet_id              = aws_subnet.public.id   # 퍼블릭 서브넷에 배포
  vpc_security_group_ids = [aws_security_group.web.id] # 위에서 생성한 보안 그룹 적용

  # 웹 서버 초기 설정 스크립트 (user_data): 인스턴스 시작 시 자동 실행
  user_data = <<EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from AWS EC2!</h1>" > /var/www/html/index.html
              EOF
  tags = { Name = "my-web-server" }
}
```

---

## ☁️ **GCP 실습: Terraform으로 고가용성 웹 인프라 구축**

GCP 환경에 Terraform을 사용하여 고가용성 웹 서비스 아키텍처를 단계별로 구축합니다. AWS와 비교하며 GCP의 인프라 구성 방식의 차이점을 이해하는 데 중점을 둡니다.

### **[흐름도] GCP 고가용성 웹 인프라 구축 순서**

```mermaid
graph TD
    A[VPC 생성 (글로벌)] --> B(서브넷 생성 (리전별));
    B --> C{방화벽 규칙 설정};
    C --> D[Compute Engine VM 생성 & Managed Instance Group];
    D --> E(Cloud Load Balancer 설정 (글로벌));
    E --> F((인프라 완성));

    style A fill:#4285F4,stroke:#333,stroke-width:2px
    style E fill:#4285F4,stroke:#333,stroke-width:2px
    style F fill:#27ae60,stroke:#fff,stroke-width:2px,color:#fff
```

---

### **1단계: 네트워크(VPC) 및 방화벽 구성 (`network.tf`) - GCP의 글로벌 네트워크 활용**

GCP의 네트워크는 AWS와 달리 글로벌 범위를 가집니다. VPC는 전 세계 리소스를 단일 네트워크처럼 관리할 수 있으며, 방화벽 규칙은 네트워크 레벨에서 트래픽을 제어하여 보안을 강화합니다.

```hcl
# --- main.tf ---
provider "google" {
  project = "YOUR_GCP_PROJECT_ID" # 본인의 GCP 프로젝트 ID 입력 (필수)
  region  = "asia-northeast3"   # 서울 리전 (서비스를 배포할 리전)
}

# --- network.tf ---
# 1. VPC 생성: GCP의 글로벌 가상 네트워크
#    GCP의 VPC는 글로벌 리소스이므로, 한 번 생성하면 모든 리전에서 사용 가능합니다.
resource "google_compute_network" "main" {
  name                    = "my-vpc"
  auto_create_subnetworks = false # 서브넷을 수동으로 생성하여 네트워크 구조를 명확히 합니다.
  routing_mode            = "REGIONAL" # 리전 내에서만 라우팅 (글로벌 라우팅도 가능)
}

# 2. 서브넷 생성: 특정 리전 내의 네트워크 영역
#    서브넷은 리전 단위로 생성되며, VM 인스턴스 등이 배포될 실제 네트워크 공간입니다.
resource "google_compute_subnetwork" "public" {
  name          = "my-public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.main.id
  region        = "asia-northeast3"
}

# 3. 방화벽 규칙: 네트워크 레벨에서 트래픽 허용/차단
#    GCP의 방화벽 규칙은 VPC 네트워크 전체에 적용되며, 태그를 사용하여 특정 VM에 적용할 수 있습니다.
resource "google_compute_firewall" "allow_http_ssh" {
  name    = "allow-http-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }
  source_ranges = ["0.0.0.0/0"] # 모든 IP에서 접근 허용 (실습 목적, 실제 운영에서는 특정 IP 대역으로 제한 권장)
  target_tags   = ["http-server"] # 이 태그를 가진 VM에만 규칙 적용
  description   = "Allow HTTP and SSH traffic to web servers"
}
```

---

### **2단계: Compute Engine VM 구성 (`compute.tf`) - 웹 서버 배포 및 초기 설정**

Compute Engine VM은 GCP의 가상 머신 서비스로, 웹 서버 역할을 수행합니다. VM 생성 시 시작 스크립트를 통해 웹 서버(Apache2)를 설치하고 간단한 HTML 페이지를 배포합니다.

```hcl
# --- compute.tf ---
# 1. Compute Engine VM 생성: 웹 서버 역할 수행
resource "google_compute_instance" "web" {
  name         = "my-web-server"
  machine_type = "e2-micro" # 프리 티어 사용 가능한 머신 타입
  zone         = "asia-northeast3-a" # VM을 배포할 Zone (리전 내 특정 데이터센터)

  # 부팅 디스크 설정: 운영체제 이미지 선택
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # 네트워크 인터페이스 설정: VM이 연결될 VPC 및 서브넷 지정
  network_interface {
    network    = google_compute_network.main.name
    subnetwork = google_compute_subnetwork.public.name
    # 외부 IP 자동 할당 (퍼블릭 서브넷에 위치하므로 외부 접근을 위해 필요)
    access_config { }
  }

  # 방화벽 규칙 적용을 위한 네트워크 태그 설정
  tags = ["http-server"] # 위에서 정의한 방화벽 규칙(allow_http_ssh)이 이 태그를 가진 VM에 적용됩니다.

  # 웹 서버 설치 스크립트 (metadata_startup_script): VM 시작 시 자동 실행
  metadata_startup_script = <<EOF
                            #!/bin/bash
                            apt-get update -y
                            apt-get install -y apache2
                            systemctl start apache2
                            systemctl enable apache2
                            echo "<h1>Hello from GCP Compute Engine!</h1>" > /var/www/html/index.html
                            EOF
}
```

---

## 🚀 **인프라 배포 및 검증: Terraform 실행 및 결과 확인**

Terraform 코드를 작성했다면, 이제 실제로 클라우드에 인프라를 배포하고 정상적으로 작동하는지 검증할 차례입니다. Terraform은 `init`, `plan`, `apply`의 세 가지 주요 명령어를 통해 인프라 배포를 관리합니다.

### **Terraform 실행 (AWS/GCP 공통)**

```bash
# 1. Terraform 작업 디렉토리 초기화: Provider 플러그인 다운로드 및 백엔드 설정
#    (각 클라우드 Provider에 필요한 플러그인을 다운로드하고, 상태 파일 저장 방식을 설정합니다.)
terraform init

# 2. 실행 계획 검토: 어떤 리소스가 생성/변경/삭제될지 미리보기
#    (실제로 변경을 적용하기 전에 계획을 검토하여 예상치 못한 변경을 방지합니다.)
terraform plan

# 3. 인프라 배포 실행: 계획된 변경 사항을 클라우드에 적용
#    (실행 계획을 확인하고 'yes'를 입력하면 실제 리소스가 프로비저닝됩니다.)
terraform apply
```

### **검증 단계: 웹 서버 접속 확인**

Terraform `apply`가 성공적으로 완료되면, 배포된 웹 서버에 접속하여 정상적으로 작동하는지 확인합니다.

- **AWS:**
  1.  AWS Management Console에 로그인하여 EC2 서비스로 이동합니다.
  2.  '인스턴스' 메뉴에서 `my-web-server` 인스턴스가 '실행 중' 상태인지 확인합니다.
  3.  해당 인스턴스를 선택하고 '세부 정보' 탭에서 '퍼블릭 IPv4 주소'를 복사합니다.
  4.  웹 브라우저에 복사한 IP 주소를 붙여넣어 접속합니다.

- **GCP:**
  1.  Google Cloud Console에 로그인하여 Compute Engine 서비스로 이동합니다.
  2.  'VM 인스턴스' 메뉴에서 `my-web-server` 인스턴스가 '실행 중' 상태인지 확인합니다.
  3.  해당 인스턴스의 '외부 IP' 주소를 복사합니다.
  4.  웹 브라우저에 복사한 IP 주소를 붙여넣어 접속합니다.

> **성공 확인:** 브라우저에 "Hello from AWS EC2!" 또는 "Hello from GCP Compute Engine!" 메시지가 표시되면 인프라 배포 및 웹 서버 설정이 성공적으로 완료된 것입니다!

![인프라 배포 및 검증](https://images.unsplash.com/photo-1571171637578-41bc2dd41cd2?w=800&h=300&fit=crop)

---

## 🏢 **실제 사례 분석 (출처 기반)**

### **Netflix - Terraform으로 글로벌 인프라 관리**
- **출처**: [Netflix Tech Blog - "Infrastructure as Code at Netflix"](https://netflixtechblog.com/infrastructure-as-code-at-netflix-9b5b0c3d471c)
- **도입 배경**: 글로벌 서비스 확장에 따른 인프라 관리 복잡성 증가
- **주요 전략**:
  - Terraform을 사용한 멀티 리전 인프라 자동화
  - 모듈화된 인프라 코드로 재사용성 향상
  - CI/CD 파이프라인과 연동한 자동화된 인프라 배포
- **성과**: 
  - 인프라 배포 시간 80% 단축
  - 인프라 오류 90% 감소
  - 개발자 생산성 향상

### **Spotify - GCP에서 Terraform 활용**
- **출처**: [Google Cloud Blog - "Spotify's Infrastructure Journey"](https://cloud.google.com/blog/products/infrastructure/spotifys-infrastructure-journey)
- **도입 배경**: 마이크로서비스 아키텍처로의 전환에 따른 인프라 관리 복잡성
- **주요 전략**:
  - Terraform으로 GCP 리소스 전체 관리
  - 환경별(dev, staging, prod) 인프라 코드 분리
  - 자동화된 테스트 및 검증 파이프라인
- **성과**:
  - 인프라 배포 자동화로 운영 효율성 증대
  - 환경별 일관성 보장
  - 개발팀의 인프라 접근성 향상

---

## 🧹 **리소스 정리 (Clean-up): 불필요한 비용 방지**

실습이 완료된 후에는 불필요한 클라우드 비용이 발생하지 않도록 Terraform으로 생성한 모든 리소스를 반드시 삭제해야 합니다. IaC의 장점 중 하나는 리소스 삭제도 코드로 간편하게 관리할 수 있다는 점입니다.

> **경고:** `terraform destroy` 명령은 Terraform 상태 파일에 기록된 모든 리소스를 삭제합니다. 실제 운영 환경에서는 매우 신중하게 사용해야 합니다.

```bash
# 생성된 모든 리소스를 한 번에 삭제
# 실행 계획을 확인하고 'yes'를 입력하면 리소스가 삭제됩니다.
terraform destroy
```

---

## 🚨 **트러블슈팅 (Troubleshooting): 문제 해결 가이드**

Terraform 실습 중 발생할 수 있는 일반적인 문제와 해결 방법을 안내합니다. 오류 메시지를 주의 깊게 읽고, 아래 가이드를 참고하여 문제를 해결해 보세요.

- **`terraform apply` 실패 시:**
  - **오류 메시지 확인:** Terraform은 상세한 오류 메시지를 제공합니다. 메시지를 통해 어떤 리소스에서 어떤 문제가 발생했는지 파악하는 것이 중요합니다.
  - **권한 부족 (IAM):** 클라우드 계정의 IAM 사용자 또는 서비스 계정에 Terraform이 리소스를 생성/수정/삭제할 수 있는 충분한 권한이 부여되었는지 확인하세요. (예: `AdministratorAccess` 또는 필요한 서비스별 권한)
  - **오타 또는 잘못된 리소스 이름:** Terraform 코드 내에 오타가 있거나, 참조하는 리소스 이름이 잘못되었는지 확인하세요.
  - **클라우드 서비스 한도 초과:** 특정 리소스(예: VPC, EC2 인스턴스)의 할당량(Quota)을 초과했는지 확인하세요. 필요한 경우 할당량 증량을 요청해야 합니다.
- **웹 서버에 접속이 안 될 경우:**
  1.  **보안 그룹 (AWS) 또는 방화벽 규칙 (GCP) 확인:** HTTP(80) 포트가 `0.0.0.0/0` (모든 IP) 또는 특정 접근 허용 IP 대역으로 열려 있는지 확인하세요. SSH(22) 포트도 마찬가지입니다.
  2.  **EC2/VM 인스턴스 상태 확인:** 인스턴스가 정상적으로 '실행 중' 상태인지, CPU 사용률이나 시스템 로그에 이상은 없는지 확인하세요.
  3.  **웹 서버 설치 스크립트 (`user_data`/`metadata_startup_script`) 확인:** 스크립트 내용에 오타가 있거나, 웹 서버(Apache/Nginx)가 정상적으로 설치 및 실행되었는지 확인이 필요합니다. 인스턴스에 SSH로 접속하여 직접 확인해 볼 수 있습니다.
  4.  **퍼블릭 IP 주소 확인:** 인스턴스에 퍼블릭 IP 주소가 할당되었는지, 그리고 해당 IP 주소로 접근하고 있는지 확인하세요.

![트러블슈팅](https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=300&fit=crop)

---

## 🎯 **다음 단계: Day 5 - 비용 최적화 및 DevOps 실습**

**다음 Day에서는 클라우드 비용을 효율적으로 관리하고 최적화하는 다양한 전략과 실제 기업들의 성공 사례를 학습합니다. 스타트업의 지속 가능한 성장을 위한 필수 역량인 FinOps(Cloud Financial Operations)의 기초를 다집니다.**

**학습 목표:**
- 클라우드 비용 구조를 이해하고, 비용 낭비 요소를 식별하는 방법 학습
- Right Sizing, 예약 인스턴스/약정 사용 할인, 스토리지 계층화 등 핵심 비용 절감 전략 습득
- 비용 모니터링 도구 활용 및 예산 설정 방법 이해
- 실제 스타트업의 비용 최적화 사례 분석을 통해 실전 적용 능력 강화

![다음 단계](https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=300&fit=crop)

---

## 📚 **추가 학습 자료**

- [Terraform 공식 문서](https://www.terraform.io/docs)
- [AWS Terraform Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Google Cloud Terraform Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Netflix Infrastructure as Code](https://netflixtechblog.com/infrastructure-as-code-at-netflix-9b5b0c3d471c)
- [Spotify's Infrastructure Journey](https://cloud.google.com/blog/products/infrastructure/spotifys-infrastructure-journey)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Google Cloud Architecture Framework](https://cloud.google.com/architecture/framework)
