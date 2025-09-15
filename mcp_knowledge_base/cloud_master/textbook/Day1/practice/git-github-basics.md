# Git/GitHub 기초 실습 가이드

<div align="center">

[← 이전: Cloud Master 메인](../README.md) | [📚 전체 커리큘럼](/curriculum.md) | [🏠 학습 경로로 돌아가기](/index.md) | [📋 학습 경로](../../learning-path.md)

</div>

<div align="center">

[← 이전: Docker 기초 실습](./docker-basics) | [📚 전체 커리큘럼](/curriculum.md) | [🏠 학습 경로로 돌아가기](/index.md) | [다음: GitHub Actions 기초 실습 →](./github-actions-basics)

</div>

## 🎯 실습 목표
- Git의 기본 개념과 워크플로우 이해
- GitHub을 활용한 협업 워크플로우 학습
- 브랜치 전략 및 Pull Request 활용
- 팀 프로젝트 기반 Git 협업 실습

## 📋 실습 환경 준비

### 필수 도구 설치
```bash
# Git 설치 확인
git --version

# Git 설정
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 설정 확인
git config --list
```

## 📝 실습 1: Git 기본 명령어

### 1. 저장소 초기화 및 기본 워크플로우
```bash
# 새 디렉토리 생성
mkdir git-practice
cd git-practice

# Git 저장소 초기화
git init

# 파일 생성
echo "Hello Git!" > hello.txt

# 파일 상태 확인
git status

# 파일 추가 (Staging Area에)
git add hello.txt

# 커밋 생성
git commit -m "Initial commit: Add hello.txt"

# 커밋 히스토리 확인
git log
git log --oneline
```

### 2. 파일 수정 및 커밋
```bash
# 파일 수정
echo "This is a Git practice file." >> hello.txt

# 변경사항 확인
git diff

# 파일 추가 및 커밋
git add hello.txt
git commit -m "Add more content to hello.txt"

# 히스토리 확인
git log --oneline
```

## 📝 실습 2: 브랜치 관리

### 1. 브랜치 생성 및 전환
```bash
# 현재 브랜치 확인
git branch

# 새 브랜치 생성 및 전환
git checkout -b feature/new-feature
# 또는 (Git 2.23+)
git switch -c feature/new-feature

# 브랜치에서 작업
echo "This is a new feature." > feature.txt
git add feature.txt
git commit -m "Add new feature file"

# 메인 브랜치로 돌아가기
git checkout main
git switch main
```

### 2. 브랜치 머지
```bash
# 브랜치 목록 확인
git branch

# feature 브랜치를 main에 머지
git merge feature/new-feature

# 머지 후 브랜치 삭제
git branch -d feature/new-feature

# 히스토리 확인
git log --oneline --graph
```

## 📝 실습 3: GitHub 협업

### 1. GitHub 저장소 생성 및 연결
```bash
# GitHub에서 새 저장소 생성 후
# 원격 저장소 추가
git remote add origin https://github.com/username/git-practice.git

# 원격 저장소 확인
git remote -v

# 첫 푸시
git push -u origin main

# 이후 푸시
git push
```

### 2. 다른 개발자 시뮬레이션
```bash
# 다른 디렉토리에서 클론
cd ..
git clone https://github.com/username/git-practice.git git-practice-clone
cd git-practice-clone

# 다른 개발자로서 작업
echo "This is from another developer." > developer2.txt
git add developer2.txt
git commit -m "Add file from developer 2"
git push origin main
```

### 3. 원격 변경사항 가져오기
```bash
# 원래 디렉토리로 돌아가기
cd ../git-practice

# 원격 변경사항 가져오기
git fetch origin
git merge origin/main

# 또는 한 번에
git pull origin main
```

## 📝 실습 4: Pull Request 워크플로우

### 1. Feature 브랜치에서 작업
```bash
# 새 feature 브랜치 생성
git checkout -b feature/awesome-feature

# 작업 수행
echo "This is an awesome feature!" > awesome.txt
git add awesome.txt
git commit -m "Add awesome feature"

# 브랜치 푸시
git push origin feature/awesome-feature
```

### 2. GitHub에서 Pull Request 생성
1. GitHub 저장소 페이지에서 "Compare & pull request" 클릭
2. PR 제목과 설명 작성
3. 리뷰어 지정
4. "Create pull request" 클릭

