# Terraform 사용 가이드

## 워크스페이스 전략
```
terraform workspace new dev
terraform workspace new stage
terraform workspace new prod
terraform workspace select dev
```

## tfvars 샘플
- 경로: `cloud_basic/automation/terraform/env/dev.tfvars`
```
project     = "cloud-basic"
department  = "it"
env         = "dev"
owner       = "student"
cost_center = "training"
region      = "ap-northeast-2"
```

## 실행 예
```
cd cloud_basic/automation/terraform/aws/ch2_vm
terraform init
terraform workspace select dev || terraform workspace new dev
terraform apply -var-file=../env/dev.tfvars -auto-approve
```
