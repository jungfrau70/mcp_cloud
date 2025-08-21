# RKE2 모니터링 시스템 (v1 - 단일 스크립트 버전)

## 개요

RKE2 클러스터를 위한 단일 스크립트 기반 모니터링 시스템입니다.
Azure VM + RHEL9 OS 환경에서 RKE2 설치형 클러스터를 운영하기 위한 점검 및 모니터링 도구입니다.

## 주요 특징

- **단일 스크립트 구조**: 각 기능별로 독립적인 스크립트 제공
- **Azure + RHEL9 최적화**: 특정 환경에 맞춘 최적화된 점검 기능
- **24x7 모니터링**: 지속적인 클러스터 상태 모니터링
- **플랫폼 점검**: 클러스터 구성 및 상태 진단
- **파드 점검**: 워크로드 상태 및 리소스 모니터링
- **HTML 보고서**: 시각적 보고서 생성
- **보안 강화**: 민감 정보 마스킹 및 명령어 검증

## 디렉토리 구조

```
rke_v1/
├── 24x7_rke2_check.sh           # 24x7 모니터링 스크립트
├── rke2_check.sh                # 플랫폼 점검 스크립트
├── rke2_pod.sh                  # 파드 점검 스크립트
├── 24x7_rke2_check.env.template # 24x7 모니터링 환경 변수 템플릿
├── rke2_check.env.template      # 플랫폼 점검 환경 변수 템플릿
├── rke2_pod.env.template        # 파드 점검 환경 변수 템플릿
├── RKE2_SPECIFIC_CONSIDERATIONS.md # RKE2 특화 고려사항 문서
└── README.md                    # 이 파일
```

## 설치 및 설정

### 1. 필수 도구 설치

```bash
# 필수 도구
sudo yum install jq yq python3-pyyaml

# 또는 Ubuntu/Debian
sudo apt-get install jq yq python3-yaml
```

### 2. 환경 변수 설정

```bash
# 24x7 모니터링용 환경 변수
cp 24x7_rke2_check.env.template 24x7_rke2_check.env
vi 24x7_rke2_check.env

# 플랫폼 점검용 환경 변수
cp rke2_check.env.template rke2_check.env
vi rke2_check.env

# 파드 점검용 환경 변수
cp rke2_pod.env.template rke2_pod.env
vi rke2_pod.env
```

### 3. 주요 환경 변수

```bash
# 필수 설정
export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
export RKE2_CONFIG_PATH="/etc/rancher/rke2"

# 로깅 설정
export LOG_LEVEL="INFO"
export LOG_DIR="./logs"
export TIMEOUT=30

# RKE2 특화 설정
export RKE2_DATA_DIR="/var/lib/rancher/rke2"
export RKE2_ETCD_DIR="/var/lib/rancher/rke2/server/tls/etcd"

# 모니터링 설정
export ENABLE_METRICS=true
export ENABLE_LOGS=true
export ENABLE_SECURITY_CHECKS=true
```

### 4. 실행 권한 설정

```bash
chmod +x *.sh
```

## 사용법

### 24x7 모니터링

```bash
# 기본 설정으로 실행
./24x7_rke2_check.sh

# 환경 변수 파일 지정
source ./24x7_rke2_check.env
./24x7_rke2_check.sh
```

**주요 점검 항목:**
- 클러스터 정보 및 상태
- 컨트롤 플레인 노드 상태
- 워커 노드 상태
- etcd 클러스터 상태
- containerd 상태
- 네트워크 정책 및 보안
- 스토리지 및 인프라 상태
- RKE2 특화 구성 요소

### 플랫폼 점검

```bash
# 기본 실행
./rke2_check.sh

# 환경 변수 파일 지정
source ./rke2_check.env
./rke2_check.sh
```

**주요 점검 항목:**
- 클러스터 구성 정보
- 노드 역할 및 상태
- 네트워크 구성
- 스토리지 구성
- 메트릭 서버 상태
- 보안 정책
- 모니터링 도구 상태

### 파드 점검

```bash
# 전체 네임스페이스 점검
./rke2_pod.sh

# 특정 네임스페이스만 점검
export NAMESPACE="kube-system"
./rke2_pod.sh

# 환경 변수 파일 지정
source ./rke2_pod.env
./rke2_pod.sh
```

