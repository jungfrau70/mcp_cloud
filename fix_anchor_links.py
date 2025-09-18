#!/usr/bin/env python3
"""
앵커 링크 자동 수정 도구
VS Code 마크다운 미리보기 표준에 맞춰 앵커 링크를 자동으로 수정합니다.
"""

import re
import os
from pathlib import Path

def generate_vscode_anchor_id(text):
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
    return text.lower()

def extract_headings(content):
    """마크다운에서 헤딩 추출"""
    headings = []
    lines = content.split('\n')
    
    for line_num, line in enumerate(lines, 1):
        # ATX 스타일 헤딩 매칭 (# ## ### 등)
        match = re.match(r'^(#{1,6})\s+(.+)$', line.strip())
        if match:
            level = len(match.group(1))
            title = match.group(2).strip()
            anchor_id = generate_vscode_anchor_id(title)
            headings.append({
                'line': line_num,
                'level': level,
                'title': title,
                'anchor_id': anchor_id
            })
    
    return headings

def fix_anchor_links(content):
    """앵커 링크 수정"""
    # 헤딩 추출
    headings = extract_headings(content)
    heading_anchors = {h['anchor_id'] for h in headings}
    
    # 앵커 링크 패턴 매칭 및 수정
    def replace_anchor_link(match):
        link_text = match.group(1)
        current_anchor = match.group(2)
        
        # VS Code 표준 앵커 ID 생성
        correct_anchor = generate_vscode_anchor_id(link_text)
        
        # 올바른 앵커 ID가 존재하는지 확인
        if correct_anchor in heading_anchors:
            return f'[{link_text}](#{correct_anchor})'
        else:
            # 부분 매칭 시도
            for heading in headings:
                if heading['anchor_id'] in current_anchor or current_anchor in heading['anchor_id']:
                    return f'[{link_text}](#{heading["anchor_id"]})'
            
            # 매칭되지 않으면 원래대로 유지
            return match.group(0)
    
    # 앵커 링크 패턴: [텍스트](#앵커)
    pattern = r'\[([^\]]+)\]\(#([^)]+)\)'
    content = re.sub(pattern, replace_anchor_link, content)
    
    return content

def process_file(file_path):
    """파일 처리"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 앵커 링크 수정
        fixed_content = fix_anchor_links(content)
        
        # 변경사항이 있으면 파일 저장
        if content != fixed_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(fixed_content)
            print(f"✅ 수정 완료: {file_path}")
            return True
        else:
            print(f"ℹ️  변경사항 없음: {file_path}")
            return False
            
    except Exception as e:
        print(f"❌ 오류 발생: {file_path} - {e}")
        return False

def main():
    """메인 함수"""
    # Cloud Master 디렉토리 처리
    cloud_master_dir = Path("mcp_knowledge_base/cloud_master")
    
    if not cloud_master_dir.exists():
        print("❌ Cloud Master 디렉토리를 찾을 수 없습니다.")
        return
    
    # 마크다운 파일 찾기
    md_files = list(cloud_master_dir.rglob("*.md"))
    
    print(f"🔍 {len(md_files)}개의 마크다운 파일을 찾았습니다.")
    
    fixed_count = 0
    for md_file in md_files:
        if process_file(md_file):
            fixed_count += 1
    
    print(f"\n🎉 완료! {fixed_count}개 파일이 수정되었습니다.")

if __name__ == "__main__":
    main()
