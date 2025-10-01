터미널 로그를 보니 CloudFormation 스택이 이미 존재한다는 오류가 발생했네요. 이 문제를 해결해보겠습니다.

Ran tool
CloudFormation 스택이 이미 존재한다는 오류가 발생했습니다. 이는 이전에 EKS 클러스터 생성이 실패했지만 CloudFormation 스택은 남아있기 때문입니다. 다음 단계로 해결해보겠습니다:

## 🔍 문제 진단

### **현재 상황**
- CloudFormation 스택 `eksctl-eks-intermediate-cluster`가 이미 존재
- EKS 클러스터는 생성되지 않았지만 스택만 남아있음
- 이로 인해 새로운 클러스터 생성이 실패

## 🛠️ 해결 방법

### **1. CloudFormation 스택 상태 확인**
```bash
# CloudFormation 스택 목록 확인
aws cloudformation list-stacks --region ap-northeast-2 --query 'StackSummaries[?contains(StackName, `eksctl-eks-intermediate`)].{Name:StackName,Status:StackStatus,CreationTime:CreationTime}' --output table

# 특정 스택 상세 정보 확인
aws cloudformation describe-stacks --region ap-northeast-2 --stack-name eksctl-eks-intermediate-cluster
```

### **2. 기존 스택 삭제**
```bash
# CloudFormation 스택 삭제
aws cloudformation delete-stack --region ap-northeast-2 --stack-name eksctl-eks-intermediate-cluster

# 삭제 완료까지 대기
aws cloudformation wait stack-delete-complete --region ap-northeast-2 --stack-name eksctl-eks-intermediate-cluster
```

### **3. eksctl을 사용한 정리**
```bash
# eksctl로 클러스터 삭제 (스택도 함께 삭제)
eksctl delete cluster --region ap-northeast-2 --name eks-intermediate

# 또는 강제 삭제
eksctl delete cluster --region ap-northeast-2 --name eks-intermediate --force
```

### **4. 수동 정리 스크립트 실행**
```bash
# comprehensive-cleanup.sh 실행
./comprehensive-cleanup.sh --provider aws --cleanup-type eks
```

## 🔧 개선된 EKS Helper 스크립트

기존 스크립트에 CloudFormation 스택 정리 기능을 추가하는 것을 권장합니다:

```bash
# EKS Helper에 스택 정리 기능 추가
./aws-eks-helper.sh --action cleanup-stacks
```

## 📋 권장 해결 순서

1. **현재 상태 확인**
   ```bash
   aws cloudformation list-stacks --region ap-northeast-2 --query 'StackSummaries[?contains(StackName, `eksctl-eks-intermediate`)].{Name:StackName,Status:StackStatus}' --output table
   ```

2. **스택 삭제**
   ```bash
   aws cloudformation delete-stack --region ap-northeast-2 --stack-name eksctl-eks-intermediate-cluster
   ```

3. **삭제 완료 대기**
   ```bash
   aws cloudformation wait stack-delete-complete --region ap-northeast-2 --stack-name eksctl-eks-intermediate-cluster
   ```

4. **EKS 클러스터 재생성**
   ```bash
   ./aws-eks-helper.sh --action cluster-create
   ```

## ⚠️ 주의사항

- CloudFormation 스택 삭제는 **비가역적**입니다
- 삭제 중에는 다른 AWS 리소스 생성이 지연될 수 있습니다
- 삭제 완료까지 **5-10분** 정도 소요될 수 있습니다

이 방법으로 CloudFormation 스택 문제를 해결하고 EKS 클러스터를 정상적으로 생성할 수 있습니다.