#!/usr/bin/env python3
"""
최종 이모지 앵커 링크 수정 도구
VS Code 마크다운 미리보기에서 실제로 동작하는 #-텍스트 형식으로 수정합니다.
"""

import re
import os
from pathlib import Path

def generate_vscode_final_anchor_id(text):
    """VS Code 마크다운 미리보기 최종 앵커 ID 생성"""
    # 1. 앞뒤 공백 제거
    text = text.strip()
    
    # 2. 이모지 제거 (유니코드 범위 기반)
    emoji_pattern = re.compile(
        "["
        "\U0001F600-\U0001F64F"  # emoticons
        "\U0001F300-\U0001F5FF"  # symbols & pictographs
        "\U0001F680-\U0001F6FF"  # transport & map symbols
        "\U0001F1E0-\U0001F1FF"  # flags (iOS)
        "\U00002702-\U000027B0"
        "\U000024C2-\U0001F251"
        "]+", flags=re.UNICODE
    )
    text = emoji_pattern.sub(r'', text)
    
    # 3. 공백을 하이픈으로 변환
    text = re.sub(r'\s+', '-', text)
    
    # 4. 연속된 하이픈을 하나로 변환
    text = re.sub(r'-+', '-', text)
    
    # 5. 앞뒤 하이픈 제거
    text = text.strip('-')
    
    # 6. 소문자로 변환
    text = text.lower()
    
    # 7. 앞에 하이픈 추가 (VS Code 실제 동작)
    return f"-{text}"

def fix_emoji_anchor_links_final(content):
    """최종 이모지 포함 앵커 링크 수정"""
    # 헤딩 추출
    headings = []
    lines = content.split('\n')
    
    for line_num, line in enumerate(lines, 1):
        match = re.match(r'^(#{1,6})\s+(.+)$', line.strip())
        if match:
            level = len(match.group(1))
            title = match.group(2).strip()
            anchor_id = generate_vscode_final_anchor_id(title)
            headings.append({
                'line': line_num,
                'level': level,
                'title': title,
                'anchor_id': anchor_id
            })
    
    heading_anchors = {h['anchor_id'] for h in headings}
    
    # 앵커 링크 패턴 매칭 및 수정
    def replace_anchor_link(match):
        link_text = match.group(1)
        current_anchor = match.group(2)
        
        # VS Code 최종 이모지 포함 앵커 ID 생성
        correct_anchor = generate_vscode_final_anchor_id(link_text)
        
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
        fixed_content = fix_emoji_anchor_links_final(content)
        
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
