#!/usr/bin/env python3
"""
하단 링크를 섹션 밖으로 이동시켜 접었을 때도 보이도록 수정
"""

import os
import re
from pathlib import Path
from typing import List, Dict

class BottomLinksFixer:
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.updated_files = []
        
    def run_fix(self):
        """하단 링크를 섹션 밖으로 이동시키는 수정 실행"""
        print("🔗 하단 링크를 섹션 밖으로 이동시키는 수정 시작")
        
        # 1. 모든 마크다운 파일 찾기
        md_files = list(self.knowledge_base_path.rglob('*.md'))
        
        print(f"  📄 발견된 마크다운 파일: {len(md_files)}개")
        
        # 2. 각 파일에서 하단 링크를 섹션 밖으로 이동
        for md_file in md_files:
            self.fix_bottom_links_in_file(md_file)
        
        # 3. 보고서 생성
        self.generate_fix_report()
        
        print(f"\n🎉 하단 링크 수정 완료! ({len(self.updated_files)}개 파일 수정)")
    
    def fix_bottom_links_in_file(self, file_path: Path):
        """파일에서 하단 링크를 섹션 밖으로 이동"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            updated = False
            
            # 1. 기존 하단 네비게이션을 찾아서 제거
            bottom_nav_patterns = [
                r'<div align="center">\s*\n\s*## 🔗 관련 과정 및 네비게이션.*?</div>\s*\n',
                r'<div align="center">\s*\n\s*## 🔗 관련 과정.*?</div>\s*\n',
                r'<div align="center">\s*\n\s*## 🔗 네비게이션.*?</div>\s*\n',
                r'<div align="center">\s*\n\s*## 🔗.*?</div>\s*\n',
            ]
            
            for pattern in bottom_nav_patterns:
                if re.search(pattern, content, re.DOTALL):
                    content = re.sub(pattern, '', content, flags=re.DOTALL)
                    updated = True
            
            # 2. 파일 끝에 하단 네비게이션 추가 (섹션 밖에)
            # 기존 하단 네비게이션이 있는지 확인
            if not re.search(r'<div align="center">\s*\n\s*🏠 홈.*?</div>', content, re.DOTALL):
                # 과정명 추출
                course_name = self.extract_course_name(file_path)
                
                # 하단 네비게이션 생성
                bottom_nav = f"""

---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/{course_name}/learning-path.md)

</div>
"""
                
                # 파일 끝에 추가
                content = content.rstrip() + bottom_nav
                updated = True
            
            # 3. 섹션 내부에 있는 하단 링크를 찾아서 섹션 밖으로 이동
            # details 태그나 섹션 내부에 있는 하단 링크 찾기
            section_patterns = [
                r'(<details>.*?</details>)\s*<div align="center">\s*\n\s*🏠 홈.*?</div>',
                r'(## .*?)\s*<div align="center">\s*\n\s*🏠 홈.*?</div>',
            ]
            
            for pattern in section_patterns:
                match = re.search(pattern, content, re.DOTALL)
                if match:
                    # 섹션 내용과 하단 링크 분리
                    section_content = match.group(1)
                    bottom_link = re.search(r'<div align="center">\s*\n\s*🏠 홈.*?</div>', content, re.DOTALL)
                    
                    if bottom_link:
                        # 섹션에서 하단 링크 제거
                        content = re.sub(pattern, r'\1', content, flags=re.DOTALL)
                        
                        # 파일 끝에 하단 링크 추가 (이미 있지 않은 경우)
                        if not re.search(r'<div align="center">\s*\n\s*🏠 홈.*?</div>', content, re.DOTALL):
                            course_name = self.extract_course_name(file_path)
                            bottom_nav = f"""

---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/{course_name}/learning-path.md)

</div>
"""
                            content = content.rstrip() + bottom_nav
                        
                        updated = True
            
            # 4. 파일이 변경되었으면 저장
            if updated and content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                self.updated_files.append({
                    'file': str(file_path),
                    'action': '하단 링크를 섹션 밖으로 이동'
                })
                
                print(f"  ✅ 수정: {file_path.relative_to(self.knowledge_base_path)}")
        
        except Exception as e:
            print(f"  ❌ 오류: {file_path} - {str(e)}")
    
    def extract_course_name(self, file_path: Path) -> str:
        """파일 경로에서 과정명 추출"""
        path_str = str(file_path)
        
        if 'cloud_basic' in path_str:
            return 'cloud_basic'
        elif 'cloud_master' in path_str:
            return 'cloud_master'
        elif 'cloud_container' in path_str:
            return 'cloud_container'
        else:
            return 'cloud_basic'  # 기본값
    
    def generate_fix_report(self):
        """수정 보고서 생성"""
        report = f"""# 하단 링크 섹션 밖 이동 수정 보고서

## 🔗 수정 내용

### 문제점
- 하단 네비게이션 링크가 섹션 내부에 포함되어 있음
- 섹션이 접혀있을 때 하단 링크가 보이지 않음
- 사용자가 네비게이션에 접근하기 어려움

### 해결책
- 하단 네비게이션을 모든 섹션 밖으로 이동
- 파일 끝에 독립적인 하단 네비게이션 배치
- 섹션 상태와 관계없이 항상 접근 가능하도록 수정

## 📊 수정 통계

- **총 수정된 파일 수**: {len(self.updated_files)}개
- **수정 유형**: 하단 링크 섹션 밖 이동

## 📋 상세 수정 내역

"""
        
        for update in self.updated_files:
            report += f"- **{update['file']}**: {update['action']}\n"
        
        report += f"""
## 🎯 수정 효과

### 1. 접근성 개선
- **항상 접근 가능**: 모든 섹션이 접혀있어도 하단 링크에 접근 가능
- **일관된 위치**: 모든 파일에서 하단 링크가 동일한 위치에 배치
- **사용자 편의성**: 네비게이션에 쉽게 접근할 수 있음

### 2. 구조 개선
- **섹션 독립성**: 하단 링크가 섹션에 의존하지 않음
- **명확한 분리**: 콘텐츠와 네비게이션의 명확한 분리
- **일관된 경험**: 모든 문서에서 동일한 네비게이션 경험

## ✅ 완료 사항

1. **섹션 내부 하단 링크 제거**: 모든 섹션에서 하단 링크 제거
2. **파일 끝에 독립적 하단 링크 배치**: 모든 파일 끝에 하단 네비게이션 추가
3. **섹션 상태 무관 접근**: 섹션이 접혀있어도 하단 링크 접근 가능
4. **일관된 형식 적용**: 모든 파일에 동일한 하단 네비게이션 형식 적용

## 🎉 결론

**총 {len(self.updated_files)}개의 파일에서 하단 링크가 성공적으로 섹션 밖으로 이동**되었습니다.

이제 모든 교육 자료에서:
- **항상 접근 가능한 하단 링크**: 섹션 상태와 관계없이 하단 네비게이션 접근 가능
- **일관된 사용자 경험**: 모든 문서에서 동일한 네비게이션 경험
- **개선된 사용성**: 사용자가 언제든지 쉽게 네비게이션에 접근 가능

**더 사용하기 쉬운 교육 자료가 되었습니다!** 🚀
"""
        
        with open("bottom_links_fix_report.md", "w", encoding="utf-8") as f:
            f.write(report)
        
        print(f"\n📋 수정 보고서 생성: bottom_links_fix_report.md")

def main():
    """메인 함수"""
    fixer = BottomLinksFixer()
    fixer.run_fix()

if __name__ == "__main__":
    main()
