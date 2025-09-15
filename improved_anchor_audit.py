#!/usr/bin/env python3
"""
개선된 앵커 링크 감사 도구
Permission denied 문제를 해결하고 더 정확한 검증을 수행합니다.
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
    file_link_pattern = re.compile(r'\[.*?\]\((?!https?://)(.*?)\)|<a\s+href="(?!https?://)(.*?)"')
    for match in file_link_pattern.finditer(content):
        link_path = match.group(1) or match.group(2)
        if link_path:
            # 앵커 부분 제거
            link_path = link_path.split('#')[0]
            links.append({'type': 'file', 'path': link_path, 'line': content.count('\n', 0, match.start()) + 1})

    # 앵커 링크 (Markdown: [text](#anchor), HTML: <a href="#anchor">)
    anchor_link_pattern = re.compile(r'\[.*?\]\((#.*?)\)|<a\s+href="(#.*?)"')
    for match in anchor_link_pattern.finditer(content):
        anchor = match.group(1) or match.group(2)
        if anchor:
            links.append({'type': 'anchor', 'anchor': anchor, 'line': content.count('\n', 0, match.start()) + 1})
    
    return links

def extract_anchors_from_markdown(content):
    """마크다운 내용에서 정의된 앵커(헤딩)를 추출합니다."""
    anchors = set()
    # Markdown headings: # H1, ## H2, etc.
    heading_pattern = re.compile(r'^(#+)\s*(.*)$', re.MULTILINE)
    for match in heading_pattern.finditer(content):
        heading_text = match.group(2).strip()
        # GitHub Flavored Markdown (GFM) anchor generation logic
        anchor = re.sub(r'[^\w\s-]', '', heading_text).strip().replace(' ', '-').lower()
        if anchor:
            anchors.add(f"#{anchor}")
    return anchors

def validate_file_link(base_file_path, link_path):
    """파일 링크의 유효성을 검사합니다."""
    if not link_path:
        return False, "링크 경로가 비어있습니다."
    
    # URL 디코딩 (한글 파일명 처리)
    decoded_link_path = unquote(link_path)

    # 절대 경로로 변환
    if link_path.startswith('/'):
        # 절대 경로 (프로젝트 루트 기준)
        abs_path = os.path.abspath(os.path.join('mcp_knowledge_base', link_path[1:]))
    else:
        # 상대 경로
        abs_path = os.path.abspath(os.path.join(os.path.dirname(base_file_path), decoded_link_path))
    
    # mcp_knowledge_base 디렉토리 내에 있는지 확인
    if not abs_path.startswith(os.path.abspath('mcp_knowledge_base')):
        # 외부 링크는 유효하다고 가정
        return True, "외부 링크"
    
    # 파일 존재 여부 확인
    if not os.path.exists(abs_path):
        return False, f"파일 '{decoded_link_path}'을 찾을 수 없음"
    
    return True, "유효한 파일"

def validate_anchor_link(content, anchor):
    """앵커 링크의 유효성을 검사합니다."""
    defined_anchors = extract_anchors_from_markdown(content)
    if anchor not in defined_anchors:
        return False, f"앵커 '{anchor}'를 찾을 수 없음"
    return True, "유효한 앵커"

def audit_file(file_path, course_base_path, mode):
    """단일 파일에 대해 링크 및 앵커를 감사합니다."""
    problems = []
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        problems.append({'type': 'error', 'description': f"파일 읽기 오류: {e}", 'file': file_path})
        return problems

    # Top-down: 파일 내 링크 검증
    if mode in ['top-down', 'both']:
        links = extract_links_from_markdown(content, file_path)
        for link in links:
            if link['type'] == 'file':
                is_valid, msg = validate_file_link(file_path, link['path'])
                if not is_valid:
                    problems.append({
                        'type': 'missing_file',
                        'description': f"파일 '{link['path']}'을 찾을 수 없음 ({os.path.basename(file_path)})",
                        'file': file_path,
                        'line': link['line']
                    })
            elif link['type'] == 'anchor':
                is_valid, msg = validate_anchor_link(content, link['anchor'])
                if not is_valid:
                    problems.append({
                        'type': 'missing_anchor',
                        'description': f"앵커 '{link['anchor']}'를 찾을 수 없음 ({os.path.basename(file_path)})",
                        'file': file_path,
                        'line': link['line']
                    })
    return problems

def audit_course(course_name, course_dir, mode):
    """단일 과정에 대해 전체 링크 및 앵커를 감사합니다."""
    print(f"----------------------------------------")
    print(f"🔍 {mode.capitalize()} 검증 시작: {course_dir}")

    all_problems = []
    
    # Top-down: 학습 경로에서 참조하는 파일 검증
    if mode in ['top-down', 'both']:
        learning_path_file = os.path.join(course_dir, 'learning-path.md')
        if os.path.exists(learning_path_file):
            try:
                with open(learning_path_file, 'r', encoding='utf-8') as f:
                    lp_content = f.read()
                lp_links = extract_links_from_markdown(lp_content, learning_path_file)
                file_links_in_lp = [link for link in lp_links if link['type'] == 'file']
                print(f"📊 학습 경로에서 {len(file_links_in_lp)}개의 파일 링크 발견")
                for link in file_links_in_lp:
                    is_valid, msg = validate_file_link(learning_path_file, link['path'])
                    if not is_valid:
                        all_problems.append({
                            'type': 'missing_file',
                            'description': f"학습 경로에서 참조하는 파일 '{link['path']}'을 찾을 수 없음",
                            'file': learning_path_file,
                            'line': link['line']
                        })
            except Exception as e:
                all_problems.append({'type': 'error', 'description': f"학습 경로 파일 읽기 오류: {e}", 'file': learning_path_file})
        else:
            all_problems.append({'type': 'error', 'description': f"학습 경로 파일 없음: {learning_path_file}", 'file': learning_path_file})

    # Bottom-up: 모든 마크다운 파일 내 링크 및 앵커 검증
    if mode in ['bottom-up', 'both']:
        md_files = get_all_markdown_files(course_dir)
        print(f"📊 {len(md_files)}개의 마크다운 파일 검사")
        for md_file in md_files:
            file_problems = audit_file(md_file, course_dir, mode)
            all_problems.extend(file_problems)
    
    return all_problems

def main():
    parser = argparse.ArgumentParser(description='개선된 마크다운 문서의 내부 링크 및 앵커 동작 전수 조사 도구')
    parser.add_argument('--course', choices=['cloud_basic', 'cloud_master', 'cloud_container', 'all'], required=True,
                        help='처리할 과정 (cloud_basic, cloud_master, cloud_container 또는 all)')
    parser.add_argument('--mode', choices=['top-down', 'bottom-up', 'both'], default='both',
                        help='검증 모드 (top-down: 학습 경로에서 파일 링크 검증, bottom-up: 모든 파일 내 링크/앵커 검증, both: 둘 다)')
    
    args = parser.parse_args()
    
    print(f"🚀 개선된 앵커 링크 전수 조사 시작")

    courses_to_process = []
    if args.course == 'all':
        courses_to_process = ['cloud_basic', 'cloud_master', 'cloud_container']
    else:
        courses_to_process = [args.course]

    total_problems_found = []

    for course_name in courses_to_process:
        print(f"============================================================")
        print(f"📚 {course_name.upper()} 과정 검증")
        
        course_directory = os.path.join('mcp_knowledge_base', course_name)
        
        problems = audit_course(course_name, course_directory, args.mode)
        total_problems_found.extend(problems)
        
        print(f"\n📊 {course_name} 검증 결과:")
        print(f"총 {len(problems)}개의 문제 발견")
        
        # 문제 유형별로 분류하여 출력
        problem_types = {}
        for p in problems:
            problem_types.setdefault(p['type'], []).append(p)
        
        for p_type, p_list in problem_types.items():
            print(f"\n🔍 {p_type} 문제 ({len(p_list)}개):")
            for p in p_list[:10]: # 처음 10개만 출력하여 요약
                line_info = f" 라인 {p['line']}" if 'line' in p else ""
                print(f"  - {p['description']}{line_info}")
            if len(p_list) > 10:
                print(f"  ... 및 {len(p_list) - 10}개 더")

    print(f"\n🎉 전체 검증 완료!")
    print(f"총 {len(total_problems_found)}개의 문제 발견")
    if total_problems_found:
        print(f"⚠️  발견된 문제들을 수정해주세요.")
    else:
        print(f"✅ 모든 링크 및 앵커가 유효합니다.")

if __name__ == "__main__":
    main()