**주요 점검 항목:**
- 파드 상태 및 리소스 사용량
- 네트워킹 상태
- 볼륨 및 스토리지 상태
- 로그 분석
- 보안 설정
- containerd 컨테이너 상태

## 출력 파일

### 로그 파일
- 위치: `$LOG_DIR/`
- 형식: `{스크립트명}_{YYYYMMDD_HHMMSS}.log`
- 내용: 상세한 점검 결과 및 오류 정보

### HTML 보고서
- 위치: `$LOG_DIR/`
- 형식: `{스크립트명}_{YYYYMMDD_HHMMSS}.html`
- 내용: 시각적 보고서 (색상 구분, 테이블 형식)

## RKE2 특화 고려사항

### 아키텍처 특성
- **단일 바이너리**: kubelet, containerd, etcd 통합
- **내장 etcd**: 별도 설치 불필요, 자동 관리
- **containerd 기반**: Docker CLI 대신 crictl 사용

### 보안 특성
- **mTLS 통신**: 모든 컴포넌트 간 상호 TLS 인증
- **etcd 암호화**: 데이터 암호화 저장
- **정책 기반 네트워킹**: Calico 기반 네트워크 정책
- **Pod Security Standards**: 표준화된 보안 정책

### 모니터링 특성
- **내장 메트릭 서버**: 별도 설치 불필요
- **etcd 메트릭**: 리더 변경, 디스크 성능 등
- **containerd 메트릭**: 컨테이너 상태 및 성능
- **RKE2 특화 로그**: 전용 로그 파일 위치

## 보안 기능

### 민감 정보 마스킹
- UUID, 토큰, 인증서 정보
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

## Azure 환경 특화 기능

### Azure VM 최적화
- Azure VM 메타데이터 수집
- Azure 리소스 그룹 정보
- Azure 지역별 설정
- Azure 네트워킹 상태

### RHEL9 OS 최적화
- RHEL9 특화 명령어 사용
- systemd 서비스 상태 점검
- SELinux 정책 확인
- RHEL9 보안 설정 검증

## 문제 해결

### 일반적인 문제

1. **환경 변수 파일 누락**
   ```bash
   # 환경 변수 파일 확인
   ls -la *.env
   
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
   
   # sudo 권한 필요 시
   sudo ./24x7_rke2_check.sh
   ```

### 디버깅

```bash
# DEBUG 레벨로 실행
export LOG_LEVEL="DEBUG"
./24x7_rke2_check.sh

# 환경 변수 확인
env | grep -E "(RKE2|KUBE|LOG)"
```

## 성능 최적화

### 병렬 처리
- 설정 가능한 병렬 실행
- 최대 병렬 작업 수 제한
- 리소스 사용량 최적화

### 로그 관리
- 로그 로테이션
- 압축 및 정리
- 보존 기간 설정

## 운영 가이드라인

### 일일 점검
- `24x7_rke2_check.sh` 실행
- HTML 보고서 확인
- 오류 및 경고 항목 점검

### 주간 점검
- `rke2_check.sh` 실행
- 플랫폼 전체 상태 점검
- 성능 메트릭 분석

### 월간 점검
- `rke2_pod.sh` 실행
- 워크로드 상태 종합 점검
- 보안 설정 검토

## 업그레이드 및 유지보수

### RKE2 업그레이드
- etcd 스냅샷 백업
- 순서: etcd → control plane → worker nodes
- 롤백 계획 수립

### 스크립트 업데이트
- 환경 변수 파일 백업
- 새 버전 테스트
- 점진적 전환

## 지원 및 문제 해결

### 로그 분석
1. 로그 파일 위치 확인
2. 오류 메시지 분석
3. 환경 변수 설정 검증
4. 권한 설정 확인

### 추가 도움말
- RKE2 공식 문서 참조
- Azure VM 관련 문서
- RHEL9 시스템 관리 가이드

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 기여

### 개발 가이드라인
- Azure + RHEL9 환경 최적화
- RKE2 특화 기능 포함
- 보안 기능 강화
- 문서화 필수

### 테스트
- 구문 검증: `bash -n script.sh`
- 기능 테스트: 실제 RKE2 환경
- 보안 테스트: 민감 정보 마스킹
- Azure 환경 테스트

---

**참고**: 이 시스템은 Azure VM + RHEL9 OS + RKE2 설치형 클러스터 환경에 최적화되어 있습니다.
다른 환경에서 사용 시 환경 변수와 설정을 적절히 조정해야 합니다.
