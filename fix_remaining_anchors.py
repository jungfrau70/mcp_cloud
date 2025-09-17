#!/usr/bin/env python3
"""
남은 앵커 링크 문제들을 간단하게 수정
"""

import re
from pathlib import Path

def fix_remaining_anchors():
    """남은 앵커 링크 문제들을 수정"""
    
    base_path = Path("mcp_knowledge_base/cloud_master/textbook")
    
    if not base_path.exists():
        print("❌ Cloud Master textbook 디렉토리를 찾을 수 없습니다.")
        return
    
    print("🔧 남은 앵커 링크 문제 수정 시작...\n")
    
    # 모든 마크다운 파일 찾기
    md_files = list(base_path.rglob("*.md"))
    
    print(f"📊 총 {len(md_files)}개의 마크다운 파일 수정 중...\n")
    
    fixed_files = 0
    
    for md_file in md_files:
        print(f"📝 수정 중: {md_file.relative_to(base_path)}")
        
        try:
            with open(md_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # 1. 모든 제목에 앵커 링크 추가
            content = add_anchors_to_headings(content)
            
            # 2. 깨진 앵커 링크 수정
            content = fix_broken_anchors(content)
            
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
    
    # 모든 제목 추출
    headings = []
    for match in re.finditer(r'^(#{1,6})\s+(.+)$', content, re.MULTILINE):
        level = len(match.group(1))
        title = match.group(2).strip()
        headings.append((level, title))
    
    # 제목별 앵커 생성
    heading_anchors = {}
    for level, title in headings:
        anchor = generate_anchor(title)
        heading_anchors[title] = anchor
    
    # 앵커 링크 수정
    def replace_anchor(match):
        link_text = match.group(1)
        anchor = match.group(2)
        
        # 해당 앵커에 맞는 제목 찾기
        for title, title_anchor in heading_anchors.items():
            if anchor == title_anchor:
                return f"[{link_text}](#{anchor})"
        
        # 가장 유사한 제목 찾기
        best_match = find_best_heading_match(anchor, headings)
        if best_match:
            new_anchor = generate_anchor(best_match)
            return f"[{link_text}](#{new_anchor})"
        
        return match.group(0)  # 수정할 수 없으면 원본 유지
    
    # 앵커 링크 수정
    content = re.sub(r'\[([^\]]+)\]\(#([^)]+)\)', replace_anchor, content)
    
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
    fix_remaining_anchors()
