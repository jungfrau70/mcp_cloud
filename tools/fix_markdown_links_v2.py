#!/usr/bin/env python3
"""
마크다운 링크 수정 도구 v2
[][] 형태의 잘못된 링크를 []() 형태로 수정
"""

import os
import re
import glob
from pathlib import Path

def fix_markdown_links(file_path):
    """마크다운 파일의 링크 수정"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # [][] 형태의 링크를 []() 형태로 수정
        # 패턴: [텍스트][URL] -> [텍스트](URL)
        # 더 정확한 패턴 매칭
        pattern = r'\[([^\]]+)\]\[([^\]]+)\]'
        replacement = r'[\1](\2)'
        content = re.sub(pattern, replacement, content)
        
        # 변경사항이 있으면 파일 저장
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
        
    except Exception as e:
        print(f"❌ 파일 처리 오류 {file_path}: {e}")
        return False

def main():
    """메인 실행 함수"""
    print("🔧 마크다운 링크 수정 도구 v2 시작")
    
    # mcp_knowledge_base 디렉토리 내 모든 .md 파일 찾기
    md_files = []
    for root, dirs, files in os.walk('mcp_knowledge_base'):
        for file in files:
            if file.endswith('.md'):
                md_files.append(os.path.join(root, file))
    
    print(f"📁 발견된 마크다운 파일: {len(md_files)}개")
    
    fixed_files = 0
    link_fixes = 0
    
    for file_path in md_files:
        print(f"🔍 처리 중: {file_path}")
        
        # 링크 형태 수정
        if fix_markdown_links(file_path):
            link_fixes += 1
            fixed_files += 1
            print(f"  ✅ 링크 형태 수정됨")
    
    print(f"\n📊 수정 완료:")
    print(f"  - 수정된 파일: {fixed_files}개")
    print(f"  - 링크 형태 수정: {link_fixes}개")

if __name__ == "__main__":
    main()
