#!/usr/bin/env python3
"""
앵커 링크 전수 조사 도구
Top-down과 Bottom-up 양방향으로 모든 내부 링크와 앵커의 동작을 검증합니다.
"""

import os
import re
import glob
import argparse
from pathlib import Path
from urllib.parse import unquote

def extract_headings(content):
    """마크다운 문서에서 헤딩 추출"""
    headings = []
    lines = content.split('\n')
    
    for line_num, line in enumerate(lines, 1):
        # ATX 스타일 헤딩 (# ## ### 등)
        match = re.match(r'^(#{1,6})\s+(.+)$', line.strip())
        if match:
            level = len(match.group(1))
            text = match.group(2).strip()
            
            # 앵커 ID 생성 (VS Code 마크다운 미리보기 표준)
            anchor_id = generate_anchor_id(text)
            
            headings.append({
                'level': level,
                'text': text,
                'anchor_id': anchor_id,
                'line': line_num
            })
    
    return headings

def generate_anchor_id(text):
    """VS Code 마크다운 미리보기 표준에 따른 앵커 ID 생성"""
    # 공백을 하이픈으로 변환
    anchor_id = re.sub(r'\s+', '-', text.strip())
    # 연속된 하이픈을 하나로 변환
    anchor_id = re.sub(r'-+', '-', anchor_id)
    # 앞뒤 하이픈 제거
    anchor_id = anchor_id.strip('-')
    # 소문자로 변환
    anchor_id = anchor_id.lower()
    
    return anchor_id

def extract_anchor_links(content):
    """마크다운 문서에서 앵커 링크 추출"""
    anchor_links = []
    lines = content.split('\n')
    
    for line_num, line in enumerate(lines, 1):
        # [text](#anchor) 패턴 찾기
        matches = re.finditer(r'\[([^\]]+)\]\(#([^)]+)\)', line)
        for match in matches:
            link_text = match.group(1)
            anchor = match.group(2)
            
            anchor_links.append({
                'text': link_text,
                'anchor': anchor,
                'line': line_num,
                'full_line': line.strip()
            })
    
    return anchor_links

def extract_file_links(content):
    """마크다운 문서에서 파일 링크 추출"""
    file_links = []
    lines = content.split('\n')
    
    for line_num, line in enumerate(lines, 1):
        # [text](./file.md) 또는 [text](../file.md) 패턴 찾기
        matches = re.finditer(r'\[([^\]]+)\]\(([^#)]+)(?:#[^)]+)?\)', line)
        for match in matches:
            link_text = match.group(1)
            file_path = match.group(2)
            
            file_links.append({
                'text': link_text,
                'file_path': file_path,
                'line': line_num,
                'full_line': line.strip()
            })
    
    return file_links

def validate_anchor_links_in_document(file_path):
    """단일 문서의 앵커 링크 검증"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return [{'type': 'error', 'message': f'파일 읽기 오류: {e}', 'line': 0}]
    
    issues = []
    
    # 헤딩 추출
    headings = extract_headings(content)
    heading_ids = {h['anchor_id'] for h in headings}
    
    # 앵커 링크 추출
    anchor_links = extract_anchor_links(content)
    
    # 앵커 링크 검증
    for link in anchor_links:
        anchor = link['anchor']
        
        # URL 디코딩
        try:
            decoded_anchor = unquote(anchor)
        except:
            decoded_anchor = anchor
        
        if decoded_anchor not in heading_ids:
            # 부분 매칭 시도
            found = False
            for heading_id in heading_ids:
                if heading_id in decoded_anchor or decoded_anchor in heading_id:
                    found = True
                    break
            
            if not found:
                issues.append({
                    'type': 'invalid_anchor',
                    'message': f"앵커 '{anchor}'에 해당하는 헤딩을 찾을 수 없음",
                    'line': link['line'],
                    'anchor': anchor,
                    'available_headings': list(heading_ids)
                })
    
    return issues

def validate_file_links_in_document(file_path):
    """단일 문서의 파일 링크 검증"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return [{'type': 'error', 'message': f'파일 읽기 오류: {e}', 'line': 0}]
    
    issues = []
    file_links = extract_file_links(content)
    
    for link in file_links:
        file_path_str = link['file_path']
        
        # 상대 경로인 경우
        if file_path_str.startswith('./') or file_path_str.startswith('../'):
            # 실제 파일 경로 계산
            base_dir = os.path.dirname(file_path)
            target_path = os.path.join(base_dir, file_path_str)
            target_path = os.path.normpath(target_path)
            
            if not os.path.exists(target_path):
                issues.append({
                    'type': 'missing_file',
                    'message': f"파일 '{file_path_str}'을 찾을 수 없음",
                    'line': link['line'],
                    'file_path': file_path_str,
                    'resolved_path': target_path
                })
    
    return issues

