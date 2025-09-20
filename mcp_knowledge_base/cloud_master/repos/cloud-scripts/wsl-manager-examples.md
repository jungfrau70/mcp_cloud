# WSL 관리 도구 사용 예제

## 📋 개요

WSL 관리 도구(`wsl-manager.sh`)의 실제 사용 시나리오와 예제를 제공합니다.

## 🚀 기본 사용 시나리오

### **시나리오 1: 새로운 WSL 환경 구축**

Cloud Master 과정을 시작하기 위해 새로운 WSL 환경을 구축하는 경우입니다.

#### **1단계: WSL 관리 도구 실행**
```bash
cd mcp_knowledge_base/cloud_master/repos/cloud-scripts
./wsl-manager.sh
```

#### **2단계: 기존 환경 확인**
```
=== WSL 관리 도구 ===
1. WSL 배포판 목록 보기
2. WSL 배포판 상태 확인
...

선택 (1-11): 1
```

**출력:**
```
[INFO] WSL 배포판 목록 조회 중...

  NAME            STATE           VERSION
* Ubuntu-22.04    Running         2
  Ubuntu-20.04    Stopped         2
```

#### **3단계: 기존 환경 정리 (선택사항)**
```
선택 (1-11): 4
확인할 배포판 이름을 입력하세요: Ubuntu-20.04
정말로 삭제하시겠습니까? (y/N): y
정말로 삭제하시겠습니까? 모든 데이터가 손실됩니다! (DELETE): DELETE
```

#### **4단계: 새로운 환경 생성**
```
선택 (1-11): 5
생성할 배포판 이름을 입력하세요 (기본값: Ubuntu-22.04): Ubuntu-22.04
[INFO] WSL 배포판 생성: Ubuntu-22.04
[INFO] Ubuntu 22.04 LTS 다운로드 중...
[SUCCESS] WSL 배포판 생성 완료: Ubuntu-22.04
[INFO] 초기 설정을 완료한 후 Enter를 눌러주세요...
[SUCCESS] WSL 사용자 설정 완료: clouduser
```

### **시나리오 2: WSL 환경 백업 및 복원**

중요한 작업 전에 WSL 환경을 백업하고, 필요시 복원하는 경우입니다.

#### **1단계: 현재 환경 백업**
```
선택 (1-11): 7
백업할 배포판 이름을 입력하세요: Ubuntu-22.04
백업 파일 경로를 입력하세요 (기본값: ~/wsl-backup-Ubuntu-22.04.tar): ~/backup-ubuntu-$(date +%Y%m%d).tar
[INFO] WSL 배포판 백업: Ubuntu-22.04 → ~/backup-ubuntu-20241201.tar
[SUCCESS] WSL 배포판 백업 완료: ~/backup-ubuntu-20241201.tar
```

#### **2단계: 실험적 작업 수행**
```bash
# WSL 환경에서 실험적 설정
wsl -d Ubuntu-22.04
# ... 실험적 작업 수행 ...
exit
```

#### **3단계: 문제 발생 시 복원**
```
선택 (1-11): 8
복원할 배포판 이름을 입력하세요: Ubuntu-22.04
백업 파일 경로를 입력하세요: ~/backup-ubuntu-20241201.tar
[INFO] WSL 배포판 복원: ~/backup-ubuntu-20241201.tar → Ubuntu-22.04
[WARNING] 기존 배포판 삭제 중: Ubuntu-22.04
[SUCCESS] WSL 배포판 복원 완료: Ubuntu-22.04
```

### **시나리오 3: WSL 환경 정리**

Cloud Master 과정 완료 후 WSL 환경을 정리하는 경우입니다.

#### **1단계: 현재 환경 확인**
```
선택 (1-11): 1
```

**출력:**
```
  NAME            STATE           VERSION
* Ubuntu-22.04    Running         2
  Ubuntu-20.04    Stopped         2
  Debian          Running         2
```

#### **2단계: 개별 배포판 정리**
```
선택 (1-11): 4
삭제할 배포판 이름을 입력하세요: Ubuntu-20.04
정말로 삭제하시겠습니까? (y/N): y
정말로 삭제하시겠습니까? 모든 데이터가 손실됩니다! (DELETE): DELETE
[SUCCESS] WSL 배포판 삭제 완료: Ubuntu-20.04
```

