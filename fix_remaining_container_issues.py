#!/usr/bin/env python3
"""
Cloud Container 과정의 남은 앵커 링크 문제 수정
"""

import re
from pathlib import Path

def fix_remaining_container_issues():
    """Cloud Container 과정의 남은 앵커 링크 문제 수정"""
    
    print("🔧 Cloud Container 과정 남은 문제 수정 시작...\n")
    
    # 1. Day2/README.md 수정
    fix_day2_readme()
    
    # 2. Day1/practice/kubernetes-basics.md 수정
    fix_kubernetes_basics()
    
    print("\n🎉 모든 문제 수정 완료!")

def fix_day2_readme():
    """Day2/README.md의 누락된 섹션 추가"""
    
    file_path = Path("mcp_knowledge_base/cloud_container/textbook/Day2/README.md")
    
    if not file_path.exists():
        print("❌ Day2/README.md 파일을 찾을 수 없습니다.")
        return
    
    print("📝 Day2/README.md 수정 중...")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 누락된 섹션들 추가
    missing_sections = [
        {
            'title': '## 🔄 자동 복구 및 운영 자동화',
            'anchor': '자동-복구-및-운영-자동화',
            'content': '''## 🔄 자동 복구 및 운영 자동화

<details>
<summary>📖 자동 복구 시스템</summary>

### 자동 복구 전략

[자동 복구 전략](#자동-복구-전략)
- **Health Check**: 정기적인 상태 확인
- **Auto Healing**: 자동 복구 및 재시작
- **Circuit Breaker**: 장애 전파 방지
- **Rolling Update**: 무중단 배포

### 운영 자동화

[운영 자동화](#운영-자동화)
- **Infrastructure as Code**: Terraform, CloudFormation
- **Configuration Management**: Ansible, Chef, Puppet
- **CI/CD Pipeline**: GitHub Actions, GitLab CI
- **Monitoring & Alerting**: 자동 알림 및 대응

### 장애 대응 프로세스

[장애 대응 프로세스](#장애-대응-프로세스)
1. **Detection**: 모니터링 시스템이 장애 감지
2. **Analysis**: 로그 및 메트릭 분석
3. **Response**: 자동 복구 또는 수동 개입
4. **Recovery**: 서비스 정상화
5. **Post-mortem**: 사후 분석 및 개선

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [자동 복구 및 운영 자동화 실습](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/auto-recovery-guide.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [자동 복구 및 운영 자동화 가이드](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/auto-recovery-guide.md)

</details>

---''',
            'insert_after': '## 📊 모니터링 및 로깅 시스템'
        },
        {
            'title': '## 💰 비용 최적화 전략',
            'anchor': '비용-최적화-전략',
            'content': '''## 💰 비용 최적화 전략

<details>
<summary>📖 비용 최적화 방법</summary>

### 비용 분석 및 모니터링

[비용 분석 및 모니터링](#비용-분석-및-모니터링)
- **Cost Explorer**: 상세한 비용 분석
- **Budget Alerts**: 예산 초과 알림
- **Resource Tagging**: 리소스별 비용 추적
- **Cost Allocation**: 부서별 비용 배분

### 최적화 전략

[최적화 전략](#최적화-전략)
- **Right Sizing**: 적절한 인스턴스 크기 선택
- **Reserved Instances**: 장기 사용 시 할인
- **Spot Instances**: 중단 가능한 작업용
- **Auto Scaling**: 수요에 따른 자동 조정

### 비용 절약 팁

[비용 절약 팁](#비용-절약-팁)
- **S3 Lifecycle**: 자동 아카이빙 및 삭제
- **CloudFront**: CDN으로 전송 비용 절약
- **RDS**: 자동 백업 및 스냅샷 최적화
- **Lambda**: 서버리스로 인프라 비용 절약

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [비용 최적화 전략 실습](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/cost-optimization-guide.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [비용 최적화 전략 가이드](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/cost-optimization-guide.md)

</details>

---''',
            'insert_after': '## 🔄 자동 복구 및 운영 자동화'
        },
        {
            'title': '## 🏗️ 고가용성 아키텍처 실습',
            'anchor': '고가용성-아키텍처-실습',
            'content': '''## 🏗️ 고가용성 아키텍처 실습

<details>
<summary>📖 실습 개요</summary>

### 실습 목표

[실습 목표](#실습-목표)
- Multi-AZ 아키텍처 구성
- Multi-Region 아키텍처 구성
- 고가용성 테스트 수행
- 장애 복구 시나리오 검증

### 실습 환경

[실습 환경](#실습-환경)
- **AWS**: EC2, RDS, ELB, Route 53
- **GCP**: Compute Engine, Cloud SQL, Load Balancer
- **모니터링**: CloudWatch, Cloud Monitoring

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [고가용성 아키텍처 실습](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/high-availability-architecture.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [고가용성 아키텍처 가이드](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/high-availability-architecture.md)

</details>

---''',
            'insert_after': '## 🎯 종합 프로젝트 및 최적화'
        },
        {
            'title': '## 📊 모니터링 및 로깅 시스템 실습',
            'anchor': '모니터링-및-로깅-시스템-실습',
            'content': '''## 📊 모니터링 및 로깅 시스템 실습

<details>
<summary>📖 실습 개요</summary>

### 실습 목표

[실습 목표](#실습-목표)
- CloudWatch 고급 설정
- Cloud Monitoring 구성
- 대시보드 및 알림 설정
- 로그 분석 및 시각화

### 실습 환경

[실습 환경](#실습-환경)
- **AWS**: CloudWatch, X-Ray
- **GCP**: Cloud Monitoring, Cloud Logging
- **오픈소스**: Prometheus, Grafana

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [모니터링 시스템 구축](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/monitoring-system-setup.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [모니터링 시스템 가이드](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/monitoring-system-setup.md)

</details>

---''',
            'insert_after': '## 🏗️ 고가용성 아키텍처 실습'
        },
        {
            'title': '## 🔄 자동 복구 및 운영 자동화 실습',
            'anchor': '자동-복구-및-운영-자동화-실습',
            'content': '''## 🔄 자동 복구 및 운영 자동화 실습

<details>
<summary>📖 실습 개요</summary>

### 실습 목표

[실습 목표](#실습-목표)
- 자동 복구 시스템 구성
- 운영 자동화 스크립트 작성
- CI/CD 파이프라인 구축
- 모니터링 및 알림 설정

### 실습 환경

[실습 환경](#실습-환경)
- **AWS**: Lambda, Step Functions, CodePipeline
- **GCP**: Cloud Functions, Cloud Build, Cloud Scheduler
- **도구**: Terraform, Ansible, GitHub Actions

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [자동 복구 및 운영 자동화 실습](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/auto-recovery-guide.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [자동 복구 및 운영 자동화 가이드](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/auto-recovery-guide.md)

</details>

---''',
            'insert_after': '## 📊 모니터링 및 로깅 시스템 실습'
        },
        {
            'title': '## 💰 비용 최적화 전략 실습',
            'anchor': '비용-최적화-전략-실습',
            'content': '''## 💰 비용 최적화 전략 실습

<details>
<summary>📖 실습 개요</summary>

### 실습 목표

[실습 목표](#실습-목표)
- 비용 분석 및 모니터링 설정
- 최적화 전략 적용
- 비용 절약 효과 측정
- 예산 관리 및 알림 설정

### 실습 환경

[실습 환경](#실습-환경)
- **AWS**: Cost Explorer, Budgets, Trusted Advisor
- **GCP**: Billing, Recommender, Budgets
- **도구**: Terraform, CloudFormation

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [비용 최적화 전략 실습](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/cost-optimization-guide.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [비용 최적화 전략 가이드](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/cost-optimization-guide.md)

</details>

---''',
            'insert_after': '## 🔄 자동 복구 및 운영 자동화 실습'
        }
    ]
    
    # 각 섹션을 적절한 위치에 삽입
    for section in missing_sections:
        # 삽입할 위치 찾기
        insert_pattern = f"^{re.escape(section['insert_after'])}$"
        match = re.search(insert_pattern, content, re.MULTILINE)
        
        if match:
            # 해당 섹션 다음에 새로운 섹션 삽입
            insert_pos = match.end()
            content = content[:insert_pos] + '\n\n' + section['content'] + '\n\n' + content[insert_pos:]
            print(f"  ✅ {section['title']} 섹션 추가")
        else:
            print(f"  ⚠️ {section['insert_after']} 섹션을 찾을 수 없어 {section['title']} 추가 실패")
    
    # 파일 저장
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"  ✅ Day2/README.md 수정 완료")

