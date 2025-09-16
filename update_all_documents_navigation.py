#!/usr/bin/env python3
"""
모든 문서에 일관된 상단/하단 링크 구조를 적용하는 자동화 스크립트
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Tuple

class DocumentNavigationUpdater:
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.updated_files = []
        self.errors = []
        
        # 교육 과정별 템플릿 정의
        self.templates = {
            "cloud_basic": {
                "course_name": "Cloud Basic",
                "learning_path": "/mcp_knowledge_base/cloud_basic/learning-path.md",
                "main_page": "/mcp_knowledge_base/cloud_basic/README.md"
            },
            "cloud_master": {
                "course_name": "Cloud Master", 
                "learning_path": "/mcp_knowledge_base/cloud_master/learning-path.md",
                "main_page": "/mcp_knowledge_base/cloud_master/README.md"
            },
            "cloud_container": {
                "course_name": "Cloud Container",
                "learning_path": "/mcp_knowledge_base/cloud_container/learning-path.md", 
                "main_page": "/mcp_knowledge_base/cloud_container/README.md"
            }
        }
    
    def get_course_info(self, file_path: Path) -> Dict[str, str]:
        """파일 경로에서 교육 과정 정보 추출"""
        parts = file_path.parts
        
        if "cloud_basic" in parts:
            return self.templates["cloud_basic"]
        elif "cloud_master" in parts:
            return self.templates["cloud_master"]
        elif "cloud_container" in parts:
            return self.templates["cloud_container"]
        else:
            return {
                "course_name": "Unknown",
                "learning_path": "/mcp_knowledge_base/index.md",
                "main_page": "/mcp_knowledge_base/index.md"
            }
    
    def get_day_info(self, file_path: Path) -> Tuple[str, str]:
        """파일 경로에서 일차 정보 추출"""
        parts = file_path.parts
        
        for part in parts:
            if part.startswith("Day"):
                day_num = part.replace("Day", "")
                return day_num, part
        
        return "1", "Day1"
    
    def get_document_title(self, content: str) -> str:
        """문서 제목 추출"""
        lines = content.split('\n')
        for line in lines:
            if line.startswith('# '):
                return line.replace('# ', '').strip()
        return "문서"
    
    def generate_top_navigation(self, course_info: Dict[str, str], day_info: Tuple[str, str], title: str) -> str:
        """상단 네비게이션 생성"""
        day_num, day_name = day_info
        
        return f"""<div align="center">

## 🏠 최상위 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로]({course_info['learning_path']})

## 📖 현재 위치
**{course_info['course_name']}** > **{day_num}일차** > **{title}**

## ⬅️ 이전/다음 네비게이션
[← 이전: {course_info['course_name']} 메인]({course_info['main_page']}) | [다음: {course_info['course_name']} {day_num}일차 →](/mcp_knowledge_base/{course_info['course_name'].lower().replace(' ', '_')}/textbook/{day_name}/README.md)

</div>"""
    
    def generate_bottom_navigation(self, course_info: Dict[str, str], day_info: Tuple[str, str], title: str) -> str:
        """하단 네비게이션 생성"""
        day_num, day_name = day_info
        
        # 관련 과정 링크 생성
        related_courses = []
        if course_info['course_name'] == "Cloud Basic":
            related_courses = [
                "[Cloud Master 1일차](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)",
                "[Cloud Container 1일차](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)"
            ]
        elif course_info['course_name'] == "Cloud Master":
            related_courses = [
                "[Cloud Basic 2일차](/mcp_knowledge_base/cloud_basic/textbook/Day2/README.md)",
                "[Cloud Container 1일차](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)"
            ]
        elif course_info['course_name'] == "Cloud Container":
            related_courses = [
                "[Cloud Master 3일차](/mcp_knowledge_base/cloud_master/textbook/Day3/README.md)",
                "[Cloud Basic 1일차](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md)"
            ]
        
        related_courses_str = " | ".join(related_courses) if related_courses else ""
        
        return f"""

---

<div align="center">

## 🔗 관련 과정 및 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로]({course_info['learning_path']})

## 📖 현재 위치
**{course_info['course_name']}** > **{day_num}일차** > **{title}**

## ⬅️ 이전/다음 네비게이션
[← 이전: {course_info['course_name']} 메인]({course_info['main_page']}) | [다음: {course_info['course_name']} {day_num}일차 →](/mcp_knowledge_base/{course_info['course_name'].lower().replace(' ', '_')}/textbook/{day_name}/README.md)

## 🔗 관련 과정
{related_courses_str}

