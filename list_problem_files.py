#!/usr/bin/env python3
"""
문제가 있는 파일들의 상세 리스트를 생성합니다.
"""

import os
import re
from pathlib import Path

def find_problem_files():
    """문제가 있는 파일들을 찾아서 상세 리스트를 생성합니다."""
    problem_files = []
    
    for root, dirs, files in os.walk("mcp_knowledge_base"):
        for file in files:
            if file.endswith('.md'):
                file_path = os.path.join(root, file)
                
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    # div align="center" 개수 확인
                    div_count = len(re.findall(r'<div align="center">', content))
                    
                    if div_count > 1:
                        # 상대 경로로 변환
                        rel_path = os.path.relpath(file_path, "mcp_knowledge_base")
                        problem_files.append({
                            'file': rel_path,
                            'div_count': div_count,
                            'full_path': file_path
                        })
                
                except Exception as e:
                    print(f"Error reading {file_path}: {e}")
    
    return problem_files

def main():
    """메인 함수"""
    print("🔍 문제가 있는 파일들 상세 리스트")
    print("=" * 60)
    
    problem_files = find_problem_files()
    
    if not problem_files:
        print("✅ 모든 파일이 정상 상태입니다!")
        return
    
    # div 개수별로 정렬
    problem_files.sort(key=lambda x: x['div_count'], reverse=True)
    
    print(f"📊 총 {len(problem_files)}개 파일에 문제가 있습니다:\n")
    
    # div 개수별로 그룹화
    div_groups = {}
    for pf in problem_files:
        count = pf['div_count']
        if count not in div_groups:
            div_groups[count] = []
        div_groups[count].append(pf)
    
    # 각 그룹별로 출력
    for div_count in sorted(div_groups.keys(), reverse=True):
        files = div_groups[div_count]
        print(f"🔴 {div_count}개 div 블록이 있는 파일들 ({len(files)}개):")
        for pf in files:
            print(f"  - {pf['file']}")
        print()
    
    # 과정별로 분류
    print("📚 과정별 분류:")
    courses = {}
    for pf in problem_files:
        if 'cloud_basic' in pf['file']:
            course = 'Cloud Basic'
        elif 'cloud_master' in pf['file']:
            course = 'Cloud Master'
        elif 'cloud_container' in pf['file']:
            course = 'Cloud Container'
        else:
            course = '기타'
        
        if course not in courses:
            courses[course] = []
        courses[course].append(pf)
    
    for course, files in courses.items():
        print(f"\n🎓 {course} ({len(files)}개 파일):")
        for pf in files:
            print(f"  - {pf['file']} ({pf['div_count']}개 div)")

if __name__ == "__main__":
    main()
