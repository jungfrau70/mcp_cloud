#!/usr/bin/env python3
"""
학습 시나리오 내용 무결성 최종 점검 도구
Top-down과 Bottom-up 방식 병행 검증
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Set, Tuple, Any
from urllib.parse import quote, unquote
from datetime import datetime

class ContentIntegrityChecker:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.knowledge_base_path = self.base_path / "mcp_knowledge_base"
        self.courses = ["cloud_basic", "cloud_container", "cloud_master"]
        self.integrity_issues = []
        self.content_stats = {}
        
    def find_markdown_files(self) -> List[Path]:
        """모든 마크다운 파일 찾기"""
        md_files = []
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                if file.endswith('.md'):
                    md_files.append(Path(root) / file)
        return md_files
    
    def extract_links_from_content(self, content: str) -> List[Tuple[str, str, int]]:
        """문서에서 모든 링크 추출"""
        links = []
        lines = content.split('\n')
        
        for i, line in enumerate(lines):
            # 마크다운 링크 패턴
            link_pattern = r'\[([^\]]+)\]\(([^)]+)\)'
            for match in re.finditer(link_pattern, line):
                text = match.group(1)
                url = match.group(2)
                links.append((text, url, i+1))
        
        return links
    
    def is_internal_link(self, url: str) -> bool:
        """내부 링크인지 확인"""
        if url.startswith(('http://', 'https://', 'mailto:', 'tel:')):
            return False
        if url.startswith('#'):
            return False
        return True
    
    def normalize_path(self, path: str) -> str:
        """경로 정규화"""
        # 백슬래시를 슬래시로 변환
        path = path.replace('\\', '/')
        
        # 상대 경로를 절대 경로로 변환
        if not path.startswith('/'):
            path = '/' + path
        
        # mcp_knowledge_base 경로 정리
        if '/mcp_knowledge_base/' in path:
            # 중복된 mcp_knowledge_base 제거
            path = re.sub(r'/mcp_knowledge_base/.*?/mcp_knowledge_base/', '/mcp_knowledge_base/', path)
            # ../mcp_knowledge_base/ 패턴 제거
            path = re.sub(r'\.\./mcp_knowledge_base/', '/mcp_knowledge_base/', path)
        
        return path
    
    def resolve_relative_path(self, from_file: Path, link_path: str) -> Path:
        """상대 경로를 절대 경로로 변환"""
        if link_path.startswith('/'):
            # 절대 경로인 경우
            return self.knowledge_base_path / link_path.lstrip('/')
        else:
            # 상대 경로인 경우
            return from_file.parent / link_path
    
    def check_file_exists(self, file_path: Path) -> bool:
        """파일 존재 여부 확인"""
        return file_path.exists() and file_path.is_file()
    
    def get_file_content_hash(self, file_path: Path) -> str:
        """파일 내용 해시값 계산"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            return str(hash(content))
        except:
            return ""
    
    def extract_learning_scenario_content(self, content: str) -> Dict[str, Any]:
        """학습 시나리오 관련 내용 추출"""
        scenario_info = {
            "learning_objectives": [],
            "practice_guides": [],
            "navigation_links": [],
            "internal_links": [],
            "content_sections": []
        }
        
        lines = content.split('\n')
        current_section = ""
        
        for i, line in enumerate(lines):
            line = line.strip()
            
            # 학습 목표 추출
            if re.match(r'^#+\s*.*학습.*목표.*', line):
                scenario_info["learning_objectives"].append({
                    "line": i+1,
                    "content": line
                })
            
            # 실습 가이드 추출
            if re.match(r'^#+\s*.*실습.*', line):
                scenario_info["practice_guides"].append({
                    "line": i+1,
                    "content": line
                })
            
            # 네비게이션 링크 추출
            if '<div align="center">' in line:
                # 다음 몇 줄에서 네비게이션 링크 찾기
                for j in range(i+1, min(i+10, len(lines))):
                    if '</div>' in lines[j]:
                        break
                    link_pattern = r'\[([^\]]+)\]\(([^)]+)\)'
                    for match in re.finditer(link_pattern, lines[j]):
                        text = match.group(1)
                        url = match.group(2)
                        scenario_info["navigation_links"].append({
                            "line": j+1,
                            "text": text,
                            "url": url
                        })
            
            # 섹션 헤딩 추출
            if re.match(r'^#+\s+', line):
                current_section = line
                scenario_info["content_sections"].append({
                    "line": i+1,
                    "content": line
                })
        
        return scenario_info
    
    def top_down_validation(self) -> Dict[str, Any]:
        """Top-down 방식 검증: 학습 경로 → 실제 문서"""
        print("🔍 Top-down 검증 시작...")
        
        top_down_issues = []
        learning_path_files = []
        
        # 학습 경로 파일 찾기
        for course in self.courses:
            learning_path_file = self.knowledge_base_path / course / "learning-path.md"
            if learning_path_file.exists():
                learning_path_files.append(learning_path_file)
        
        # 전체 인덱스 파일도 확인
        index_file = self.knowledge_base_path / "index.md"
        if index_file.exists():
            learning_path_files.append(index_file)
        
        for learning_path_file in learning_path_files:
            print(f"  📄 검증 중: {learning_path_file.relative_to(self.base_path)}")
            
            try:
                with open(learning_path_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # 학습 경로에서 참조하는 모든 링크 추출
                links = self.extract_links_from_content(content)
                internal_links = [(text, url, line) for text, url, line in links if self.is_internal_link(url)]
                
                for text, url, line in internal_links:
                    normalized_url = self.normalize_path(url)
                    target_file = self.resolve_relative_path(learning_path_file, normalized_url)
                    
                    if not self.check_file_exists(target_file):
                        top_down_issues.append({
                            "type": "missing_file",
                            "source_file": str(learning_path_file.relative_to(self.base_path)),
                            "source_line": line,
                            "missing_file": str(target_file.relative_to(self.base_path)),
                            "link_text": text,
                            "link_url": url
                        })
                        print(f"    ❌ 누락된 파일: {target_file.relative_to(self.base_path)}")
                    else:
                        print(f"    ✅ 파일 존재: {target_file.relative_to(self.base_path)}")
            
            except Exception as e:
                top_down_issues.append({
                    "type": "file_read_error",
                    "source_file": str(learning_path_file.relative_to(self.base_path)),
                    "error": str(e)
                })
                print(f"    ❌ 파일 읽기 오류: {e}")
        
        return {
            "issues": top_down_issues,
            "total_issues": len(top_down_issues)
        }
    
    def bottom_up_validation(self) -> Dict[str, Any]:
        """Bottom-up 방식 검증: 실제 문서 → 학습 경로"""
        print("\n🔍 Bottom-up 검증 시작...")
        
        bottom_up_issues = []
        all_files = self.find_markdown_files()
        
        # 학습 경로 파일들
        learning_path_files = set()
        for course in self.courses:
            learning_path_file = self.knowledge_base_path / course / "learning-path.md"
            if learning_path_file.exists():
                learning_path_files.add(learning_path_file)
        
        index_file = self.knowledge_base_path / "index.md"
        if index_file.exists():
            learning_path_files.add(index_file)
        
        # 모든 파일의 내용 무결성 검사
        for file_path in all_files:
            print(f"  📄 검증 중: {file_path.relative_to(self.base_path)}")
            
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # 파일 내용 해시 계산
                content_hash = self.get_file_content_hash(file_path)
                
                # 학습 시나리오 내용 추출
                scenario_content = self.extract_learning_scenario_content(content)
                
                # 내용 손실 검사
                if len(scenario_content["learning_objectives"]) == 0 and "README" in file_path.name:
                    bottom_up_issues.append({
                        "type": "missing_learning_objectives",
                        "file": str(file_path.relative_to(self.base_path)),
                        "issue": "학습 목표가 없습니다"
                    })
                    print(f"    ⚠️ 학습 목표 누락")
                
                if len(scenario_content["practice_guides"]) == 0 and "practice" in str(file_path):
                    bottom_up_issues.append({
                        "type": "missing_practice_guides",
                        "file": str(file_path.relative_to(self.base_path)),
                        "issue": "실습 가이드가 없습니다"
                    })
                    print(f"    ⚠️ 실습 가이드 누락")
                
                # 내부 링크 검증
                links = self.extract_links_from_content(content)
                internal_links = [(text, url, line) for text, url, line in links if self.is_internal_link(url)]
                
                broken_links = 0
                for text, url, line in internal_links:
                    normalized_url = self.normalize_path(url)
                    target_file = self.resolve_relative_path(file_path, normalized_url)
                    
                    if not self.check_file_exists(target_file):
                        broken_links += 1
                        bottom_up_issues.append({
                            "type": "broken_internal_link",
                            "file": str(file_path.relative_to(self.base_path)),
                            "line": line,
                            "broken_link": url,
                            "target_file": str(target_file.relative_to(self.base_path))
                        })
                
                if broken_links > 0:
                    print(f"    ❌ 깨진 링크: {broken_links}개")
                else:
                    print(f"    ✅ 링크 정상")
                
                # 파일 통계 저장
                self.content_stats[str(file_path.relative_to(self.base_path))] = {
                    "content_hash": content_hash,
                    "learning_objectives_count": len(scenario_content["learning_objectives"]),
                    "practice_guides_count": len(scenario_content["practice_guides"]),
                    "navigation_links_count": len(scenario_content["navigation_links"]),
                    "internal_links_count": len(internal_links),
                    "broken_links_count": broken_links,
                    "content_sections_count": len(scenario_content["content_sections"])
                }
            
            except Exception as e:
                bottom_up_issues.append({
                    "type": "file_processing_error",
                    "file": str(file_path.relative_to(self.base_path)),
                    "error": str(e)
                })
                print(f"    ❌ 파일 처리 오류: {e}")
        
        return {
            "issues": bottom_up_issues,
            "total_issues": len(bottom_up_issues),
            "content_stats": self.content_stats
        }
    
    def generate_integrity_report(self, top_down_result: Dict, bottom_up_result: Dict):
        """무결성 검사 보고서 생성"""
        report = {
            "timestamp": datetime.now().isoformat(),
            "summary": {
                "total_files_checked": len(self.find_markdown_files()),
                "top_down_issues": top_down_result["total_issues"],
                "bottom_up_issues": bottom_up_result["total_issues"],
                "total_issues": top_down_result["total_issues"] + bottom_up_result["total_issues"]
            },
            "top_down_validation": top_down_result,
            "bottom_up_validation": bottom_up_result,
            "recommendations": []
        }
        
        # 권장사항 생성
        if top_down_result["total_issues"] > 0:
            report["recommendations"].append("Top-down 검증에서 누락된 파일들을 복구하거나 링크를 수정해야 합니다.")
        
        if bottom_up_result["total_issues"] > 0:
            report["recommendations"].append("Bottom-up 검증에서 발견된 내용 손실을 복구해야 합니다.")
        
        if report["summary"]["total_issues"] == 0:
            report["recommendations"].append("✅ 모든 학습 시나리오 내용이 무결성을 유지하고 있습니다.")
        
        # JSON 보고서 저장
        with open("content_integrity_report.json", "w", encoding="utf-8") as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        return report
    
    def run_comprehensive_check(self):
        """종합 무결성 검사 실행"""
        print("🔍 학습 시나리오 내용 무결성 최종 점검")
        print("=" * 60)
        
        # Top-down 검증
        top_down_result = self.top_down_validation()
        
        # Bottom-up 검증
        bottom_up_result = self.bottom_up_validation()
        
        # 보고서 생성
        report = self.generate_integrity_report(top_down_result, bottom_up_result)
        
        # 결과 출력
        print("\n" + "=" * 60)
        print("📊 최종 검사 결과")
        print("=" * 60)
        print(f"📁 총 검사 파일 수: {report['summary']['total_files_checked']}")
        print(f"🔍 Top-down 이슈: {report['summary']['top_down_issues']}개")
        print(f"🔍 Bottom-up 이슈: {report['summary']['bottom_up_issues']}개")
        print(f"⚠️ 총 이슈 수: {report['summary']['total_issues']}개")
        
        if report['summary']['total_issues'] == 0:
            print("\n🎉 모든 학습 시나리오 내용이 무결성을 유지하고 있습니다!")
        else:
            print(f"\n⚠️ {report['summary']['total_issues']}개의 이슈가 발견되었습니다.")
            print("📋 상세 내용은 content_integrity_report.json 파일을 확인하세요.")
        
        print(f"\n📊 보고서 생성: content_integrity_report.json")
        
        return report

def main():
    """메인 함수"""
    base_path = Path.cwd()
    checker = ContentIntegrityChecker(base_path)
    
    # 종합 무결성 검사 실행
    report = checker.run_comprehensive_check()
    
    return report

if __name__ == "__main__":
    main()