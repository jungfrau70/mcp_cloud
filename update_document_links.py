#!/usr/bin/env python3
"""
문서 연결 구조 정비 도구
모든 문서에 일관된 네비게이션 링크를 추가하고 연결 구조를 개선합니다.
"""

import os
import re
import glob
import argparse
from pathlib import Path

def get_course_info(file_path):
    """파일 경로에서 과정 정보 추출"""
    if 'cloud_basic' in file_path:
        return {
            'course': 'cloud_basic',
            'course_name': 'Cloud Basic',
            'course_korean': '클라우드 기초'
        }
    elif 'cloud_master' in file_path:
        return {
            'course': 'cloud_master',
            'course_name': 'Cloud Master',
            'course_korean': '클라우드 마스터'
        }
    elif 'cloud_container' in file_path:
        return {
            'course': 'cloud_container',
            'course_name': 'Cloud Container',
            'course_korean': '클라우드 컨테이너'
        }
    return None

def get_document_type(file_path):
    """문서 타입 결정"""
    if 'README.md' in file_path:
        return 'readme'
    elif 'learning-path.md' in file_path:
        return 'learning_path'
    elif 'practice/' in file_path:
        return 'practice'
    elif 'accounts/' in file_path:
        return 'accounts'
    elif 'install/' in file_path:
        return 'install'
    elif 'automation/' in file_path:
        return 'automation'
    elif 'presentation/' in file_path:
        return 'presentation'
    elif 'textbook/' in file_path:
        return 'textbook'
    else:
        return 'other'

def generate_navigation_links(file_path, course_info):
    """문서 타입에 따른 네비게이션 링크 생성"""
    if not course_info:
        return ""
    
    course = course_info['course']
    course_name = course_info['course_name']
    
    # 기본 네비게이션 링크
    base_links = [
        f"[📚 전체 커리큘럼](../../../curriculum.md)",
        f"[🏠 학습 경로로 돌아가기](../../../index.md)",
        f"[📋 학습 경로](../../../learning-path.md)"
    ]
    
    # 문서 타입별 특화 링크
    doc_type = get_document_type(file_path)
    
    if doc_type == 'readme':
        if 'Day1' in file_path:
            day_links = [
                f"[← 이전: {course_name} 1일차 메인](../README.md)",
                f"[다음: {course_name} 2일차 →](../Day2/README.md)"
            ]
        elif 'Day2' in file_path:
            day_links = [
                f"[← 이전: {course_name} 1일차](../Day1/README.md)",
                f"[다음: {course_name} 2일차 →](../Day2/README.md)"
            ]
        elif 'Day3' in file_path:
            day_links = [
                f"[← 이전: {course_name} 2일차](../Day2/README.md)",
                f"[다음: {course_name} 3일차 →](../Day3/README.md)"
            ]
        else:
            day_links = [f"[← 이전: {course_name} 메인](../README.md)"]
    else:
        # 다른 문서 타입들
        if 'textbook/Day1' in file_path:
            day_links = [f"[← 이전: {course_name} 1일차 메인](../README.md)"]
        elif 'textbook/Day2' in file_path:
            day_links = [f"[← 이전: {course_name} 2일차 메인](../README.md)"]
        elif 'textbook/Day3' in file_path:
            day_links = [f"[← 이전: {course_name} 3일차 메인](../README.md)"]
        else:
            day_links = [f"[← 이전: {course_name} 메인](../../README.md)"]
    
    all_links = day_links + base_links
    return " | ".join(all_links)