def fix_kubernetes_basics():
    """Day1/practice/kubernetes-basics.md의 누락된 앵커 링크 추가"""
    
    file_path = Path("mcp_knowledge_base/cloud_container/textbook/Day1/practice/kubernetes-basics.md")
    
    if not file_path.exists():
        print("❌ kubernetes-basics.md 파일을 찾을 수 없습니다.")
        return
    
    print("📝 kubernetes-basics.md 수정 중...")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 누락된 앵커 링크 추가
    missing_anchor = '🏗️ GKE 클러스터 생성'
    expected_anchor = 'gke-클러스터-생성'
    
    # 해당 제목 찾기
    heading_pattern = f"^### {re.escape(missing_anchor)}$"
    match = re.search(heading_pattern, content, re.MULTILINE)
    
    if match:
        # 제목 다음에 앵커 링크 추가
        insert_pos = match.end()
        anchor_link = f"\n\n[{missing_anchor}](#{expected_anchor})"
        content = content[:insert_pos] + anchor_link + content[insert_pos:]
        print(f"  ✅ {missing_anchor} 앵커 링크 추가")
    else:
        print(f"  ⚠️ {missing_anchor} 제목을 찾을 수 없음")
    
    # 파일 저장
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"  ✅ kubernetes-basics.md 수정 완료")

if __name__ == "__main__":
    fix_remaining_container_issues()
