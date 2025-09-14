#!/usr/bin/env python3
"""
학습 경로 검증 도구
Top-down 및 Bottom-up 방식으로 학습 경로의 완전성을 검증합니다.
"""

import argparse
import os
import re
import glob
import sys
from pathlib import Path

def validate_top_down_links(learning_path_file):
    """학습 경로에서 참조하는 모든 문서의 존재 여부 검증"""
    errors = []
    
    try:
        with open(learning_path_file, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        return [f"학습 경로 파일을 찾을 수 없습니다: {learning_path_file}"]
    except Exception as e:
        return [f"파일 읽기 오류: {e}"]
    
    # 상대 경로 링크 추출
    links = re.findall(r'\[([^\]]+)\]\(\./([^)]+)\)', content)
    
    for link_text, file_path in links:
        full_path = os.path.join(os.path.dirname(learning_path_file), file_path)
        if not os.path.exists(full_path):
            errors.append(f"누락된 파일: {file_path}")
    
    return errors

def validate_bottom_up_coverage(learning_path_file, course_directory):
    """실제 문서들이 학습 경로에 모두 포함되어 있는지 검증"""
    try:
        with open(learning_path_file, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        return [f"학습 경로 파일을 찾을 수 없습니다: {learning_path_file}"]
    except Exception as e:
        return [f"파일 읽기 오류: {e}"]
    
    # 학습 경로에서 참조하는 파일 목록 추출
    referenced_files = set()
    links = re.findall(r'\[([^\]]+)\]\(\./([^)]+)\)', content)
    for link_text, file_path in links:
        referenced_files.add(file_path)
    
    # 실제 존재하는 마크다운 파일 목록
    actual_files = set()
    try:
        for md_file in glob.glob(os.path.join(course_directory, '**/*.md'), recursive=True):
            rel_path = os.path.relpath(md_file, course_directory)
            rel_path = rel_path.replace('\\', '/')
            # 백업 파일과 README 파일 제외
            if (not rel_path.endswith('.backup') 
                and not rel_path.endswith('README.md')
                and rel_path != 'learning-path.md'
                and 'backup' not in rel_path.lower()
                and 'Day2_backup' not in rel_path):
                actual_files.add(rel_path)
    except Exception as e:
        return [f"디렉토리 스캔 오류: {e}"]
    
    # 누락된 파일 찾기
    missing_files = actual_files - referenced_files
    
    return list(missing_files)

def get_course_stats(course_directory):
    """과정별 문서 통계 정보 수집"""
    stats = {
        'total_files': 0,
        'referenced_files': 0,
        'missing_files': 0,
        'coverage_rate': 0.0
    }
    
    try:
        # 전체 마크다운 파일 수 (백업 파일 제외)
        all_md_files = glob.glob(os.path.join(course_directory, '**/*.md'), recursive=True)
        stats['total_files'] = len([f for f in all_md_files 
                                   if not f.endswith('.backup') 
                                   and not f.endswith('README.md')
                                   and not f.endswith('learning-path.md')
                                   and 'backup' not in f.lower()
                                   and 'Day2_backup' not in f])
        
        # 학습 경로 파일 읽기
        learning_path_file = os.path.join(course_directory, 'learning-path.md')
        if os.path.exists(learning_path_file):
            with open(learning_path_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 참조된 파일 수 (중복 제거)
            links = re.findall(r'\[([^\]]+)\]\(\./([^)]+)\)', content)
            referenced_set = set(file_path for _, file_path in links)
            stats['referenced_files'] = len(referenced_set)
            
            # 누락된 파일 수
            missing_files = validate_bottom_up_coverage(learning_path_file, course_directory)
            stats['missing_files'] = len(missing_files)
            
            # 포함률 계산 (실제 파일 기준)
            if stats['total_files'] > 0:
                stats['coverage_rate'] = ((stats['total_files'] - stats['missing_files']) / stats['total_files']) * 100
    
    except Exception as e:
        print(f"통계 수집 오류: {e}")
    
    return stats

def main():
    parser = argparse.ArgumentParser(description='학습 경로 검증 도구')
    parser.add_argument('--mode', choices=['top-down', 'bottom-up', 'stats'], required=True,
                       help='검증 모드 선택')
    parser.add_argument('--course', choices=['cloud_basic', 'cloud_master', 'cloud_container'], required=True,
                       help='검증할 과정 선택')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='상세한 출력 표시')
    
    args = parser.parse_args()
    
    course_path = f"mcp_knowledge_base/{args.course}"
    learning_path_file = f"{course_path}/learning-path.md"
    
    if not os.path.exists(course_path):
        print(f"❌ 과정 디렉토리를 찾을 수 없습니다: {course_path}")
        sys.exit(1)
    
    if args.mode == 'top-down':
        print(f"🔍 {args.course} 과정 Top-down 검증 중...")
        errors = validate_top_down_links(learning_path_file)
        
        if errors:
            print("❌ Top-down 검증 실패:")
            for error in errors:
                print(f"  - {error}")
            sys.exit(1)
        else:
            print("✅ Top-down 검증 성공: 모든 참조 문서가 존재합니다.")
    
    elif args.mode == 'bottom-up':
        print(f"🔍 {args.course} 과정 Bottom-up 검증 중...")
        missing_files = validate_bottom_up_coverage(learning_path_file, course_path)
        
        if missing_files:
            print("❌ Bottom-up 검증 실패 - 누락된 문서:")
            for file in missing_files:
                print(f"  - {file}")
            if args.verbose:
                print(f"\n총 {len(missing_files)}개의 문서가 누락되었습니다.")
            sys.exit(1)
        else:
            print("✅ Bottom-up 검증 성공: 모든 문서가 학습 경로에 포함되어 있습니다.")
    
    elif args.mode == 'stats':
        print(f"📊 {args.course} 과정 통계 정보:")
        stats = get_course_stats(course_path)
        
        print(f"  📁 전체 문서 수: {stats['total_files']}")
        print(f"  🔗 참조된 문서 수: {stats['referenced_files']}")
        print(f"  ❌ 누락된 문서 수: {stats['missing_files']}")
        print(f"  📈 문서 포함률: {stats['coverage_rate']:.1f}%")
        
        if stats['coverage_rate'] == 100.0:
            print("🎉 완벽한 학습 경로입니다!")
        elif stats['coverage_rate'] >= 90.0:
            print("👍 거의 완벽한 학습 경로입니다!")
        else:
            print("⚠️  학습 경로를 개선할 필요가 있습니다.")

if __name__ == "__main__":
    main()
