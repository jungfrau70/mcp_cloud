#!/usr/bin/env python3
"""
고급 링크 수정 스크립트 - 더 정교한 패턴 매칭과 수정
"""
import os
import re
import json
from pathlib import Path
from typing import Dict, List, Tuple, Set, Optional

class AdvancedLinkFixer:
    def __init__(self, root_dir: str = "mcp_knowledge_base"):
        self.root_dir = Path(root_dir)
        self.all_files = set()
        self.file_map = {}  # 파일명 -> 전체 경로 매핑
        self.fixed_count = 0
        self.error_count = 0
        
    def find_all_md_files(self) -> List[Path]:
        """모든 마크다운 파일 찾기"""
        md_files = []
        for file_path in self.root_dir.rglob("*.md"):
            md_files.append(file_path)
            # 상대 경로로 변환하여 저장
            rel_path = file_path.relative_to(self.root_dir)
            rel_path_str = str(rel_path).replace('\\', '/')
            self.all_files.add(rel_path_str)
            
            # 파일명으로도 매핑
            filename = file_path.name
            if filename not in self.file_map:
                self.file_map[filename] = []
            self.file_map[filename].append(rel_path_str)
        return md_files
    
    def find_target_file_advanced(self, current_file: Path, target_url: str) -> Optional[str]:
        """고급 대상 파일 찾기"""
        if target_url.startswith('#'):
            return None  # 앵커 링크는 수정하지 않음
        
        if target_url.startswith('http'):
            return None  # 외부 링크는 수정하지 않음
        
        if target_url.startswith('mdc:'):
            # mdc: 링크 처리
            mdc_path = target_url.replace('mdc:', '').replace('mcp_knowledge_base/', '')
            if mdc_path in self.all_files:
                return f"/mcp_knowledge_base/{mdc_path}"
            return None
        
        if target_url.startswith('/mcp_knowledge_base/'):
            # 이미 올바른 형식
            rel_path = target_url.replace('/mcp_knowledge_base/', '')
            if rel_path in self.all_files:
                return target_url
            return None
        
        if target_url.startswith('/'):
            # 절대 경로 처리
            abs_path = target_url.lstrip('/')
            if abs_path in self.all_files:
                return f"/mcp_knowledge_base/{abs_path}"
            return None
        
        # 상대 경로 처리
        current_dir = current_file.parent
        target_path = current_dir / target_url
        
        # .md 확장자가 없으면 추가
        if not target_path.suffix and not target_path.name.startswith('.'):
            target_path = target_path.with_suffix('.md')
        
        try:
            rel_path = target_path.relative_to(self.root_dir)
            rel_path_str = str(rel_path).replace('\\', '/')
            if rel_path_str in self.all_files:
                return f"/mcp_knowledge_base/{rel_path_str}"
        except ValueError:
            pass
        
        # 파일명으로 검색
        target_filename = target_url
        if not target_filename.endswith('.md'):
            target_filename += '.md'
        
        if target_filename in self.file_map:
            # 같은 디렉토리에서 우선 검색
            current_dir_str = str(current_file.parent.relative_to(self.root_dir)).replace('\\', '/')
            for file_path in self.file_map[target_filename]:
                if file_path.startswith(current_dir_str):
                    return f"/mcp_knowledge_base/{file_path}"
            
            # 첫 번째 매치 사용
            return f"/mcp_knowledge_base/{self.file_map[target_filename][0]}"
        
        return None
    
    def fix_links_in_file(self, file_path: Path) -> bool:
        """파일 내 링크 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            modified = False
            
            # 마크다운 링크 패턴: [text](url)
            def replace_markdown_link(match):
                text = match.group(1)
                url = match.group(2)
                
                # 이미 올바른 형식인지 확인
                if url.startswith('/mcp_knowledge_base/'):
                    return match.group(0)
                
                # 대상 파일 찾기
                target_file = self.find_target_file_advanced(file_path, url)
                if target_file:
                    return f"[{text}]({target_file})"
                
                return match.group(0)
            
            content = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', replace_markdown_link, content)
            
            # HTML 링크 패턴: <a href="url">text</a>
            def replace_html_link(match):
                url = match.group(1)
                text = match.group(2)
                
                # 이미 올바른 형식인지 확인
                if url.startswith('/mcp_knowledge_base/'):
                    return match.group(0)
                
                # 대상 파일 찾기
                target_file = self.find_target_file_advanced(file_path, url)
                if target_file:
                    return f'<a href="{target_file}">{text}</a>'
                
                return match.group(0)
            
            content = re.sub(r'<a[^>]+href=["\']([^"\']+)["\'][^>]*>([^<]+)</a>', replace_html_link, content)
            
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                self.fixed_count += 1
                return True
            
            return False
            
        except Exception as e:
            print(f"파일 수정 중 오류 발생: {file_path} - {e}")
            self.error_count += 1
            return False
    
    def fix_all_links(self):
        """모든 파일의 링크 수정"""
        md_files = self.find_all_md_files()
        print(f"총 {len(md_files)}개의 마크다운 파일을 처리합니다...")
        
        for file_path in md_files:
            if self.fix_links_in_file(file_path):
                print(f"수정됨: {file_path.relative_to(self.root_dir)}")
        
        print(f"\n=== 수정 완료 ===")
        print(f"수정된 파일 수: {self.fixed_count}")
        print(f"오류 발생 파일 수: {self.error_count}")

def main():
    fixer = AdvancedLinkFixer()
    fixer.fix_all_links()

if __name__ == "__main__":
    main()
