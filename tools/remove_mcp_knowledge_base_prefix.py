#!/usr/bin/env python3
"""
/mcp_knowledge_base/ 접두사를 제거하는 스크립트
기존에 변환된 절대 경로에서 /mcp_knowledge_base/ 접두사를 제거
"""

import os
import re
import glob
from pathlib import Path
from typing import List, Tuple

class PrefixRemover:
    def __init__(self, knowledge_base_root: str = "mcp_knowledge_base"):
        self.knowledge_base_root = Path(knowledge_base_root)
        self.conversion_count = 0
        self.file_count = 0
        
    def remove_mcp_knowledge_base_prefix(self, content: str) -> str:
        """mcp_knowledge_base 접두사 제거"""
        # /mcp_knowledge_base/ 접두사 제거 패턴
        pattern = r'\[([^\]]+)\]\(/mcp_knowledge_base/([^)]+)\)'
        replacement = r'[\1](\2)'
        
        converted_content = re.sub(pattern, replacement, content)
        return converted_content
    
    def process_file(self, file_path: Path) -> bool:
        """단일 파일 처리"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            converted_content = self.remove_mcp_knowledge_base_prefix(content)
            
            if original_content != converted_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(converted_content)
                
                self.conversion_count += 1
                print(f"✅ 접두사 제거 완료: {file_path}")
                return True
            else:
                print(f"⏭️  변경사항 없음: {file_path}")
                return False
                
        except Exception as e:
            print(f"❌ 오류 발생: {file_path} - {str(e)}")
            return False
    
    def process_all_markdown_files(self) -> None:
        """모든 마크다운 파일 처리"""
        print("🔍 마크다운 파일 검색 중...")
        
        # 모든 .md 파일 찾기
        md_files = list(self.knowledge_base_root.rglob("*.md"))
        
        print(f"📁 총 {len(md_files)}개 파일 발견")
        
        for file_path in md_files:
            self.file_count += 1
            self.process_file(file_path)
        
        print(f"\n📊 접두사 제거 결과:")
        print(f"   - 처리된 파일: {self.file_count}개")
        print(f"   - 변환된 파일: {self.conversion_count}개")
        print(f"   - 변환률: {self.conversion_count/self.file_count*100:.1f}%")
    
    def find_mcp_knowledge_base_prefixes(self, file_path: Path) -> List[Tuple[str, str, int]]:
        """파일에서 /mcp_knowledge_base/ 접두사 찾기"""
        prefixes = []
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            for line_num, line in enumerate(lines, 1):
                # /mcp_knowledge_base/ 접두사 패턴 찾기
                pattern = r'\[([^\]]+)\]\(/mcp_knowledge_base/([^)]+)\)'
                matches = re.finditer(pattern, line)
                
                for match in matches:
                    prefixes.append((
                        match.group(1),  # 링크 텍스트
                        match.group(2),  # 경로
                        line_num
                    ))
        
        except Exception as e:
            print(f"❌ 파일 읽기 오류: {file_path} - {str(e)}")
        
        return prefixes
    
    def analyze_mcp_knowledge_base_prefixes(self) -> None:
        """mcp_knowledge_base 접두사 분석"""
        print("🔍 /mcp_knowledge_base/ 접두사 분석 중...")
        
        total_prefixes = 0
        files_with_prefixes = 0
        
        for file_path in self.knowledge_base_root.rglob("*.md"):
            prefixes = self.find_mcp_knowledge_base_prefixes(file_path)
            
            if prefixes:
                files_with_prefixes += 1
                total_prefixes += len(prefixes)
                
                print(f"\n📄 {file_path}:")
                for link_text, path, line_num in prefixes:
                    print(f"   라인 {line_num}: [{link_text}](/mcp_knowledge_base/{path})")
        
        print(f"\n📊 분석 결과:")
        print(f"   - 접두사가 있는 파일: {files_with_prefixes}개")
        print(f"   - 총 접두사 수: {total_prefixes}개")

def main():
    """메인 함수"""
    print("🚀 /mcp_knowledge_base/ 접두사 제거 도구")
    print("=" * 50)
    
    remover = PrefixRemover()
    
    # 1. 현재 상태 분석
    print("\n1️⃣ 현재 상태 분석")
    remover.analyze_mcp_knowledge_base_prefixes()
    
    # 2. 접두사 제거 실행
    print("\n2️⃣ 접두사 제거 실행")
    remover.process_all_markdown_files()
    
    print("\n✅ 접두사 제거 완료!")

if __name__ == "__main__":
    main()
