#!/usr/bin/env python3
"""
앵커 링크 자동 수정 도구
발견된 문제들을 자동으로 수정합니다.
"""

import os
import re
import glob
import argparse
from pathlib import Path

def fix_korean_filename_links(content):
    """한글 파일명 링크 수정"""
    # 한글 파일명이 잘린 경우 수정
    patterns = [
        (r'클라우드실무력강화_활용법\(기초', '클라우드실무력강화_활용법(기초)_교재.pdf'),
        (r'클라우드실무력강화_활용법\(기초_교재\.pdf', '클라우드실무력강화_활용법(기초)_교재.pdf'),
    ]
    
    for pattern, replacement in patterns:
        content = re.sub(pattern, replacement, content)
    
    return content

def fix_relative_path_links(content, file_path):
    """상대 경로 링크 수정"""
    # 현재 파일의 위치에 따라 상대 경로 조정
    if 'mcp_knowledge_base' in file_path:
        # mcp_knowledge_base 내부 파일인 경우
        if file_path.endswith('README.md') or file_path.endswith('과정명.md') or file_path.endswith('과정상세.md'):
            # 루트 디렉토리 파일들
            content = re.sub(r'\.\./\.\./\.\./curriculum\.md', '../curriculum.md', content)
            content = re.sub(r'\.\./\.\./\.\./index\.md', '../index.md', content)
            content = re.sub(r'\.\./\.\./\.\./learning-path\.md', '../learning-path.md', content)
        else:
            # 하위 디렉토리 파일들
            content = re.sub(r'\.\./\.\./\.\./curriculum\.md', '../../curriculum.md', content)
            content = re.sub(r'\.\./\.\./\.\./index\.md', '../../index.md', content)
            content = re.sub(r'\.\./\.\./\.\./learning-path\.md', '../../learning-path.md', content)
    
    return content

def fix_missing_files(content, file_path):
    """누락된 파일 링크 수정"""
    # 실제 존재하는 파일로 링크 수정
    fixes = [
        (r'\./textbook/Day3/monitoring-setup-guide\.md', './textbook/Day3/monitoring-advanced/monitoring-setup.yaml'),
        (r'\./textbook/Day3/cost-optimization-guide\.md', './textbook/Day3/cost-optimization/cost-optimization-guide.md'),
    ]
    
    for pattern, replacement in fixes:
        content = re.sub(pattern, replacement, content)
    
    return content

def process_file(file_path, dry_run=False):
    """단일 파일 처리"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            original_content = f.read()
        
        content = original_content
        
        # 1. 한글 파일명 링크 수정
        content = fix_korean_filename_links(content)
        
        # 2. 상대 경로 링크 수정
        content = fix_relative_path_links(content, file_path)
        
        # 3. 누락된 파일 링크 수정
        content = fix_missing_files(content, file_path)
        
        if content != original_content:
            if not dry_run:
                # 백업 생성
                backup_path = file_path + '.backup'
                with open(backup_path, 'w', encoding='utf-8') as f:
                    f.write(original_content)
                
                # 수정된 내용 저장
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                print(f"✅ {file_path}: 수정 완료")
            else:
                print(f"🔍 {file_path}: 수정 예정")
            return True
        else:
            print(f"📄 {file_path}: 변경 없음")
            return False
            
    except Exception as e:
        print(f"❌ {file_path} 처리 중 오류: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='앵커 링크 자동 수정 도구')
    parser.add_argument('--course', choices=['cloud_basic', 'cloud_master', 'cloud_container', 'all'], 
                       default='all', help='수정할 과정 선택')
    parser.add_argument('--dry-run', action='store_true', help='실제 변경사항을 적용하지 않고 미리보기')
    
    args = parser.parse_args()
    
    if args.course == 'all':
        courses = ['cloud_basic', 'cloud_master', 'cloud_container']
    else:
        courses = [args.course]
    
    print(f"🔧 앵커 링크 자동 수정 시작 (Dry-run: {args.dry_run})")
    print("=" * 60)
    
    total_files_processed = 0
    total_files_updated = 0
    
    for course in courses:
        course_path = f"mcp_knowledge_base/{course}"
        
        if not os.path.exists(course_path):
            print(f"❌ 과정 디렉토리를 찾을 수 없습니다: {course_path}")
            continue
        
        print(f"\n📚 {course.upper()} 과정 수정")
        print("-" * 40)
        
        # 마크다운 파일 찾기
        md_files = glob.glob(os.path.join(course_path, '**/*.md'), recursive=True)
        md_files = [f for f in md_files if '.backup' not in f]
        
        course_files_updated = 0
        for md_file in md_files:
            total_files_processed += 1
            if process_file(md_file, args.dry_run):
                total_files_updated += 1
                course_files_updated += 1
        
        print(f"🎉 {course} 과정 수정 완료: {course_files_updated}/{len(md_files)} 파일 업데이트")
    
    print(f"\n🎉 전체 수정 완료!")
    print(f"총 {total_files_updated}/{total_files_processed} 파일 업데이트")

if __name__ == "__main__":
    main()