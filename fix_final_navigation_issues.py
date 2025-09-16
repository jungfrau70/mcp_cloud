#!/usr/bin/env python3
"""
최종 네비게이션 문제 수정 스크립트
"""

import os
import re
from pathlib import Path
from typing import Dict, List

class FinalNavigationFixer:
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.fixed_files = []
        self.errors = []
    
    def fix_cloud_container_day2_readme(self, file_path: Path):
        """Cloud Container Day2 README.md 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 올바른 네비게이션 구조로 교체
            correct_nav = """<div align="center">

## 🏠 최상위 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_container/learning-path.md)

## 📖 현재 위치
**Cloud Container** > **2일차** > **고가용성 아키텍처 및 모니터링**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Container 1일차](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md) | [다음: Cloud Container 메인 →](/mcp_knowledge_base/cloud_container/README.md)

</div>"""
            
            # 기존 네비게이션 제거
            content = re.sub(r'<div align="center">\s*\n.*?</div>', '', content, flags=re.DOTALL)
            
            # 새로운 네비게이션 추가
            if content.startswith('# '):
                content = correct_nav + '\n\n' + content
            else:
                content = correct_nav + '\n\n' + content
            
            # 하단 네비게이션 추가
            bottom_nav = f"""

---

<div align="center">

## 🔗 관련 과정 및 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_container/learning-path.md)

## 📖 현재 위치
**Cloud Container** > **2일차** > **고가용성 아키텍처 및 모니터링**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Container 1일차](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md) | [다음: Cloud Container 메인 →](/mcp_knowledge_base/cloud_container/README.md)

## 🔗 관련 과정
[Cloud Master 3일차](/mcp_knowledge_base/cloud_master/textbook/Day3/README.md) | [Cloud Basic 2일차](/mcp_knowledge_base/cloud_basic/textbook/Day2/README.md)

