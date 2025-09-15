#!/usr/bin/env python3
"""
남은 학습 경로 링크 수정 스크립트
../../learning-path.md 패턴을 올바른 상대 경로로 수정합니다.
"""

import os
import re
from pathlib import Path

def fix_remaining_learning_path_links():
    """남은 학습 경로 링크를 수정합니다."""
    
    # 수정할 파일들 찾기
    files_to_fix = []
    
    for course in ['cloud_basic', 'cloud_master', 'cloud_container']:
        course_dir = f'mcp_knowledge_base/{course}'
        if not os.path.exists(course_dir):
            continue
            
        for root, dirs, files in os.walk(course_dir):
            for file in files:
                if file.endswith('.md'):
                    file_path = os.path.join(root, file)
                    
                    # 파일 내용 확인
                    try:
                        with open(file_path, 'r', encoding='utf-8') as f:
                            content = f.read()
                        
                        # ../../learning-path.md 패턴이 있는지 확인
                        if '../../learning-path.md' in content:
                            # 파일의 상대 경로 계산
                            rel_path = os.path.relpath(file_path, course_dir)
                            path_parts = rel_path.split(os.sep)
                            
                            # 올바른 상대 경로 결정
                            if len(path_parts) == 1:  # 루트 디렉토리 (README.md, 과정명.md 등)
                                correct_path = '../learning-path.md'
                            elif 'textbook' in path_parts:
                                if 'practice' in path_parts:
                                    # textbook/Day1/practice/ -> ../../learning-path.md (이미 올바름)
                                    correct_path = '../../learning-path.md'
                                else:
                                    # textbook/Day1/ -> ../learning-path.md
                                    correct_path = '../learning-path.md'
                            elif 'accounts' in path_parts or 'install' in path_parts:
                                # accounts/, install/ -> ../learning-path.md
                                correct_path = '../learning-path.md'
                            else:
                                # 기타 하위 디렉토리 -> ../learning-path.md
                                correct_path = '../learning-path.md'
                            
                            files_to_fix.append({
                                'file_path': file_path,
                                'correct_path': correct_path,
                                'content': content,
                                'current_path': '../../learning-path.md'
                            })
                            
                    except Exception as e:
                        print(f"Error reading {file_path}: {e}")
    
    print(f"🔍 수정할 파일 {len(files_to_fix)}개 발견")
    
    # 파일들 수정
    fixed_count = 0
    for file_info in files_to_fix:
        file_path = file_info['file_path']
        correct_path = file_info['correct_path']
        content = file_info['content']
        current_path = file_info['current_path']
        
        print(f"🔧 수정 중: {file_path}")
        print(f"  현재: {current_path} -> 올바른 경로: {correct_path}")
        
        # 잘못된 경로를 올바른 경로로 교체
        old_pattern = r'\[📋 학습 경로\]\([^)]*learning-path\.md\)'
        new_link = f'[📋 학습 경로]({correct_path})'
        
        new_content = re.sub(old_pattern, new_link, content)
        
        if new_content != content:
            try:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"  ✅ 수정 완료")
                fixed_count += 1
            except Exception as e:
                print(f"  ❌ 오류: {e}")
        else:
            print(f"  ⏭️  수정 불필요")
    
    print(f"\n🎉 수정 완료! {fixed_count}개 파일 수정됨")

def main():
    """메인 함수"""
    print("🔧 남은 학습 경로 링크 수정 시작")
    fix_remaining_learning_path_links()

if __name__ == "__main__":
    main()
