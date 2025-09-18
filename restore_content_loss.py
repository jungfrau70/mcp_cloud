#!/usr/bin/env python3
"""
내용 손실 복구 도구
학습 목표, 실습 가이드 등 누락된 내용 복구
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Tuple, Any
from datetime import datetime

class ContentLossRestorer:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.knowledge_base_path = self.base_path / "mcp_knowledge_base"
        self.restored_files = []
        self.restore_count = 0
        
    def find_markdown_files(self) -> List[Path]:
        """모든 마크다운 파일 찾기"""
        md_files = []
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                if file.endswith('.md'):
                    md_files.append(Path(root) / file)
        return md_files
    
    def has_learning_objectives(self, content: str) -> bool:
        """학습 목표가 있는지 확인"""
        patterns = [
            r'#+\s*.*학습.*목표.*',
            r'#+\s*.*Learning.*Objectives.*',
            r'#+\s*.*🎯.*',
            r'##\s*학습\s*목표',
            r'##\s*Learning\s*Objectives'
        ]
        
        for pattern in patterns:
            if re.search(pattern, content, re.IGNORECASE):
                return True
        return False
    
    def has_practice_guide(self, content: str) -> bool:
        """실습 가이드가 있는지 확인"""
        patterns = [
            r'#+\s*.*실습.*',
            r'#+\s*.*Practice.*',
            r'#+\s*.*💻.*',
            r'##\s*실습',
            r'##\s*Practice'
        ]
        
        for pattern in patterns:
            if re.search(pattern, content, re.IGNORECASE):
                return True
        return False
    
    def generate_learning_objectives(self, file_path: Path) -> str:
        """학습 목표 생성"""
        course_name = ""
        day_info = ""
        
        # 과정명 추출
        if "cloud_basic" in str(file_path):
            course_name = "Cloud Basic"
        elif "cloud_container" in str(file_path):
            course_name = "Cloud Container"
        elif "cloud_master" in str(file_path):
            course_name = "Cloud Master"
        
        # 일차 정보 추출
        day_match = re.search(r'Day(\d+)', str(file_path))
        if day_match:
            day_info = f" - {day_match.group(1)}일차"
        
        # 파일 유형에 따른 학습 목표
        if "README" in file_path.name:
            return f"""## 🎯 학습 목표

### 핵심 학습 목표
- **{course_name} 기초** 클라우드 서비스 이해 및 활용
- **{course_name} 실무** 실제 프로젝트 적용 능력 향상

### 실습 후 달성할 수 있는 능력
- ✅ 클라우드 서비스 기본 개념 이해
- ✅ 실제 환경에서 서비스 배포 및 관리
- ✅ 문제 해결 및 최적화 능력

### 예상 소요 시간
- **기초 학습**: 90-120분
- **실습 진행**: 60-90분
- **전체 과정**: 3-4시간"""
        
        elif "practice" in str(file_path):
            return f"""## 🎯 실습 목표

### 실습 목표
- **{course_name} 실습** 단계별 실습을 통한 실무 능력 향상
- **문제 해결** 실제 상황에서의 문제 해결 능력 개발

### 실습 후 달성할 수 있는 능력
- ✅ 단계별 실습 완료
- ✅ 실제 환경에서의 서비스 구성
- ✅ 문제 해결 및 디버깅 능력

### 예상 소요 시간
- **기본 실습**: 60-90분
- **심화 실습**: 30-60분
- **전체 실습**: 2-3시간"""
        
        elif "guide" in file_path.name:
            return f"""## 🎯 가이드 목표

### 가이드 목표
- **{course_name} 가이드** 상세한 설정 및 활용 방법 학습
- **실무 적용** 실제 프로젝트에서의 활용 능력 향상

### 학습 후 달성할 수 있는 능력
- ✅ 상세한 설정 방법 이해
- ✅ 실제 환경에서의 적용
- ✅ 고급 기능 활용 능력

### 예상 소요 시간
- **기본 가이드**: 45-60분
- **고급 가이드**: 30-45분
- **전체 가이드**: 1-2시간"""
        
        else:
            return f"""## 🎯 학습 목표

### 핵심 학습 목표
- **{course_name} 이해** 클라우드 서비스 기본 개념 학습
- **실무 적용** 실제 프로젝트에서의 활용 능력 향상

### 학습 후 달성할 수 있는 능력
- ✅ 기본 개념 이해
- ✅ 실제 환경에서의 적용
- ✅ 문제 해결 능력

### 예상 소요 시간
- **기본 학습**: 60-90분
- **실습 진행**: 30-60분
- **전체 과정**: 2-3시간"""
    
    def generate_practice_guide(self, file_path: Path) -> str:
        """실습 가이드 생성"""
        course_name = ""
        
        # 과정명 추출
        if "cloud_basic" in str(file_path):
            course_name = "Cloud Basic"
        elif "cloud_container" in str(file_path):
            course_name = "Cloud Container"
        elif "cloud_master" in str(file_path):
            course_name = "Cloud Master"
        
        return f"""## 💻 실습 가이드

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/{course_name.lower().replace(' ', '_')}/repos/samples/day[숫자]/[주제]/`
- **자동화 스크립트**: `/mcp_knowledge_base/{course_name.lower().replace(' ', '_')}/repos/automation/day[숫자]/[주제]-practice-automation.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/{course_name.lower().replace(' ', '_')}/repos/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: Google Cloud 서비스 관리
- **Docker**: 컨테이너 관리
- **Git**: 버전 관리