#### **3단계: 전체 정리 (필요시)**
```
선택 (1-11): 9
정말로 모든 WSL 배포판을 삭제하시겠습니까? (y/N): y
정말로 모든 WSL 배포판을 삭제하시겠습니까? (DELETE ALL): DELETE ALL
[INFO] 모든 WSL 배포판 정리 중...
[INFO] WSL 배포판 삭제 중: Ubuntu-22.04
[INFO] WSL 배포판 삭제 중: Debian
[SUCCESS] 모든 WSL 배포판 정리 완료
```

## 🔧 고급 사용 시나리오

### **시나리오 4: 다중 WSL 환경 관리**

여러 프로젝트를 위해 여러 WSL 환경을 관리하는 경우입니다.

#### **1단계: 프로젝트별 WSL 환경 생성**
```bash
# Cloud Master 환경
./wsl-manager.sh
# 선택: 5
# 배포판 이름: CloudMaster-Ubuntu-22.04

# 다른 프로젝트 환경
./wsl-manager.sh
# 선택: 5
# 배포판 이름: WebDev-Ubuntu-22.04
```

#### **2단계: 환경별 백업**
```bash
# Cloud Master 환경 백업
./wsl-manager.sh
# 선택: 7
# 배포판 이름: CloudMaster-Ubuntu-22.04
# 백업 경로: ~/backups/cloudmaster-$(date +%Y%m%d).tar

# WebDev 환경 백업
./wsl-manager.sh
# 선택: 7
# 배포판 이름: WebDev-Ubuntu-22.04
# 백업 경로: ~/backups/webdev-$(date +%Y%m%d).tar
```

#### **3단계: 환경 전환**
```bash
# Cloud Master 환경으로 전환
wsl -d CloudMaster-Ubuntu-22.04

# WebDev 환경으로 전환
wsl -d WebDev-Ubuntu-22.04
```

### **시나리오 5: 자동화 스크립트와 연동**

WSL 관리 도구를 자동화 스크립트와 연동하여 사용하는 경우입니다.

#### **자동 백업 스크립트**
```bash
#!/bin/bash
# auto-backup-wsl.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/wsl-backups"

# 백업 디렉토리 생성
mkdir -p "$BACKUP_DIR"

# 모든 WSL 배포판 백업
wsl --list --quiet | while read distro; do
    if [[ "$distro" != "Windows" ]]; then
        echo "백업 중: $distro"
        wsl --export "$distro" "$BACKUP_DIR/${distro}-${DATE}.tar"
    fi
done

echo "백업 완료: $BACKUP_DIR"
```

#### **자동 정리 스크립트**
```bash
#!/bin/bash
# auto-cleanup-wsl.sh

# 7일 이상 된 백업 파일 삭제
find ~/wsl-backups -name "*.tar" -mtime +7 -delete

# 중지된 WSL 배포판 정리
wsl --list --quiet | while read distro; do
    if [[ "$distro" != "Windows" ]]; then
        status=$(wsl --list --verbose | grep "$distro" | awk '{print $2}')
        if [[ "$status" == "Stopped" ]]; then
            echo "중지된 배포판 발견: $distro"
            # 필요시 삭제 로직 추가
        fi
    fi
done
```

## 🧪 테스트 시나리오

### **시나리오 6: WSL 관리 도구 테스트**

WSL 관리 도구의 기능을 테스트하는 경우입니다.

#### **1단계: 테스트 환경 생성**
```bash
# 테스트용 WSL 환경 생성
./wsl-manager.sh
# 선택: 5
# 배포판 이름: Test-Ubuntu-22.04
```

#### **2단계: 기능 테스트**
```bash
# 상태 확인 테스트
./wsl-manager.sh
# 선택: 2
# 배포판 이름: Test-Ubuntu-22.04

# 중지 테스트
./wsl-manager.sh
# 선택: 3
# 배포판 이름: Test-Ubuntu-22.04

# 재시작 테스트
./wsl-manager.sh
# 선택: 6
# 배포판 이름: Test-Ubuntu-22.04

# 백업 테스트
./wsl-manager.sh
# 선택: 7
# 배포판 이름: Test-Ubuntu-22.04
# 백업 경로: ~/test-backup.tar

# 복원 테스트
./wsl-manager.sh
# 선택: 8
# 배포판 이름: Test-Ubuntu-22.04-Restored
# 백업 경로: ~/test-backup.tar
```

