아키텍처(허브-스포크, Bastion→Jumpbox, 각 리전 웹 VM, 80포트 제공)에 맞춰 **Azure CLI로 한 번에 배포**할 수 있는 스크립트. 서울(Korea Central)과 뉴욕(East US)을 사용했고, Jumpbox는 허브 VNet에, 각 리전의 웹 서버 VM은 스포크 VNet에 배치하고 허브↔스포크 피어링을 맺습니다. 각 리전에는 퍼블릭 **Standard Load Balancer**(80/TCP)로 외부 트래픽을 받고, 운영자는 **Azure Bastion**을 통해 Jumpbox로 진입합니다. 

 **Cloud Shell(Bash)**  (로컬이라면 `az login` 선행)

> 기본값
>
> * 서울: `koreacentral` / 뉴욕: `eastus`
> * Jumpbox: Windows Server 2022 (Bastion로 RDP)
> * 웹서버: Ubuntu 22.04 + *custom data*로 Apache 자동설치
> * 각 리전별 Standard Public Load Balancer(frontend IP) 제공

---

### 1) 배포 스크립트 (한 번에 실행)

```bash
# =====[ 변수 ]=====
PREFIX="webhub"
RG_HUB="${PREFIX}-rg-hub"
RG_SEOUL="${PREFIX}-rg-seoul"
RG_NY="${PREFIX}-rg-ny"

LOC_HUB="koreacentral"   # 서울(허브)
LOC_SEOUL="koreacentral" # 서울(스포크)
LOC_NY="eastus"          # 뉴욕(스포크)

# 주소공간 (충돌 시 조정)
HUB_CIDR="10.5.0.0/16"
HUB_JUMPBOX_SUBNET="10.5.1.0/24"
HUB_BASTION_SUBNET="10.5.254.0/26"

SEOUL_VNET_CIDR="10.10.0.0/16"
SEOUL_WEB_SUBNET="10.10.1.0/24"

NY_VNET_CIDR="10.20.0.0/16"
NY_WEB_SUBNET="10.20.1.0/24"

# 관리자 계정(테스트용, 실제 운영은 키볼트/비밀관리 권장)
JUMPBOX_ADMIN="opsadmin"
JUMPBOX_PASSWORD="$(openssl rand -base64 18)!"

WEB_ADMIN="azureuser"

# =====[ 0. custom data 파일 생성 ]=====
cat > apache-init.sh << 'EOF'
#!/bin/bash
sudo apt-get update
sudo apt-get install -y apache2
echo "Hello, World!" | sudo tee /var/www/html/index.html
sudo systemctl restart apache2
EOF

# =====[ 1. 리소스 그룹 ]=====
az group create -n "$RG_HUB"   -l "$LOC_HUB"
az group create -n "$RG_SEOUL" -l "$LOC_SEOUL"
az group create -n "$RG_NY"    -l "$LOC_NY"

# =====[ 2. 허브 VNet + 서브넷(Bastion/Jumpbox) ]=====
az network vnet create -g "$RG_HUB" -n "${PREFIX}-hub-vnet" \
  --location "$LOC_HUB" --address-prefixes $HUB_CIDR \
  --subnet-name JumpboxSubnet --subnet-prefixes $HUB_JUMPBOX_SUBNET

az network vnet subnet create -g "$RG_HUB" \
  --vnet-name "${PREFIX}-hub-vnet" -n AzureBastionSubnet \
  --address-prefixes $HUB_BASTION_SUBNET

# =====[ 3. Bastion ]=====
az network public-ip create -g "$RG_HUB" -n "${PREFIX}-bastion-pip" \
  --sku Standard --allocation-method Static

az network bastion create -g "$RG_HUB" -n "${PREFIX}-bastion" \
  --public-ip-address "${PREFIX}-bastion-pip" \
  --vnet-name "${PREFIX}-hub-vnet" \
  --location "$LOC_HUB"

# =====[ 4. Jumpbox (Windows, 허브 VNet, Public IP 없음) ]=====
az vm create -g "$RG_HUB" -n "${PREFIX}-jumpbox" \
  --image Win2022Datacenter --size Standard_B2s \
  --admin-username "$JUMPBOX_ADMIN" --admin-password "$JUMPBOX_PASSWORD" \
  --vnet-name "${PREFIX}-hub-vnet" --subnet JumpboxSubnet \
  --public-ip-address "" --nsg "" --only-show-errors

echo ">>> Jumpbox 임시 비밀번호: $JUMPBOX_PASSWORD"

# =====[ 5. 스포크 VNet (서울/뉴욕) ]=====
az network vnet create -g "$RG_SEOUL" -n "${PREFIX}-vnet-seoul" \
  --location "$LOC_SEOUL" --address-prefixes $SEOUL_VNET_CIDR \
  --subnet-name WebSubnet --subnet-prefixes $SEOUL_WEB_SUBNET

az network vnet create -g "$RG_NY" -n "${PREFIX}-vnet-ny" \
  --location "$LOC_NY" --address-prefixes $NY_VNET_CIDR \
  --subnet-name WebSubnet --subnet-prefixes $NY_WEB_SUBNET

# =====[ 6. 허브-스포크 피어링 (양방향) ]=====
# 허브 → 서울
az network vnet peering create -g "$RG_HUB" \
  -n hub-to-seoul --vnet-name "${PREFIX}-hub-vnet" \
  --remote-vnet "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG_SEOUL/providers/Microsoft.Network/virtualNetworks/${PREFIX}-vnet-seoul" \
  --allow-vnet-access

# 서울 → 허브
az network vnet peering create -g "$RG_SEOUL" \
  -n seoul-to-hub --vnet-name "${PREFIX}-vnet-seoul" \
  --remote-vnet "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG_HUB/providers/Microsoft.Network/virtualNetworks/${PREFIX}-hub-vnet" \
  --allow-vnet-access

# 허브 → 뉴욕
az network vnet peering create -g "$RG_HUB" \
  -n hub-to-ny --vnet-name "${PREFIX}-hub-vnet" \
  --remote-vnet "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG_NY/providers/Microsoft.Network/virtualNetworks/${PREFIX}-vnet-ny" \
  --allow-vnet-access

# 뉴욕 → 허브
az network vnet peering create -g "$RG_NY" \
  -n ny-to-hub --vnet-name "${PREFIX}-vnet-ny" \
  --remote-vnet "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG_HUB/providers/Microsoft.Network/virtualNetworks/${PREFIX}-hub-vnet" \
  --allow-vnet-access

# =====[ 7. 리전별 Public Load Balancer (80/TCP) ]=====
# 서울
az network public-ip create -g "$RG_SEOUL" -n "${PREFIX}-pip-seoul" \
  --sku Standard --allocation-method Static
az network lb create -g "$RG_SEOUL" -n "${PREFIX}-lb-seoul" --sku Standard \
  --public-ip-address "${PREFIX}-pip-seoul" \
  --frontend-ip-name fe1 --backend-pool-name be1
az network lb probe create -g "$RG_SEOUL" --lb-name "${PREFIX}-lb-seoul" \
  -n httpProbe --protocol tcp --port 80
az network lb rule create -g "$RG_SEOUL" --lb-name "${PREFIX}-lb-seoul" \
  -n http80 --protocol tcp --frontend-port 80 --backend-port 80 \
  --frontend-ip-name fe1 --backend-pool-name be1 --probe-name httpProbe

# 뉴욕
az network public-ip create -g "$RG_NY" -n "${PREFIX}-pip-ny" \
  --sku Standard --allocation-method Static
az network lb create -g "$RG_NY" -n "${PREFIX}-lb-ny" --sku Standard \
  --public-ip-address "${PREFIX}-pip-ny" \
  --frontend-ip-name fe1 --backend-pool-name be1
az network lb probe create -g "$RG_NY" --lb-name "${PREFIX}-lb-ny" \
  -n httpProbe --protocol tcp --port 80
az network lb rule create -g "$RG_NY" --lb-name "${PREFIX}-lb-ny" \
  -n http80 --protocol tcp --frontend-port 80 --backend-port 80 \
  --frontend-ip-name fe1 --backend-pool-name be1 --probe-name httpProbe

# =====[ 8. 리눅스 웹서버 VM (custom data로 Apache 설치) ]=====
# 서울 VM
az vm create -g "$RG_SEOUL" -n "${PREFIX}-vm-seoul" \
  --image Ubuntu2204 --size Standard_B1s \
  --admin-username "$WEB_ADMIN" --generate-ssh-keys \
  --custom-data ./apache-init.sh \
  --vnet-name "${PREFIX}-vnet-seoul" --subnet WebSubnet \
  --public-ip-address "" --nsg "" --only-show-errors

# 뉴욕 VM
az vm create -g "$RG_NY" -n "${PREFIX}-vm-ny" \
  --image Ubuntu2204 --size Standard_B1s \
  --admin-username "$WEB_ADMIN" --generate-ssh-keys \
  --custom-data ./apache-init.sh \
  --vnet-name "${PREFIX}-vnet-ny" --subnet WebSubnet \
  --public-ip-address "" --nsg "" --only-show-errors

# =====[ 9. 웹서버 NIC을 LB 백엔드 풀에 연결 ]=====
# 서울
az network nic ip-config address-pool add \
  --address-pool be1 --lb-name "${PREFIX}-lb-seoul" \
  --nic-name "${PREFIX}-vm-seoulVMNic" \
  -g "$RG_SEOUL" --ip-config-name ipconfig1

# 뉴욕
az network nic ip-config address-pool add \
  --address-pool be1 --lb-name "${PREFIX}-lb-ny" \
  --nic-name "${PREFIX}-vm-nyVMNic" \
  -g "$RG_NY" --ip-config-name ipconfig1

# =====[ 10. 결과 확인: LB 퍼블릭 IP ]=====
echo "==== 서울 LB IP ===="
az network public-ip show -g "$RG_SEOUL" -n "${PREFIX}-pip-seoul" --query ipAddress -o tsv
echo "==== 뉴욕 LB IP ===="
az network public-ip show -g "$RG_NY" -n "${PREFIX}-pip-ny" --query ipAddress -o tsv

echo "---- 배포 완료 ----"
```

