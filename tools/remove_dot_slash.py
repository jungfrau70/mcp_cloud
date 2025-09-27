#!/usr/bin/env python3
"""
상대 경로에서 ./ 제거 도구
모든 마크다운 파일에서 ./를 제거하여 깔끔한 경로로 변경
"""

import os
import re
import glob
from pathlib import Path

def remove_dot_slash(file_path):
    """마크다운 파일에서 ./ 제거"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # ./ 제거 패턴들
        patterns_to_fix = [
            # 링크에서 ./ 제거
            (r'\]\(\./([^)]+)\)', r'](\1)'),
            # 이미지에서 ./ 제거  
            (r'!\[([^\]]*)\]\(\./([^)]+)\)', r'![\1](\2)'),
            # 기타 ./ 제거
            (r'\./([^/\s\)\]\>]+)', r'\1')
        ]
        
        for pattern, replacement in patterns_to_fix:
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
    print("🔧 ./ 제거 도구 시작")
    
    # mcp_knowledge_base 디렉토리 내 모든 .md 파일 찾기
    md_files = []
    for root, dirs, files in os.walk('mcp_knowledge_base'):
        for file in files:
            if file.endswith('.md'):
                md_files.append(os.path.join(root, file))
    
    print(f"📁 발견된 마크다운 파일: {len(md_files)}개")
    
    fixed_files = 0
    total_changes = 0
    
    for file_path in md_files:
        print(f"🔍 처리 중: {file_path}")
        
        # ./ 제거
        if remove_dot_slash(file_path):
            fixed_files += 1
            print(f"  ✅ ./ 제거됨")
            total_changes += 1
    
    print(f"\n📊 수정 완료:")
    print(f"  - 수정된 파일: {fixed_files}개")
    print(f"  - 총 변경사항: {total_changes}개")

if __name__ == "__main__":
    main()
