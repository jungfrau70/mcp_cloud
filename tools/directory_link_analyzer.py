#!/usr/bin/env python3
"""
디렉토리 링크 분석 및 처리 도구
내부 링크가 디렉토리에 걸린 경우의 처리 방안 분석
"""

import os
import re
import glob
from pathlib import Path
from typing import List, Tuple, Dict

class DirectoryLinkAnalyzer:
    def __init__(self, knowledge_base_root: str = "mcp_knowledge_base"):
        self.knowledge_base_root = Path(knowledge_base_root)
        self.directory_links = []
        self.external_links = []
        self.internal_file_links = []
        
    def analyze_directory_links(self) -> Dict:
        """디렉토리 링크 분석"""
        print("🔍 디렉토리 링크 분석 중...")
        
        # 모든 마크다운 파일에서 링크 추출
        for md_file in self.knowledge_base_root.rglob("*.md"):
            self._analyze_file_links(md_file)
        
        # 분석 결과 정리
        analysis_result = {
            "total_directory_links": len(self.directory_links),
            "total_external_links": len(self.external_links),
            "total_internal_file_links": len(self.internal_file_links),
            "directory_links": self.directory_links,
            "external_links": self.external_links,
            "internal_file_links": self.internal_file_links
        }
        
        return analysis_result
    
    def _analyze_file_links(self, file_path: Path) -> None:
        """파일 내 링크 분석"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 링크 패턴 찾기
            link_pattern = r'\[([^\]]+)\]\(([^)]+)\)'
            matches = re.finditer(link_pattern, content)
            
            for match in matches:
                link_text = match.group(1)
                link_url = match.group(2)
                
                # 링크 분류
                if self._is_external_link(link_url):
                    self.external_links.append({
                        "file": str(file_path),
                        "text": link_text,
                        "url": link_url,
                        "type": "external"
                    })
                elif self._is_directory_link(link_url):
                    self.directory_links.append({
                        "file": str(file_path),
                        "text": link_text,
                        "url": link_url,
                        "type": "directory",
                        "exists": self._check_directory_exists(file_path, link_url)
                    })
                else:
                    self.internal_file_links.append({
                        "file": str(file_path),
                        "text": link_text,
                        "url": link_url,
                        "type": "internal_file",
                        "exists": self._check_file_exists(file_path, link_url)
                    })
        
        except Exception as e:
            print(f"❌ 파일 분석 오류: {file_path} - {str(e)}")
    
    def _is_external_link(self, url: str) -> bool:
        """외부 링크 확인"""
        return url.startswith(('http://', 'https://', 'ftp://', 'mailto:'))
    
    def _is_directory_link(self, url: str) -> bool:
        """디렉토리 링크 확인"""
        return url.endswith('/') and not self._is_external_link(url)
    
    def _check_directory_exists(self, file_path: Path, link_url: str) -> bool:
        """디렉토리 존재 확인"""
        try:
            # 상대 경로를 절대 경로로 변환
            if link_url.startswith('/'):
                # 절대 경로
                target_path = self.knowledge_base_root / link_url[1:]
            else:
                # 상대 경로
                target_path = file_path.parent / link_url
            
            return target_path.exists() and target_path.is_dir()
        except:
            return False
    
    def _check_file_exists(self, file_path: Path, link_url: str) -> bool:
        """파일 존재 확인"""
        try:
            # 상대 경로를 절대 경로로 변환
            if link_url.startswith('/'):
                # 절대 경로
                target_path = self.knowledge_base_root / link_url[1:]
            else:
                # 상대 경로
                target_path = file_path.parent / link_url
            
            return target_path.exists() and target_path.is_file()
        except:
            return False
    
    def generate_directory_link_guidelines(self) -> str:
        """디렉토리 링크 처리 가이드라인 생성"""
        guidelines = """
# 디렉토리 링크 처리 가이드라인

## 🎯 목적
내부 링크가 디렉토리에 걸린 경우의 처리 방안을 정의합니다.

## 📋 디렉토리 링크 처리 규칙

### 1. 디렉토리 링크의 정의
- 링크 URL이 `/`로 끝나는 경우
- 외부 링크가 아닌 경우
- 예: `[실습 코드](cloud_intermediate/samples/day1/)`

### 2. 디렉토리 링크 처리 방안

