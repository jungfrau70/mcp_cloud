# WSL 관리 도구 가이드

## 📋 개요

WSL 관리 도구(`wsl-manager.sh`)는 Windows Subsystem for Linux (WSL) 배포판을 쉽고 안전하게 관리할 수 있는 통합 도구입니다. Cloud Master 과정에서 필요한 WSL 환경을 효율적으로 구축하고 관리할 수 있습니다.

## 🎯 주요 기능

### **WSL 배포판 관리**
- ✅ 배포판 목록 조회
- ✅ 배포판 상태 확인
- ✅ 배포판 중지/재시작
- ✅ 배포판 생성/삭제
- ✅ 백업 및 복원

### **안전 기능**
- ✅ 이중 확인 시스템
- ✅ 백업 권장 안내
- ✅ 오류 처리 강화
- ✅ 권한 확인

## 🚀 설치 및 실행

### **1. 스크립트 다운로드**
```bash
# Cloud Master 저장소 클론
git clone <repository-url>
cd mcp_cloud/mcp_knowledge_base/cloud_master/repos/cloud-scripts

# 실행 권한 부여 (WSL 환경에서)
chmod +x wsl-manager.sh
```

### **2. 실행**
```bash
# WSL 관리 도구 실행
./wsl-manager.sh
```

## 📖 사용법

### **메인 메뉴**

WSL 관리 도구를 실행하면 다음과 같은 메뉴가 표시됩니다:

```
=== WSL 관리 도구 ===
1. WSL 배포판 목록 보기
2. WSL 배포판 상태 확인
3. WSL 배포판 중지
4. WSL 배포판 삭제
5. WSL 배포판 생성
6. WSL 배포판 재시작
7. WSL 배포판 백업
8. WSL 배포판 복원
9. WSL 전체 정리
10. WSL 자동 설정 실행
11. 종료

선택 (1-11):
```

### **1. WSL 배포판 목록 보기**

현재 설치된 모든 WSL 배포판의 목록과 상태를 확인합니다.

```bash
# 메뉴에서 1 선택
# 또는 직접 명령어 실행
wsl --list --verbose
```

**출력 예시:**
```
  NAME            STATE           VERSION
* Ubuntu-22.04    Running         2
  Ubuntu-20.04    Stopped         2
  Debian          Running         2
```

### **2. WSL 배포판 상태 확인**

특정 배포판의 현재 상태를 확인합니다.

```bash
# 메뉴에서 2 선택
# 배포판 이름 입력: Ubuntu-22.04
```

**출력 예시:**
```
✅ Ubuntu-22.04: 실행 중
```

### **3. WSL 배포판 중지**

실행 중인 WSL 배포판을 중지합니다.

```bash
# 메뉴에서 3 선택
# 배포판 이름 입력: Ubuntu-22.04
# 확인: y
```

**주의사항:**
- 중지된 배포판의 데이터는 보존됩니다
- 언제든지 다시 시작할 수 있습니다

### **4. WSL 배포판 삭제**

WSL 배포판을 완전히 삭제합니다.

```bash
# 메뉴에서 4 선택
# 배포판 이름 입력: Ubuntu-22.04
# 확인: y
# 최종 확인: DELETE
```

**⚠️ 주의사항:**
- 삭제된 배포판의 모든 데이터가 손실됩니다
- 되돌릴 수 없으므로 신중하게 결정하세요
- 삭제 전 백업을 권장합니다

### **5. WSL 배포판 생성**

새로운 WSL 배포판을 생성합니다.

```bash
# 메뉴에서 5 선택
# 배포판 이름 입력: Ubuntu-22.04 (또는 Enter로 기본값 사용)
```

**생성 과정:**
1. Ubuntu 22.04 LTS 다운로드
2. WSL 배포판 설치
3. 초기 사용자 설정
4. sudo 권한 부여

### **6. WSL 배포판 재시작**

중지된 WSL 배포판을 다시 시작합니다.

```bash
# 메뉴에서 6 선택
# 배포판 이름 입력: Ubuntu-22.04
```

### **7. WSL 배포판 백업**

WSL 배포판을 tar 파일로 백업합니다.

```bash
# 메뉴에서 7 선택
# 배포판 이름 입력: Ubuntu-22.04
# 백업 파일 경로 입력: ~/wsl-backup-ubuntu.tar (또는 Enter로 기본값 사용)
```

**백업 파일 위치:**
- 기본 경로: `~/wsl-backup-{배포판명}.tar`
- 사용자 지정 경로 가능

### **8. WSL 배포판 복원**

백업 파일에서 WSL 배포판을 복원합니다.

```bash
# 메뉴에서 8 선택
# 배포판 이름 입력: Ubuntu-22.04
# 백업 파일 경로 입력: ~/wsl-backup-ubuntu.tar
```

**복원 과정:**
1. 기존 배포판 삭제 (있는 경우)
2. 백업 파일에서 복원
3. 복원 완료 확인

### **9. WSL 전체 정리**

모든 WSL 배포판을 삭제합니다.

```bash
# 메뉴에서 9 선택
# 확인: y
# 최종 확인: DELETE ALL
```

**⚠️ 주의사항:**
- 모든 WSL 배포판이 삭제됩니다
- 모든 데이터가 손실됩니다
- 되돌릴 수 없습니다

### **10. WSL 자동 설정 실행**

WSL 자동 설정 스크립트를 실행합니다.

