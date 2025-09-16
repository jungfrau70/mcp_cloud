<div align="center">

## 🏠 최상위 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_container/learning-path.md)

## 📖 현재 위치
**Cloud Container** > **1일차** > **Azure 계정 가입 및 권한 위임 가이드**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Container 메인](/mcp_knowledge_base/cloud_container/README.md) | [다음: Cloud Container 1일차 →](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)

</div>

# Azure 계정 가입 및 권한 위임 가이드

<div align="center">

[← 이전: Cloud Container 메인](/mcp_knowledge_base/cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

## 📋 개요

이 문서는 개인 Microsoft 계정으로 Azure에 가입한 후, 조직용 관리자 계정을 생성하고 권한을 위임하는 전체 과정을 단계별로 안내합니다.

### 🎯 목표
- **개인 메일(Azure 구독 가입 계정)** → **itadmin 계정 생성** → **Entra ID 및 Azure 리소스 전체 권한 위임**

---

## 1️⃣ 기본 개념 정리

### 계정 유형 구분
- **Azure 구독 가입 계정**: `hong.gildong@<domain-name>.com` (Microsoft 계정 MSA)
  - Azure에 처음 가입한 계정
  - 기본적으로 **구독의 Account Administrator** 역할 보유
- **itadmin 계정**: Azure AD(Entra ID)에 새로 만든 조직 계정
  - 예: `itadmin@<tenant>.onmicrosoft.com`

### 권한 구조 이해
Azure에서는 **이중 권한 구조**를 가지고 있습니다:

#### 1️⃣ Entra ID 권한 (디렉토리 관리)
- **Global Administrator**: 사용자, 그룹, 앱 등록, 보안 정책 관리
- **User Administrator**: 사용자 계정 관리
- **Security Administrator**: 보안 설정 관리

#### 2️⃣ Azure 구독 권한 (리소스 관리)  
- **Owner**: 구독 내 모든 리소스 생성/삭제/수정
- **Contributor**: 리소스 생성/수정 (역할 할당 제외)
- **Reader**: 리소스 조회만 가능

> **💡 중요**: 완전한 관리자 권한을 위해서는 **Entra ID 권한**과 **Azure 구독 권한**을 모두 부여해야 합니다.

---

## 2️⃣ itadmin 계정 생성

### 단계별 진행
1. `hong.gildong@<domain-name>.com` 계정으로 [Azure Portal](https://portal.azure.com) 로그인
2. **Microsoft Entra ID** → **사용자(User)** → **새 사용자(New user)**
3. 계정 정보 입력:
   - 사용자 이름: `itadmin@<tenant>.onmicrosoft.com`
   - 초기 암호 생성 → 로그인 후 비밀번호 변경

---

## 3️⃣ Entra ID(조직 디렉토리) 관리자 권한 부여

### Global Administrator 역할 할당
1. **Microsoft Entra ID** → **역할 및 관리자(Roles and administrators)**
2. **Global Administrator** 역할 클릭
3. **할당 추가(Add assignments)** 클릭
4. `itadmin` 사용자 선택 → **추가(Add)**

> ✅ 이렇게 하면 `itadmin`은 디렉토리 전체 관리(사용자/앱 등록/보안 정책 등) 권한을 가집니다.

---

## 4️⃣ Azure 구독(리소스) 관리자 권한 부여

### Owner 역할 할당
1. **구독(Subscriptions)** 메뉴 이동
2. 구독 선택 → **Access Control (IAM)**
3. **+ Add** → **Add role assignment** 클릭
4. 역할 선택: **Owner**
5. 멤버 선택: `itadmin@<tenant>.onmicrosoft.com` → **저장(Save)**

> ✅ 이렇게 하면 `itadmin`은 구독 내 모든 리소스 생성/삭제가 가능합니다.

---

## 5️⃣ 비용 관리 권한 부여

### Billing Administrator 역할 할당
비용 관리와 결제 정보 접근을 위해 추가 권한이 필요합니다.

#### 방법 1: 구독 레벨에서 Billing Administrator 할당
1. **구독(Subscriptions)** 메뉴 이동
2. 구독 선택 → **Access Control (IAM)**
3. **+ Add** → **Add role assignment** 클릭
4. 역할 선택: **Billing Administrator**
5. 멤버 선택: `itadmin@<tenant>.onmicrosoft.com` → **저장(Save)**

#### 방법 2: Billing Account 레벨에서 권한 부여
1. **Cost Management + Billing** 메뉴 이동
2. **Billing accounts** 선택
3. 해당 billing account 선택 → **Access Control (IAM)**
4. **+ Add** → **Add role assignment** 클릭
5. 역할 선택: **Billing Administrator** 또는 **Billing Reader**
6. 멤버 선택: `itadmin@<tenant>.onmicrosoft.com` → **저장(Save)**

### 비용 관리 관련 역할 설명

| 역할 | 권한 범위 | 용도 |
|------|-----------|------|
| **Billing Administrator** | 결제 정보, 청구서, 결제 방법 관리 | 비용 관리자 |
| **Billing Reader** | 결제 정보, 청구서 조회만 가능 | 비용 모니터링 |
| **Cost Management Contributor** | 비용 분석, 예산 설정, 알림 관리 | 비용 최적화 |
| **Cost Management Reader** | 비용 분석, 예산 조회만 가능 | 비용 보고서 |

> 💡 **권장**: `itadmin` 계정에는 **Billing Administrator** + **Cost Management Contributor** 역할을 모두 부여하여 완전한 비용 관리 권한을 제공합니다.

---

## 6️⃣ 최종 점검

### 권한 확인 방법
`itadmin` 계정으로 로그인 후:

1. **Entra ID 권한 확인**:
   - Microsoft Entra ID → 사용자 → `itadmin` → **Assigned roles**
   - **Global Administrator** 표시 확인

2. **Azure 구독 권한 확인**:
   - 구독 → IAM → Role assignments
   - **Owner** 표시 확인

3. **비용 관리 권한 확인**:
   - Cost Management + Billing → Billing accounts → Access Control (IAM)
   - **Billing Administrator** 또는 **Cost Management Contributor** 표시 확인
   - 또는 구독 → IAM에서 **Billing Administrator** 확인

### Billing 관련 권한

Azure는 Role-Based Access Control (RBAC) 방식으로 권한을 부여합니다. Billing 관련 역할은 Subscription 또는 Billing scope에서 할당됩니다.

역할 권한 범위 특징
   - Billing Reader	구독/청구 정보 조회	비용, 청구서, 사용량 데이터 조회 가능
   - Billing Contributor	구독/청구 관리	결제 정보 수정 가능 (카드, 인보이스 등)
   - Cost Management Contributor	비용 관리	Cost Analysis, 예산 설정 가능
   - Owner / Contributor	전체 구독 관리	청구 정보 포함 모든 권한

핵심 특징
   Azure에서는 IAM 사용자 개념 대신 Azure AD 사용자/그룹을 구독 또는 Billing scope에 연결합니다.

**조건부 액세스(Conditions)**를 통해 특정 서비스나 리소스 범위 제한 가능.

---

## ✅ 최종 권한 구조

| 계정 | 역할 | 권한 범위 |
|------|------|-----------|
| `hong.gildong@<domain-name>.com` | Account Administrator | 초기 가입자, 결제 계정 및 백업 관리자 |
| `itadmin@<tenant>.onmicrosoft.com` | Global Administrator + Owner + Billing Administrator | Entra ID + Azure 리소스 + 비용 관리 전체 |

### 상세 권한 내역
- **Global Administrator**: 디렉토리 관리, 사용자/앱 등록, 보안 정책
- **Owner**: 구독 내 모든 리소스 생성/삭제/수정
- **Billing Administrator**: 결제 정보, 청구서, 비용 분석, 예산 관리

> 💡 **결과**: `hong.gildong@<domain-name>.com`은 초기 가입 계정(백업 관리자)으로 두고, 실제 운영은 `itadmin`이 **Entra ID + Azure 리소스 + 비용 관리 풀 관리자** 권한으로 운영할 수 있습니다.

---

## 🔧 자동화 스크립트

### Azure CLI를 이용한 권한 할당 자동화

```bash
# 1. itadmin 계정에 Global Administrator 역할 할당
az ad user show --id "itadmin@<tenant>.onmicrosoft.com" --query objectId -o tsv
az rest --method POST --uri "https://graph.microsoft.com/v1.0/directoryRoles/roleTemplateId=<GlobalAdminRoleTemplateId>/members/$ref" --body '{"@odata.id":"https://graph.microsoft.com/v1.0/users/<itadminObjectId>"}'

# 2. 구독 Owner 역할 할당
az role assignment create \
  --assignee "itadmin@<tenant>.onmicrosoft.com" \
  --role "Owner" \
  --scope "/subscriptions/<subscriptionId>"

# 3. 비용 관리 권한 할당
# Billing Administrator 역할 할당
az role assignment create \
  --assignee "itadmin@<tenant>.onmicrosoft.com" \
  --role "Billing Administrator" \
  --scope "/subscriptions/<subscriptionId>"

# Cost Management Contributor 역할 할당 (선택사항)
az role assignment create \
  --assignee "itadmin@<tenant>.onmicrosoft.com" \
  --role "Cost Management Contributor" \
  --scope "/subscriptions/<subscriptionId>"
```

### PowerShell을 이용한 권한 할당

```powershell
# 1. 구독 Owner 역할 할당
New-AzRoleAssignment -SignInName "itadmin@<tenant>.onmicrosoft.com" -RoleDefinitionName "Owner" -Scope "/subscriptions/<subscriptionId>"

# 2. Billing Administrator 역할 할당
New-AzRoleAssignment -SignInName "itadmin@<tenant>.onmicrosoft.com" -RoleDefinitionName "Billing Administrator" -Scope "/subscriptions/<subscriptionId>"

# 3. Cost Management Contributor 역할 할당
New-AzRoleAssignment -SignInName "itadmin@<tenant>.onmicrosoft.com" -RoleDefinitionName "Cost Management Contributor" -Scope "/subscriptions/<subscriptionId>"
```

---

## 📚 FAQ - 자주 묻는 질문

### Q1: 그룹에 Global Administrator 역할을 할당할 수 있나요?

**A**: 네, 가능합니다. 하지만 **Azure AD Premium P1 이상 라이선스**가 필요합니다.

#### 그룹 기반 역할 할당 방법:
> ⚠️ **주의**: 그룹 기반 역할 할당은 **Azure AD Premium P1 이상**에서만 가능합니다. Free 버전에서는 사용자 단위로만 할당 가능합니다.
1. **Microsoft Entra ID → 그룹(Groups)** → **새 그룹(New group)**
   - 그룹 유형: **보안(Security)**
   - 그룹 이름: `Global-Admins`
2. **Microsoft Entra ID → 역할 및 관리자(Roles and administrators)**
   - `Global Administrator` 선택 → **할당 추가(Add assignments)**
   - **그룹(Group)** 탭 선택 → `Global-Admins` 그룹 선택
3. **Microsoft Entra ID → 그룹(Groups)** → `Global-Admins` → **멤버 추가** → `itadmin` 선택

### Q2: "할당 추가(Add assignments)" 버튼이 안 보여요

**A**: 역할 목록 화면이 아닌 **특정 역할 상세 화면**에서만 나타납니다.

#### 해결 방법:
1. **역할 및 관리자** → **Global Administrator** 역할 이름을 **직접 클릭**
2. "Role | Global Administrator" 세부 화면으로 이동
3. 왼쪽 메뉴에서 **Assignments(할당)** 선택
4. 상단에서 **+ Add assignments** 버튼 확인

### Q3: "Unable to list classic administrators" 경고가 나타나요

**A**: 이는 정상적인 현상입니다. 클래식 관리자와 RBAC 역할 조회 방식의 차이 때문입니다.

#### 원인:
- Azure는 예전 관리 모델(서비스 관리자/공동 관리자)을 RBAC로 전환 중
- MSA 계정의 경우 일부 role assignment 정보 조회 제한
- 기능적 문제가 아닌 **클래식 역할과 RBAC 역할 조회 방식 차이**

> ✅ **해결**: 경고는 무시하고 Owner 역할이 정상적으로 표시되면 문제없습니다.

### Q4: Assigned roles vs Azure role assignments 차이가 뭔가요?

**A**: Azure의 이중 권한 구조로 인해 두 가지 다른 권한 체계가 있습니다.

| 구분 | Assigned roles (Entra ID) | Azure role assignments (RBAC) |
|------|---------------------------|-------------------------------|
| **관리 범위** | 디렉토리 (사용자, 그룹, 앱) | Azure 리소스 (구독, 리소스 그룹, VM 등) |
| **역할 예시** | Global Administrator, User Administrator | Owner, Contributor, Reader |
| **저장 위치** | Entra ID | Azure Resource Manager |
| **계정 유형** | 조직 사용자만 가능 | 조직 사용자 + 외부 사용자(MSA, Guest) 모두 가능 |
| **권한 범위** | 사용자 관리, 보안 정책 | 리소스 생성/수정/삭제 |

#### 확인 방법:
- **Assigned roles**: Microsoft Entra ID → 사용자 → Assigned roles
- **Azure role assignments**: 구독 → IAM → Role assignments 또는 사용자 → Azure role assignments

> **💡 이해하기**: `itadmin`이 완전한 관리자가 되려면 **두 권한 모두** 필요합니다!

### Q5: 비용 관리 권한이 왜 필요한가요?

**A**: Azure 리소스 사용량과 비용을 모니터링하고 관리하기 위해 필요합니다.

#### 비용 관리 권한이 필요한 이유:
- **비용 모니터링**: 리소스별 사용량 및 비용 추적
- **예산 설정**: 월별/연별 예산 한도 설정 및 알림
- **비용 최적화**: 불필요한 리소스 식별 및 정리
- **청구서 관리**: 결제 정보 및 청구서 확인
- **비용 분석**: 부서별/프로젝트별 비용 분석

#### 권장 비용 관리 역할:
- **Billing Administrator**: 결제 정보, 청구서, 결제 방법 관리
- **Cost Management Contributor**: 비용 분석, 예산 설정, 알림 관리

### Q6: Billing Administrator와 Cost Management Contributor의 차이는?

**A**: 관리 범위와 권한이 다릅니다.

| 구분 | Billing Administrator | Cost Management Contributor |
|------|----------------------|---------------------------|
| **결제 관리** | ✅ 결제 정보, 청구서, 결제 방법 관리 | ❌ 결제 정보 접근 불가 |
| **비용 분석** | ✅ 비용 분석 조회 | ✅ 비용 분석 조회 및 생성 |
| **예산 관리** | ❌ 예산 설정 불가 | ✅ 예산 설정 및 알림 관리 |
| **리소스 태깅** | ❌ 태깅 불가 | ✅ 비용 할당을 위한 태깅 관리 |

> 💡 **권장**: 완전한 비용 관리를 위해서는 **두 역할을 모두** 부여하는 것이 좋습니다.

---

## 🔐 보안 권장사항

### MFA(다중 인증) 설정
- `itadmin` 계정에는 반드시 **MFA 활성화** 권장
- 높은 권한을 가진 계정의 보안 강화 필수

### 그룹 기반 권한 관리 (Premium 라이선스 필요)
- **Azure AD Premium P1 이상**에서 그룹 단위 역할 할당 가능
- 보안상 최소한의 계정만 관리자 그룹에 포함
- 정기적인 권한 검토 및 감사 로그 모니터링

---

## 🚀 다음 단계

### 추가 학습 자료
- [Azure RBAC 공식 문서](https://docs.microsoft.com/ko-kr/azure/role-based-access-control/)
- [Microsoft Entra ID 관리자 역할](https://docs.microsoft.com/ko-kr/azure/active-directory/roles/permissions-reference)
- [Azure CLI를 이용한 역할 관리](https://docs.microsoft.com/ko-kr/azure/role-based-access-control/role-assignments-cli)

### 자동화 확장
- PowerShell 스크립트를 이용한 대량 사용자 권한 관리
- Azure Policy를 이용한 권한 정책 자동화
- 조건부 액세스를 이용한 보안 정책 적용

---

## 📞 문제 해결

### 일반적인 오류 및 해결방법
1. **권한 부족 오류**: Global Administrator 권한이 필요한 작업인지 확인
2. **사용자 검색 실패**: UPN(User Principal Name) 형식으로 정확히 입력
3. **역할 할당 실패**: 구독 범위와 역할 정의 확인

### 지원 채널
- [Azure 지원 센터](https://azure.microsoft.com/ko-kr/support/)
- [Microsoft 커뮤니티 포럼](https://docs.microsoft.com/ko-kr/answers/topics/azure-active-directory.html)



---

<div align="center">

## 🔗 관련 과정 및 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_container/learning-path.md)

## 📖 현재 위치
**Cloud Container** > **1일차** > **Azure 계정 가입 및 권한 위임 가이드**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Container 메인](/mcp_knowledge_base/cloud_container/README.md) | [다음: Cloud Container 1일차 →](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)

## 🔗 관련 과정
[Cloud Master 3일차](/mcp_knowledge_base/cloud_master/textbook/Day3/README.md) | [Cloud Basic 1일차](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md)

</div>