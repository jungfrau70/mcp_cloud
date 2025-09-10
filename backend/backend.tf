# Terraform 및 Google Provider 설정
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  # GCS 버킷이 생성된 후, 이 부분을 활성화하여 원격 상태 저장소로 사용합니다.
  backend "gcs" {
    bucket  = "mcp-tfstate-bucket-alpha-ktixap" # GCS 버킷 이름
    prefix  = "terraform/state"
  }
}

provider "google" {
  project     = "alpha-ktixap"
  region      = "asia-northeast3" # 서울 리전
  credentials = file("C:/Users/JIH/githubs/mcp_cloud/backend/env/alpha-ktixap-43e9bf90eb00.json")
}

# Terraform 상태 파일을 저장할 GCS 버킷을 생성합니다.
resource "google_storage_bucket" "tfstate" {
  name          = "mcp-tfstate-bucket-alpha-ktixap" # 버킷 이름은 전역적으로 고유해야 합니다.
  location      = "ASIA-NORTHEAST3"
  force_destroy = false # 실수로 버킷이 삭제되는 것을 방지

  storage_class = "STANDARD"
  uniform_bucket_level_access = true

  versioning {
    enabled = true # 상태 파일의 변경 이력을 추적하기 위해 버전 관리를 활성화합니다.
  }

  lifecycle {
    prevent_destroy = true # terraform destroy 명령으로 버킷이 삭제되는 것을 방지합니다.
  }
}
