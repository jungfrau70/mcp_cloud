

Windows 에서 **WSL(Windows Subsystem for Linux)** 을 활성화(Enable)하는 방법은 Windows 10, Windows 11 공통적으로 아래와 같습니다.

---

## 1. 관리자 권한 PowerShell 실행

1. 시작 메뉴에서 **PowerShell** 검색
2. **관리자 권한으로 실행** 클릭

---

## 2. WSL 기능 활성화

### Windows 10 (2004 이상) / Windows 11

아래 명령을 입력하면 필요한 Windows 기능을 켜고 최신 WSL까지 자동 설치됩니다:

```powershell
wsl --install
```

👉 실행 후 재부팅하면 Ubuntu 등 기본 Linux 배포판이 자동 설치됩니다.

---

### 구버전 (Windows 10 1909 이하)

직접 기능을 켜야 합니다:

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

재부팅 후, Microsoft Store 에서 원하는 배포판(Ubuntu, Debian 등)을 설치하면 됩니다.

---

## 3. WSL 버전 확인 및 설정

```powershell
wsl --list --verbose
```

WSL 2로 설정:

```powershell
wsl --set-default-version 2
```

특정 배포판 버전 지정:

```powershell
wsl --set-version <배포판이름> 2
```

---

## 4. Linux 배포판 설치

* **Windows 11 / 최신 Windows 10**: `wsl --install -d Ubuntu` 처럼 바로 설치 가능
* **구버전**: Microsoft Store 접속 → Ubuntu, Debian, Kali Linux 등 선택 설치

---

👉 정리:

* 최신 Windows → `wsl --install` 한 줄이면 끝
* 구버전 Windows → `dism.exe` 로 기능 켜고, Store에서 배포판 설치

---

원하시면 제가 **Windows 10과 Windows 11 각각의 단계별 스크린샷 포함 가이드**로 정리해드릴 수도 있는데, 그 방식이 더 필요하실까요?


WSL 에서 현재 설치/사용 중인 리눅스 배포판 정보를 확인하는 방법은 여러 가지가 있습니다.

---

## 1. PowerShell / CMD에서 확인

```powershell
wsl --list --verbose
```

또는 짧게:

```powershell
wsl -l -v
```

출력 예시:

```
  NAME      STATE           VERSION
* Ubuntu    Running         2
  Debian    Stopped         2
```

* **NAME**: 배포판 이름
* **STATE**: 실행 중인지 여부 (Running / Stopped)
* **VERSION**: WSL 버전 (1 또는 2)
* `*` 표시: 기본(default) 배포판

---

## 2. 현재 기본 배포판만 확인

```powershell
wsl --list --default
```

---

## 3. WSL 안에서 배포판 종류 확인

WSL 배포판에 들어간 후 실행:

```bash
cat /etc/os-release
```

출력 예시 (Ubuntu):

```WSL 에서 현재 설치/사용 중인 리눅스 배포판 정보를 확인하는 방법은 여러 가지가 있습니다.

---

## 1. PowerShell / CMD에서 확인

```powershell
wsl --list --verbose
```

또는 짧게:

```powershell
wsl -l -v
```

출력 예시:

```
  NAME      STATE           VERSION
* Ubuntu    Running         2
  Debian    Stopped         2
```

* **NAME**: 배포판 이름
* **STATE**: 실행 중인지 여부 (Running / Stopped)
* **VERSION**: WSL 버전 (1 또는 2)
* `*` 표시: 기본(default) 배포판

---

## 2. 현재 기본 배포판만 확인

```powershell
wsl --list --default
```

---

## 3. WSL 안에서 배포판 종류 확인

WSL 배포판에 들어간 후 실행:

```bash
cat /etc/os-release
```

출력 예시 (Ubuntu):

```
NAME="Ubuntu"
VERSION="22.04.3 LTS (Jammy Jellyfish)"
ID=ubuntu
```

---

👉 정리하면, **Windows 쪽에서는 `wsl -l -v`**,
**리눅스 내부에서는 `cat /etc/os-release`** 로 확인 가능합니다.

원하시는 게 "현재 실행 중인 기본 배포판만 확인"인지, 아니면 "설치된 배포판 전체 목록"인지 알려주실래요?

NAME="Ubuntu"
VERSION="22.04.3 LTS (Jammy Jellyfish)"
ID=ubuntu
```

---

👉 정리하면, **Windows 쪽에서는 `wsl -l -v`**,
**리눅스 내부에서는 `cat /etc/os-release`** 로 확인 가능합니다.
