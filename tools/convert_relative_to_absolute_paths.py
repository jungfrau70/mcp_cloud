#!/usr/bin/env python3
"""
상대 경로를 절대 경로로 변환하는 스크립트
mcp_knowledge_base 내 모든 마크다운 문서의 상대 경로를 절대 경로로 변경
"""

import os
import re
import glob
from pathlib import Path
from typing import List, Tuple

class PathConverter:
    def __init__(self, knowledge_base_root: str = "mcp_knowledge_base"):
        self.knowledge_base_root = Path(knowledge_base_root)
        self.conversion_count = 0
        self.file_count = 0
        
    def convert_relative_to_absolute(self, content: str, file_path: Path) -> str:
        """상대 경로를 절대 경로로 변환"""
        # 상대 경로 패턴들
        patterns = [
            # ../ 패턴 (상위 디렉토리)
            (r'\[([^\]]+)\]\(\.\./([^)]+)\)', r'[\1](\2)'),
            # ./ 패턴 (현재 디렉토리)
            (r'\[([^\]]+)\]\(\./([^)]+)\)', r'[\1](\2)'),
            # 상대 경로 (../ 또는 ./ 없이)
            (r'\[([^\]]+)\]\(([^/][^)]*)\)', self._convert_simple_relative_path),
        ]
        
        converted_content = content
        
        for pattern, replacement in patterns:
            if callable(replacement):
                converted_content = re.sub(pattern, replacement, converted_content)
            else:
                converted_content = re.sub(pattern, replacement, converted_content)
        
        return converted_content
    
    def _convert_simple_relative_path(self, match) -> str:
        """단순한 상대 경로를 절대 경로로 변환"""
        link_text = match.group(1)
        path = match.group(2)
        
        # 이미 절대 경로인 경우 스킵
        if path.startswith('/mcp_knowledge_base/') or path.startswith('http'):
            return match.group(0)
        
        # 절대 경로로 변환 (mcp_knowledge_base 접두사 제거)
        return f'[{link_text}]({path})'
    
    def process_file(self, file_path: Path) -> bool:
        """단일 파일 처리"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            converted_content = self.convert_relative_to_absolute(content, file_path)
            
            if original_content != converted_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(converted_content)
                
                self.conversion_count += 1
                print(f"✅ 변환 완료: {file_path}")
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
        
        print(f"\n📊 변환 결과:")
        print(f"   - 처리된 파일: {self.file_count}개")
        print(f"   - 변환된 파일: {self.conversion_count}개")
        print(f"   - 변환률: {self.conversion_count/self.file_count*100:.1f}%")
    
    def find_relative_paths(self, file_path: Path) -> List[Tuple[str, str, int]]:
        """파일에서 상대 경로 찾기"""
        relative_paths = []
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            for line_num, line in enumerate(lines, 1):
                # 상대 경로 패턴 찾기
                patterns = [
                    r'\[([^\]]+)\]\(\.\./([^)]+)\)',  # ../ 패턴
                    r'\[([^\]]+)\]\(\./([^)]+)\)',    # ./ 패턴
                    r'\[([^\]]+)\]\(([^/][^)]*)\)',   # 단순 상대 경로
                ]
                
                for pattern in patterns:
                    matches = re.finditer(pattern, line)
                    for match in matches:
                        if not match.group(2).startswith('http') and not match.group(2).startswith('/mcp_knowledge_base/'):
                            relative_paths.append((
                                match.group(1),  # 링크 텍스트
                                match.group(2),  # 경로
                                line_num
                            ))
        
        except Exception as e:
            print(f"❌ 파일 읽기 오류: {file_path} - {str(e)}")
        
        return relative_paths
    
    def analyze_relative_paths(self) -> None:
        """상대 경로 분석"""
        print("🔍 상대 경로 분석 중...")
        
        total_relative_paths = 0
        files_with_relative_paths = 0
        
        for file_path in self.knowledge_base_root.rglob("*.md"):
            relative_paths = self.find_relative_paths(file_path)
            
            if relative_paths:
                files_with_relative_paths += 1
                total_relative_paths += len(relative_paths)
                
                print(f"\n📄 {file_path}:")
                for link_text, path, line_num in relative_paths:
                    print(f"   라인 {line_num}: [{link_text}]({path})")
        
        print(f"\n📊 분석 결과:")
        print(f"   - 상대 경로가 있는 파일: {files_with_relative_paths}개")
        print(f"   - 총 상대 경로 수: {total_relative_paths}개")

def main():
    """메인 함수"""
    print("🚀 상대 경로 → 절대 경로 변환 도구")
    print("=" * 50)
    
    converter = PathConverter()
    
    # 1. 현재 상태 분석
    print("\n1️⃣ 현재 상태 분석")
    converter.analyze_relative_paths()
    
    # 2. 변환 실행
    print("\n2️⃣ 변환 실행")
    converter.process_all_markdown_files()
    
    print("\n✅ 변환 완료!")

if __name__ == "__main__":
    main()
