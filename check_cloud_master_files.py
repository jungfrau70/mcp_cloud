#!/usr/bin/env python3
"""
Cloud Master textbook 디렉토리의 모든 마크다운 파일 검사
"""

import re
from pathlib import Path

def check_cloud_master_files():
    """Cloud Master textbook 디렉토리의 모든 마크다운 파일 검사"""
    
    base_path = Path("mcp_knowledge_base/cloud_master/textbook")
    
    if not base_path.exists():
        print("❌ Cloud Master textbook 디렉토리를 찾을 수 없습니다.")
        return
    
    print("🔍 Cloud Master textbook 디렉토리 검사 시작...\n")
    
    # 모든 마크다운 파일 찾기
    md_files = list(base_path.rglob("*.md"))
    
    print(f"📊 총 {len(md_files)}개의 마크다운 파일 발견\n")
    
    issues_found = []
    
    for md_file in md_files:
        print(f"📝 검사 중: {md_file.relative_to(base_path)}")
        
        try:
            with open(md_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 파일별 검사
            file_issues = check_markdown_file(content, md_file)
            
            if file_issues:
                issues_found.extend(file_issues)
                print(f"  ⚠️ {len(file_issues)}개 문제 발견")
            else:
                print(f"  ✅ 문제 없음")
                
        except Exception as e:
            print(f"  ❌ 파일 읽기 오류: {e}")
            issues_found.append({
                'file': str(md_file.relative_to(base_path)),
                'type': 'file_read_error',
                'message': str(e)
            })
    
    # 결과 요약
    print(f"\n📊 검사 결과 요약")
    print(f"  - 총 파일 수: {len(md_files)}")
    print(f"  - 문제가 있는 파일: {len(set(issue['file'] for issue in issues_found))}")
    print(f"  - 총 문제 수: {len(issues_found)}")
    
    if issues_found:
        print(f"\n⚠️ 발견된 문제들:")
        for issue in issues_found:
            print(f"  - {issue['file']}: {issue['type']} - {issue['message']}")
    else:
        print(f"\n🎉 모든 파일이 정상입니다!")

def check_markdown_file(content, file_path):
    """개별 마크다운 파일 검사"""
    issues = []
    
    # 1. 제목 구조 검사
    headings = re.findall(r'^(#{1,6})\s+(.+)$', content, re.MULTILINE)
    
    for level, title in headings:
        # H1 제목은 앵커 링크가 필요하지 않음
        if level == '#':
            continue
            
        # 이모지가 포함된 제목인지 확인
        if re.search(r'[🎯📚🔧🚀🐳☸️🖥️💾🔐☁️🏗️📊🔄💰]', title):
            # 앵커 링크 생성 규칙 확인
            expected_anchor = generate_anchor(title)
            
            # 실제 앵커 링크가 있는지 확인
            anchor_links = re.findall(r'\[([^\]]+)\]\(#([^)]+)\)', content)
            found_anchor = False
            
            for link_text, anchor in anchor_links:
                if anchor == expected_anchor:
                    found_anchor = True
                    break
            
            if not found_anchor:
                issues.append({
                    'file': str(file_path.relative_to(Path("mcp_knowledge_base/cloud_master/textbook"))),
                    'type': 'missing_anchor',
                    'message': f"제목 '{title}'에 대한 앵커 링크가 없습니다. 예상 앵커: #{expected_anchor}"
                })
    
    # 2. 앵커 링크 검사
    anchor_links = re.findall(r'\[([^\]]+)\]\(#([^)]+)\)', content)
    
    for link_text, anchor in anchor_links:
        # 해당 앵커에 맞는 제목이 있는지 확인
        found_heading = False
        for level, title in headings:
            expected_anchor = generate_anchor(title)
            if anchor == expected_anchor:
                found_heading = True
                break
        
        if not found_heading:
            issues.append({
                'file': str(file_path.relative_to(Path("mcp_knowledge_base/cloud_master/textbook"))),
                'type': 'broken_anchor',
                'message': f"앵커 링크 '#{anchor}'에 해당하는 제목을 찾을 수 없습니다."
            })
    
    # 3. 목차 구조 검사 (README.md 파일만)
    if file_path.name == 'README.md':
        if '<details>' in content and '<summary>📋 목차</summary>' in content:
            # 목차 섹션이 있는지 확인
            toc_section = re.search(r'<details>\s*<summary>📋 목차</summary>(.*?)</details>', content, re.DOTALL)
            if toc_section:
                toc_content = toc_section.group(1)
                # 목차의 앵커 링크들이 실제 제목과 일치하는지 확인
                toc_links = re.findall(r'\[([^\]]+)\]\(#([^)]+)\)', toc_content)
                
                for link_text, anchor in toc_links:
                    found_heading = False
                    for level, title in headings:
                        expected_anchor = generate_anchor(title)
                        if anchor == expected_anchor:
                            found_heading = True
                            break
                    
                    if not found_heading:
                        issues.append({
                            'file': str(file_path.relative_to(Path("mcp_knowledge_base/cloud_master/textbook"))),
                            'type': 'toc_broken_anchor',
                            'message': f"목차의 앵커 링크 '#{anchor}'에 해당하는 제목을 찾을 수 없습니다."
                        })
    
    return issues

def generate_anchor(title):
    """VS Code 마크다운 미리보기 표준에 맞는 앵커 생성"""
    # 1. 앞뒤 공백 제거
    title = title.strip()
    
    # 2. 이모지와 특수문자 제거 (VS Code는 이모지를 제거함)
    title = re.sub(r'[^\w\s가-힣]', '', title)
    
    # 3. 공백을 하이픈으로 변환
    title = re.sub(r'\s+', '-', title)
    
    # 4. 연속된 하이픈을 하나로 변환
    title = re.sub(r'-+', '-', title)
    
    # 5. 앞뒤 하이픈 제거
    title = title.strip('-')
    
    # 6. 소문자로 변환
    return title.lower()

if __name__ == "__main__":
    check_cloud_master_files()
