#!/usr/bin/env python3
"""
가이드 문서 링크 최종 수정 도구
깨진 링크 보고서를 기반으로 정확한 수정 수행
"""

import os
import re
import json
from pathlib import Path
from urllib.parse import quote, unquote
from typing import Dict, List, Set, Tuple

class GuidesLinksFinalFixer:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.knowledge_base_path = self.base_path / "mcp_knowledge_base"
        self.fixed_files = 0
        self.fixed_links = 0
        
        # 실제 파일 매핑
        self.actual_files = {}
        self.build_actual_files_map()
        
        # 가이드 파일 이동 매핑
        self.guides_moves = {
            # Cloud Basic 과정 가이드 이동
            "/mcp_knowledge_base/cloud_basic/install/": "/mcp_knowledge_base/cloud_basic/textbook/Day1/guides/",
            
            # Cloud Master 과정 가이드 이동
            "/mcp_knowledge_base/cloud_master/install/": "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/",
            "/mcp_knowledge_base/cloud_master/textbook/Day1/scripts/": "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/",
            
            # Cloud Container 과정 가이드 이동
            "/mcp_knowledge_base/cloud_container/install/": "/mcp_knowledge_base/cloud_container/textbook/Day1/guides/",
            "/mcp_knowledge_base/cloud_container/textbook/Day1/scripts/": "/mcp_knowledge_base/cloud_container/textbook/Day1/guides/",
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
    
    def fix_external_links(self, content: str) -> Tuple[str, int]:
        """외부 링크 프로토콜 수정"""
        fixes_count = 0
        
        # https:/ → https:// 수정
        old_pattern = r'https:/'
        new_pattern = 'https://'
        
        if re.search(old_pattern, content):
            content = re.sub(old_pattern, new_pattern, content)
            fixes_count += content.count(new_pattern) - content.count('https://')
            print(f"    🔧 외부 링크 프로토콜 수정: {fixes_count}개")
        
        return content, fixes_count
    
    def fix_guides_paths(self, content: str) -> Tuple[str, int]:
        """가이드 파일 경로 수정"""
        fixes_count = 0
        
        # 가이드 파일 이동 매핑 적용
        for old_path, new_path in self.guides_moves.items():
            if old_path in content:
                content = content.replace(old_path, new_path)
                fixes_count += content.count(new_path) - content.count(old_path)
                print(f"    🔧 가이드 경로 수정: {old_path} → {new_path}")
        
        return content, fixes_count
    
    def fix_specific_broken_links(self, content: str) -> Tuple[str, int]:
        """특정 깨진 링크 수정"""
        fixes_count = 0
        
        # 특정 링크 수정 매핑
        specific_fixes = {
            # Cloud Basic 가이드
            "/mcp_knowledge_base/cloud_basic/install/install_gcp_cli.md": "/mcp_knowledge_base/cloud_basic/textbook/Day1/guides/install_gcp_cli.md",
            
            # Cloud Master 가이드
            "/mcp_knowledge_base/cloud_master/install/github-actions-setup.md": "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/github-actions-setup.md",
            "/mcp_knowledge_base/cloud_master/textbook/Day1/scripts/GCP_SSH_KEY_GUIDE.md": "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/GCP_SSH_KEY_GUIDE.md",
            "/mcp_knowledge_base/cloud_master/textbook/Day1/github-actions-advanced-guide": "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/github-actions-advanced-guide.md",
            
            # Cloud Master Day2 가이드 (존재하지 않는 파일들)
            "/mcp_knowledge_base/cloud_master/textbook/Day2/matrix-build-guide.md": "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/matrix-build-guide.md",
            "/mcp_knowledge_base/cloud_master/textbook/Day2/kubernetes-guide.md": "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/kubernetes-guide.md",
            "/mcp_knowledge_base/cloud_master/textbook/Day2/kubernetes-setup-guide.md": "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/kubernetes-setup-guide.md",
            "/mcp_knowledge_base/cloud_master/textbook/Day2/automated-deployment-guide.md": "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/automated-deployment-guide.md",
            "/mcp_knowledge_base/cloud_master/textbook/Day2/infrastructure-as-code-guide.md": "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/infrastructure-as-code-guide.md",
            
            # Cloud Master Day3 가이드 (존재하지 않는 파일들)
            "/mcp_knowledge_base/cloud_master/textbook/Day3/elk-stack-guide.md": "/mcp_knowledge_base/cloud_master/textbook/Day3/guides/elk-stack-guide.md",
            "/mcp_knowledge_base/cloud_master/textbook/Day3/operations-automation-guide.md": "/mcp_knowledge_base/cloud_master/textbook/Day3/guides/operations-automation-guide.md",
        }
        
        for old_path, new_path in specific_fixes.items():
            if old_path in content:
                content = content.replace(old_path, new_path)
                fixes_count += 1
                print(f"    🔧 특정 링크 수정: {old_path} → {new_path}")
        
        return content, fixes_count
    
    def fix_file(self, file_path: Path) -> bool:
        """파일 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            total_fixes = 0
            
            # 1. 외부 링크 프로토콜 수정
            content, fixes = self.fix_external_links(content)
            total_fixes += fixes
            
            # 2. 가이드 파일 경로 수정
            content, fixes = self.fix_guides_paths(content)
            total_fixes += fixes
            
            # 3. 특정 깨진 링크 수정
            content, fixes = self.fix_specific_broken_links(content)
            total_fixes += fixes
            
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                self.fixed_files += 1
                self.fixed_links += total_fixes
                print(f"  ✅ {file_path.relative_to(self.base_path)}: {total_fixes}개 링크 수정")
                return True
            else:
                print(f"  ⏭️ {file_path.relative_to(self.base_path)}: 수정할 링크 없음")
                return False
                
        except Exception as e:
            print(f"  ❌ {file_path.relative_to(self.base_path)}: 오류 - {e}")
            return False
    
    def run_fix(self):
        """수정 실행"""
        print("🔧 가이드 문서 링크 최종 수정 시작...")
        print("=" * 60)
        
        # 모든 마크다운 파일 수정
        md_files = self.find_markdown_files()
        print(f"📁 총 {len(md_files)}개 마크다운 파일 수정 중...")
        
        for file_path in md_files:
            print(f"📄 처리 중: {file_path.relative_to(self.base_path)}")
            self.fix_file(file_path)
        
        print("\n" + "=" * 60)
        print("📊 가이드 문서 링크 최종 수정 완료!")
        print("=" * 60)
        print(f"📁 수정된 파일: {self.fixed_files}개")
        print(f"🔗 수정된 링크: {self.fixed_links}개")
        
        if self.fixed_files > 0:
            print("\n✅ 가이드 문서 링크 수정이 완료되었습니다!")
        else:
            print("\n✅ 수정할 링크가 없습니다!")

def main():
    """메인 함수"""
    base_path = Path.cwd()
    fixer = GuidesLinksFinalFixer(base_path)
    fixer.run_fix()

if __name__ == "__main__":
    main()