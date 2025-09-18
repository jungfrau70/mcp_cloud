#!/usr/bin/env python3
"""
남은 경로 문제 해결 도구
mcp_knowledge_base/../..//mcp_knowledge_base/ 패턴 완전 제거
"""

import os
import re
from pathlib import Path
from typing import List, Tuple

class RemainingPathFixer:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.knowledge_base_path = self.base_path / "mcp_knowledge_base"
        self.fixed_files = 0
        self.fixed_links = 0
        
    def find_markdown_files(self) -> List[Path]:
        """모든 마크다운 파일 찾기"""
        md_files = []
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                if file.endswith('.md'):
                    md_files.append(Path(root) / file)
        return md_files
    
    def fix_path_patterns(self, content: str) -> Tuple[str, int]:
        """경로 패턴 수정"""
        original_content = content
        fixes_count = 0
        
        # 패턴 1: mcp_knowledge_base/../..//mcp_knowledge_base/ -> /mcp_knowledge_base/
        pattern1 = r'mcp_knowledge_base/\.\./\.\.//mcp_knowledge_base/'
        replacement1 = '/mcp_knowledge_base/'
        content = re.sub(pattern1, replacement1, content)
        fixes_count += len(re.findall(pattern1, original_content))
        
        # 패턴 2: mcp_knowledge_base/../mcp_knowledge_base/ -> /mcp_knowledge_base/
        pattern2 = r'mcp_knowledge_base/\.\./mcp_knowledge_base/'
        replacement2 = '/mcp_knowledge_base/'
        content = re.sub(pattern2, replacement2, content)
        fixes_count += len(re.findall(pattern2, original_content))
        
        # 패턴 3: ../mcp_knowledge_base/ -> /mcp_knowledge_base/
        pattern3 = r'\.\./mcp_knowledge_base/'
        replacement3 = '/mcp_knowledge_base/'
        content = re.sub(pattern3, replacement3, content)
        fixes_count += len(re.findall(pattern3, original_content))
        
        # 패턴 4: mcp_knowledge_base/mcp_knowledge_base/ -> /mcp_knowledge_base/
        pattern4 = r'mcp_knowledge_base/mcp_knowledge_base/'
        replacement4 = '/mcp_knowledge_base/'
        content = re.sub(pattern4, replacement4, content)
        fixes_count += len(re.findall(pattern4, original_content))
        
        # 패턴 5: //mcp_knowledge_base/ -> /mcp_knowledge_base/
        pattern5 = r'//mcp_knowledge_base/'
        replacement5 = '/mcp_knowledge_base/'
        content = re.sub(pattern5, replacement5, content)
        fixes_count += len(re.findall(pattern5, original_content))
        
        # 패턴 6: 백슬래시를 슬래시로 변환
        content = content.replace('\\', '/')
        
        return content, fixes_count
    
    def fix_file(self, file_path: Path) -> bool:
        """파일 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            content, fixes_count = self.fix_path_patterns(content)
            
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
        print("🔧 남은 경로 문제 해결 시작...")
        print("=" * 60)
        
        md_files = self.find_markdown_files()
        print(f"📁 총 {len(md_files)}개 마크다운 파일 검사 중...")
        
        for file_path in md_files:
            print(f"📄 처리 중: {file_path.relative_to(self.base_path)}")
            self.fix_file(file_path)
        
        print("\n" + "=" * 60)
        print("📊 수정 완료!")
        print("=" * 60)
        print(f"📁 수정된 파일: {self.fixed_files}개")
        print(f"🔗 수정된 링크: {self.fixed_links}개")
        
        if self.fixed_files > 0:
            print("\n✅ 남은 경로 문제가 해결되었습니다!")
        else:
            print("\n✅ 수정할 경로 문제가 없습니다!")

def main():
    """메인 함수"""
    base_path = Path.cwd()
    fixer = RemainingPathFixer(base_path)
    fixer.run_fix()

if __name__ == "__main__":
    main()