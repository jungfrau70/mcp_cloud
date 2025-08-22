# RKE2 모니터링 시스템 (모듈화 버전)

## 개요

RKE2 클러스터를 위한 모듈화된 모니터링 시스템입니다. 
공통 라이브러리를 사용하여 코드 재사용성을 높이고, YAML 설정 파일을 통해 유연한 설정이 가능하게 했습니다.

## 주요 특징

- **모듈화된 구조**: 공통 라이브러리를 통한 코드 재사용
- **설정 파일 기반**: YAML 설정 파일로 유연한 설정
- **RKE2 특화**: RKE2 아키텍처에 최적화된 점검 기능
- **서비스 체크 통합**: HTTP/HTTPS 서비스 상태 자동 체크
- **보안 강화**: 민감 정보 마스킹 및 명령어 검증
- **HTML 보고서**: 시각적 보고서 생성
- **명령행 인터페이스**: 다양한 옵션 지원

## 디렉토리 구조

```
rke/
├── lib/                          # 공통 라이브러리
│   ├── rke2_common.sh           # 기본 공통 함수
│   ├── rke2_logging.sh          # 로깅 관련 함수
│   ├── rke2_security.sh         # 보안 관련 함수
│   ├── rke2_monitoring.sh       # 모니터링 관련 함수 (서비스 체크 포함)
│   └── rke2_config.sh           # 설정 파일 파서
├── config/                       # 설정 파일
│   └── rke2-monitoring.yaml     # 메인 설정 파일
├── 24x7_rke2_check.sh   # 24x7 모니터링 스크립트
├── rke2_check.sh        # 플랫폼 점검 스크립트
├── rke2_pod.sh          # 파드 점검 스크립트
├── *.env.template               # 환경 변수 템플릿
└── README.md            # 이 파일
```

## 설치 및 설정

### 1. 필수 도구 설치

```bash
# 필수 도구
sudo apt-get install jq yq python3-yaml

# 또는 CentOS/RHEL
sudo yum install jq yq python3-pyyaml
```

### 2. 환경 변수 설정

```bash
# 환경 변수 파일 복사 및 편집
cp 24x7_rke2_check.env.template 24x7_rke2_check.env
vi 24x7_rke2_check.env

# 주요 설정
export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
export RKE2_CONFIG_PATH="/etc/rancher/rke2"
export LOG_DIR="./logs"
export LOG_LEVEL="INFO"
```

### 3. 실행 권한 설정

```bash
chmod +x lib/*.sh *.sh
```

## 사용법

### 24x7 모니터링

```bash
# 기본 설정으로 실행
./24x7_rke2_check.sh

# 사용자 정의 설정 파일 사용
./24x7_rke2_check.sh -c /path/to/config.yaml

# 환경 변수 파일 지정
./24x7_rke2_check.sh -e /path/to/env.file

# 도움말
./24x7_rke2_check.sh -h
```

### 서비스 체크 기능

모든 모니터링 스크립트에 HTTP/HTTPS 서비스 체크가 통합되어 있습니다:

```bash
# 24x7 모니터링 (서비스 체크 포함)
./24x7_rke2_check.sh

# 플랫폼 점검 (서비스 체크 포함)
./rke2_check.sh

# 파드 점검 (해당 네임스페이스 서비스 체크 포함)
./rke2_pod.sh -n kube-system
```

**자동 체크되는 서비스들:**
- Kubernetes API 서버
- RKE2 핵심 서비스 (메트릭 서버, 컨트롤러 매니저, 스케줄러)
- NodePort/LoadBalancer 애플리케이션 서비스
- 사용자 정의 서비스 (환경 변수로 설정)
- 네트워크 연결성
```

### 플랫폼 점검

```bash
# 기본 실행
./rke2_check.sh

# 설정 파일 지정
./rke2_check.sh -c /path/to/config.yaml
```

### 파드 점검

```bash
# 전체 네임스페이스 점검
./rke2_pod.sh

# 특정 네임스페이스만 점검
./rke2_pod.sh -n kube-system

# 설정 파일 지정
./rke2_pod.sh -c /path/to/config.yaml
```

## 설정 파일

### YAML 설정 파일 구조

```yaml
# 기본 설정
defaults:
  timeout: 30
  log_dir: "./logs"
  log_level: "INFO"
  retention_days: 30

# RKE2 특화 설정
rke2:
  config_path: "/etc/rancher/rke2"
  data_dir: "/var/lib/rancher/rke2"
  kubeconfig: "/etc/rancher/rke2/rke2.yaml"

# 점검 범위 설정
checks:
  24x7:
    cluster_info: true
    control_plane: true
    rke2_specific: true
    service_checks: true  # 서비스 체크 활성화
    # ... 기타 설정

  platform:
    cluster_config: true
    service_checks: true  # 플랫폼 점검에 서비스 체크 포함

  pod:
    pod_status: true
    service_checks: true  # 파드 점검에 서비스 체크 포함

# 서비스 체크 세부 설정
service_check:
  kubernetes_api: true
  rke2_services: true
  application_services: true
  custom_services: true
  network_connectivity: true
  http_timeout: 10
  https_timeout: 10
  expected_status: 200