</div>"""
    
    def update_document_navigation(self, file_path: Path) -> bool:
        """문서의 네비게이션 구조 업데이트"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 교육 과정 정보 추출
            course_info = self.get_course_info(file_path)
            day_info = self.get_day_info(file_path)
            title = self.get_document_title(content)
            
            # 기존 상단 링크 제거 (복잡한 링크 구조)
            old_top_pattern = r'<div align="center">\s*\n\s*\[.*?\]\s*\n\s*</div>'
            content = re.sub(old_top_pattern, '', content, flags=re.DOTALL)
            
            # 새로운 상단 네비게이션 추가
            new_top_nav = self.generate_top_navigation(course_info, day_info, title)
            
            # 문서 시작 부분에 상단 네비게이션 추가
            if content.startswith('# '):
                content = new_top_nav + '\n\n' + content
            else:
                content = new_top_nav + '\n\n' + content
            
            # 기존 하단 링크 제거
            old_bottom_pattern = r'<div align="center">\s*\n\s*\[.*?\]\s*\n\s*</div>\s*$'
            content = re.sub(old_bottom_pattern, '', content, flags=re.DOTALL)
            
            # 새로운 하단 네비게이션 추가
            new_bottom_nav = self.generate_bottom_navigation(course_info, day_info, title)
            content += new_bottom_nav
            
            # 파일 저장
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            self.updated_files.append(str(file_path))
            return True
            
        except Exception as e:
            self.errors.append(f"Error updating {file_path}: {str(e)}")
            return False
    
    def find_all_markdown_files(self) -> List[Path]:
        """모든 마크다운 파일 찾기"""
        markdown_files = []
        
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                if file.endswith('.md') and file != 'navigation_templates.md':
                    markdown_files.append(Path(root) / file)
        
        return markdown_files
    
    def update_all_documents(self):
        """모든 문서 업데이트"""
        print("🔍 마크다운 파일 검색 중...")
        markdown_files = self.find_all_markdown_files()
        print(f"📄 총 {len(markdown_files)}개 파일 발견")
        
        print("\n🔄 문서 업데이트 시작...")
        for i, file_path in enumerate(markdown_files, 1):
            print(f"[{i}/{len(markdown_files)}] {file_path}")
            
            if self.update_document_navigation(file_path):
                print(f"  ✅ 업데이트 완료")
            else:
                print(f"  ❌ 업데이트 실패")
        
        print(f"\n📊 업데이트 결과:")
        print(f"  ✅ 성공: {len(self.updated_files)}개 파일")
        print(f"  ❌ 실패: {len(self.errors)}개 파일")
        
        if self.errors:
            print(f"\n❌ 오류 목록:")
            for error in self.errors:
                print(f"  - {error}")
    
    def generate_report(self):
        """업데이트 보고서 생성"""
        report = f"""# 문서 네비게이션 업데이트 보고서

## 📊 업데이트 통계
- **총 파일 수**: {len(self.updated_files) + len(self.errors)}개
- **성공**: {len(self.updated_files)}개
- **실패**: {len(self.errors)}개

## ✅ 업데이트된 파일 목록
"""
        
        for file_path in self.updated_files:
            report += f"- {file_path}\n"
        
        if self.errors:
            report += f"\n## ❌ 실패한 파일 목록\n"
            for error in self.errors:
                report += f"- {error}\n"
        
        report += f"""
## 🎯 적용된 변경사항

### 상단 네비게이션 (3단계 계층)
1. **최상위 네비게이션**: 홈, 전체 커리큘럼, 학습 경로
2. **현재 위치**: 교육 과정 > 일차 > 주제
3. **이전/다음 네비게이션**: 이전/다음 문서 링크

### 하단 네비게이션 (상단 + 관련 과정)
1. **상단과 동일한 구조**
2. **관련 과정 링크 추가**

## 🔧 개선 효과
- **복잡성 감소**: 8개 링크 → 3단계 구조
- **일관성 확보**: 모든 문서가 동일한 구조
- **가독성 향상**: 계층적 구조로 명확한 네비게이션
- **사용성 개선**: 현재 위치 파악 및 이동 용이
"""
        
        with open("navigation_update_report.md", "w", encoding="utf-8") as f:
            f.write(report)
        
        print(f"\n📋 보고서 생성: navigation_update_report.md")

def main():
    """메인 함수"""
    print("🚀 문서 네비게이션 업데이트 시작")
    
    updater = DocumentNavigationUpdater()
    updater.update_all_documents()
    updater.generate_report()
    
    print("\n🎉 모든 작업 완료!")

if __name__ == "__main__":
    main()
