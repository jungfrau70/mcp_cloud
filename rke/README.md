# RKE2 모니터링 시스템 통합 사용설명서

## 개요

RKE2 클러스터를 위한 두 가지 버전의 모니터링 시스템을 제공:
- **v1 (단일 스크립트 버전)**: 간단하고 직관적인 단일 파일 구조
- **v2 (모듈화 버전)**: 재사용 가능한 라이브러리와 설정 파일 기반 구조

## 버전 비교 및 선택 가이드

### v1 (단일 스크립트 버전) - `rke_v1/`

**적합한 사용자:**
- 빠른 설정과 즉시 사용이 필요한 경우
- 단순한 환경에서 기본 모니터링만 필요한 경우
- Azure VM + RHEL9 OS 환경에 특화된 기능이 필요한 경우

**주요 특징:**
- 각 스크립트가 독립적으로 동작
- 환경 변수 파일 기반 설정
- Azure + RHEL9 환경 최적화
- 단순한 구조로 쉬운 이해와 수정
- **서비스 체크**: HTTP/HTTPS 서비스 상태 점검 (별도 스크립트)

**구조:**
```
rke_v1/
├── 24x7_rke2_check.sh           # 24x7 모니터링
├── rke2_check.sh                # 플랫폼 점검
├── rke2_pod.sh                  # 파드 점검
├── *.env.template               # 환경 변수 템플릿
└── RKE2_SPECIFIC_CONSIDERATIONS.md
```

### v2 (모듈화 버전) - `rke_v2/`

**적합한 사용자:**
- 대규모 환경에서 일관된 모니터링이 필요한 경우
- 설정 파일을 통한 유연한 구성이 필요한 경우
- 코드 재사용성과 유지보수성이 중요한 경우
- 다양한 환경에서 사용할 계획이 있는 경우

**주요 특징:**
- 공통 라이브러리 기반 모듈화
- YAML 설정 파일 지원
- 명령행 옵션 및 플래그 지원
- 확장 가능한 구조
- **서비스 체크 통합**: 모든 모니터링 스크립트에 HTTP/HTTPS 서비스 체크 자동 포함

**구조:**
```
rke_v2/
├── lib/                          # 공통 라이브러리
│   ├── rke2_common.sh           # 기본 공통 함수
│   ├── rke2_logging.sh          # 로깅 관련 함수
│   ├── rke2_security.sh         # 보안 관련 함수
│   ├── rke2_monitoring.sh       # 모니터링 관련 함수
│   └── rke2_config.sh           # 설정 파일 파서
├── config/                       # 설정 파일
│   └── rke2-monitoring.yaml     # 메인 설정 파일
├── 24x7_rke2_check.sh           # 24x7 모니터링
├── rke2_check.sh                # 플랫폼 점검
├── rke2_pod.sh                  # 파드 점검
└── README.md                     # 상세 문서
```

## 설치 및 설정

### 공통 요구사항

```bash
# 필수 도구 설치
sudo yum install jq yq python3-pyyaml  # RHEL/CentOS
# 또는
sudo apt-get install jq yq python3-yaml  # Ubuntu/Debian

# 실행 권한 설정
chmod +x rke_v1/*.sh
chmod +x rke_v2/*.sh rke_v2/lib/*.sh
```

### v1 설정 (단일 스크립트)

```bash
cd rke_v1

# 환경 변수 파일 설정
cp 24x7_rke2_check.env.template 24x7_rke2_check.env
cp rke2_check.env.template rke2_check.env
cp rke2_pod.env.template rke2_pod.env

# 환경 변수 편집
vi 24x7_rke2_check.env
```

**주요 환경 변수:**
```bash
export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
export RKE2_CONFIG_PATH="/etc/rancher/rke2"
export LOG_LEVEL="INFO"
export LOG_DIR="./logs"
export TIMEOUT=30
```

### v2 설정 (모듈화)

```bash
cd rke_v2

# 환경 변수 파일 설정
cp 24x7_rke2_check.env.template 24x7_rke2_check.env
cp rke2_check.env.template rke2_check.env
cp rke2_pod.env.template rke2_pod.env

# 설정 파일 편집
vi config/rke2-monitoring.yaml
```