# 보안 설정
security:
  mask_sensitive_info: true
  validate_commands: true
  check_certificate_expiry: true
```

### 환경 변수 파일

```bash
# 필수 설정
export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
export RKE2_CONFIG_PATH="/etc/rancher/rke2"

# 로깅 설정
export LOG_LEVEL="INFO"
export LOG_DIR="./logs"
export TIMEOUT=30

# 모니터링 설정
export ENABLE_METRICS=true
export ENABLE_LOGS=true
export ENABLE_SECURITY_CHECKS=true
```

## 출력 파일

### 로그 파일
- 위치: `$LOG_DIR/`
- 형식: `{스크립트명}_{YYYYMMDD_HHMMSS}.log`
- 내용: 상세한 점검 결과 및 오류 정보

### HTML 보고서
- 위치: `$LOG_DIR/`
- 형식: `{스크립트명}_{YYYYMMDD_HHMMSS}.html`
- 내용: 시각적 보고서 (색상 구분, 테이블 형식)

## 라이브러리 설명

### rke2_common.sh
- 기본 공통 함수들
- 환경 변수 초기화
- 필수 도구 검증
- 유틸리티 함수들

### rke2_logging.sh
- 로그 메시지 출력
- HTML 보고서 생성
- 로그 파일 관리
- 색상 코드 정의

### rke2_security.sh
- 민감 정보 마스킹
- 명령어 검증
- 파일 권한 검증
- 인증서 만료 확인

### rke2_monitoring.sh
- 안전한 명령어 실행
- RKE2 특화 점검 함수들
- 클러스터 상태 점검
- 파드 상태 점검
- **서비스 체크 함수들** (HTTP/HTTPS, Kubernetes API, RKE2 서비스 등)

### rke2_config.sh
- YAML 설정 파일 파싱
- 환경 변수 변환
- 설정 검증
- 기본값 적용

## 점검 항목

### 24x7 모니터링
- 클러스터 정보
- 컨트롤 플레인 상태
- 노드 상태
- 네임스페이스/파드 상태
- 스토리지 및 인프라
- RKE2 특화 구성
- etcd 상태
- containerd 상태
- 보안 설정
- 로그 분석
- **서비스 체크** (HTTP/HTTPS 상태)

### 플랫폼 점검
- 클러스터 구성
- 노드 역할
- 네트워크 상태
- 스토리지 상태
- 메트릭 서버
- 보안 정책
- 모니터링 도구
- **서비스 체크** (전체 클러스터 서비스)

### 파드 점검
- 파드 상태
- 리소스 사용량
- 네트워킹
- 볼륨 상태
- 로그 분석
- 보안 설정
- containerd 컨테이너
- **서비스 체크** (해당 네임스페이스 서비스)

## 보안 기능

### 민감 정보 마스킹
- UUID, 토큰, 인증서
- Azure 관련 정보
- SSH 키, 비밀번호
- RKE2 특화 정보

### 명령어 검증
- 허용된 명령어 패턴 확인
- 명령어 인젝션 방지
- 타임아웃 설정
- 재시도 메커니즘

### 파일 권한 검증
- 설정 파일 권한 확인
- 인증서 디렉토리 권한 확인
- 보안 정책 적용

## 성능 최적화

### 병렬 처리
- 설정 가능한 병렬 실행
- 최대 병렬 작업 수 제한
- 리소스 사용량 최적화

### 캐싱
- 설정 파일 캐싱
- 명령어 결과 캐싱
- 중복 실행 방지

### 로그 관리
- 로그 로테이션
- 압축 및 정리
- 보존 기간 설정

## 문제 해결

### 일반적인 문제

1. **YAML 파서 오류**
   ```bash
   # yq 또는 python3 설치 확인
   which yq || which python3
   ```

2. **권한 오류**
   ```bash
   # 실행 권한 확인
   ls -la *.sh
   chmod +x *.sh
   ```

3. **kubectl 연결 오류**
   ```bash
   # KUBECONFIG 확인
   echo $KUBECONFIG
   kubectl cluster-info
   ```

### 디버깅

```bash
# DEBUG 레벨로 실행
export LOG_LEVEL="DEBUG"
./24x7_rke2_check.sh

# 설정 정보 출력
./24x7_rke2_check.sh -v
```

## 업그레이드

### 버전 관리
- 라이브러리 버전: `RKE2_COMMON_VERSION`
- 스크립트 버전: `SCRIPT_VERSION`
- 호환성 확인 필요

### 마이그레이션
1. 기존 환경 변수 파일 백업
2. 새 설정 파일 적용
3. 테스트 실행
4. 점진적 전환

## 기여

### 개발 가이드라인
- 공통 라이브러리 사용
- 설정 파일 기반 구조
- 보안 기능 포함
- 문서화 필수

### 테스트
- 구문 검증: `bash -n script.sh`
- 기능 테스트: 실제 RKE2 환경
- 보안 테스트: 민감 정보 마스킹

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 지원

문제가 발생하면 다음을 확인하세요:
1. 설정 파일 문법
2. 환경 변수 설정
3. 필수 도구 설치
4. 권한 설정
5. 로그 파일 내용
