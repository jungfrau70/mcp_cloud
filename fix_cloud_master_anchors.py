#!/usr/bin/env python3
"""
Cloud Master textbook 디렉토리의 모든 앵커 링크 문제 자동 수정
"""

import re
from pathlib import Path

def fix_cloud_master_anchors():
    """Cloud Master textbook 디렉토리의 모든 앵커 링크 문제 수정"""
    
    base_path = Path("mcp_knowledge_base/cloud_master/textbook")
    
    if not base_path.exists():
        print("❌ Cloud Master textbook 디렉토리를 찾을 수 없습니다.")
        return
    
    print("🔧 Cloud Master textbook 디렉토리 앵커 링크 수정 시작...\n")
    
    # 모든 마크다운 파일 찾기
    md_files = list(base_path.rglob("*.md"))
    
    print(f"📊 총 {len(md_files)}개의 마크다운 파일 수정 중...\n")
    
    fixed_files = 0
    total_fixes = 0
    
    for md_file in md_files:
        print(f"📝 수정 중: {md_file.relative_to(base_path)}")
        
        try:
            with open(md_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 파일 수정
            original_content = content
            content = fix_markdown_anchors(content, md_file)
            
            if content != original_content:
                # 파일 저장
                with open(md_file, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                fixed_files += 1
                print(f"  ✅ 수정 완료")
            else:
                print(f"  ℹ️ 수정할 내용 없음")
                
        except Exception as e:
            print(f"  ❌ 파일 수정 오류: {e}")
    
    print(f"\n🎉 수정 완료!")
    print(f"  - 수정된 파일 수: {fixed_files}")
    print(f"  - 총 파일 수: {len(md_files)}")

def fix_markdown_anchors(content, file_path):
    """개별 마크다운 파일의 앵커 링크 수정"""
    
    # 1. 모든 제목 추출
    headings = []
    for match in re.finditer(r'^(#{1,6})\s+(.+)$', content, re.MULTILINE):
        level = len(match.group(1))
        title = match.group(2).strip()
        headings.append((level, title))
    
    # 2. 제목별 앵커 생성
    heading_anchors = {}
    for level, title in headings:
        anchor = generate_anchor(title)
        heading_anchors[title] = anchor
    
    # 3. 누락된 앵커 링크 추가
    # 각 제목에 대한 앵커 링크가 있는지 확인하고 없으면 추가
    for level, title in headings:
        if level >= 2:  # H2 이상만 처리
            anchor = heading_anchors[title]
            
            # 해당 앵커 링크가 이미 있는지 확인
            if f"#{anchor}" not in content:
                # 제목 바로 아래에 앵커 링크 추가
                title_pattern = f"^(#{level})\\s+{re.escape(title)}$"
                replacement = f"\\1 {title}\n\n[{title}](#{anchor})"
                content = re.sub(title_pattern, replacement, content, flags=re.MULTILINE)
    
    # 4. 깨진 앵커 링크 수정
    # 앵커 링크가 있지만 해당하는 제목이 없는 경우 수정
    anchor_links = re.findall(r'\[([^\]]+)\]\(#([^)]+)\)', content)
    
    for link_text, anchor in anchor_links:
        # 해당 앵커에 맞는 제목이 있는지 확인
        found_heading = False
        for title, title_anchor in heading_anchors.items():
            if anchor == title_anchor:
                found_heading = True
                break
        
        if not found_heading:
            # 가장 유사한 제목 찾기
            best_match = find_best_heading_match(anchor, headings)
            if best_match:
                new_anchor = generate_anchor(best_match)
                content = content.replace(f"#{anchor}", f"#{new_anchor}")
    
    # 5. 목차 섹션 수정 (README.md 파일만)
    if file_path.name == 'README.md':
        content = fix_toc_section(content, headings)
    
    return content

def fix_toc_section(content, headings):
    """목차 섹션의 앵커 링크 수정"""
    
    # 목차 섹션 찾기
    toc_match = re.search(r'<details>\s*<summary>📋 목차</summary>(.*?)</details>', content, re.DOTALL)
    
    if not toc_match:
        return content
    
    toc_content = toc_match.group(1)
    
    # 목차의 각 앵커 링크 수정
    def replace_toc_anchor(match):
        link_text = match.group(1)
        anchor = match.group(2)
        
        # 해당 앵커에 맞는 제목 찾기
        for level, title in headings:
            if generate_anchor(title) == anchor:
                return f"[{link_text}](#{anchor})"
        
        # 가장 유사한 제목 찾기
        best_match = find_best_heading_match(anchor, headings)
        if best_match:
            new_anchor = generate_anchor(best_match)
            return f"[{link_text}](#{new_anchor})"
        
        return match.group(0)  # 수정할 수 없으면 원본 유지
    
    # 목차의 앵커 링크 수정
    toc_content = re.sub(r'\[([^\]]+)\]\(#([^)]+)\)', replace_toc_anchor, toc_content)
    
    # 수정된 목차로 교체
    new_toc = f"<details>\n<summary>📋 목차</summary>{toc_content}\n</details>"
    content = re.sub(r'<details>\s*<summary>📋 목차</summary>.*?</details>', new_toc, content, flags=re.DOTALL)
    
    return content

def find_best_heading_match(anchor, headings):
    """앵커와 가장 유사한 제목 찾기"""
    
    # 정확한 매칭 먼저 시도
    for level, title in headings:
        if generate_anchor(title) == anchor:
            return title
    
    # 부분 매칭 시도
    anchor_words = set(anchor.split('-'))
    best_match = None
    best_score = 0
    
    for level, title in headings:
        title_anchor = generate_anchor(title)
        title_words = set(title_anchor.split('-'))
        
        # 공통 단어 수 계산
        common_words = anchor_words.intersection(title_words)
        score = len(common_words)
        
        if score > best_score:
            best_score = score
            best_match = title
    
    return best_match if best_score > 0 else None

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
    fix_cloud_master_anchors()
