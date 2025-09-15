#!/usr/bin/env python3
"""
최종 앵커 링크 감사 도구
VS Code 마크다운 미리보기와 정확히 동일한 앵커 ID 생성
"""

import os
import re
import glob
import argparse
from urllib.parse import urlparse, unquote

def get_all_markdown_files(base_path):
    """지정된 경로에서 모든 마크다운 파일을 찾아 리스트로 반환합니다."""
    md_files = []
    for root, _, files in os.walk(base_path):
        for file in files:
            if file.endswith('.md') and \
               not file.startswith('.') and \
               'backup' not in root.lower() and \
               'backup' not in file.lower():
                full_path = os.path.join(root, file)
                # 파일인지 확인 (디렉토리가 아닌)
                if os.path.isfile(full_path):
                    md_files.append(full_path)
    return md_files

def extract_links_from_markdown(content, file_path):
    """마크다운 내용에서 파일 링크와 앵커 링크를 추출합니다."""
    links = []
    
    # 파일 링크 (Markdown: [text](path), HTML: <a href="path">)
    # 수정: 앵커 링크(#로 시작)와 빈 링크() 제외
    file_link_pattern = re.compile(r'\[.*?\]\((?!https?://|#)([^)]+)\)|<a\s+href="(?!https?://|#)([^"]+)"')
    for match in file_link_pattern.finditer(content):
        link_path = match.group(1) or match.group(2)
        if link_path and link_path.strip():  # 빈 문자열 제외
            # 앵커 부분 제거
            link_path = link_path.split('#')[0]
            links.append({'type': 'file', 'path': link_path, 'line': content.count('\n', 0, match.start()) + 1})

    # 앵커 링크 (Markdown: [text](#anchor), HTML: <a href="#anchor">)
    anchor_link_pattern = re.compile(r'\[.*?\]\(#(.*?)\)|<a\s+href="#(.*?)"')
    for match in anchor_link_pattern.finditer(content):
        anchor = match.group(1) or match.group(2)
        if anchor:
            links.append({'type': 'anchor', 'anchor': f"#{anchor}", 'line': content.count('\n', 0, match.start()) + 1})
    
    return links

def vscode_anchor_generation(text):
    """VS Code 마크다운 미리보기와 동일한 앵커 ID 생성"""
    # 1. 앞뒤 공백 제거
    text = text.strip()
    
    # 2. 이모지와 특수문자 제거 (VS Code는 이모지를 제거함)
    text = re.sub(r'[^\w\s가-힣]', '', text)
    
    # 3. 공백을 하이픈으로 변환
    text = re.sub(r'\s+', '-', text)
    
    # 4. 연속된 하이픈을 하나로 변환
    text = re.sub(r'-+', '-', text)
    
    # 5. 앞뒤 하이픈 제거
    text = text.strip('-')
    
    # 6. 소문자로 변환
    text = text.lower()
    
    return text

def extract_anchors_from_markdown(content):
    """마크다운 내용에서 정의된 앵커(헤딩)를 추출합니다."""
    anchors = set()
    
    # ATX 헤딩 (# ## ### #### ##### ######)
    for line in content.split('\n'):
        match = re.match(r'^(#{1,6})\s+(.+)$', line.strip())
        if match:
            heading_text = match.group(2).strip()
            # VS Code 마크다운 미리보기와 동일한 ID 생성
            anchor_id = vscode_anchor_generation(heading_text)
            anchors.add(f"#{anchor_id}")
    
    return anchors

def resolve_file_path(link_path, base_file_path):
    """상대 경로를 절대 경로로 변환합니다."""
    if not link_path:
        return None
    
    # 절대 경로인 경우
    if link_path.startswith('/'):
        return link_path[1:]  # 앞의 / 제거
    
    # 상대 경로인 경우
    base_dir = os.path.dirname(base_file_path)
    resolved_path = os.path.normpath(os.path.join(base_dir, link_path))
    
    # 상대 경로로 변환
    try:
        rel_path = os.path.relpath(resolved_path, 'mcp_knowledge_base')
        return rel_path.replace('\\', '/')
    except ValueError:
        return None