#### A. README.md 파일이 있는 경우
```markdown
<!-- ✅ DO: README.md 파일로 링크 -->
[실습 코드](cloud_intermediate/samples/day1/README.md)
```

#### B. README.md 파일이 없는 경우
```markdown
<!-- ✅ DO: 대표 파일로 링크 -->
[실습 코드](cloud_intermediate/samples/day1/main.md)
```

#### C. 여러 파일이 있는 경우
```markdown
<!-- ✅ DO: 인덱스 파일 생성 후 링크 -->
[실습 코드](cloud_intermediate/samples/day1/index.md)
```

### 3. 자동 처리 방안

#### A. README.md 파일 자동 생성
```python
def create_directory_readme(directory_path: Path) -> None:
    \"\"\"디렉토리에 README.md 파일 생성\"\"\"
    readme_path = directory_path / "README.md"
    
    if not readme_path.exists():
        content = f\"\"\"# {directory_path.name}
        
## 📁 디렉토리 개요
이 디렉토리는 {directory_path.name} 관련 파일들을 포함합니다.

## 📄 파일 목록
{self._generate_file_list(directory_path)}

## 🔗 관련 링크
- [상위 디렉토리](../README.md)
- [전체 프로젝트](../../README.md)
\"\"\"
        
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(content)
```

#### B. 디렉토리 링크 자동 수정
```python
def fix_directory_links(file_path: Path) -> None:
    \"\"\"디렉토리 링크를 적절한 파일 링크로 수정\"\"\"
    # 디렉토리 링크 찾기
    # README.md 파일 존재 확인
    # 적절한 파일로 링크 수정
```

### 4. 품질 보장

#### A. 디렉토리 링크 검증
- 모든 디렉토리 링크가 실제 디렉토리를 가리키는지 확인
- 디렉토리에 적절한 인덱스 파일이 있는지 확인
- 링크가 깨지지 않는지 확인

#### B. 자동화 도구
- 디렉토리 링크 자동 감지
- README.md 파일 자동 생성
- 링크 자동 수정

## 🚨 주의사항

### 절대 금지사항
- ❌ 존재하지 않는 디렉토리로 링크
- ❌ 디렉토리 링크를 그대로 두기
- ❌ 외부 링크를 내부 링크로 잘못 분류

### 권장사항
- ✅ 모든 디렉토리에 README.md 파일 생성
- ✅ 디렉토리 링크를 구체적인 파일 링크로 변경
- ✅ 정기적인 링크 검증 및 수정
"""
        return guidelines
    
    def print_analysis_report(self, analysis_result: Dict) -> None:
        """분석 결과 출력"""
        print("\n📊 디렉토리 링크 분석 결과")
        print("=" * 50)
        
        print(f"📁 디렉토리 링크: {analysis_result['total_directory_links']}개")
        for link in analysis_result['directory_links']:
            status = "✅ 존재" if link['exists'] else "❌ 없음"
            print(f"   - {link['file']}: [{link['text']}]({link['url']}) {status}")
        
        print(f"\n🌐 외부 링크: {analysis_result['total_external_links']}개")
        print(f"📄 내부 파일 링크: {analysis_result['total_internal_file_links']}개")
        
        # 문제가 있는 디렉토리 링크
        broken_links = [link for link in analysis_result['directory_links'] if not link['exists']]
        if broken_links:
            print(f"\n⚠️  문제가 있는 디렉토리 링크: {len(broken_links)}개")
            for link in broken_links:
                print(f"   - {link['file']}: [{link['text']}]({link['url']})")

def main():
    """메인 함수"""
    print("🔍 디렉토리 링크 분석 도구")
    print("=" * 50)
    
    analyzer = DirectoryLinkAnalyzer()
    
    # 분석 실행
    analysis_result = analyzer.analyze_directory_links()
    
    # 결과 출력
    analyzer.print_analysis_report(analysis_result)
    
    # 가이드라인 생성
    guidelines = analyzer.generate_directory_link_guidelines()
    
    # 가이드라인 파일 저장
    with open("tools/directory_link_guidelines.md", 'w', encoding='utf-8') as f:
        f.write(guidelines)
    
    print(f"\n📚 가이드라인 저장: tools/directory_link_guidelines.md")

if __name__ == "__main__":
    main()