#### 환경 설정
```bash
# AWS CLI 설치 확인
aws --version

# GCP CLI 설치 확인
gcloud --version

# Docker 설치 확인
docker --version
```

</details>

<details>
<summary>🔧 1단계: 기본 실습</summary>

#### 기본 설정
```bash
# 환경 변수 설정
export AWS_REGION=us-west-2
export GCP_PROJECT_ID=your-project-id

# 설정 확인
echo $AWS_REGION
echo $GCP_PROJECT_ID
```

#### 기본 실습
```bash
# 기본 명령어 실행
aws s3 ls
gcloud auth list
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# AWS 기본 명령어
aws s3 ls
aws ec2 describe-instances

# GCP 기본 명령어
gcloud auth list
gcloud config list
```

### 문제 해결
1. **인증 오류**
   - AWS 자격 증명 확인
   - GCP 인증 상태 확인

2. **권한 오류**
   - IAM 권한 확인
   - 서비스 계정 권한 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# 실습 자동 정리
./mcp_knowledge_base/{course_name.lower().replace(' ', '_')}/repos/automation/day[숫자]/[주제]-practice-automation.sh --cleanup
```

### 수동 정리
```bash
# 리소스 정리
aws s3 rm s3://your-bucket --recursive
gcloud compute instances delete your-instance
```

### 정리 확인
- [ ] 모든 리소스 정리 완료
- [ ] 비용 발생 없음 확인
- [ ] 로그 파일 정리"""
    
    def restore_file_content(self, file_path: Path) -> bool:
        """파일 내용 복구"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            restore_count = 0
            
            # 학습 목표 복구
            if not self.has_learning_objectives(content) and "README" in file_path.name:
                learning_objectives = self.generate_learning_objectives(file_path)
                
                # 파일 시작 부분에 학습 목표 추가
                if content.startswith('#'):
                    # 첫 번째 헤딩 다음에 추가
                    lines = content.split('\n')
                    for i, line in enumerate(lines):
                        if line.startswith('#') and not line.startswith('##'):
                            lines.insert(i + 1, "")
                            lines.insert(i + 2, learning_objectives)
                            break
                    content = '\n'.join(lines)
                else:
                    content = learning_objectives + '\n\n' + content
                
                restore_count += 1
            
            # 실습 가이드 복구
            if not self.has_practice_guide(content) and "practice" in str(file_path):
                practice_guide = self.generate_practice_guide(file_path)
                
                # 파일 끝에 실습 가이드 추가
                content = content + '\n\n' + practice_guide
                restore_count += 1
            
            if restore_count > 0:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                self.restored_files.append({
                    'file': str(file_path.relative_to(self.base_path)),
                    'restores': restore_count
                })
                self.restore_count += restore_count
                return True
            
        except Exception as e:
            print(f"오류 발생 {file_path}: {e}")
            return False
        
        return False
    
    def restore_all_content(self):
        """모든 내용 복구"""
        print("🔍 마크다운 파일 검색 중...")
        md_files = self.find_markdown_files()
        print(f"📁 총 {len(md_files)}개 파일 발견")
        
        print("\n🔧 내용 손실 복구 시작...")
        restored_count = 0
        
        for file_path in md_files:
            print(f"\n📄 처리 중: {file_path.relative_to(self.base_path)}")
            
            if self.restore_file_content(file_path):
                restored_count += 1
                print(f"  ✅ {self.restored_files[-1]['restores']}개 내용 복구")
            else:
                print(f"  ⏭️ 복구할 내용 없음")
        
        print(f"\n✅ 복구 완료: {restored_count}개 파일")
        print(f"🔧 총 복구된 내용: {self.restore_count}개")
        
        return restored_count
    
    def generate_report(self):
        """복구 보고서 생성"""
        report = {
            "timestamp": datetime.now().isoformat(),
            "total_files_processed": len(self.find_markdown_files()),
            "files_restored": len(self.restored_files),
            "total_restores": self.restore_count,
            "restored_files": self.restored_files
        }
        
        with open("content_restoration_report.json", "w", encoding="utf-8") as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        print(f"\n📊 보고서 생성: content_restoration_report.json")

def main():
    """메인 함수"""
    print("🔧 내용 손실 복구 도구")
    print("=" * 60)
    
    base_path = Path.cwd()
    restorer = ContentLossRestorer(base_path)
    
    # 내용 복구 실행
    restored_count = restorer.restore_all_content()
    
    # 보고서 생성
    restorer.generate_report()
    
    print(f"\n🎉 내용 손실 복구 완료! ({restored_count}개 파일 복구)")

if __name__ == "__main__":
    main()