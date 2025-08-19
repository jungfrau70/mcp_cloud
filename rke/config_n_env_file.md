모듈화된 코드에서는 **config 파일과 env 파일을 모두 사용** 하여, 코드의 유연성과 관리 편의성을 극대화했습니다!

## 설정 파일과 환경 변수 파일의 역할

### 1. **YAML Config 파일** (`config/rke2-monitoring.yaml`)
- **목적**: 시스템 전체의 기본 설정 및 점검 범위 제어
- **특징**: 
  - 구조화된 설정 (YAML 형식)
  - 점검 항목별 활성화/비활성화
  - 보안, 성능, 로깅 등 세부 설정
  - 모든 스크립트가 공유하는 중앙 설정

### 2. **환경 변수 파일** (`.env`)
- **목적**: 런타임 설정 및 환경별 오버라이드
- **특징**:
  - 실행 시점의 동적 설정
  - 환경별 차이점 관리
  - 민감한 정보 (경로, URL 등)
  - Config 파일의 설정을 오버라이드

## 사용 방법

### 설정 우선순위
```bash
1. 명령행 인수 (최우선)
2. 환경 변수 파일 (.env)
3. YAML 설정 파일 (config.yaml)
4. 기본값 (하드코딩)
```

### 실제 사용 예시

#### **1. YAML Config 파일 설정**
```yaml
# config/rke2-monitoring.yaml
defaults:
  timeout: 30
  log_dir: "./logs"
  log_level: "INFO"

rke2:
  config_path: "/etc/rancher/rke2"
  kubeconfig: "/etc/rancher/rke2/rke2.yaml"

checks:
  24x7:
    cluster_info: true
    control_plane: true
    rke2_specific: true
```

#### **2. 환경 변수 파일 설정**
```bash
# 24x7_rke2_check.env
export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
export RKE2_CONFIG_PATH="/etc/rancher/rke2"
export LOG_DIR="./logs"
export LOG_LEVEL="DEBUG"  # YAML의 INFO를 오버라이드
export TIMEOUT=60         # YAML의 30을 오버라이드
```

#### **3. 스크립트 실행**
```bash
# 기본 실행 (config.yaml + .env 파일 사용)
./24x7_rke2_check_modular.sh

# 사용자 정의 설정 파일 사용
./24x7_rke2_check_modular.sh -c /path/to/custom-config.yaml

# 사용자 정의 환경 변수 파일 사용
./24x7_rke2_check_modular.sh -e /path/to/custom.env

# 둘 다 사용자 정의
./24x7_rke2_check_modular.sh -c custom-config.yaml -e custom.env
```

## 코드에서의 처리 순서

```bash
# 1. YAML 설정 파일 로드
init_config "$CONFIG_FILE"

# 2. 환경 변수 파일 로드 (YAML 설정을 오버라이드)
if [[ -f "$ENV_FILE" ]]; then
    source "$ENV_FILE"
fi

# 3. 명령행 인수 처리 (환경 변수를 오버라이드)
parse_arguments "$@"
```

## 실제 활용 시나리오

### **시나리오 1: 개발/운영 환경 분리**
```bash
# 개발 환경
config/dev-config.yaml:
  log_level: "DEBUG"
  timeout: 60

dev.env:
  KUBECONFIG="/home/dev/.kube/config"
  LOG_DIR="./dev-logs"

# 운영 환경  
config/prod-config.yaml:
  log_level: "INFO"
  timeout: 30

prod.env:
  KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
  LOG_DIR="/var/log/rke2-monitoring"
```

### **시나리오 2: 점검 범위 제어**
```yaml
# config/rke2-monitoring.yaml
checks:
  24x7:
    cluster_info: true
    control_plane: true
    rke2_specific: true
    rke2_etcd: false        # etcd 점검 비활성화
    rke2_containerd: false  # containerd 점검 비활성화
```

```bash
# 24x7_rke2_check.env
export ENABLE_ETCD_CHECKS=true      # YAML 설정을 오버라이드
export ENABLE_CONTAINERD_CHECKS=true
```

### **시나리오 3: 보안 설정**
```yaml
# config/rke2-monitoring.yaml
security:
  mask_sensitive_info: true
  validate_commands: true
  check_certificate_expiry: true
```

```bash
# 24x7_rke2_check.env
export MASK_SENSITIVE_INFO=true
export VALIDATE_COMMANDS=true
export CERTIFICATE_WARNING_DAYS=7  # 기본값 30일에서 변경
```

## 장점

### **1. 유연성**
- YAML: 구조화된 설정 관리
- ENV: 런타임 동적 설정

### **2. 환경 분리**
- 개발/테스트/운영 환경별 설정
- 민감한 정보 분리

### **3. 오버라이드 지원**
- 설정 우선순위에 따른 유연한 제어
- 부분적 설정 변경 가능

### **4. 유지보수성**
- 중앙화된 설정 관리
- 버전 관리 용이

---