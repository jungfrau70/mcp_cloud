#!/usr/bin/env python3
"""
Cloud Container textbook 디렉토리의 앵커 링크 문제 수정
"""

import re
from pathlib import Path

def fix_cloud_container_anchors():
    """Cloud Container textbook 디렉토리의 앵커 링크 문제 수정"""
    
    base_path = Path("mcp_knowledge_base/cloud_container/textbook")
    
    if not base_path.exists():
        print("❌ Cloud Container textbook 디렉토리를 찾을 수 없습니다.")
        return
    
    print("🔧 Cloud Container textbook 디렉토리 앵커 링크 수정 시작...\n")
    
    # 모든 마크다운 파일 찾기
    md_files = list(base_path.rglob("*.md"))
    
    print(f"📊 총 {len(md_files)}개의 마크다운 파일 발견\n")
    
    fixed_files = 0
    total_issues_fixed = 0
    
    for md_file in md_files:
        print(f"📝 수정 중: {md_file.relative_to(base_path)}")
        
        try:
            with open(md_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 파일 수정
            original_content = content
            content = fix_markdown_anchors(content)
            
            # 변경사항이 있으면 파일 저장
            if content != original_content:
                with open(md_file, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                # 수정된 문제 수 계산
                issues_before = count_issues(original_content)
                issues_after = count_issues(content)
                issues_fixed = issues_before - issues_after
                
                print(f"  ✅ {issues_fixed}개 문제 수정 완료")
                fixed_files += 1
                total_issues_fixed += issues_fixed
            else:
                print(f"  ✅ 문제 없음")
                
        except Exception as e:
            print(f"  ❌ 파일 수정 오류: {e}")
    
    print(f"\n🎉 수정 완료!")
    print(f"  - 수정된 파일 수: {fixed_files}")
    print(f"  - 총 수정된 문제 수: {total_issues_fixed}")

def fix_markdown_anchors(content):
    """마크다운 파일의 앵커 링크 수정"""
    
    # 1. 모든 제목에 앵커 링크 추가
    content = add_anchors_to_headings(content)
    
    # 2. 깨진 앵커 링크 수정
    content = fix_broken_anchors(content)
    
    return content

def add_anchors_to_headings(content):
    """모든 제목에 앵커 링크 추가"""
    
    # H2 이상의 제목에 앵커 링크 추가
    def add_anchor_to_heading(match):
        level = len(match.group(1))
        title = match.group(2).strip()
        
        if level >= 2:
            anchor = generate_anchor(title)
            # 이미 앵커 링크가 있는지 확인
            if f"#{anchor}" not in content:
                return f"{match.group(1)} {title}\n\n[{title}](#{anchor})"
        
        return match.group(0)
    
    # H2 이상의 제목에 앵커 링크 추가
    content = re.sub(r'^(#{2,6})\s+(.+)$', add_anchor_to_heading, content, flags=re.MULTILINE)
    
    return content

def fix_broken_anchors(content):
    """깨진 앵커 링크 수정"""
    
    # 모든 제목에서 앵커 생성
    headings = re.findall(r'^(#{1,6})\s+(.+)$', content, re.MULTILINE)
    valid_anchors = set()
    
    for level, title in headings:
        if level != '#':  # H1 제목 제외
            anchor = generate_anchor(title)
            valid_anchors.add(anchor)
    
    # 앵커 링크 검사 및 수정
    def fix_anchor_link(match):
        link_text = match.group(1)
        anchor = match.group(2)
        
        # 유효한 앵커인지 확인
        if anchor in valid_anchors:
            return match.group(0)  # 유효한 앵커는 그대로 유지
        
        # 가장 유사한 앵커 찾기
        best_match = find_best_anchor_match(anchor, valid_anchors)
        if best_match:
            return f"[{link_text}](#{best_match})"
        
        return match.group(0)  # 매치를 찾지 못하면 원본 유지
    
    # 앵커 링크 수정
    content = re.sub(r'\[([^\]]+)\]\(#([^)]+)\)', fix_anchor_link, content)
    
    return content

def find_best_anchor_match(target_anchor, valid_anchors):
    """가장 유사한 앵커 찾기"""
    
    # 정확한 매치
    if target_anchor in valid_anchors:
        return target_anchor
    
    # 부분 매치 (한글 제목용)
    for anchor in valid_anchors:
        if target_anchor in anchor or anchor in target_anchor:
            return anchor
    
    # 공백 제거 후 매치
    target_clean = target_anchor.replace(' ', '')
    for anchor in valid_anchors:
        anchor_clean = anchor.replace(' ', '')
        if target_clean in anchor_clean or anchor_clean in target_clean:
            return anchor
    
    return None

def count_issues(content):
    """파일의 문제 수 계산"""
    issues = 0
    
    # 제목 구조 검사
    headings = re.findall(r'^(#{1,6})\s+(.+)$', content, re.MULTILINE)
    
    for level, title in headings:
        if level == '#':  # H1 제목은 제외
            continue
            
        if re.search(r'[🎯📚🔧🚀🐳☸️🖥️💾🔐☁️🏗️📊🔄💰]', title):
            expected_anchor = generate_anchor(title)
            anchor_links = re.findall(r'\[([^\]]+)\]\(#([^)]+)\)', content)
            found_anchor = False
            
            for link_text, anchor in anchor_links:
                if anchor == expected_anchor:
                    found_anchor = True
                    break
            
            if not found_anchor:
                issues += 1
    
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
    fix_cloud_container_anchors()
