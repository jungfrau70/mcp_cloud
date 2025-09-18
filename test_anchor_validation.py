#!/usr/bin/env python3
"""
앵커 링크 검증 테스트
이모지 포함 앵커 링크가 올바르게 작동하는지 검증합니다.
"""

import re
from pathlib import Path

def generate_vscode_emoji_anchor_id(text):
    """VS Code 마크다운 미리보기와 동일한 이모지 포함 앵커 ID 생성"""
    text = text.strip()
    text = re.sub(r'\s+', '-', text)
    text = re.sub(r'-+', '-', text)
    text = text.strip('-')
    return text.lower()

def validate_anchors_in_file(file_path):
    """파일 내 앵커 링크 검증"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 헤딩 추출
        headings = []
        lines = content.split('\n')
        
        for line_num, line in enumerate(lines, 1):
            match = re.match(r'^(#{1,6})\s+(.+)$', line.strip())
            if match:
                level = len(match.group(1))
                title = match.group(2).strip()
                anchor_id = generate_vscode_emoji_anchor_id(title)
                headings.append({
                    'line': line_num,
                    'level': level,
                    'title': title,
                    'anchor_id': anchor_id
                })
        
        # 앵커 링크 추출
        anchor_links = []
        for line_num, line in enumerate(lines, 1):
            matches = re.finditer(r'\[([^\]]+)\]\(#([^)]+)\)', line)
            for match in matches:
                link_text = match.group(1)
                anchor = match.group(2)
                anchor_links.append({
                    'line': line_num,
                    'link_text': link_text,
                    'anchor': anchor
                })
        
        # 검증
        heading_anchors = {h['anchor_id'] for h in headings}
        valid_links = 0
        invalid_links = 0
        
        print(f"\n📁 파일: {file_path}")
        print("=" * 60)
        
        print("🔍 발견된 헤딩들:")
        for heading in headings:
            print(f"  라인 {heading['line']}: {heading['title']} → #{heading['anchor_id']}")
        
        print(f"\n🔗 발견된 앵커 링크들:")
        for link in anchor_links:
            if link['anchor'] in heading_anchors:
                print(f"  ✅ 라인 {link['line']}: [{link['link_text']}](#{link['anchor']})")
                valid_links += 1
            else:
                print(f"  ❌ 라인 {link['line']}: [{link['link_text']}](#{link['anchor']}) - 매칭되는 헤딩 없음")
                invalid_links += 1
        
        print(f"\n📊 검증 결과:")
        print(f"  총 헤딩: {len(headings)}개")
        print(f"  총 앵커 링크: {len(anchor_links)}개")
        print(f"  유효한 링크: {valid_links}개")
        print(f"  무효한 링크: {invalid_links}개")
        
        if invalid_links == 0:
            print("  🎉 모든 앵커 링크가 정상적으로 작동합니다!")
        else:
            print(f"  ⚠️ {invalid_links}개의 앵커 링크에 문제가 있습니다.")
        
        return invalid_links == 0
        
    except Exception as e:
        print(f"❌ 파일 처리 오류: {file_path} - {e}")
        return False

def main():
    """메인 함수"""
    print("🧪 앵커 링크 검증 테스트 시작")
    print("=" * 60)
    
    # 테스트할 파일들
    test_files = [
        "mcp_knowledge_base/cloud_master/textbook/Day3/README.md",
        "mcp_knowledge_base/cloud_master/textbook/Day2/README.md",
        "mcp_knowledge_base/cloud_master/textbook/Day1/README.md"
    ]
    
    total_files = 0
    valid_files = 0
    
    for file_path in test_files:
        if Path(file_path).exists():
            total_files += 1
            if validate_anchors_in_file(file_path):
                valid_files += 1
    
    print(f"\n🎯 전체 검증 결과:")
    print(f"  테스트 파일: {total_files}개")
    print(f"  정상 파일: {valid_files}개")
    print(f"  문제 파일: {total_files - valid_files}개")
    
    if valid_files == total_files:
        print("  🎉 모든 파일의 앵커 링크가 정상적으로 작동합니다!")
    else:
        print(f"  ⚠️ {total_files - valid_files}개 파일에 앵커 링크 문제가 있습니다.")

if __name__ == "__main__":
    main()
