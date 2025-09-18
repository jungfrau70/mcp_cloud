#!/usr/bin/env python3
"""
파일 이동으로 인한 링크 수정 도구
실제 파일 위치에 맞춰 링크 업데이트
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Tuple

class MovedFilesLinkFixer:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.knowledge_base_path = self.base_path / "mcp_knowledge_base"
        self.fixed_files = 0
        self.fixed_links = 0
        
        # 파일 이동 매핑 (이전 경로 -> 새 경로)
        self.file_moves = {
            # Cloud Master 과정 파일 이동
            "/mcp_knowledge_base/cloud_master/textbook/Day1/scripts/": "/mcp_knowledge_base/cloud_master/repos/cloud-scripts/",
            "/mcp_knowledge_base/cloud_master/textbook/Day1/automation/": "/mcp_knowledge_base/cloud_master/repos/automation/",
            "/mcp_knowledge_base/cloud_master/textbook/Day1/samples/": "/mcp_knowledge_base/cloud_master/repos/samples/",
            
            # Cloud Basic 과정 파일 이동
            "/mcp_knowledge_base/cloud_basic/textbook/Day1/scripts/": "/mcp_knowledge_base/cloud_basic/automation/",
            "/mcp_knowledge_base/cloud_basic/textbook/Day1/automation/": "/mcp_knowledge_base/cloud_basic/automation/",
            
            # Cloud Container 과정 파일 이동
            "/mcp_knowledge_base/cloud_container/textbook/Day1/scripts/": "/mcp_knowledge_base/cloud_container/automation/",
            "/mcp_knowledge_base/cloud_container/textbook/Day1/automation/": "/mcp_knowledge_base/cloud_container/automation/",
        }
        
        # 실제 파일 존재 확인을 위한 매핑
        self.actual_files = {}
        self.build_actual_files_map()
    
    def build_actual_files_map(self):
        """실제 존재하는 파일 매핑 구축"""
        print("🗂️ 실제 파일 위치 매핑 중...")
        
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                file_path = Path(root) / file
                relative_path = file_path.relative_to(self.knowledge_base_path)
                abs_path = f"/mcp_knowledge_base/{relative_path.as_posix()}"
                self.actual_files[abs_path] = file_path
                
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
    
    def find_correct_file_path(self, broken_path: str) -> str:
        """깨진 경로의 올바른 파일 경로 찾기"""
        normalized_path = self.normalize_path(broken_path)
        
        # 1. 정확한 경로가 존재하는지 확인
        if normalized_path in self.actual_files:
            return normalized_path
        
        # 2. 파일 이동 매핑 확인
        for old_path, new_path in self.file_moves.items():
            if normalized_path.startswith(old_path):
                # 경로 교체
                new_file_path = normalized_path.replace(old_path, new_path)
                if new_file_path in self.actual_files:
                    return new_file_path
        
        # 3. 파일명으로 검색
        filename = Path(normalized_path).name
        if filename in self.actual_files:
            return self.actual_files[filename][0]
        
        # 4. 유사한 파일명 검색
        for actual_path in self.actual_files:
            if filename in actual_path:
                return actual_path
        
        return None
    
    def fix_links_in_content(self, content: str) -> Tuple[str, int]:
        """콘텐츠의 링크 수정"""
        original_content = content
        fixes_count = 0
        
        # 모든 링크 추출
        links = self.extract_links_from_content(content)
        
        for text, url, line_num in links:
            if not self.is_internal_link(url):
                continue
            
            # 올바른 파일 경로 찾기
            correct_path = self.find_correct_file_path(url)
            if correct_path and correct_path != url:
                # 링크 수정
                old_link = f"[{text}]({url})"
                new_link = f"[{text}]({correct_path})"
                content = content.replace(old_link, new_link)
                fixes_count += 1
                print(f"    🔧 링크 수정: {url} → {correct_path}")
        
        return content, fixes_count
    
    def fix_file(self, file_path: Path) -> bool:
        """파일 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            content, fixes_count = self.fix_links_in_content(content)
            
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                self.fixed_files += 1
                self.fixed_links += fixes_count
                print(f"  ✅ {file_path.relative_to(self.base_path)}: {fixes_count}개 링크 수정")
                return True
            else:
                print(f"  ⏭️ {file_path.relative_to(self.base_path)}: 수정할 링크 없음")
                return False
                
        except Exception as e:
            print(f"  ❌ {file_path.relative_to(self.base_path)}: 오류 - {e}")
            return False
    
    def run_fix(self):
        """수정 실행"""
        print("🔧 파일 이동으로 인한 링크 수정 시작...")
        print("=" * 60)
        
        # 모든 마크다운 파일 수정
        md_files = self.find_markdown_files()
        print(f"📁 총 {len(md_files)}개 마크다운 파일 수정 중...")
        
        for file_path in md_files:
            print(f"📄 처리 중: {file_path.relative_to(self.base_path)}")
            self.fix_file(file_path)
        
        print("\n" + "=" * 60)
        print("📊 파일 이동 링크 수정 완료!")
        print("=" * 60)
        print(f"📁 수정된 파일: {self.fixed_files}개")
        print(f"🔗 수정된 링크: {self.fixed_links}개")
        
        if self.fixed_files > 0:
            print("\n✅ 파일 이동으로 인한 링크 수정이 완료되었습니다!")
        else:
            print("\n✅ 수정할 링크가 없습니다!")

def main():
    """메인 함수"""
    base_path = Path.cwd()
    fixer = MovedFilesLinkFixer(base_path)
    fixer.run_fix()

if __name__ == "__main__":
    main()