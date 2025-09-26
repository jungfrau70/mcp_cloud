#!/usr/bin/env python3
"""
mcp_knowledge_base 디렉토리 내 마크다운 파일에서
[파일명] 패턴을 (파일명) 패턴으로 변경하는 스크립트
"""

import os
import re
import glob
from pathlib import Path

def fix_bracket_links_in_file(file_path):
    """단일 파일에서 [파일명] 패턴을 (파일명) 패턴으로 변경"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # [파일명.md] 패턴을 (파일명.md) 패턴으로 변경
        # 단, 이미 링크 형태인 [텍스트](파일명)는 제외
        pattern = r'\[([^\[\]]+\.md)\]'
        
        def replace_brackets(match):
            filename = match.group(1)
            return f'({filename})'
        
        content = re.sub(pattern, replace_brackets, content)
        
        # 변경사항이 있으면 파일 저장
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        else:
            return False
            
    except Exception as e:
        print(f"❌ 파일 처리 오류 {file_path}: {e}")
        return False

def find_markdown_files(directory):
    """디렉토리에서 모든 마크다운 파일 찾기"""
    md_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.md'):
                md_files.append(os.path.join(root, file))
    return md_files

def main():
    """메인 실행 함수"""
    knowledge_base_dir = "mcp_knowledge_base"
    
    if not os.path.exists(knowledge_base_dir):
        print(f"❌ {knowledge_base_dir} 디렉토리를 찾을 수 없습니다.")
        return
    
    print(f"🔍 {knowledge_base_dir} 디렉토리에서 마크다운 파일 검색 중...")
    
    md_files = find_markdown_files(knowledge_base_dir)
    print(f"📄 총 {len(md_files)}개의 마크다운 파일을 찾았습니다.")
    
    modified_files = []
    total_changes = 0
    
    for file_path in md_files:
        print(f"🔧 처리 중: {file_path}")
        
        if fix_bracket_links_in_file(file_path):
            modified_files.append(file_path)
            total_changes += 1
            print(f"  ✅ 변경 완료")
        else:
            print(f"  ⏭️ 변경사항 없음")
    
    print(f"\n📊 작업 완료 요약:")
    print(f"  - 처리된 파일: {len(md_files)}개")
    print(f"  - 변경된 파일: {len(modified_files)}개")
    print(f"  - 총 변경 횟수: {total_changes}개")
    
    if modified_files:
        print(f"\n📝 변경된 파일 목록:")
        for file_path in modified_files:
            print(f"  - {file_path}")

if __name__ == "__main__":
    main()