**YAML 설정 파일 예시:**
```yaml
defaults:
  timeout: 30
  log_dir: "./logs"
  log_level: "INFO"
  retention_days: 30

rke2:
  config_path: "/etc/rancher/rke2"
  data_dir: "/var/lib/rancher/rke2"
  kubeconfig: "/etc/rancher/rke2/rke2.yaml"

checks:
  24x7:
    cluster_info: true
    control_plane: true
    rke2_specific: true
    security: true
```

## 사용법

### v1 사용법 (단일 스크립트)

```bash
cd rke_v1

# 24x7 모니터링
./24x7_rke2_check.sh

# 플랫폼 점검
./rke2_check.sh

# 파드 점검 (전체 네임스페이스)
./rke2_pod.sh

# 특정 네임스페이스만 점검
export NAMESPACE="kube-system"
./rke2_pod.sh
```

### v2 사용법 (모듈화)

```bash
cd rke_v2

# 기본 실행
./24x7_rke2_check.sh

# 설정 파일 지정
./24x7_rke2_check.sh -c config/rke2-monitoring.yaml

# 환경 변수 파일 지정
./24x7_rke2_check.sh -e 24x7_rke2_check.env

# 특정 네임스페이스 점검
./rke2_pod.sh -n kube-system

# 도움말
./24x7_rke2_check.sh -h
```

## 기능 비교

| 기능 | v1 (단일 스크립트) | v2 (모듈화) |
|------|-------------------|-------------|
| **설정 방식** | 환경 변수 파일 | YAML 설정 파일 + 환경 변수 |
| **구조** | 독립적 스크립트 | 공통 라이브러리 + 스크립트 |
| **확장성** | 제한적 | 높음 |
| **유지보수** | 간단 | 체계적 |
| **설정 유연성** | 환경 변수만 | YAML + 환경 변수 |
| **명령행 옵션** | 없음 | 다양한 플래그 지원 |
| **코드 재사용** | 없음 | 높음 |
| **학습 곡선** | 낮음 | 중간 |
| **대규모 환경** | 부적합 | 적합 |
| **빠른 시작** | 매우 빠름 | 빠름 |
| **서비스 체크** | 별도 스크립트 | 통합 모듈 |

## 점검 항목

### 공통 점검 항목

**24x7 모니터링:**
- 클러스터 정보 및 상태
- 컨트롤 플레인 노드 상태
- 워커 노드 상태
- etcd 클러스터 상태
- containerd 상태
- 네트워크 정책 및 보안
- 스토리지 및 인프라 상태
- **서비스 체크** (HTTP/HTTPS 상태)

**플랫폼 점검:**
- 클러스터 구성 정보
- 노드 역할 및 상태
- 네트워크 구성
- 스토리지 구성
- 메트릭 서버 상태
- 보안 정책
- 모니터링 도구 상태
- **서비스 체크** (전체 클러스터 서비스)

**파드 점검:**
- 파드 상태 및 리소스 사용량
- 네트워킹 상태
- 볼륨 및 스토리지 상태
- 로그 분석
- 보안 설정
- containerd 컨테이너 상태
- **서비스 체크** (해당 네임스페이스 서비스)

### v2 특화 기능

- **설정 파일 기반 점검 범위 제어**
- **병렬 처리 및 성능 최적화**
- **캐싱 및 중복 실행 방지**
- **확장 가능한 점검 모듈**
- **통합 서비스 체크**: 모든 모니터링 스크립트에 자동 포함

## 보안 기능

### 공통 보안 기능

- **민감 정보 마스킹**: UUID, 토큰, 인증서, Azure 정보 등
- **명령어 검증**: 허용된 패턴 확인, 인젝션 방지
- **파일 권한 검증**: 설정 파일 및 인증서 디렉토리 권한 확인
- **타임아웃 설정**: 명령어 실행 시간 제한

### v2 추가 보안 기능

