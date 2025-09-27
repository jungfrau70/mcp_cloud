# 마스터 과정 자동화 사용자 가이드


## 빠른 시작

### 1단계: 실행
```bash
cd automation_tests
python master_course_automation.py
```

### 2단계: 생성된 스크립트 확인
```bash
ls mcp_knowledge_base/cloud_master/automation/
```

### 3단계: 실습 스크립트 실행
```bash
cd mcp_knowledge_base/cloud_master/automation/day1
chmod +x *.sh
docker_basics.sh
```

## 생성되는 실습 스크립트

### Day 1: 기초
- `docker_basics.sh` - Docker 컨테이너 실습
- `git_github_basics.sh` - Git/GitHub 협업 실습
- `github_actions.sh` - CI/CD 파이프라인 구축
- `vm_deployment.sh` - 클라우드 VM 배포

### Day 2: 고급
- `docker_advanced.sh` - Docker 최적화 기법
- `advanced_cicd.sh` - 고급 CI/CD 파이프라인
- `container_orchestration.sh` - 컨테이너 오케스트레이션

### Day 3: 운영
- `load_balancing.sh` - 로드 밸런싱 및 스케일링
- `monitoring.sh` - 모니터링 및 로깅
- `cost_optimization.sh` - 비용 최적화

## 테스트 실행

```bash
# 모든 테스트 실행
python run_master_course_tests.py

# 개별 테스트 실행
pytest test_master_course_automation.py -v
```

## 문제 해결

### 권한 오류
```bash
chmod +x *.sh
```

### 도구 누락
일부 도구가 없어도 자동화는 계속 진행됩니다.

### 인코딩 문제
모든 파일은 UTF-8로 저장되어 있습니다.

## 지원
문제가 있으면 이슈를 등록해 주세요.


---


---



<div align="center">

["← 이전: Cloud Master 메인"](README.md) | ["📚 전체 커리큘럼"](curriculum.md) | ["🏠 학습 경로로 돌아가기"](index.md) | ["📋 학습 경로"](learning-path.md)

</div>