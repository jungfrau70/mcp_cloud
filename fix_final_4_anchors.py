#!/usr/bin/env python3
"""
마지막 4개 앵커 링크 문제 수정
"""

import re
from pathlib import Path

def fix_final_4_anchors():
    """마지막 4개 앵커 링크 문제 수정"""
    
    files_to_fix = [
        "mcp_knowledge_base/cloud_master/textbook/Day1/docker-basic-guide.md",
        "mcp_knowledge_base/cloud_master/textbook/Day3/cost-optimization-guide.md", 
        "mcp_knowledge_base/cloud_master/textbook/Day3/monitoring-setup-guide.md",
        "mcp_knowledge_base/cloud_master/textbook/Day3/cost-optimization/cost-optimization-guide.md"
    ]
    
    print("🔧 마지막 4개 앵커 링크 문제 수정 시작...\n")
    
    for file_path in files_to_fix:
        path = Path(file_path)
        
        if not path.exists():
            print(f"❌ 파일을 찾을 수 없습니다: {file_path}")
            continue
            
        print(f"📝 수정 중: {path.relative_to(Path('mcp_knowledge_base/cloud_master/textbook'))}")
        
        try:
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 제목에 앵커 링크 추가
            content = add_anchors_to_headings(content)
            
            # 파일 저장
            with open(path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"  ✅ 수정 완료")
                
        except Exception as e:
            print(f"  ❌ 파일 수정 오류: {e}")
    
    print(f"\n🎉 마지막 4개 파일 수정 완료!")

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
    fix_final_4_anchors()