def top_down_validation(course_path):
    """Top-down 검증: 학습 경로 → 실제 문서"""
    print(f"🔍 Top-down 검증 시작: {course_path}")
    
    learning_path_file = os.path.join(course_path, 'learning-path.md')
    if not os.path.exists(learning_path_file):
        print(f"❌ 학습 경로 파일을 찾을 수 없습니다: {learning_path_file}")
        return []
    
    try:
        with open(learning_path_file, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"❌ 학습 경로 파일 읽기 오류: {e}")
        return []
    
    issues = []
    file_links = extract_file_links(content)
    
    print(f"📊 학습 경로에서 {len(file_links)}개의 파일 링크 발견")
    
    for link in file_links:
        file_path_str = link['file_path']
        
        if file_path_str.startswith('./') or file_path_str.startswith('../'):
            base_dir = os.path.dirname(learning_path_file)
            target_path = os.path.join(base_dir, file_path_str)
            target_path = os.path.normpath(target_path)
            
            if not os.path.exists(target_path):
                issues.append({
                    'type': 'missing_file',
                    'message': f"학습 경로에서 참조하는 파일 '{file_path_str}'을 찾을 수 없음",
                    'line': link['line'],
                    'file_path': file_path_str,
                    'resolved_path': target_path
                })
            else:
                # 파일이 존재하면 앵커 링크도 검증
                anchor_issues = validate_anchor_links_in_document(target_path)
                for issue in anchor_issues:
                    issue['source_file'] = learning_path_file
                    issue['referenced_file'] = target_path
                issues.extend(anchor_issues)
    
    return issues

def bottom_up_validation(course_path):
    """Bottom-up 검증: 실제 문서 → 학습 경로"""
    print(f"🔍 Bottom-up 검증 시작: {course_path}")
    
    issues = []
    md_files = glob.glob(os.path.join(course_path, '**/*.md'), recursive=True)
    
    # 백업 파일 제외
    md_files = [f for f in md_files if '.backup' not in f and 'learning-path.md' not in f]
    
    print(f"📊 {len(md_files)}개의 마크다운 파일 검사")
    
    for md_file in md_files:
        rel_path = os.path.relpath(md_file, course_path)
        
        # 앵커 링크 검증
        anchor_issues = validate_anchor_links_in_document(md_file)
        for issue in anchor_issues:
            issue['file'] = rel_path
        issues.extend(anchor_issues)
        
        # 파일 링크 검증
        file_issues = validate_file_links_in_document(md_file)
        for issue in file_issues:
            issue['file'] = rel_path
        issues.extend(file_issues)
    
    return issues

def generate_report(issues, course_name):
    """검증 결과 보고서 생성"""
    if not issues:
        print(f"✅ {course_name}: 모든 링크가 정상입니다!")
        return
    
    print(f"\n📊 {course_name} 검증 결과:")
    print(f"총 {len(issues)}개의 문제 발견")
    
    # 문제 유형별 분류
    issues_by_type = {}
    for issue in issues:
        issue_type = issue['type']
        if issue_type not in issues_by_type:
            issues_by_type[issue_type] = []
        issues_by_type[issue_type].append(issue)
    
    # 각 유형별 상세 보고
    for issue_type, type_issues in issues_by_type.items():
        print(f"\n🔍 {issue_type} 문제 ({len(type_issues)}개):")
        
        for issue in type_issues[:10]:  # 최대 10개만 표시
            file_info = f" ({issue.get('file', '')})" if 'file' in issue else ""
            line_info = f" 라인 {issue['line']}" if issue['line'] > 0 else ""
            print(f"  - {issue['message']}{file_info}{line_info}")
            
            if 'available_headings' in issue:
                print(f"    사용 가능한 헤딩: {', '.join(issue['available_headings'][:5])}")
        
        if len(type_issues) > 10:
            print(f"  ... 및 {len(type_issues) - 10}개 더")

def main():
    parser = argparse.ArgumentParser(description='앵커 링크 전수 조사 도구')
    parser.add_argument('--course', choices=['cloud_basic', 'cloud_master', 'cloud_container', 'all'], 
                       default='all', help='검증할 과정 선택')
    parser.add_argument('--mode', choices=['top-down', 'bottom-up', 'both'], 
                       default='both', help='검증 모드 선택')
    parser.add_argument('--verbose', '-v', action='store_true', help='상세한 출력 표시')
    
    args = parser.parse_args()
    
    if args.course == 'all':
        courses = ['cloud_basic', 'cloud_master', 'cloud_container']
    else:
        courses = [args.course]
    
    print("🚀 앵커 링크 전수 조사 시작")
    print("=" * 60)
    
    total_issues = 0
    
    for course in courses:
        course_path = f"mcp_knowledge_base/{course}"
        
        if not os.path.exists(course_path):
            print(f"❌ 과정 디렉토리를 찾을 수 없습니다: {course_path}")
            continue
        
        print(f"\n📚 {course.upper()} 과정 검증")
        print("-" * 40)
        
        course_issues = []
        
        if args.mode in ['top-down', 'both']:
            top_down_issues = top_down_validation(course_path)
            course_issues.extend(top_down_issues)
        
        if args.mode in ['bottom-up', 'both']:
            bottom_up_issues = bottom_up_validation(course_path)
            course_issues.extend(bottom_up_issues)
        
        generate_report(course_issues, course)
        total_issues += len(course_issues)
    
    print(f"\n🎉 전체 검증 완료!")
    print(f"총 {total_issues}개의 문제 발견")
    
    if total_issues == 0:
        print("🎊 모든 링크가 완벽합니다!")
    else:
        print("⚠️  발견된 문제들을 수정해주세요.")

if __name__ == "__main__":
    main()