- **설정 파일 검증**: YAML 문법 및 내용 검증
- **환경 변수 암호화**: 민감한 설정 값 암호화 지원
- **감사 로그**: 모든 보안 관련 작업 기록

## 출력 및 보고서

### 로그 파일
- **위치**: `$LOG_DIR/`
- **형식**: `{스크립트명}_{YYYYMMDD_HHMMSS}.log`
- **내용**: 상세한 점검 결과, 오류 정보, 성능 메트릭

### HTML 보고서
- **위치**: `$LOG_DIR/`
- **형식**: `{스크립트명}_{YYYYMMDD_HHMMSS}.html`
- **특징**: 
  - 색상 구분 (성공/경고/오류)
  - 테이블 형식의 정리된 정보
  - 클릭 가능한 링크 및 상세 정보

## 서비스 체크 기능

### 개요
RKE2 클러스터의 HTTP/HTTPS 서비스 상태를 자동으로 점검하는 기능입니다.

### v1 서비스 체크
- **별도 스크립트**: `rke2_service_check.sh`
- **환경 변수 기반**: `.env` 파일로 설정
- **독립 실행**: 필요시에만 실행

**사용법:**
```bash
cd rke_v1
cp rke2_service_check.env.template rke2_service_check.env
vi rke2_service_check.env  # 서비스 URL 설정
./rke2_service_check.sh
```

### v2 서비스 체크 (통합)
- **모듈 통합**: 모든 모니터링 스크립트에 자동 포함
- **설정 파일 제어**: YAML로 서비스 체크 옵션 관리
- **자동 실행**: 24x7, 플랫폼, 파드 점검 시 자동 실행

**설정 예시:**
```yaml
# config/rke2-monitoring.yaml
checks:
  24x7:
    service_checks: true  # 24x7 모니터링에 서비스 체크 포함

service_check:
  kubernetes_api: true
  rke2_services: true
  application_services: true
  custom_services: true
  network_connectivity: true
```

### 체크되는 서비스들
1. **Kubernetes API 서버**
   - 클러스터 내부 API 엔드포인트
   - 헬스체크 및 버전 정보

2. **RKE2 핵심 서비스**
   - 메트릭 서버
   - 컨트롤러 매니저
   - 스케줄러

3. **애플리케이션 서비스**
   - NodePort 서비스 (자동 감지)
   - LoadBalancer 서비스 (자동 감지)
   - ClusterIP 서비스 정보

4. **사용자 정의 서비스**
   - 환경 변수로 설정 가능
   - HTTP/HTTPS 자동 감지

5. **네트워크 연결성**
   - DNS 확인
   - 게이트웨이 상태
   - 네트워크 인터페이스

## 성능 최적화

### v1 최적화
- **단순한 구조**: 오버헤드 최소화
- **직접 실행**: 라이브러리 로딩 시간 없음

### v2 최적화
- **병렬 처리**: 설정 가능한 병렬 실행
- **캐싱**: 설정 파일 및 명령어 결과 캐싱
- **중복 실행 방지**: 동일 작업의 중복 실행 방지
- **리소스 사용량 최적화**: 메모리 및 CPU 사용량 제어

## 문제 해결

### 공통 문제 해결

1. **환경 변수 파일 누락**
   ```bash
   # 템플릿에서 복사
   cp *.env.template *.env
   ```

2. **kubectl 연결 오류**
   ```bash
   # KUBECONFIG 확인
   echo $KUBECONFIG
   kubectl cluster-info
   
   # 권한 확인
   ls -la /etc/rancher/rke2/rke2.yaml
   ```

3. **권한 오류**
   ```bash
   # 실행 권한 확인
   ls -la *.sh
   chmod +x *.sh
   ```

### v2 특화 문제 해결

1. **YAML 파서 오류**
   ```bash
   # yq 또는 python3 설치 확인
   which yq || which python3
   ```

2. **라이브러리 로딩 오류**
   ```bash
   # 라이브러리 경로 확인
   ls -la lib/*.sh
   chmod +x lib/*.sh
   ```