</div>"""
            
            content += bottom_nav
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            self.fixed_files.append(str(file_path))
            return True
            
        except Exception as e:
            self.errors.append(f"Error fixing {file_path}: {str(e)}")
            return False
    
    def fix_broken_links_in_content(self, content: str) -> str:
        """내용의 깨진 링크 수정"""
        # 깨진 링크 패턴들
        broken_patterns = [
            # README.md 확장자 누락
            (r'(\[([^\]]+)\]\(/mcp_knowledge_base/[^)]+README)\)', r'\1.md'),
            # 일반 .md 확장자 누락
            (r'(\[([^\]]+)\]\(/mcp_knowledge_base/[^)]+)(?<!\.md)\)', r'\1.md'),
            # 잘못된 학습 경로 링크
            (r'\[🔗 학습 경로\]\(/mcp_knowledge_base/learning-path\.md\)', 
             '[🔗 학습 경로](/mcp_knowledge_base/index.md)'),
        ]
        
        for pattern, replacement in broken_patterns:
            content = re.sub(pattern, replacement, content)
        
        return content
    
    def fix_special_documents(self, file_path: Path):
        """특수 문서들 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 깨진 링크 수정
            content = self.fix_broken_links_in_content(content)
            
            # 특수 문서용 네비게이션 생성
            if "integrated_automation" in str(file_path):
                course_name = "통합 자동화"
            elif "work" in str(file_path):
                course_name = "작업 문서"
            else:
                course_name = "프로젝트 개요"
            
            special_nav = f"""<div align="center">

## 🏠 최상위 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/index.md)

## 📖 현재 위치
**{course_name}**

## 🔗 관련 과정
[Cloud Basic 1일차](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md) | [Cloud Master 1일차](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md) | [Cloud Container 1일차](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)

</div>"""
            
            # 기존 네비게이션 제거
            content = re.sub(r'<div align="center">\s*\n.*?</div>', '', content, flags=re.DOTALL)
            
            # 새로운 네비게이션 추가
            if content.startswith('# '):
                content = special_nav + '\n\n' + content
            else:
                content = special_nav + '\n\n' + content
            
            # 하단에도 동일한 네비게이션 추가
            content += f"""

---

{special_nav}"""
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            self.fixed_files.append(str(file_path))
            return True
            
        except Exception as e:
            self.errors.append(f"Error fixing {file_path}: {str(e)}")
            return False
    
    def fix_all_remaining_issues(self):
        """모든 남은 문제 수정"""
        print("🔧 최종 네비게이션 문제 수정 시작...")
        
        # Cloud Container Day2 README.md 수정
        cloud_container_day2 = self.knowledge_base_path / "cloud_container" / "textbook" / "Day2" / "README.md"
        if cloud_container_day2.exists():
            print(f"수정 중: {cloud_container_day2}")
            self.fix_cloud_container_day2_readme(cloud_container_day2)
        
        # 특수 문서들 수정
        special_files = [
            "mcp_knowledge_base/integrated_automation/INSTALLATION_GUIDE.md",
            "mcp_knowledge_base/integrated_automation/README.md", 
            "mcp_knowledge_base/integrated_automation/USAGE_GUIDE.md",
            "mcp_knowledge_base/work/README.md",
            "mcp_knowledge_base/work/링크_Master과정.md"
        ]
        
        for file_path_str in special_files:
            file_path = Path(file_path_str)
            if file_path.exists():
                print(f"수정 중: {file_path}")
                self.fix_special_documents(file_path)
        
        # integrated_automation/results 디렉토리의 모든 파일 수정
        results_dir = self.knowledge_base_path / "integrated_automation" / "results"
        if results_dir.exists():
            for file_path in results_dir.glob("*.md"):
                print(f"수정 중: {file_path}")
                self.fix_special_documents(file_path)
        
        # Cloud Master Day1 파일들의 깨진 링크 수정
        cloud_master_day1_files = [
            "mcp_knowledge_base/cloud_master/textbook/Day1/aws-gcp-permissions-setup.md",
            "mcp_knowledge_base/cloud_master/textbook/Day1/docker-advanced-guide.md",
            "mcp_knowledge_base/cloud_master/textbook/Day1/docker-hub-setup-guide.md"
        ]
        
        for file_path_str in cloud_master_day1_files:
            file_path = Path(file_path_str)
            if file_path.exists():
                print(f"수정 중: {file_path}")
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    content = self.fix_broken_links_in_content(content)
                    
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    
                    self.fixed_files.append(str(file_path))
                except Exception as e:
                    self.errors.append(f"Error fixing {file_path}: {str(e)}")
        
        # Cloud Master Day3 파일들의 깨진 링크 수정
        cloud_master_day3_files = [
            "mcp_knowledge_base/cloud_master/textbook/Day3/disaster-recovery-guide.md",
            "mcp_knowledge_base/cloud_master/textbook/Day3/troubleshooting-guide.md"
        ]
        
        for file_path_str in cloud_master_day3_files:
            file_path = Path(file_path_str)
            if file_path.exists():
                print(f"수정 중: {file_path}")
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    content = self.fix_broken_links_in_content(content)
                    
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    
                    self.fixed_files.append(str(file_path))
                except Exception as e:
                    self.errors.append(f"Error fixing {file_path}: {str(e)}")
        
        print(f"\n📊 최종 수정 결과:")
        print(f"  ✅ 수정됨: {len(self.fixed_files)}개 파일")
        print(f"  ❌ 오류: {len(self.errors)}개 파일")
        
        if self.errors:
            print(f"\n❌ 오류 목록:")
            for error in self.errors:
                print(f"  - {error}")

def main():
    """메인 함수"""
    print("🚀 최종 네비게이션 문제 수정 시작")
    
    fixer = FinalNavigationFixer()
    fixer.fix_all_remaining_issues()
    
    print("\n🎉 최종 수정 완료!")

if __name__ == "__main__":
    main()