### 3. PR 리뷰 및 머지
1. 리뷰어가 코드 리뷰 수행
2. 필요시 수정사항 요청
3. 모든 리뷰 통과 후 머지
4. 로컬에서 브랜치 정리

```bash
# main 브랜치로 전환
git checkout main

# 최신 변경사항 가져오기
git pull origin main

# 로컬 브랜치 삭제
git branch -d feature/awesome-feature

# 원격 브랜치 삭제
git push origin --delete feature/awesome-feature
```

## 📝 실습 5: 충돌 해결

### 1. 충돌 상황 만들기
```bash
# main 브랜치에서 파일 수정
echo "Modified by main branch" > conflict.txt
git add conflict.txt
git commit -m "Modify file in main branch"
git push origin main

# feature 브랜치에서 같은 파일 수정
git checkout -b feature/conflict-test
echo "Modified by feature branch" > conflict.txt
git add conflict.txt
git commit -m "Modify file in feature branch"
git push origin feature/conflict-test
```

### 2. 충돌 해결
```bash
# main 브랜치로 돌아가서 머지 시도
git checkout main
git merge feature/conflict-test

# 충돌 발생 시 파일 확인
cat conflict.txt

# 충돌 해결 (수동으로 편집)
# <<<<<<< HEAD
# Modified by main branch
# =======
# Modified by feature branch
# >>>>>>> feature/conflict-test

# 충돌 해결 후
git add conflict.txt
git commit -m "Resolve merge conflict"
```

## 📝 실습 6: 고급 Git 기능

### 1. 커밋 수정
```bash
# 마지막 커밋 메시지 수정
git commit --amend -m "Updated commit message"

# 마지막 커밋에 파일 추가
echo "Additional content" > additional.txt
git add additional.txt
git commit --amend --no-edit
```

### 2. 커밋 되돌리기
```bash
# 특정 커밋으로 되돌리기 (새 커밋 생성)
git revert <commit-hash>

# 커밋 히스토리에서 제거 (위험)
git reset --hard <commit-hash>
```

### 3. Stash 사용
```bash
# 작업 중인 변경사항 임시 저장
git stash

# Stash 목록 확인
git stash list

# Stash 적용
git stash apply

# Stash 삭제
git stash drop
```

## 📝 실습 7: 협업 시나리오

### 1. 팀 프로젝트 시뮬레이션
```bash
# 프로젝트 디렉토리 생성
mkdir team-project
cd team-project
git init

# README 파일 생성
echo "# Team Project" > README.md
git add README.md
git commit -m "Initial project setup"

# GitHub에 푸시
git remote add origin https://github.com/username/team-project.git
git push -u origin main
```

### 2. 각자 브랜치에서 작업
```bash
# 개발자 A: 기능 개발
git checkout -b feature/user-authentication
echo "User authentication feature" > auth.js
git add auth.js
git commit -m "Add user authentication"
git push origin feature/user-authentication

# 개발자 B: 버그 수정
git checkout -b bugfix/login-error
echo "Fixed login error" > login.js
git add login.js
git commit -m "Fix login error"
git push origin bugfix/login-error
```

### 3. 코드 리뷰 및 머지
1. 각각 Pull Request 생성
2. 코드 리뷰 수행
3. 수정사항 반영
4. 머지 승인 및 실행

## 🎯 실습 완료 체크리스트

- [ ] Git 기본 명령어 사용
- [ ] 브랜치 생성, 전환, 머지
- [ ] GitHub 저장소 생성 및 연결
- [ ] Pull Request 워크플로우
- [ ] 충돌 해결
- [ ] 고급 Git 기능 사용
- [ ] 팀 협업 시나리오 실습

## 📚 추가 학습 자료

- [Git 공식 문서](https://git-scm.com/doc)
- [GitHub Learning Lab](https://lab.github.com/)
- [Atlassian Git 튜토리얼](https://www.atlassian.com/git/tutorials)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

## 🚀 다음 단계

- **GitHub Actions**: CI/CD 파이프라인 구축
- **VM 배포**: 클라우드 환경에 애플리케이션 배포
- **고급 협업**: 이슈 관리, 프로젝트 관리
