#!/usr/bin/env python3
"""
사용자 친화성 및 초보자 접근성 점검 도구
"""

import os
import re
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Set, Tuple, Any

class UserFriendlinessAuditor:
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.courses = ['cloud_basic', 'cloud_master', 'cloud_container']
        self.audit_results = {}
        
    def run_comprehensive_audit(self):
        """종합적인 사용자 친화성 감사 실행"""
        print("🔍 사용자 친화성 및 초보자 접근성 점검 시작")
        
        # 1. 초보자 접근성 점검
        self.audit_beginner_accessibility()
        
        # 2. 학습 경로 명확성 점검
        self.audit_learning_path_clarity()
        
        # 3. 문서 구조 및 네비게이션 점검
        self.audit_document_structure()
        
        # 4. 실습 가이드 품질 점검
        self.audit_practice_guide_quality()
        
        # 5. 보고서 생성
        self.generate_audit_report()
        
        print("\n🎉 사용자 친화성 점검 완료!")
    
    def audit_beginner_accessibility(self):
        """초보자 접근성 점검"""
        print("\n📚 초보자 접근성 점검 중...")
        
        beginner_issues = []
        
        for course in self.courses:
            course_path = self.knowledge_base_path / course
            if not course_path.exists():
                continue
            
            # 과정 메인 README 점검
            main_readme = course_path / 'README.md'
            if main_readme.exists():
                issues = self.check_beginner_friendly_readme(main_readme, course)
                beginner_issues.extend(issues)
        
        self.audit_results['beginner_accessibility'] = {
            'issues': beginner_issues,
            'total_issues': len(beginner_issues)
        }
        
        print(f"  📊 초보자 접근성 이슈: {len(beginner_issues)}개 발견")
    
    def check_beginner_friendly_readme(self, readme_path: Path, course_day: str) -> List[Dict]:
        """README 파일의 초보자 친화성 점검"""
        issues = []
        
        try:
            with open(readme_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 1. 명확한 학습 목표 확인
            if not re.search(r'학습\s*목표|learning\s*objective', content, re.IGNORECASE):
                issues.append({
                    'type': 'missing_learning_objectives',
                    'file': str(readme_path),
                    'course_day': course_day,
                    'severity': 'high',
                    'description': '학습 목표가 명시되지 않음'
                })
            
            # 2. 사전 요구사항 확인
            if not re.search(r'사전\s*요구사항|prerequisite|선수\s*지식', content, re.IGNORECASE):
                issues.append({
                    'type': 'missing_prerequisites',
                    'file': str(readme_path),
                    'course_day': course_day,
                    'severity': 'medium',
                    'description': '사전 요구사항이 명시되지 않음'
                })
            
            # 3. 예상 소요 시간 확인
            if not re.search(r'소요\s*시간|duration|예상\s*시간', content, re.IGNORECASE):
                issues.append({
                    'type': 'missing_duration',
                    'file': str(readme_path),
                    'course_day': course_day,
                    'severity': 'medium',
                    'description': '예상 소요 시간이 명시되지 않음'
                })
            
            # 4. 단계별 가이드 확인
            step_patterns = [
                r'단계\s*\d+',
                r'step\s*\d+',
                r'\d+\.\s*',
                r'##\s*단계'
            ]
            has_steps = any(re.search(pattern, content, re.IGNORECASE) for pattern in step_patterns)
            if not has_steps:
                issues.append({
                    'type': 'missing_step_by_step',
                    'file': str(readme_path),
                    'course_day': course_day,
                    'severity': 'high',
                    'description': '단계별 가이드가 부족함'
                })
            
            # 5. 친절한 안내 메시지 확인
            friendly_patterns = [
                r'안녕하세요',
                r'환영합니다',
                r'도움이 필요하시면',
                r'궁금한 점이 있으시면',
                r'문제가 발생하면'
            ]
            has_friendly_messages = any(re.search(pattern, content, re.IGNORECASE) for pattern in friendly_patterns)
            if not has_friendly_messages:
                issues.append({
                    'type': 'missing_friendly_messages',
                    'file': str(readme_path),
                    'course_day': course_day,
                    'severity': 'low',
                    'description': '친절한 안내 메시지가 부족함'
                })
            
        except Exception as e:
            issues.append({
                'type': 'file_read_error',
                'file': str(readme_path),
                'course_day': course_day,
                'severity': 'high',
                'description': f'파일 읽기 오류: {str(e)}'
            })
        
        return issues
    
    def audit_learning_path_clarity(self):
        """학습 경로 명확성 점검"""
        print("\n🛤️ 학습 경로 명확성 점검 중...")
        
        path_issues = []
        
        for course in self.courses:
            # 학습 경로 파일 점검
            learning_path = self.knowledge_base_path / course / 'learning-path.md'
            if learning_path.exists():
                issues = self.check_learning_path_clarity(learning_path, course)
                path_issues.extend(issues)
        
        self.audit_results['learning_path_clarity'] = {
            'issues': path_issues,
            'total_issues': len(path_issues)
        }
        
        print(f"  📊 학습 경로 명확성 이슈: {len(path_issues)}개 발견")
    
    def check_learning_path_clarity(self, learning_path: Path, course: str) -> List[Dict]:
        """학습 경로 파일의 명확성 점검"""
        issues = []
        
        try:
            with open(learning_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 1. 전체 과정 개요 확인
            if not re.search(r'전체\s*과정|course\s*overview|과정\s*개요', content, re.IGNORECASE):
                issues.append({
                    'type': 'missing_course_overview',
                    'file': str(learning_path),
                    'course': course,
                    'severity': 'high',
                    'description': '전체 과정 개요가 없음'
                })
            
            # 2. 학습 순서 확인
            if not re.search(r'학습\s*순서|learning\s*order|진행\s*순서', content, re.IGNORECASE):
                issues.append({
                    'type': 'missing_learning_order',
                    'file': str(learning_path),
                    'course': course,
                    'severity': 'high',
                    'description': '학습 순서가 명시되지 않음'
                })
            
            # 3. 난이도 표시 확인
            if not re.search(r'난이도|difficulty|level', content, re.IGNORECASE):
                issues.append({
                    'type': 'missing_difficulty_level',
                    'file': str(learning_path),
                    'course': course,
                    'severity': 'medium',
                    'description': '난이도 표시가 없음'
                })
            
        except Exception as e:
            issues.append({
                'type': 'file_read_error',
                'file': str(learning_path),
                'course': course,
                'severity': 'high',
                'description': f'파일 읽기 오류: {str(e)}'
            })
        
        return issues
    
    def audit_document_structure(self):
        """문서 구조 및 네비게이션 점검"""
        print("\n📄 문서 구조 및 네비게이션 점검 중...")
        
        structure_issues = []
        
        for course in self.courses:
            course_path = self.knowledge_base_path / course
            if not course_path.exists():
                continue
            
            # 과정 메인 README 구조 점검
            main_readme = course_path / 'README.md'
            if main_readme.exists():
                issues = self.check_document_structure(main_readme, f"{course}_main")
                structure_issues.extend(issues)
        
        self.audit_results['document_structure'] = {
            'issues': structure_issues,
            'total_issues': len(structure_issues)
        }
        
        print(f"  📊 문서 구조 이슈: {len(structure_issues)}개 발견")
    
    def check_document_structure(self, readme_path: Path, course_day: str) -> List[Dict]:
        """문서 구조 점검"""
        issues = []
        
        try:
            with open(readme_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 1. 목차 확인
            toc_patterns = [
                r'##\s*목차|##\s*Table\s*of\s*Contents',
                r'<details>.*목차.*</details>',
                r'1\.\s*\[.*\].*2\.\s*\[.*\]'
            ]
            has_toc = any(re.search(pattern, content, re.IGNORECASE | re.DOTALL) for pattern in toc_patterns)
            if not has_toc:
                issues.append({
                    'type': 'missing_table_of_contents',
                    'file': str(readme_path),
                    'course_day': course_day,
                    'severity': 'medium',
                    'description': '목차가 없음'
                })
            
            # 2. 네비게이션 링크 확인
            nav_patterns = [
                r'이전.*다음',
                r'previous.*next',
                r'←.*→'
            ]
            has_navigation = any(re.search(pattern, content, re.IGNORECASE) for pattern in nav_patterns)
            if not has_navigation:
                issues.append({
                    'type': 'missing_navigation',
                    'file': str(readme_path),
                    'course_day': course_day,
                    'severity': 'high',
                    'description': '네비게이션 링크가 없음'
                })
            
        except Exception as e:
            issues.append({
                'type': 'file_read_error',
                'file': str(readme_path),
                'course_day': course_day,
                'severity': 'high',
                'description': f'파일 읽기 오류: {str(e)}'
            })
        
        return issues
    
    def audit_practice_guide_quality(self):
        """실습 가이드 품질 점검"""
        print("\n💻 실습 가이드 품질 점검 중...")
        
        practice_issues = []
        
        for course in self.courses:
            course_path = self.knowledge_base_path / course
            if not course_path.exists():
                continue
            
            # practice 디렉토리 점검
            practice_dirs = [
                course_path / 'textbook' / 'Day1' / 'practice',
                course_path / 'textbook' / 'Day2' / 'practice',
                course_path / 'textbook' / 'Day3' / 'practice'
            ]
            
            for practice_dir in practice_dirs:
                if practice_dir.exists():
                    for practice_file in practice_dir.glob('*.md'):
                        issues = self.check_practice_guide_quality(practice_file, course)
                        practice_issues.extend(issues)
        
        self.audit_results['practice_guide_quality'] = {
            'issues': practice_issues,
            'total_issues': len(practice_issues)
        }
        
        print(f"  📊 실습 가이드 품질 이슈: {len(practice_issues)}개 발견")
    
    def check_practice_guide_quality(self, practice_file: Path, course: str) -> List[Dict]:
        """실습 가이드 품질 점검"""
        issues = []
        
        try:
            with open(practice_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 1. 실습 목표 확인
            if not re.search(r'실습\s*목표|practice\s*objective|목표', content, re.IGNORECASE):
                issues.append({
                    'type': 'missing_practice_objective',
                    'file': str(practice_file),
                    'course': course,
                    'severity': 'high',
                    'description': '실습 목표가 명시되지 않음'
                })
            
            # 2. 단계별 지침 확인
            step_patterns = [
                r'단계\s*\d+',
                r'step\s*\d+',
                r'\d+\.\s*',
                r'###\s*단계'
            ]
            has_steps = any(re.search(pattern, content, re.IGNORECASE) for pattern in step_patterns)
            if not has_steps:
                issues.append({
                    'type': 'missing_step_by_step_instructions',
                    'file': str(practice_file),
                    'course': course,
                    'severity': 'high',
                    'description': '단계별 실습 지침이 부족함'
                })
            
        except Exception as e:
            issues.append({
                'type': 'file_read_error',
                'file': str(practice_file),
                'course': course,
                'severity': 'high',
                'description': f'파일 읽기 오류: {str(e)}'
            })
        
        return issues
    
    def generate_audit_report(self):
        """감사 보고서 생성"""
        report = f"""# 사용자 친화성 및 초보자 접근성 점검 보고서

## 📊 전체 점검 결과

### 점검 항목별 결과
"""
        
        total_issues = 0
        for category, data in self.audit_results.items():
            total_issues += data['total_issues']
            report += f"""
#### {category.replace('_', ' ').title()}
- **발견된 이슈**: {data['total_issues']}개
"""
        
        report += f"""
## 🎯 주요 발견사항

### 1. 초보자 접근성
"""
        
        beginner_issues = self.audit_results.get('beginner_accessibility', {}).get('issues', [])
        if beginner_issues:
            report += f"- **총 {len(beginner_issues)}개 이슈 발견**\n"
            
            # 이슈 유형별 분류
            issue_types = defaultdict(int)
            for issue in beginner_issues:
                issue_types[issue['type']] += 1
            
            for issue_type, count in issue_types.items():
                report += f"  - {issue_type}: {count}개\n"
        else:
            report += "- ✅ 초보자 접근성 양호\n"
        
        report += f"""
## 🔧 개선 권장사항

### 우선순위별 개선사항

#### 🔴 높은 우선순위 (즉시 개선 필요)
"""
        
        # 높은 우선순위 이슈 수집
        high_priority_issues = []
        for category, data in self.audit_results.items():
            for issue in data['issues']:
                if issue['severity'] == 'high':
                    high_priority_issues.append(issue)
        
        if high_priority_issues:
            for issue in high_priority_issues[:5]:  # 상위 5개만 표시
                report += f"- **{issue['type']}**: {issue['description']}\n"
                report += f"  - 파일: {issue['file']}\n"
        else:
            report += "- ✅ 높은 우선순위 이슈 없음\n"
        
        report += f"""
## 🎉 결론

**총 {total_issues}개의 이슈가 발견되었습니다.**

이 점검을 통해 교육 과정의 사용자 친화성과 초보자 접근성을 크게 향상시킬 수 있습니다.
특히 **학습 목표 명시화**와 **단계별 가이드 보완**에 집중하면 초보자들이 더 쉽게 학습할 수 있을 것입니다.
"""
        
        with open("user_friendliness_audit_report.md", "w", encoding="utf-8") as f:
            f.write(report)
        
        print(f"\n📋 사용자 친화성 점검 보고서 생성: user_friendliness_audit_report.md")

def main():
    """메인 함수"""
    auditor = UserFriendlinessAuditor()
    auditor.run_comprehensive_audit()

if __name__ == "__main__":
    main()