```bash
# 메뉴에서 10 선택
# wsl-auto-setup.sh 스크립트 실행
```

## 🔧 고급 사용법

### **직접 명령어 사용**

WSL 관리 도구 없이 직접 명령어를 사용할 수도 있습니다:

```bash
# WSL 배포판 목록 보기
wsl --list --verbose

# WSL 배포판 중지
wsl --terminate Ubuntu-22.04

# WSL 배포판 삭제
wsl --unregister Ubuntu-22.04

# WSL 배포판 생성
wsl --install -d Ubuntu-22.04

# WSL 배포판 내보내기 (백업)
wsl --export Ubuntu-22.04 ~/backup-ubuntu.tar

# WSL 배포판 가져오기 (복원)
wsl --import Ubuntu-22.04 ~/.wsl/Ubuntu-22.04 ~/backup-ubuntu.tar
```

### **배치 작업**

여러 배포판을 한 번에 관리하는 경우:

```bash
# 모든 배포판 중지
wsl --shutdown

# 특정 배포판들만 중지
wsl --terminate Ubuntu-22.04
wsl --terminate Ubuntu-20.04

# 모든 배포판 상태 확인
wsl --list --verbose
```

## 🛡️ 안전 가이드

### **백업 전략**

#### **정기 백업**
```bash
# 매주 백업 스크립트 예시
#!/bin/bash
DATE=$(date +%Y%m%d)
wsl --export Ubuntu-22.04 ~/backups/ubuntu-22.04-$DATE.tar
```

#### **중요 작업 전 백업**
- 배포판 삭제 전
- 시스템 업데이트 전
- 실험적 설정 전

### **복원 테스트**

백업 파일의 무결성을 정기적으로 확인하세요:

```bash
# 백업 파일 확인
file ~/wsl-backup-ubuntu.tar

# 복원 테스트 (테스트용 배포판)
wsl --import Ubuntu-Test ~/.wsl/Ubuntu-Test ~/wsl-backup-ubuntu.tar
```

## 🚨 문제 해결

### **일반적인 문제들**

#### **1. WSL이 설치되지 않음**
```bash
# Windows에서 WSL 설치
wsl --install

# 또는 PowerShell에서
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

#### **2. 배포판 삭제 실패**
```bash
# 배포판 강제 중지
wsl --terminate Ubuntu-22.04

# 잠시 대기 후 다시 시도
sleep 5
wsl --unregister Ubuntu-22.04
```

#### **3. 백업 파일 복원 실패**
```bash
# 백업 파일 무결성 확인
tar -tf ~/wsl-backup-ubuntu.tar

# 다른 이름으로 복원 시도
wsl --import Ubuntu-New ~/.wsl/Ubuntu-New ~/wsl-backup-ubuntu.tar
```

#### **4. 권한 문제**
```bash
# 관리자 권한으로 실행
# Windows PowerShell을 관리자로 실행 후
wsl --install
```

### **로그 확인**

WSL 관련 로그를 확인하여 문제를 진단할 수 있습니다:

```bash
# WSL 로그 확인
wsl --status

# 이벤트 뷰어에서 WSL 로그 확인
# Windows 이벤트 뷰어 > Windows 로그 > 애플리케이션
```

## 📊 성능 최적화

### **WSL 성능 향상**

#### **1. 메모리 제한 설정**
```bash
# ~/.wslconfig 파일 생성
[wsl2]
memory=4GB
processors=2
```

#### **2. 가상 디스크 최적화**
```bash
# WSL 종료
wsl --shutdown

# 가상 디스크 압축
wsl --shutdown
diskpart
# diskpart에서:
# select vdisk file="C:\Users\사용자명\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu22.04LTS_79rhkp1fndgsc\LocalState\ext4.vhdx"
# compact vdisk
```

## 🔗 관련 도구

### **WSL 자동 설정 스크립트**
- `wsl-auto-setup.sh`: WSL 환경 자동 구축
- `wsl-setup-guide.md`: 상세한 WSL 설정 가이드

### **환경 체크 도구**
- `environment-check-wsl.sh`: WSL 환경 상태 확인
- `cluster-cleanup-interactive.sh`: 클러스터 정리 도구

### **Cloud Master 과정 도구**
- `k8s-cluster-create.sh`: GKE 클러스터 생성
- `eks-cluster-create.sh`: EKS 클러스터 생성
- `vm-cleanup-interactive.sh`: VM 정리 도구

## 📚 추가 자료

### **Microsoft 공식 문서**
- [WSL 설치 가이드](https://docs.microsoft.com/ko-kr/windows/wsl/install)
- [WSL 명령어 참조](https://docs.microsoft.com/ko-kr/windows/wsl/basic-commands)
- [WSL 고급 설정](https://docs.microsoft.com/ko-kr/windows/wsl/wsl-config)

### **Cloud Master 과정**
- [Day1 실습 가이드](../textbook/Day1/README.md)
- [Day2 실습 가이드](../textbook/Day2/README.md)
- [Day3 실습 가이드](../textbook/Day3/README.md)

## 🤝 지원 및 피드백

### **문제 신고**
- GitHub Issues를 통해 문제 신고
- 상세한 오류 메시지와 함께 보고

### **기능 요청**
- 새로운 기능 제안
- 개선 사항 제안

### **기여하기**
- 코드 개선
- 문서 개선
- 테스트 케이스 추가

---

**Cloud Master 과정과 함께 WSL 환경을 효율적으로 관리하세요!** 🚀