---

### 2) 접속/검증 방법

* **운영자 → Jumpbox**
  Azure Portal → Bastion에서 `${PREFIX}-jumpbox` 선택 후 **RDP**로 접속 (Public IP 필요 없음).
  (Bastion는 443/TCP로만 노출, Jumpbox는 내부 통신만)

* **사용자 웹접속(80/TCP)**
  위 스크립트 마지막에 출력된 각 리전 **LB 공인 IP**로 접속

  ```
  http://<서울_LB_IP>   → Hello, World!
  http://<뉴욕_LB_IP>   → Hello, World!
  ```

* **리눅스 VM에 직접 SSH (운영자 경유)**
  Bastion → Jumpbox(RDP) → 각 리전 VM(SSH, 22/TCP)
  (허브-스포크 피어링으로 내부 라우팅 연결)

---

### 3) 선택 옵션 (원하면 추가)

* **글로벌 엔드포인트**로 단일 URL을 쓰고 싶다면
  `Azure Traffic Manager`(Priority/Performance) 또는 `Azure Front Door`를 두 LB 프런트에 얹으면 됩니다.
  *Traffic Manager 예시(요약)*:

  1. 두 LB의 Public IP에 **DNS 라벨**을 달고(FQDN 확보)
  2. `az network traffic-manager profile create` → `external-endpoint`로 두 리전을 등록하면 끝.

---

### 4) 보안/운영 팁

* Jumpbox/웹서버 모두 **Public IP 없이** 운영(Bastion, LB만 Public).
* NSG는 기본 `AllowAzureLoadBalancerInBound` 규칙으로 80 트래픽 허용됩니다. 더 엄격히 하려면 **웹 서브넷 NSG**에서

  * Inbound 80: Source = `AzureLoadBalancer`만 허용
  * SSH(22)/RDP(3389)는 **허브 VNet**에서만 허용(인터넷 차단)
* 운영 시 비밀번호 대신 **SSH 키/Key Vault** 사용 권장.

---