3. **설정 파일 문법 오류**
   ```bash
   # YAML 문법 검증
   yq eval '.' config/rke2-monitoring.yaml
   ```

## 운영 가이드라인

### 일일 점검
- **v1**: `./24x7_rke2_check.sh` 실행
- **v2**: `./24x7_rke2_check.sh -c config/rke2-monitoring.yaml` 실행
- HTML 보고서 확인 및 오류/경고 항목 점검

### 주간 점검
- **v1**: `./rke2_check.sh` 실행
- **v2**: `./rke2_check.sh -c config/rke2-monitoring.yaml` 실행
- 플랫폼 전체 상태 점검 및 성능 메트릭 분석

### 월간 점검
- **v1**: `./rke2_pod.sh` 실행
- **v2**: `./rke2_pod.sh -c config/rke2-monitoring.yaml` 실행
- 워크로드 상태 종합 점검 및 보안 설정 검토

## 마이그레이션 가이드

### v1에서 v2로 마이그레이션

1. **환경 변수 파일 백업**
   ```bash
   cp rke_v1/*.env rke_v1/backup/
   ```

2. **새 설정 파일 생성**
   ```bash
   cd rke_v2
   vi config/rke2-monitoring.yaml
   # 기존 환경 변수 값들을 YAML로 변환
   ```

3. **테스트 실행**
   ```bash
   ./24x7_rke2_check.sh -c config/rke2-monitoring.yaml
   ```

4. **점진적 전환**
   - 기존 v1 스크립트와 병행 실행
   - 결과 비교 및 검증
   - 완전 전환 후 v1 제거

### v2에서 v1으로 다운그레이드

1. **환경 변수 파일 생성**
   ```bash
   cd rke_v1
   # YAML 설정을 환경 변수로 변환하여 .env 파일 생성
   ```

2. **기본 설정으로 실행**
   ```bash
   ./24x7_rke2_check.sh
   ```

## 환경별 최적화

### Azure VM + RHEL9 환경
- **v1 권장**: Azure 특화 기능이 이미 포함되어 있음
- **v2 사용 시**: Azure 관련 설정을 YAML에 추가

### 온프레미스 환경
- **v2 권장**: 다양한 환경에 대한 유연한 설정 가능
- **v1 사용 시**: 환경 변수 파일을 환경에 맞게 수정

### 멀티 클러스터 환경
- **v2 필수**: 설정 파일을 통한 클러스터별 설정 관리
- **v1 사용 시**: 클러스터별 환경 변수 파일 생성

## 개발 및 확장

### v1 확장
- 스크립트 내부에 새로운 점검 함수 추가
- 환경 변수로 새로운 설정 추가
- Azure + RHEL9 특화 기능 강화

### v2 확장
- 새로운 라이브러리 모듈 추가
- YAML 설정 스키마 확장
- 플러그인 형태의 점검 모듈 개발
- API 인터페이스 추가

## 지원 및 문제 해결

### 로그 분석
1. 로그 파일 위치 확인 (`$LOG_DIR/`)
2. 오류 메시지 분석
3. 환경 변수 설정 검증
4. 권한 설정 확인

### 추가 도움말
- RKE2 공식 문서: https://docs.rke2.io/
- Azure VM 관련 문서
- RHEL9 시스템 관리 가이드

### 커뮤니티 지원
- GitHub Issues를 통한 버그 리포트
- 기능 요청 및 개선 제안
- 코드 기여 및 풀 리퀘스트

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 기여 가이드라인

### 개발 원칙
- **v1**: 단순성과 Azure + RHEL9 최적화 유지
- **v2**: 모듈화와 확장성 강화
- **공통**: 보안 기능 및 문서화 필수

### 테스트 요구사항
- 구문 검증: `bash -n script.sh`
- 기능 테스트: 실제 RKE2 환경
- 보안 테스트: 민감 정보 마스킹
- 환경별 테스트: Azure, 온프레미스 등

---

**참고**: 
- v1은 Azure VM + RHEL9 OS + RKE2 설치형 클러스터 환경에 최적화.
- v2는 다양한 환경에서 사용할 수 있도록 설계.