#### **3단계: 테스트 환경 정리**
```bash
# 테스트 환경 삭제
./wsl-manager.sh
# 선택: 4
# 배포판 이름: Test-Ubuntu-22.04

# 선택: 4
# 배포판 이름: Test-Ubuntu-22.04-Restored
```

## 🚨 문제 해결 시나리오

### **시나리오 7: WSL 삭제 실패 해결**

WSL 배포판 삭제가 실패하는 경우의 해결 방법입니다.

#### **1단계: 문제 진단**
```bash
# WSL 상태 확인
wsl --status

# 배포판 상태 확인
wsl --list --verbose
```

#### **2단계: 강제 중지**
```bash
# 특정 배포판 강제 중지
wsl --terminate Ubuntu-22.04

# 모든 WSL 중지
wsl --shutdown
```

#### **3단계: 재시도**
```bash
# WSL 관리 도구로 삭제 재시도
./wsl-manager.sh
# 선택: 4
# 배포판 이름: Ubuntu-22.04
```

#### **4단계: 수동 삭제 (최후 수단)**
```bash
# Windows PowerShell에서 실행
wsl --unregister Ubuntu-22.04
```

### **시나리오 8: 백업 복원 실패 해결**

백업 파일 복원이 실패하는 경우의 해결 방법입니다.

#### **1단계: 백업 파일 확인**
```bash
# 백업 파일 존재 확인
ls -la ~/wsl-backup-ubuntu.tar

# 백업 파일 무결성 확인
file ~/wsl-backup-ubuntu.tar
```

#### **2단계: 다른 이름으로 복원 시도**
```bash
./wsl-manager.sh
# 선택: 8
# 배포판 이름: Ubuntu-22.04-Restored
# 백업 경로: ~/wsl-backup-ubuntu.tar
```

#### **3단계: 수동 복원**
```bash
# WSL 디렉토리 생성
mkdir -p ~/.wsl/Ubuntu-22.04-Restored

# 수동 복원
wsl --import Ubuntu-22.04-Restored ~/.wsl/Ubuntu-22.04-Restored ~/wsl-backup-ubuntu.tar
```

## 📊 성능 최적화 시나리오

### **시나리오 9: WSL 성능 최적화**

WSL 환경의 성능을 최적화하는 경우입니다.

#### **1단계: 현재 설정 확인**
```bash
# WSL 설정 확인
wsl --status
```

#### **2단계: WSL 설정 파일 생성**
```bash
# ~/.wslconfig 파일 생성
cat > ~/.wslconfig << EOF
[wsl2]
memory=4GB
processors=2
swap=2GB
localhostForwarding=true
EOF
```

#### **3단계: WSL 재시작**
```bash
# WSL 완전 종료
wsl --shutdown

# WSL 재시작
wsl -d Ubuntu-22.04
```

## 🔗 통합 사용 시나리오

### **시나리오 10: Cloud Master 과정과 통합**

WSL 관리 도구를 Cloud Master 과정과 통합하여 사용하는 경우입니다.

#### **1단계: 환경 구축**
```bash
# WSL 자동 설정 실행
./wsl-manager.sh
# 선택: 10
# wsl-auto-setup.sh 실행
```

#### **2단계: 실습 진행**
```bash
# Day1 실습
cd mcp_knowledge_base/cloud_master/textbook/Day1
./practices/aws-basics-practice.sh

# Day2 실습
cd mcp_knowledge_base/cloud_master/textbook/Day2
./practices/kubernetes-practice.sh
```

#### **3단계: 정리**
```bash
# 클러스터 정리
./cluster-cleanup-interactive.sh

# VM 정리
./vm-cleanup-interactive.sh

# WSL 환경 정리 (필요시)
./wsl-manager.sh
# 선택: 9
```

---

**이 예제들을 참고하여 WSL 관리 도구를 효과적으로 활용하세요!** 🚀
