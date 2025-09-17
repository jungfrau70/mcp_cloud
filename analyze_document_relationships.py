#!/usr/bin/env python3
"""
과정별, 날짜별 README와 DayX 내 문서간 관계 분석
"""

import os
import re
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Set, Tuple

class DocumentRelationshipAnalyzer:
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.courses = ['cloud_basic', 'cloud_master', 'cloud_container']
        self.relationships = {}
        self.analysis_results = {}
        
    def analyze_course_structure(self):
        """과정별 구조 분석"""
        print("🔍 과정별 구조 분석 중...")
        
        for course in self.courses:
            course_path = self.knowledge_base_path / course
            if not course_path.exists():
                continue
                
            print(f"\n📚 {course.upper()} 과정 분석")
            
            # 과정 메인 README
            main_readme = course_path / 'README.md'
            if main_readme.exists():
                print(f"  📄 메인 README: {main_readme}")
                self.analyze_main_readme(main_readme, course)
            
            # Day별 구조 분석
            textbook_path = course_path / 'textbook'
            if textbook_path.exists():
                self.analyze_day_structure(textbook_path, course)
    
    def analyze_main_readme(self, readme_path: Path, course: str):
        """과정 메인 README 분석"""
        try:
            with open(readme_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 링크 추출
            links = self.extract_links(content)
            
            # Day별 링크 분석
            day_links = {}
            for link in links:
                if 'textbook/Day' in link['url']:
                    day_match = re.search(r'Day(\d+)', link['url'])
                    if day_match:
                        day = int(day_match.group(1))
                        if day not in day_links:
                            day_links[day] = []
                        day_links[day].append(link)
            
            self.analysis_results[f"{course}_main"] = {
                'file': str(readme_path),
                'day_links': day_links,
                'total_links': len(links),
                'day_count': len(day_links)
            }
            
            print(f"    📊 Day별 링크: {len(day_links)}개")
            for day in sorted(day_links.keys()):
                print(f"      - Day{day}: {len(day_links[day])}개 링크")
                
        except Exception as e:
            print(f"    ❌ 오류: {str(e)}")
    
    def analyze_day_structure(self, textbook_path: Path, course: str):
        """Day별 구조 분석"""
        day_dirs = [d for d in textbook_path.iterdir() if d.is_dir() and d.name.startswith('Day')]
        
        for day_dir in sorted(day_dirs):
            day_num = day_dir.name.replace('Day', '')
            print(f"\n  📅 Day{day_num} 분석")
            
            # Day README 분석
            day_readme = day_dir / 'README.md'
            if day_readme.exists():
                self.analyze_day_readme(day_readme, course, day_num)
            
            # Day 내 문서들 분석
            self.analyze_day_documents(day_dir, course, day_num)
    
    def analyze_day_readme(self, readme_path: Path, course: str, day_num: str):
        """Day README 분석"""
        try:
            with open(readme_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 링크 추출
            links = self.extract_links(content)
            
            # 내부 문서 링크 분석
            internal_links = []
            external_links = []
            
            for link in links:
                if link['url'].startswith('/mcp_knowledge_base/'):
                    if f"{course}/textbook/Day{day_num}" in link['url']:
                        internal_links.append(link)
                    else:
                        external_links.append(link)
                elif not (link['url'].startswith('http') or link['url'].startswith('#')):
                    internal_links.append(link)
            
            # 문서 구조 분석
            document_structure = self.analyze_document_structure(content)
            
            self.analysis_results[f"{course}_day{day_num}"] = {
                'file': str(readme_path),
                'internal_links': internal_links,
                'external_links': external_links,
                'document_structure': document_structure,
                'total_links': len(links)
            }
            
            print(f"    📄 Day{day_num} README: {len(links)}개 링크")
            print(f"      - 내부 링크: {len(internal_links)}개")
            print(f"      - 외부 링크: {len(external_links)}개")
            print(f"      - 문서 구조: {len(document_structure)}개 섹션")
            
        except Exception as e:
            print(f"    ❌ 오류: {str(e)}")
    
    def analyze_day_documents(self, day_dir: Path, course: str, day_num: str):
        """Day 내 문서들 분석"""
        md_files = list(day_dir.rglob('*.md'))
        
        documents = []
        for md_file in md_files:
            if md_file.name == 'README.md':
                continue
                
            try:
                with open(md_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # 링크 추출
                links = self.extract_links(content)
                
                # 문서 유형 분석
                doc_type = self.analyze_document_type(md_file, content)
                
                documents.append({
                    'file': str(md_file.relative_to(self.knowledge_base_path)),
                    'name': md_file.name,
                    'type': doc_type,
                    'links': links,
                    'link_count': len(links)
                })
                
            except Exception as e:
                print(f"    ❌ 파일 읽기 오류: {md_file} - {str(e)}")
        
        self.analysis_results[f"{course}_day{day_num}_documents"] = {
            'day_dir': str(day_dir),
            'documents': documents,
            'total_documents': len(documents)
        }
        
        print(f"    📚 Day{day_num} 내 문서: {len(documents)}개")
        for doc in documents:
            print(f"      - {doc['name']} ({doc['type']}): {doc['link_count']}개 링크")
    
    def analyze_document_structure(self, content: str) -> List[Dict]:
        """문서 구조 분석"""
        structure = []
        
        # 헤딩 추출
        heading_pattern = r'^(#{1,6})\s+(.+)$'
        for match in re.finditer(heading_pattern, content, re.MULTILINE):
            level = len(match.group(1))
            text = match.group(2).strip()
            
            structure.append({
                'level': level,
                'text': text,
                'line': content[:match.start()].count('\n') + 1
            })
        
        return structure
    
    def analyze_document_type(self, file_path: Path, content: str) -> str:
        """문서 유형 분석"""
        file_name = file_path.name.lower()
        
        if 'practice' in file_name or '실습' in content:
            return 'practice'
        elif 'guide' in file_name or '가이드' in content:
            return 'guide'
        elif 'troubleshooting' in file_name or '문제해결' in content:
            return 'troubleshooting'
        elif 'setup' in file_name or '설정' in content:
            return 'setup'
        elif 'comparison' in file_name or '비교' in content:
            return 'comparison'
        elif 'deployment' in file_name or '배포' in content:
            return 'deployment'
        else:
            return 'general'
    
    def extract_links(self, content: str) -> List[Dict]:
        """마크다운 링크 추출"""
        links = []
        
        # 마크다운 링크 패턴
        link_pattern = r'\[([^\]]+)\]\(([^)]+)\)'
        
        for match in re.finditer(link_pattern, content):
            link_text = match.group(1)
            link_url = match.group(2)
            
            # 라인 번호
            line_number = content[:match.start()].count('\n') + 1
            
            links.append({
                'text': link_text,
                'url': link_url,
                'line': line_number
            })
        
        return links
    
    def analyze_relationships(self):
        """문서간 관계 분석"""
        print("\n🔗 문서간 관계 분석 중...")
        
        relationships = {
            'course_to_days': {},
            'day_to_documents': {},
            'document_cross_references': {},
            'missing_links': {},
            'circular_references': {}
        }
        
        for course in self.courses:
            course_key = f"{course}_main"
            if course_key in self.analysis_results:
                # 과정 → Day 관계
                day_links = self.analysis_results[course_key]['day_links']
                relationships['course_to_days'][course] = {
                    'expected_days': len(day_links),
                    'actual_days': len([d for d in day_links.keys()]),
                    'day_links': day_links
                }
                
                # Day → 문서 관계
                for day in day_links.keys():
                    day_key = f"{course}_day{day}"
                    if day_key in self.analysis_results:
                        day_docs_key = f"{course}_day{day}_documents"
                        if day_docs_key in self.analysis_results:
                            documents = self.analysis_results[day_docs_key]['documents']
                            relationships['day_to_documents'][f"{course}_day{day}"] = {
                                'document_count': len(documents),
                                'documents': documents
                            }
        
        self.relationships = relationships
        return relationships
    
    def generate_relationship_report(self):
        """관계 분석 보고서 생성"""
        report = f"""# 과정별, 날짜별 README와 DayX 내 문서간 관계 분석 보고서

## 📊 전체 구조 개요

### 과정별 구조
"""
        
        for course in self.courses:
            course_key = f"{course}_main"
            if course_key in self.analysis_results:
                data = self.analysis_results[course_key]
                report += f"""
#### {course.upper()} 과정
- **메인 README**: {data['file']}
- **Day 수**: {data['day_count']}개
- **총 링크 수**: {data['total_links']}개
"""
                
                for day in sorted(data['day_links'].keys()):
                    day_links = data['day_links'][day]
                    report += f"  - **Day{day}**: {len(day_links)}개 링크\n"
        
        report += f"""
## 🔗 문서간 관계 분석

### 1. 과정 → Day 관계
"""
        
        for course, data in self.relationships.get('course_to_days', {}).items():
            report += f"""
#### {course.upper()}
- **예상 Day 수**: {data['expected_days']}개
- **실제 Day 수**: {data['actual_days']}개
- **Day별 링크 분포**:
"""
            for day, links in data['day_links'].items():
                report += f"  - Day{day}: {len(links)}개 링크\n"
        
        report += f"""
### 2. Day → 문서 관계
"""
        
        for day_key, data in self.relationships.get('day_to_documents', {}).items():
            report += f"""
#### {day_key.upper()}
- **문서 수**: {data['document_count']}개
- **문서 목록**:
"""
            for doc in data['documents']:
                report += f"  - {doc['name']} ({doc['type']}): {doc['link_count']}개 링크\n"
        
        report += f"""
## 📈 상세 분석 결과

### 과정별 상세 분석
"""
        
        for course in self.courses:
            report += f"""
#### {course.upper()} 과정 상세 분석
"""
            
            # 메인 README 분석
            course_key = f"{course}_main"
            if course_key in self.analysis_results:
                data = self.analysis_results[course_key]
                report += f"""
**메인 README 분석**:
- 파일: {data['file']}
- 총 링크: {data['total_links']}개
- Day 수: {data['day_count']}개
"""
            
            # Day별 분석
            for day in range(1, 4):  # 최대 3일차
                day_key = f"{course}_day{day}"
                if day_key in self.analysis_results:
                    data = self.analysis_results[day_key]
                    report += f"""
**Day{day} README 분석**:
- 파일: {data['file']}
- 내부 링크: {len(data['internal_links'])}개
- 외부 링크: {len(data['external_links'])}개
- 문서 구조: {len(data['document_structure'])}개 섹션
"""
                
                # Day 내 문서 분석
                docs_key = f"{course}_day{day}_documents"
                if docs_key in self.analysis_results:
                    docs_data = self.analysis_results[docs_key]
                    report += f"""
**Day{day} 내 문서들**:
- 총 문서 수: {docs_data['total_documents']}개
"""
                    for doc in docs_data['documents']:
                        report += f"  - {doc['name']} ({doc['type']}): {doc['link_count']}개 링크\n"
        
        report += f"""
## 🎯 권장사항

### 1. 구조 개선
- 각 Day의 README가 해당 Day 내 모든 문서를 링크해야 함
- 과정 메인 README가 모든 Day를 링크해야 함
- 문서간 상호 참조 링크 추가

### 2. 링크 일관성
- 모든 링크가 절대 경로로 통일되어야 함
- 링크 텍스트가 실제 문서 제목과 일치해야 함
- 깨진 링크 정기적 점검 필요

### 3. 문서 분류
- practice, guide, troubleshooting 등 문서 유형별 명확한 분류
- 각 유형별 표준 템플릿 적용
- 문서간 계층 구조 명확화

## 🎉 결론
문서간 관계가 체계적으로 분석되었으며, 개선 방향이 제시되었습니다.
"""
        
        with open("document_relationship_analysis_report.md", "w", encoding="utf-8") as f:
            f.write(report)
        
        print(f"\n📋 관계 분석 보고서 생성: document_relationship_analysis_report.md")
    
    def run_analysis(self):
        """전체 분석 실행"""
        print("🚀 문서 관계 분석 시작")
        
        # 1. 과정별 구조 분석
        self.analyze_course_structure()
        
        # 2. 관계 분석
        self.analyze_relationships()
        
        # 3. 보고서 생성
        self.generate_relationship_report()
        
        print("\n🎉 문서 관계 분석 완료!")

def main():
    """메인 함수"""
    analyzer = DocumentRelationshipAnalyzer()
    analyzer.run_analysis()

if __name__ == "__main__":
    main()
