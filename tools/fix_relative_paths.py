#!/usr/bin/env python3
"""
상대 경로 수정 도구
디렉토리 내부 링크를 올바른 상대 경로로 수정
"""

import os
import re
from pathlib import Path

def fix_relative_paths(file_path):
    """파일의 상대 경로를 올바르게 수정"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # 파일 경로 분석
        file_path_obj = Path(file_path)
        relative_to_root = file_path_obj.relative_to('mcp_knowledge_base')
        
        # 현재 파일이 cloud_intermediate 디렉토리에 있는 경우
        if 'cloud_intermediate' in str(relative_to_root):
            # cloud_intermediate로 시작하는 링크를 ../cloud_intermediate로 수정
            content = re.sub(
                r'\]\(cloud_intermediate/([^)]+)\)',
                r'](../cloud_intermediate/\1)',
                content
            )
        
        # 현재 파일이 cloud_master 디렉토리에 있는 경우
        elif 'cloud_master' in str(relative_to_root):
            # cloud_master로 시작하는 링크를 ../cloud_master로 수정
            content = re.sub(
                r'\]\(cloud_master/([^)]+)\)',
                r'](../cloud_master/\1)',
                content
            )
        
        # 현재 파일이 cloud_basic 디렉토리에 있는 경우
        elif 'cloud_basic' in str(relative_to_root):
            # cloud_basic로 시작하는 링크를 ../cloud_basic로 수정
            content = re.sub(
                r'\]\(cloud_basic/([^)]+)\)',
                r'](../cloud_basic/\1)',
                content
            )
        
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
    print("🔧 상대 경로 수정 도구 시작")
    
    # mcp_knowledge_base 디렉토리 내 모든 .md 파일 찾기
    md_files = []
    for root, dirs, files in os.walk('mcp_knowledge_base'):
        for file in files:
            if file.endswith('.md'):
                md_files.append(os.path.join(root, file))
    
    print(f"📁 발견된 마크다운 파일: {len(md_files)}개")
    
    fixed_files = 0
    
    for file_path in md_files:
        print(f"🔍 처리 중: {file_path}")
        
        # 상대 경로 수정
        if fix_relative_paths(file_path):
            fixed_files += 1
            print(f"  ✅ 상대 경로 수정됨")
    
    print(f"\n📊 수정 완료:")
    print(f"  - 수정된 파일: {fixed_files}개")

if __name__ == "__main__":
    main()
