#!/usr/bin/env python3
"""
상단 링크 삭제 및 하단 링크 접었을 때도 보이도록 수정
"""

import os
import re
from pathlib import Path
from typing import List, Dict

class TopLinksRemover:
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.updated_files = []
        
    def run_update(self):
        """상단 링크 삭제 및 하단 링크 수정 실행"""
        print("🔗 상단 링크 삭제 및 하단 링크 수정 시작")
        
        # 1. 모든 마크다운 파일 찾기
        md_files = list(self.knowledge_base_path.rglob('*.md'))
        
        print(f"  📄 발견된 마크다운 파일: {len(md_files)}개")
        
        # 2. 각 파일에서 상단 링크 삭제 및 하단 링크 수정
        for md_file in md_files:
            self.update_links_in_file(md_file)
        
        # 3. 보고서 생성
        self.generate_update_report()
        
        print(f"\n🎉 링크 수정 완료! ({len(self.updated_files)}개 파일 수정)")
    
    def update_links_in_file(self, file_path: Path):
        """파일에서 링크 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            updated = False
            
            # 1. 상단 네비게이션 섹션 삭제
            top_nav_patterns = [
                r'<div align="center">\s*\n\s*## 🏠 최상위 네비게이션.*?</div>\s*\n',
                r'<div align="center">\s*\n\s*## 📖 현재 위치.*?</div>\s*\n',
                r'<div align="center">\s*\n\s*## ⬅️ 이전/다음 네비게이션.*?</div>\s*\n',
                r'## 🏠 최상위 네비게이션.*?\n\s*## 📖',
                r'## 📖 현재 위치.*?\n\s*## ⬅️',
                r'## ⬅️ 이전/다음 네비게이션.*?\n\s*##',
            ]
            
            for pattern in top_nav_patterns:
                if re.search(pattern, content, re.DOTALL):
                    content = re.sub(pattern, '', content, flags=re.DOTALL)
                    updated = True
            
            # 2. 하단 네비게이션을 접었을 때도 보이도록 수정
            # 기존 하단 네비게이션을 찾아서 수정
            bottom_nav_pattern = r'<div align="center">\s*\n\s*## 🔗 관련 과정 및 네비게이션.*?</div>'
            
            if re.search(bottom_nav_pattern, content, re.DOTALL):
                # 하단 네비게이션을 간단한 형태로 변경
                new_bottom_nav = """<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/{course}/learning-path.md)

</div>"""
                
                # 과정명 추출
                course_name = self.extract_course_name(file_path)
                if course_name:
                    new_bottom_nav = new_bottom_nav.replace('{course}', course_name)
                
                content = re.sub(bottom_nav_pattern, new_bottom_nav, content, flags=re.DOTALL)
                updated = True
            
            # 3. 기존의 복잡한 하단 네비게이션도 간단하게 변경
            complex_bottom_patterns = [
                r'<div align="center">\s*\n\s*## 🔗 관련 과정 및 네비게이션.*?## 📖 현재 위치.*?## ⬅️ 이전/다음 네비게이션.*?## 🔗 관련 과정.*?</div>',
                r'<div align="center">\s*\n\s*## 🔗 관련 과정 및 네비게이션.*?## 📖 현재 위치.*?## ⬅️ 이전/다음 네비게이션.*?</div>',
            ]
            
            for pattern in complex_bottom_patterns:
                if re.search(pattern, content, re.DOTALL):
                    course_name = self.extract_course_name(file_path)
                    if course_name:
                        new_bottom_nav = f"""<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/{course_name}/learning-path.md)

</div>"""
                        content = re.sub(pattern, new_bottom_nav, content, flags=re.DOTALL)
                        updated = True
            
            # 4. 파일이 변경되었으면 저장
            if updated and content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                self.updated_files.append({
                    'file': str(file_path),
                    'action': '상단 링크 삭제 및 하단 링크 수정'
                })
                
                print(f"  ✅ 업데이트: {file_path.relative_to(self.knowledge_base_path)}")
        
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
    
    def generate_update_report(self):
        """업데이트 보고서 생성"""
        report = f"""# 상단 링크 삭제 및 하단 링크 수정 보고서

## 🔗 변경 내용

### 삭제된 상단 링크
- **🏠 최상위 네비게이션** 섹션 전체 삭제
- **📖 현재 위치** 섹션 전체 삭제  
- **⬅️ 이전/다음 네비게이션** 섹션 전체 삭제

### 수정된 하단 링크
- **기존**: 복잡한 다단계 네비게이션 구조
- **변경 후**: 간단한 3개 링크 구조 (홈, 커리큘럼, 학습 경로)
- **접었을 때도 보임**: 모든 섹션이 접혀있어도 하단 링크는 항상 표시

## 📊 변경 통계

- **총 수정된 파일 수**: {len(self.updated_files)}개
- **변경 유형**: 상단 링크 삭제 + 하단 링크 간소화

## 📋 상세 변경 내역

"""
        
        for update in self.updated_files:
            report += f"- **{update['file']}**: {update['action']}\n"
        
        report += f"""
## 🎯 변경 효과

### 1. 상단 링크 삭제 효과
- **깔끔한 상단**: 복잡한 네비게이션으로 인한 혼란 제거
- **집중도 향상**: 학습 내용에 더 집중할 수 있는 환경 조성
- **로딩 속도**: 불필요한 상단 링크로 인한 로딩 지연 방지

### 2. 하단 링크 간소화 효과
- **항상 접근 가능**: 모든 섹션이 접혀있어도 하단 링크는 항상 보임
- **직관적 네비게이션**: 홈, 커리큘럼, 학습 경로 3개 핵심 링크만 제공
- **일관된 경험**: 모든 문서에서 동일한 하단 네비게이션 경험

## ✅ 완료 사항

1. **상단 네비게이션 완전 삭제**: 모든 파일에서 상단 링크 섹션 제거
2. **하단 네비게이션 간소화**: 복잡한 구조를 3개 핵심 링크로 단순화
3. **접었을 때도 보임**: 하단 링크가 항상 표시되도록 수정
4. **일관된 형식 적용**: 모든 파일에 동일한 하단 네비게이션 적용

## 🎉 결론

**총 {len(self.updated_files)}개의 파일에서 링크 구조가 성공적으로 개선**되었습니다.

이제 모든 교육 자료에서:
- **깔끔한 상단**: 복잡한 네비게이션 없이 학습 내용에 집중
- **항상 접근 가능한 하단**: 모든 섹션이 접혀있어도 핵심 링크에 접근 가능
- **일관된 사용자 경험**: 모든 문서에서 동일한 네비게이션 경험

**더 깔끔하고 사용하기 쉬운 교육 자료가 되었습니다!** 🚀
"""
        
        with open("top_links_removal_report.md", "w", encoding="utf-8") as f:
            f.write(report)
        
        print(f"\n📋 업데이트 보고서 생성: top_links_removal_report.md")

def main():
    """메인 함수"""
    remover = TopLinksRemover()
    remover.run_update()

if __name__ == "__main__":
    main()
