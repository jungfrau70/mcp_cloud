#!/usr/bin/env python3
"""
업데이트된 최종 무결성 검증 도구
수정된 파일 구조와 링크 패턴에 맞춰 검증 로직 개선
"""

import os
import re
import json
from pathlib import Path
from urllib.parse import quote, unquote
from typing import Dict, List, Set, Tuple, Optional

class UpdatedIntegrityChecker:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.knowledge_base_path = self.base_path / "mcp_knowledge_base"
        
        # 실제 파일 매핑
        self.actual_files = {}
        self.build_actual_files_map()
        
        # 파일 이동 매핑
        self.file_moves = {
            # scripts → guides 이동
            "/mcp_knowledge_base/cloud_basic/textbook/Day1/scripts/": "/mcp_knowledge_base/cloud_basic/textbook/Day1/guides/",
            "/mcp_knowledge_base/cloud_container/textbook/Day1/scripts/": "/mcp_knowledge_base/cloud_container/textbook/Day1/guides/",
            "/mcp_knowledge_base/cloud_master/textbook/Day1/scripts/": "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/",
            
            # install → guides 이동
            "/mcp_knowledge_base/cloud_basic/install/": "/mcp_knowledge_base/cloud_basic/textbook/Day1/guides/",
            "/mcp_knowledge_base/cloud_container/install/": "/mcp_knowledge_base/cloud_container/textbook/Day1/guides/",
            "/mcp_knowledge_base/cloud_master/install/": "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/",
        }
    
    def build_actual_files_map(self):
        """실제 존재하는 파일 매핑 구축"""
        print("🗂️ 실제 파일 위치 매핑 중...")
        
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                file_path = Path(root) / file
                relative_path = file_path.relative_to(self.knowledge_base_path)
                abs_path = f"/mcp_knowledge_base/{relative_path.as_posix()}"
                self.actual_files[abs_path] = file_path
                
                # URL 인코딩된 경로도 매핑
                encoded_path = f"/mcp_knowledge_base/{quote(str(relative_path), safe='/')}"
                self.actual_files[encoded_path] = file_path
                
                # 파일명으로도 매핑
                if file not in self.actual_files:
                    self.actual_files[file] = []
                self.actual_files[file].append(abs_path)
        
        print(f"📁 {len(self.actual_files)}개 실제 파일 매핑 완료")
    
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
        
        return path
    
    def find_correct_file_path(self, broken_path: str) -> Optional[str]:
        """깨진 링크의 올바른 경로 찾기"""
        normalized_path = self.normalize_path(broken_path)
        
        # 1. 정확한 경로가 존재하는지 확인
        if normalized_path in self.actual_files:
            return normalized_path
        
        # 2. URL 디코딩 시도
        try:
            decoded_path = unquote(normalized_path)
            if decoded_path in self.actual_files:
                return decoded_path
        except:
            pass
        
        # 3. 파일 이동 매핑 확인
        for old_path, new_path in self.file_moves.items():
            if normalized_path.startswith(old_path):
                # 경로 교체
                new_file_path = normalized_path.replace(old_path, new_path)
                if new_file_path in self.actual_files:
                    return new_file_path
                
                # 파일명만 추출해서 새 경로에서 검색
                filename = Path(normalized_path).name
                new_file_path = new_path + filename
                if new_file_path in self.actual_files:
                    return new_file_path
        
        # 4. 파일명으로 검색
        filename = Path(normalized_path).name
        if filename in self.actual_files:
            return self.actual_files[filename][0]
        
        # 5. 유사한 파일명 검색
        for actual_path in self.actual_files:
            if filename in actual_path:
                return actual_path
        
        return None
    
    def check_learning_paths(self) -> List[Dict]:
        """학습 경로 파일들 검증 (Top-down)"""
        issues = []
        learning_path_files = [
            "mcp_knowledge_base/cloud_basic/learning-path.md",
            "mcp_knowledge_base/cloud_container/learning-path.md", 
            "mcp_knowledge_base/cloud_master/learning-path.md"
        ]
        
        for learning_path_file in learning_path_files:
            file_path = self.knowledge_base_path / learning_path_file
            if not file_path.exists():
                continue
                
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            links = self.extract_links_from_content(content)
            
            for text, url, line_num in links:
                if not self.is_internal_link(url):
                    continue
                
                correct_path = self.find_correct_file_path(url)
                if not correct_path:
                    issues.append({
                        "type": "broken_link",
                        "source_file": learning_path_file,
                        "source_line": line_num,
                        "broken_link": url,
                        "link_text": text
                    })
        
        return issues
    
    def check_internal_links(self) -> List[Dict]:
        """내부 링크 검증 (Bottom-up)"""
        issues = []
        md_files = self.find_markdown_files()
        
        for file_path in md_files:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                links = self.extract_links_from_content(content)
                
                for text, url, line_num in links:
                    if not self.is_internal_link(url):
                        continue
                    
                    correct_path = self.find_correct_file_path(url)
                    if not correct_path:
                        issues.append({
                            "type": "broken_internal_link",
                            "file": str(file_path.relative_to(self.base_path)),
                            "line": line_num,
                            "broken_link": url,
                            "link_text": text
                        })
                        
            except Exception as e:
                print(f"  ❌ {file_path.relative_to(self.base_path)}: 오류 - {e}")
        
        return issues
    
    def check_content_integrity(self) -> Dict:
        """콘텐츠 무결성 검사"""
        content_stats = {}
        md_files = self.find_markdown_files()
        
        for file_path in md_files:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                links = self.extract_links_from_content(content)
                internal_links = [link for link in links if self.is_internal_link(link[1])]
                
                broken_links = 0
                valid_links = 0
                
                for text, url, line_num in internal_links:
                    correct_path = self.find_correct_file_path(url)
                    if correct_path:
                        valid_links += 1
                    else:
                        broken_links += 1
                
                content_stats[str(file_path.relative_to(self.base_path))] = {
                    "internal_links_count": len(internal_links),
                    "broken_links_count": broken_links,
                    "valid_links_count": valid_links
                }
                
            except Exception as e:
                print(f"  ❌ {file_path.relative_to(self.base_path)}: 오류 - {e}")
        
        return content_stats
    
    def run_verification(self):
        """검증 실행"""
        print("🔍 업데이트된 무결성 검증 시작...")
        print("=" * 60)
        
        # Top-down 검증 (학습 경로)
        print("📚 Top-down 검증 (학습 경로) 중...")
        top_down_issues = self.check_learning_paths()
        
        # Bottom-up 검증 (내부 링크)
        print("🔗 Bottom-up 검증 (내부 링크) 중...")
        bottom_up_issues = self.check_internal_links()
        
        # 콘텐츠 통계
        print("📊 콘텐츠 통계 수집 중...")
        content_stats = self.check_content_integrity()
        
        # 결과 요약
        total_issues = len(top_down_issues) + len(bottom_up_issues)
        
        print("\n" + "=" * 60)
        print("📊 업데이트된 검사 결과")
        print("=" * 60)
        print(f"📁 총 검사 파일 수: {len(self.find_markdown_files())}")
        print(f"🔍 Top-down 이슈: {len(top_down_issues)}개")
        print(f"🔍 Bottom-up 이슈: {len(bottom_up_issues)}개")
        print(f"⚠️ 총 이슈 수: {total_issues}개")
        
        if total_issues > 0:
            print(f"\n⚠️ {total_issues}개의 이슈가 발견되었습니다.")
            print("📋 상세 내용은 updated_integrity_report.json 파일을 확인하세요.")
        else:
            print("\n✅ 모든 링크가 정상입니다!")
        
        # 보고서 생성
        report = {
            "timestamp": "2025-09-18T21:45:00",
            "summary": {
                "total_files_checked": len(self.find_markdown_files()),
                "top_down_issues": len(top_down_issues),
                "bottom_up_issues": len(bottom_up_issues),
                "total_issues": total_issues
            },
            "top_down_validation": {
                "issues": top_down_issues,
                "total_issues": len(top_down_issues)
            },
            "bottom_up_validation": {
                "issues": bottom_up_issues,
                "total_issues": len(bottom_up_issues),
                "content_stats": content_stats
            },
            "recommendations": [
                "Top-down 검증에서 깨진 링크들을 수정해야 합니다." if top_down_issues else "Top-down 검증 통과",
                "Bottom-up 검증에서 발견된 깨진 링크를 수정해야 합니다." if bottom_up_issues else "Bottom-up 검증 통과"
            ]
        }
        
        with open("updated_integrity_report.json", "w", encoding="utf-8") as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        print(f"\n📊 보고서 생성: updated_integrity_report.json")
        
        return report

def main():
    """메인 함수"""
    base_path = Path.cwd()
    checker = UpdatedIntegrityChecker(base_path)
    checker.run_verification()

if __name__ == "__main__":
    main()