def validate_top_down_links(learning_path_file, course_directory):
    """Top-down 검증: 학습 경로에서 참조하는 파일들이 존재하는지 확인"""
    print(f"🔍 Top-down 검증: {learning_path_file}")
    
    issues = []
    
    if not os.path.exists(learning_path_file):
        print(f"❌ 학습 경로 파일을 찾을 수 없음: {learning_path_file}")
        return issues
    
    with open(learning_path_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    links = extract_links_from_markdown(content, learning_path_file)
    file_links = [link for link in links if link['type'] == 'file']
    
    print(f"📊 학습 경로에서 {len(file_links)}개의 파일 링크 발견")
    
    for link in file_links:
        link_path = link['path']
        line = link['line']
        
        if not link_path or not link_path.strip():
            issues.append({
                'type': 'missing_file',
                'file': link_path,
                'line': line,
                'message': f"빈 파일 경로"
            })
            continue
        
        resolved_path = resolve_file_path(link_path, learning_path_file)
        if not resolved_path:
            issues.append({
                'type': 'missing_file',
                'file': link_path,
                'line': line,
                'message': f"파일 경로 해석 실패"
            })
            continue
        
        full_path = os.path.join('mcp_knowledge_base', resolved_path)
        if not os.path.exists(full_path):
            issues.append({
                'type': 'missing_file',
                'file': link_path,
                'line': line,
                'message': f"파일 '{resolved_path}'을 찾을 수 없음"
            })
    
    return issues

def validate_bottom_up_coverage(learning_path_file, course_directory):
    """Bottom-up 검증: 실제 파일들이 학습 경로에 포함되어 있는지 확인"""
    print(f"🔍 Bottom-up 검증: {course_directory}")
    
    issues = []
    
    if not os.path.exists(learning_path_file):
        print(f"❌ 학습 경로 파일을 찾을 수 없음: {learning_path_file}")
        return issues
    
    with open(learning_path_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 학습 경로에서 참조하는 파일 목록
    links = extract_links_from_markdown(content, learning_path_file)
    referenced_files = set()
    
    for link in links:
        if link['type'] == 'file' and link['path'] and link['path'].strip():
            resolved_path = resolve_file_path(link['path'], learning_path_file)
            if resolved_path:
                referenced_files.add(resolved_path)
    
    # 실제 존재하는 파일 목록
    actual_files = set()
    for root, _, files in os.walk(course_directory):
        for file in files:
            if file.endswith('.md') and not file.endswith('.backup'):
                rel_path = os.path.relpath(os.path.join(root, file), course_directory)
                rel_path = rel_path.replace('\\', '/')
                actual_files.add(rel_path)
    
    # 누락된 파일 찾기
    missing_files = actual_files - referenced_files
    
    # 백업 파일과 README 파일 제외
    missing_files = {f for f in missing_files 
                    if not f.endswith('.backup') 
                    and not f.endswith('README.md')
                    and f != 'learning-path.md'
                    and 'backup' not in f.lower()
                    and 'Day2_backup' not in f}
    
    for missing_file in missing_files:
        issues.append({
            'type': 'missing_reference',
            'file': missing_file,
            'message': f"학습 경로에 포함되지 않은 파일: {missing_file}"
        })
    
    return issues

def validate_anchor_links_in_document(file_path):
    """개별 문서의 앵커 링크를 검증합니다."""
    issues = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        issues.append({
            'type': 'error',
            'file': file_path,
            'message': f"파일 읽기 오류: {e}"
        })
        return issues
    
    # 앵커 링크 추출
    links = extract_links_from_markdown(content, file_path)
    anchor_links = [link for link in links if link['type'] == 'anchor']
    
    # 정의된 앵커 추출 (VS Code 스타일)
    defined_anchors = extract_anchors_from_markdown(content)
    
    # 앵커 링크 검증
    for link in anchor_links:
        anchor = link['anchor']
        line = link['line']
        
        if anchor not in defined_anchors:
            issues.append({
                'type': 'missing_anchor',
                'file': file_path,
                'anchor': anchor,
                'line': line,
                'message': f"앵커 '{anchor}'를 찾을 수 없음"
            })
    
    return issues

def main():
    parser = argparse.ArgumentParser(description='최종 앵커 링크 전수 조사 도구')
    parser.add_argument('--course', choices=['cloud_basic', 'cloud_master', 'cloud_container', 'all'], required=True)
    parser.add_argument('--mode', choices=['top-down', 'bottom-up', 'both'], default='both')
    args = parser.parse_args()

    print("🚀 최종 앵커 링크 전수 조사 시작")
    print("=" * 60)

    courses_to_process = []
    if args.course == 'all':
        courses_to_process = ['cloud_basic', 'cloud_master', 'cloud_container']
    else:
        courses_to_process = [args.course]

    total_issues = []

    for course in courses_to_process:
        print(f"\n📚 {course.upper()} 과정 검증")
        print("-" * 40)
        
        course_dir = f"mcp_knowledge_base/{course}"
        learning_path_file = f"{course_dir}/learning-path.md"
        
        if args.mode in ['top-down', 'both']:
            print(f"🔍 Top-down 검증 시작: {course_dir}")
            top_down_issues = validate_top_down_links(learning_path_file, course_dir)
            total_issues.extend(top_down_issues)
        
        if args.mode in ['bottom-up', 'both']:
            print(f"🔍 Bottom-up 검증 시작: {course_dir}")
            bottom_up_issues = validate_bottom_up_coverage(learning_path_file, course_dir)
            total_issues.extend(bottom_up_issues)
        
        # 개별 문서 앵커 링크 검증
        md_files = get_all_markdown_files(course_dir)
        print(f"📊 {len(md_files)}개의 마크다운 파일 검사")
        
        for file_path in md_files:
            anchor_issues = validate_anchor_links_in_document(file_path)
            total_issues.extend(anchor_issues)
        
        # 과정별 결과 요약
        course_issues = [issue for issue in total_issues if course in issue.get('file', '')]
        print(f"\n📊 {course} 검증 결과:")
        print(f"총 {len(course_issues)}개의 문제 발견")
        
        # 문제 유형별 분류
        missing_file_issues = [issue for issue in course_issues if issue['type'] == 'missing_file']
        missing_anchor_issues = [issue for issue in course_issues if issue['type'] == 'missing_anchor']
        missing_reference_issues = [issue for issue in course_issues if issue['type'] == 'missing_reference']
        
        if missing_file_issues:
            print(f"\n🔍 missing_file 문제 ({len(missing_file_issues)}개):")
            for issue in missing_file_issues[:10]:  # 처음 10개만 표시
                print(f"  - {issue['message']} ({os.path.basename(issue.get('file', ''))}) 라인 {issue.get('line', 'N/A')}")
            if len(missing_file_issues) > 10:
                print(f"  ... 및 {len(missing_file_issues) - 10}개 더")
        
        if missing_anchor_issues:
            print(f"\n🔍 missing_anchor 문제 ({len(missing_anchor_issues)}개):")
            for issue in missing_anchor_issues:
                print(f"  - 앵커 '{issue['anchor']}'를 찾을 수 없음 ({os.path.basename(issue['file'])}) 라인 {issue['line']}")
        
        if missing_reference_issues:
            print(f"\n🔍 missing_reference 문제 ({len(missing_reference_issues)}개):")
            for issue in missing_reference_issues:
                print(f"  - {issue['message']}")

    print(f"\n🎉 전체 검증 완료!")
    print(f"총 {len(total_issues)}개의 문제 발견")
    if total_issues:
        print("⚠️  발견된 문제들을 수정해주세요.")
    else:
        print("✅ 모든 링크와 앵커가 정상입니다!")

if __name__ == "__main__":
    main()
