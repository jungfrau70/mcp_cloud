#!/usr/bin/env python3
"""
학습 경로 링크 수정 스크립트
각 과정별로 올바른 상대 경로로 학습 경로 링크를 수정합니다.
"""

import os
import re
from pathlib import Path

def fix_learning_path_links():
    """학습 경로 링크를 수정합니다."""
    
    # 각 과정별 올바른 상대 경로 매핑
    course_paths = {
        'cloud_basic': {
            'root': '../../learning-path.md',
            'day1': '../learning-path.md', 
            'day2': '../learning-path.md',
            'accounts': '../learning-path.md',
            'install': '../learning-path.md',
            'practice': '../../learning-path.md'
        },
        'cloud_master': {
            'root': '../../learning-path.md',
            'day1': '../learning-path.md',
            'day2': '../learning-path.md', 
            'day3': '../learning-path.md',
            'accounts': '../learning-path.md',
            'install': '../learning-path.md',
            'practice': '../../learning-path.md'
        },
        'cloud_container': {
            'root': '../../learning-path.md',
            'day1': '../learning-path.md',
            'day2': '../learning-path.md',
            'accounts': '../learning-path.md', 
            'install': '../learning-path.md',
            'practice': '../../learning-path.md'
        }
    }
    
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
                        
                        # 잘못된 학습 경로 링크가 있는지 확인
                        if 'learning-path.md' in content and '../../../../learning-path.md' in content:
                            # 파일의 상대 경로 계산
                            rel_path = os.path.relpath(file_path, course_dir)
                            path_parts = rel_path.split(os.sep)
                            
                            # 올바른 상대 경로 결정
                            if len(path_parts) == 1:  # 루트 디렉토리
                                correct_path = course_paths[course]['root']
                            elif 'Day1' in path_parts or 'Day2' in path_parts or 'Day3' in path_parts:
                                correct_path = course_paths[course]['day1']  # day1, day2, day3 모두 동일
                            elif 'accounts' in path_parts or 'install' in path_parts:
                                correct_path = course_paths[course]['accounts']
                            elif 'practice' in path_parts:
                                correct_path = course_paths[course]['practice']
                            else:
                                correct_path = course_paths[course]['root']
                            
                            files_to_fix.append({
                                'file_path': file_path,
                                'correct_path': correct_path,
                                'content': content
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
        
        print(f"🔧 수정 중: {file_path}")
        print(f"  올바른 경로: {correct_path}")
        
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
    print("🔧 학습 경로 링크 수정 시작")
    fix_learning_path_links()

if __name__ == "__main__":
    main()
