#!/usr/bin/env python3
"""
수정된 최종 무결성 검증 도구
올바른 링크 검증 로직 적용
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Set, Tuple, Any
from urllib.parse import quote, unquote
from datetime import datetime

class CorrectedIntegrityChecker:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.knowledge_base_path = self.base_path / "mcp_knowledge_base"
        self.integrity_issues = []
        self.content_stats = {}
        self.file_map = {}  # 파일명 -> 실제 경로 매핑
        
    def build_file_map(self):
        """파일 매핑 테이블 구축"""
        print("🗂️ 파일 매핑 테이블 구축 중...")
        
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                if file.endswith('.md'):
                    file_path = Path(root) / file
                    relative_path = file_path.relative_to(self.knowledge_base_path)
                    
                    # 절대 경로로 매핑
                    abs_path = f"/mcp_knowledge_base/{relative_path.as_posix()}"
                    self.file_map[abs_path] = file_path
                    
                    # 파일명으로도 매핑
                    if file not in self.file_map:
                        self.file_map[file] = []
                    self.file_map[file].append(abs_path)
        
        print(f"📁 {len(self.file_map)}개 파일 매핑 완료")
    
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
    
    def check_link_validity(self, url: str) -> bool:
        """링크 유효성 검사"""
        if not self.is_internal_link(url):
            return True  # 외부 링크는 유효한 것으로 간주
        
        # 경로 정규화
        normalized_url = self.normalize_path(url)
        
        # 파일 매핑에서 확인
        if normalized_url in self.file_map:
            return True
        
        # 상대 경로로도 확인
        if url in self.file_map:
            return True
        
        return False
    
    def top_down_validation(self) -> Dict[str, Any]:
        """Top-down 방식 검증: 학습 경로 → 실제 문서"""
        print("🔍 Top-down 검증 시작...")
        
        top_down_issues = []
        learning_path_files = []
        
        # 학습 경로 파일 찾기
        courses = ["cloud_basic", "cloud_container", "cloud_master"]
        for course in courses:
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
                
                broken_links = 0
                for text, url, line in internal_links:
                    if not self.check_link_validity(url):
                        top_down_issues.append({
                            "type": "broken_link",
                            "source_file": str(learning_path_file.relative_to(self.base_path)),
                            "source_line": line,
                            "broken_link": url,
                            "link_text": text
                        })
                        broken_links += 1
                
                if broken_links > 0:
                    print(f"    ❌ 깨진 링크: {broken_links}개")
                else:
                    print(f"    ✅ 링크 정상")
            
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
        
        # 모든 파일의 내용 무결성 검사
        for file_path in all_files:
            print(f"  📄 검증 중: {file_path.relative_to(self.base_path)}")
            
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # 내부 링크 검증
                links = self.extract_links_from_content(content)
                internal_links = [(text, url, line) for text, url, line in links if self.is_internal_link(url)]
                
                broken_links = 0
                for text, url, line in internal_links:
                    if not self.check_link_validity(url):
                        broken_links += 1
                        bottom_up_issues.append({
                            "type": "broken_internal_link",
                            "file": str(file_path.relative_to(self.base_path)),
                            "line": line,
                            "broken_link": url,
                            "link_text": text
                        })
                
                if broken_links > 0:
                    print(f"    ❌ 깨진 링크: {broken_links}개")
                else:
                    print(f"    ✅ 링크 정상")
                
                # 파일 통계 저장
                self.content_stats[str(file_path.relative_to(self.base_path))] = {
                    "internal_links_count": len(internal_links),
                    "broken_links_count": broken_links,
                    "valid_links_count": len(internal_links) - broken_links
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
            report["recommendations"].append("Top-down 검증에서 깨진 링크들을 수정해야 합니다.")
        
        if bottom_up_result["total_issues"] > 0:
            report["recommendations"].append("Bottom-up 검증에서 발견된 깨진 링크를 수정해야 합니다.")
        
        if report["summary"]["total_issues"] == 0:
            report["recommendations"].append("✅ 모든 학습 시나리오 내용이 무결성을 유지하고 있습니다.")
        
        # JSON 보고서 저장
        with open("corrected_integrity_report.json", "w", encoding="utf-8") as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        return report
    
    def run_comprehensive_check(self):
        """종합 무결성 검사 실행"""
        print("🔍 학습 시나리오 내용 무결성 최종 점검 (수정된 버전)")
        print("=" * 60)
        
        # 파일 매핑 테이블 구축
        self.build_file_map()
        
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
            print("📋 상세 내용은 corrected_integrity_report.json 파일을 확인하세요.")
        
        print(f"\n📊 보고서 생성: corrected_integrity_report.json")
        
        return report

def main():
    """메인 함수"""
    base_path = Path.cwd()
    checker = CorrectedIntegrityChecker(base_path)
    
    # 종합 무결성 검사 실행
    report = checker.run_comprehensive_check()
    
    return report

if __name__ == "__main__":
    main()