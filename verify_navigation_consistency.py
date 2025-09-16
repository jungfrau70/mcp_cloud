#!/usr/bin/env python3
"""
모든 문서의 네비게이션 구조 일관성 검증 스크립트
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Tuple, Set
from collections import defaultdict

class NavigationConsistencyChecker:
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.issues = []
        self.stats = {
            "total_files": 0,
            "valid_navigation": 0,
            "missing_top_nav": 0,
            "missing_bottom_nav": 0,
            "inconsistent_structure": 0,
            "broken_links": 0,
            "missing_course_info": 0
        }
        
        # 표준 네비게이션 패턴
        self.standard_patterns = {
            "top_nav": {
                "home_link": r'\[🏠 홈\]\(/mcp_knowledge_base/index\.md\)',
                "curriculum_link": r'\[📚 전체 커리큘럼\]\(/mcp_knowledge_base/curriculum\.md\)',
                "learning_path_link": r'\[🔗 학습 경로\]\(/mcp_knowledge_base/[^/]+/learning-path\.md\)'
            },
            "current_position": {
                "course_name": r'\*\*[^*]+\*\*',
                "day_info": r'\*\*\d+일차\*\*',
                "title": r'\*\*[^*]+\*\*'
            },
            "prev_next_nav": {
                "prev_link": r'\[← 이전: [^]]+\]\([^)]+\)',
                "next_link": r'\[다음: [^]]+ →\]\([^)]+\)'
            }
        }
    
    def find_all_markdown_files(self) -> List[Path]:
        """모든 마크다운 파일 찾기"""
        markdown_files = []
        
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                if file.endswith('.md') and file != 'navigation_templates.md':
                    markdown_files.append(Path(root) / file)
        
        return markdown_files
    
    def check_top_navigation(self, content: str, file_path: Path) -> List[str]:
        """상단 네비게이션 검증"""
        issues = []
        
        # 최상위 네비게이션 섹션 확인
        if "## 🏠 최상위 네비게이션" not in content:
            issues.append("상단 네비게이션 섹션 누락")
            self.stats["missing_top_nav"] += 1
            return issues
        
        # 홈 링크 확인
        if not re.search(self.standard_patterns["top_nav"]["home_link"], content):
            issues.append("홈 링크 누락 또는 형식 오류")
        
        # 커리큘럼 링크 확인
        if not re.search(self.standard_patterns["top_nav"]["curriculum_link"], content):
            issues.append("커리큘럼 링크 누락 또는 형식 오류")
        
        # 학습 경로 링크 확인
        if not re.search(self.standard_patterns["top_nav"]["learning_path_link"], content):
            issues.append("학습 경로 링크 누락 또는 형식 오류")
        
        # 현재 위치 섹션 확인
        if "## 📖 현재 위치" not in content:
            issues.append("현재 위치 섹션 누락")
        
        # 이전/다음 네비게이션 섹션 확인
        if "## ⬅️ 이전/다음 네비게이션" not in content:
            issues.append("이전/다음 네비게이션 섹션 누락")
        
        return issues
    
    def check_bottom_navigation(self, content: str, file_path: Path) -> List[str]:
        """하단 네비게이션 검증"""
        issues = []
        
        # 하단 네비게이션 섹션 확인
        if "## 🔗 관련 과정 및 네비게이션" not in content:
            issues.append("하단 네비게이션 섹션 누락")
            self.stats["missing_bottom_nav"] += 1
            return issues
        
        # 상단과 동일한 구조 확인
        if "## 🏠 최상위 네비게이션" not in content:
            issues.append("하단에 최상위 네비게이션 누락")
        
        if "## 📖 현재 위치" not in content:
            issues.append("하단에 현재 위치 섹션 누락")
        
        if "## ⬅️ 이전/다음 네비게이션" not in content:
            issues.append("하단에 이전/다음 네비게이션 섹션 누락")
        
        # 관련 과정 섹션 확인
        if "## 🔗 관련 과정" not in content:
            issues.append("관련 과정 섹션 누락")
        
        return issues
    
    def check_link_consistency(self, content: str, file_path: Path) -> List[str]:
        """링크 일관성 검증"""
        issues = []
        
        # 상단과 하단의 링크가 일치하는지 확인
        top_nav_section = re.search(r'## 🏠 최상위 네비게이션.*?## 📖 현재 위치', content, re.DOTALL)
        bottom_nav_section = re.search(r'## 🔗 관련 과정 및 네비게이션.*?## 📖 현재 위치', content, re.DOTALL)
        
        if top_nav_section and bottom_nav_section:
            top_links = re.findall(r'\[([^\]]+)\]\(([^)]+)\)', top_nav_section.group())
            bottom_links = re.findall(r'\[([^\]]+)\]\(([^)]+)\)', bottom_nav_section.group())
            
            # 상단과 하단의 링크가 일치하는지 확인
            if top_links != bottom_links:
                issues.append("상단과 하단 네비게이션 링크 불일치")
        
        return issues
    
    def check_course_info_consistency(self, content: str, file_path: Path) -> List[str]:
        """교육 과정 정보 일관성 검증"""
        issues = []
        
        # 파일 경로에서 교육 과정 추출
        course_name = None
        if "cloud_basic" in str(file_path):
            course_name = "Cloud Basic"
        elif "cloud_master" in str(file_path):
            course_name = "Cloud Master"
        elif "cloud_container" in str(file_path):
            course_name = "Cloud Container"
        
        if not course_name:
            self.stats["missing_course_info"] += 1
            return issues
        
        # 현재 위치에서 교육 과정명 확인
        current_position_match = re.search(r'## 📖 현재 위치\s*\n\*\*([^*]+)\*\*', content)
        if current_position_match:
            doc_course_name = current_position_match.group(1)
            if doc_course_name != course_name:
                issues.append(f"교육 과정명 불일치: 예상 '{course_name}', 실제 '{doc_course_name}'")
        
        return issues
    
    def check_broken_links(self, content: str, file_path: Path) -> List[str]:
        """깨진 링크 검증"""
        issues = []
        
        # 마크다운 링크 패턴 찾기
        links = re.findall(r'\[([^\]]+)\]\(([^)]+)\)', content)
        
        for link_text, link_url in links:
            # 상대 경로 링크 확인
            if link_url.startswith('/mcp_knowledge_base/'):
                # 절대 경로 링크는 파일 존재 여부 확인
                relative_path = link_url.replace('/mcp_knowledge_base/', '')
                target_file = self.knowledge_base_path / relative_path
                
                if not target_file.exists():
                    issues.append(f"깨진 링크: {link_text} -> {link_url}")
                    self.stats["broken_links"] += 1
        
        return issues
    
    def verify_document(self, file_path: Path) -> Dict[str, any]:
        """개별 문서 검증"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            issues = []
            
            # 상단 네비게이션 검증
            issues.extend(self.check_top_navigation(content, file_path))
            
            # 하단 네비게이션 검증
            issues.extend(self.check_bottom_navigation(content, file_path))
            
            # 링크 일관성 검증
            issues.extend(self.check_link_consistency(content, file_path))
            
            # 교육 과정 정보 일관성 검증
            issues.extend(self.check_course_info_consistency(content, file_path))
            
            # 깨진 링크 검증
            issues.extend(self.check_broken_links(content, file_path))
            
            return {
                "file_path": str(file_path),
                "issues": issues,
                "is_valid": len(issues) == 0
            }
            
        except Exception as e:
            return {
                "file_path": str(file_path),
                "issues": [f"파일 읽기 오류: {str(e)}"],
                "is_valid": False
            }
    
    def verify_all_documents(self):
        """모든 문서 검증"""
        print("🔍 마크다운 파일 검색 중...")
        markdown_files = self.find_all_markdown_files()
        print(f"📄 총 {len(markdown_files)}개 파일 발견")
        
        print("\n🔄 문서 검증 시작...")
        results = []
        
        for i, file_path in enumerate(markdown_files, 1):
            print(f"[{i}/{len(markdown_files)}] {file_path}")
            
            result = self.verify_document(file_path)
            results.append(result)
            
            if result["is_valid"]:
                print(f"  ✅ 검증 통과")
                self.stats["valid_navigation"] += 1
            else:
                print(f"  ❌ 검증 실패: {len(result['issues'])}개 문제")
                for issue in result["issues"]:
                    print(f"    - {issue}")
                    self.issues.append(f"{file_path}: {issue}")
        
        self.stats["total_files"] = len(markdown_files)
        self.stats["inconsistent_structure"] = len([r for r in results if not r["is_valid"]])
        
        return results
    
    def generate_verification_report(self, results: List[Dict[str, any]]):
        """검증 보고서 생성"""
        report = f"""# 네비게이션 구조 일관성 검증 보고서

## 📊 검증 통계
- **총 파일 수**: {self.stats['total_files']}개
- **검증 통과**: {self.stats['valid_navigation']}개
- **검증 실패**: {self.stats['inconsistent_structure']}개
- **상단 네비게이션 누락**: {self.stats['missing_top_nav']}개
- **하단 네비게이션 누락**: {self.stats['missing_bottom_nav']}개
- **깨진 링크**: {self.stats['broken_links']}개
- **교육 과정 정보 누락**: {self.stats['missing_course_info']}개

## ✅ 검증 통과 파일 목록
"""
        
        valid_files = [r for r in results if r["is_valid"]]
        for result in valid_files:
            report += f"- {result['file_path']}\n"
        
        if self.issues:
            report += f"\n## ❌ 검증 실패 파일 목록\n"
            for issue in self.issues:
                report += f"- {issue}\n"
        
        report += f"""
## 🎯 검증 기준

### 상단 네비게이션 (3단계 계층)
1. **최상위 네비게이션**: 홈, 전체 커리큘럼, 학습 경로
2. **현재 위치**: 교육 과정 > 일차 > 주제
3. **이전/다음 네비게이션**: 이전/다음 문서 링크

### 하단 네비게이션 (상단 + 관련 과정)
1. **상단과 동일한 구조**
2. **관련 과정 링크 추가**

### 일관성 검증
1. **상단/하단 링크 일치**
2. **교육 과정명 일관성**
3. **링크 정상 작동**

## 🔧 개선 권장사항

"""
        
        if self.stats["missing_top_nav"] > 0:
            report += f"- 상단 네비게이션이 누락된 {self.stats['missing_top_nav']}개 파일 수정 필요\n"
        
        if self.stats["missing_bottom_nav"] > 0:
            report += f"- 하단 네비게이션이 누락된 {self.stats['missing_bottom_nav']}개 파일 수정 필요\n"
        
        if self.stats["broken_links"] > 0:
            report += f"- 깨진 링크 {self.stats['broken_links']}개 수정 필요\n"
        
        if self.stats["missing_course_info"] > 0:
            report += f"- 교육 과정 정보가 누락된 {self.stats['missing_course_info']}개 파일 수정 필요\n"
        
        report += f"""
## 📈 품질 지표
- **일관성 점수**: {(self.stats['valid_navigation'] / self.stats['total_files'] * 100):.1f}%
- **완성도 점수**: {((self.stats['total_files'] - self.stats['missing_top_nav'] - self.stats['missing_bottom_nav']) / self.stats['total_files'] * 100):.1f}%
- **링크 정상성**: {((self.stats['total_files'] - self.stats['broken_links']) / self.stats['total_files'] * 100):.1f}%

## 🎉 결론
"""
        
        if self.stats["inconsistent_structure"] == 0:
            report += "모든 문서가 일관된 네비게이션 구조를 가지고 있습니다! 🎉"
        else:
            report += f"{self.stats['inconsistent_structure']}개 파일의 네비게이션 구조를 개선해야 합니다."
        
        with open("navigation_verification_report.md", "w", encoding="utf-8") as f:
            f.write(report)
        
        print(f"\n📋 검증 보고서 생성: navigation_verification_report.md")

def main():
    """메인 함수"""
    print("🚀 네비게이션 구조 일관성 검증 시작")
    
    checker = NavigationConsistencyChecker()
    results = checker.verify_all_documents()
    checker.generate_verification_report(results)
    
    print(f"\n📊 검증 결과:")
    print(f"  ✅ 통과: {checker.stats['valid_navigation']}개 파일")
    print(f"  ❌ 실패: {checker.stats['inconsistent_structure']}개 파일")
    print(f"  🔗 깨진 링크: {checker.stats['broken_links']}개")
    
    if checker.stats["inconsistent_structure"] == 0:
        print("\n🎉 모든 문서가 일관된 네비게이션 구조를 가지고 있습니다!")
    else:
        print(f"\n⚠️ {checker.stats['inconsistent_structure']}개 파일의 개선이 필요합니다.")
    
    print("\n🎯 검증 완료!")

if __name__ == "__main__":
    main()