def update_document_navigation(file_path, dry_run=False):
    """문서의 네비게이션 링크 업데이트"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"❌ 파일 읽기 오류 {file_path}: {e}")
        return False
    
    course_info = get_course_info(file_path)
    if not course_info:
        return False
    
    # 기존 네비게이션 섹션 찾기
    nav_pattern = r'<div align="center">\s*\n\s*\[.*?\]\s*\n\s*</div>'
    nav_match = re.search(nav_pattern, content, re.DOTALL)
    
    # 새로운 네비게이션 링크 생성
    new_nav_links = generate_navigation_links(file_path, course_info)
    new_nav_section = f'<div align="center">\n\n{new_nav_links}\n\n</div>'
    
    if nav_match:
        # 기존 네비게이션 교체
        new_content = content.replace(nav_match.group(0), new_nav_section)
    else:
        # 새로운 네비게이션 추가 (제목 바로 아래)
        title_pattern = r'(# .+?\n)'
        title_match = re.search(title_pattern, content)
        if title_match:
            insert_pos = title_match.end()
            new_content = content[:insert_pos] + '\n' + new_nav_section + '\n' + content[insert_pos:]
        else:
            new_content = content
    
    if new_content != content:
        if dry_run:
            print(f"🔍 {file_path}: 네비게이션 링크 업데이트 예정")
            return True
        else:
            try:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"✅ {file_path}: 네비게이션 링크 업데이트 완료")
                return True
            except Exception as e:
                print(f"❌ 파일 쓰기 오류 {file_path}: {e}")
                return False
    else:
        print(f"ℹ️  {file_path}: 변경사항 없음")
        return True

def update_related_links_section(file_path, dry_run=False):
    """관련 과정 링크 섹션 업데이트"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"❌ 파일 읽기 오류 {file_path}: {e}")
        return False
    
    course_info = get_course_info(file_path)
    if not course_info:
        return False
    
    course = course_info['course']
    course_name = course_info['course_name']
    
    # 관련 과정 링크 섹션 패턴
    related_pattern = r'### 🔗 관련 과정 링크.*?(?=\n###|\n---|\n##|\Z)'
    related_match = re.search(related_pattern, content, re.DOTALL)
    
    if related_match:
        # 표준 관련 과정 링크 생성
        if course == 'cloud_basic':
            related_links = [
                "- 🔗 [Cloud Master 과정](../../../cloud_master/textbook/Day1/README.md) - Docker, CI/CD 심화 과정",
                "- 🔗 [Cloud Container 과정](../../../cloud_container/textbook/Day1/README.md) - Kubernetes 고급 과정",
                "- 🔗 [전체 커리큘럼](../../../curriculum.md) - 전체 과정 구조 및 학습 경로",
                "- 🔗 [통합 인덱스](../../../index.md) - 전체 과정 인덱스",
                "- 🔗 [학습 경로로 돌아가기](../../../learning-path.md) - Cloud Basic 학습 경로"
            ]
        elif course == 'cloud_master':
            related_links = [
                "- 🔗 [Cloud Basic 과정](../../../cloud_basic/textbook/Day1/README.md) - AWS/GCP 기초 과정",
                "- 🔗 [Cloud Container 과정](../../../cloud_container/textbook/Day1/README.md) - Kubernetes 고급 과정",
                "- 🔗 [전체 커리큘럼](../../../curriculum.md) - 전체 과정 구조 및 학습 경로",
                "- 🔗 [통합 인덱스](../../../index.md) - 전체 과정 인덱스",
                "- 🔗 [학습 경로로 돌아가기](../../../learning-path.md) - Cloud Master 학습 경로"
            ]
        elif course == 'cloud_container':
            related_links = [
                "- 🔗 [Cloud Basic 과정](../../../cloud_basic/textbook/Day1/README.md) - AWS/GCP 기초 과정",
                "- 🔗 [Cloud Master 과정](../../../cloud_master/textbook/Day1/README.md) - Docker, CI/CD 심화 과정",
                "- 🔗 [전체 커리큘럼](../../../curriculum.md) - 전체 과정 구조 및 학습 경로",
                "- 🔗 [통합 인덱스](../../../index.md) - 전체 과정 인덱스",
                "- 🔗 [학습 경로로 돌아가기](../../../learning-path.md) - Cloud Container 학습 경로"
            ]
        
        new_related_section = "### 🔗 관련 과정 링크\n" + "\n".join(related_links) + "\n"
        
        new_content = content.replace(related_match.group(0), new_related_section)
        
        if new_content != content:
            if dry_run:
                print(f"🔍 {file_path}: 관련 과정 링크 업데이트 예정")
                return True
            else:
                try:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"✅ {file_path}: 관련 과정 링크 업데이트 완료")
                    return True
                except Exception as e:
                    print(f"❌ 파일 쓰기 오류 {file_path}: {e}")
                    return False
    
    return True

def process_course_documents(course, dry_run=False):
    """특정 과정의 모든 문서 처리"""
    course_path = f"mcp_knowledge_base/{course}"
    
    if not os.path.exists(course_path):
        print(f"❌ 과정 디렉토리를 찾을 수 없습니다: {course_path}")
        return False
    
    # 마크다운 파일 찾기
    md_files = glob.glob(os.path.join(course_path, '**/*.md'), recursive=True)
    
    updated_count = 0
    total_count = len(md_files)
    
    print(f"🔧 {course} 과정 문서 처리 시작 ({total_count}개 파일)")
    
    for md_file in md_files:
        # 백업 파일 제외
        if '.backup' in md_file or 'learning-path.md' in md_file:
            continue
        
        print(f"\n📄 처리 중: {os.path.relpath(md_file, course_path)}")
        
        # 네비게이션 링크 업데이트
        nav_success = update_document_navigation(md_file, dry_run)
        
        # 관련 과정 링크 업데이트
        related_success = update_related_links_section(md_file, dry_run)
        
        if nav_success and related_success:
            updated_count += 1
    
    print(f"\n🎉 {course} 과정 처리 완료: {updated_count}/{total_count} 파일 업데이트")
    return True

def main():
    parser = argparse.ArgumentParser(description='문서 연결 구조 정비 도구')
    parser.add_argument('--course', choices=['cloud_basic', 'cloud_master', 'cloud_container', 'all'], 
                       default='all', help='처리할 과정 선택')
    parser.add_argument('--dry-run', action='store_true', help='실제 변경사항을 적용하지 않고 미리보기만 실행')
    parser.add_argument('--verbose', '-v', action='store_true', help='상세한 출력 표시')
    
    args = parser.parse_args()
    
    if args.course == 'all':
        courses = ['cloud_basic', 'cloud_master', 'cloud_container']
    else:
        courses = [args.course]
    
    print(f"🚀 문서 연결 구조 정비 시작 (Dry-run: {args.dry_run})")
    
    for course in courses:
        print(f"\n{'='*60}")
        print(f"📚 {course.upper()} 과정 처리")
        print(f"{'='*60}")
        
        success = process_course_documents(course, args.dry_run)
        
        if not success:
            print(f"❌ {course} 과정 처리 실패")
            return 1
    
    print(f"\n🎉 모든 과정 처리 완료!")
    return 0

if __name__ == "__main__":
    exit(main())
