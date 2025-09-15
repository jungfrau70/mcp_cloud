#!/usr/bin/env python3
"""
앵커 링크 매칭 문제 해결 도구
"""

import os
import re
import glob
import datetime

def normalize_anchor_id(text):
    """헤딩 텍스트를 앵커 ID로 변환"""
    # 이모지와 특수문자 제거
    text = re.sub(r'[^\w\s가-힣]', '', text)
    # 공백을 하이픈으로 변환
    text = re.sub(r'\s+', '-', text.strip())
    # 소문자로 변환
    return text.lower()

def fix_anchor_matching():
    """앵커 링크 매칭 문제를 해결합니다."""
    print("🔧 앵커 링크 매칭 문제 해결")
    print("=" * 50)
    
    # 모든 마크다운 파일 찾기
    base_path = 'mcp_knowledge_base'
    md_files = [f for f in glob.glob(os.path.join(base_path, '**/*.md'), recursive=True)
                if not f.endswith('.backup') and 'backup' not in f.lower()]
    
    print(f"📊 총 {len(md_files)}개의 마크다운 파일 처리")
    
    fixed_count = 0
    
    for file_path in md_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            updated = False
            
            # 1. 헤딩 추출
            headings = []
            for line in content.split('\n'):
                match = re.match(r'^(#{1,6})\s+(.+)$', line.strip())
                if match:
                    level = len(match.group(1))
                    text = match.group(2).strip()
                    anchor_id = normalize_anchor_id(text)
                    headings.append({
                        'level': level,
                        'text': text,
                        'anchor_id': anchor_id
                    })
            
            # 2. 앵커 링크 찾기 및 수정
            def replace_anchor_link(match):
                link_text = match.group(1)
                old_anchor = match.group(2)
                
                # 현재 앵커 ID 생성
                current_anchor_id = normalize_anchor_id(link_text)
                
                # 헤딩에서 매칭되는 앵커 찾기
                for heading in headings:
                    if heading['anchor_id'] == current_anchor_id:
                        return f"[{link_text}](#{heading['anchor_id']})"
                
                # 정확한 매칭이 없으면 현재 앵커 ID 사용
                return f"[{link_text}](#{current_anchor_id})"
            
            # 앵커 링크 패턴 찾기 및 수정
            anchor_pattern = r'\[([^\]]+)\]\(#([^)]+)\)'
            new_content = re.sub(anchor_pattern, replace_anchor_link, content)
            
            if new_content != content:
                updated = True
            
            # 3. 빈 링크 수정
            empty_link_pattern = r'\[([^\]]+)\]\(\s*\)'
            def replace_empty_link(match):
                link_text = match.group(1)
                anchor_id = normalize_anchor_id(link_text)
                return f"[{link_text}](#{anchor_id})"
            
            new_content = re.sub(empty_link_pattern, replace_empty_link, new_content)
            
            if new_content != content:
                updated = True
            
            if updated:
                # 백업 파일 생성
                backup_dir = os.path.join(os.path.dirname(file_path), 'backup')
                os.makedirs(backup_dir, exist_ok=True)
                timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                backup_file_path = os.path.join(backup_dir, f"{os.path.basename(file_path)}.backup.{timestamp}")
                with open(backup_file_path, 'w', encoding='utf-8') as f:
                    f.write(original_content)
                
                # 파일 업데이트
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                
                print(f"✅ {file_path}: 앵커 링크 매칭 수정 완료")
                fixed_count += 1
                
        except Exception as e:
            print(f"❌ {file_path} 처리 중 오류: {e}")
    
    print(f"\n🎉 앵커 링크 매칭 문제 해결 완료: {fixed_count}개 파일 수정")

def create_missing_anchors():
    """누락된 앵커들을 생성합니다."""
    print("\n🔧 누락된 앵커 생성")
    print("=" * 50)
    
    # 앵커가 필요한 파일들
    anchor_files = [
        {
            'file': 'mcp_knowledge_base/cloud_master/textbook/Day1/README.md',
            'anchors': [
                '## 📝 Git/GitHub 기초 및 협업'
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_master/textbook/Day3/integration-guide.md',
            'anchors': [
                '## 🔄 자가 치유(Self-healing) 시스템'
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_container/textbook/Day2/monitoring-setup.md',
            'anchors': [
                '## 📈 Prometheus + Grafana 스택'
            ]
        }
    ]
    
    created_count = 0
    
    for anchor_info in anchor_files:
        file_path = anchor_info['file']
        if os.path.exists(file_path):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # 앵커가 이미 있는지 확인
                needs_anchors = False
                for anchor in anchor_info['anchors']:
                    if anchor not in content:
                        needs_anchors = True
                        break
                
                if needs_anchors:
                    # 파일 끝에 앵커 추가
                    content += '\n\n' + '\n\n'.join(anchor_info['anchors']) + '\n'
                    
                    # 백업 파일 생성
                    backup_dir = os.path.join(os.path.dirname(file_path), 'backup')
                    os.makedirs(backup_dir, exist_ok=True)
                    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                    backup_file_path = os.path.join(backup_dir, f"{os.path.basename(file_path)}.backup.{timestamp}")
                    with open(backup_file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    
                    # 파일 업데이트
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    
                    print(f"✅ {file_path}: 누락된 앵커 생성 완료")
                    created_count += 1
                else:
                    print(f"📄 {file_path}: 앵커 이미 존재")
                    
            except Exception as e:
                print(f"❌ {file_path} 처리 중 오류: {e}")
        else:
            print(f"❌ {file_path}: 파일을 찾을 수 없음")
    
    print(f"\n🎉 누락된 앵커 생성 완료: {created_count}개 파일 수정")

def main():
    """메인 함수"""
    print("🚀 앵커 링크 매칭 문제 해결 시작")
    print("=" * 60)
    
    # 1. 앵커 링크 매칭 문제 해결
    fix_anchor_matching()
    
    # 2. 누락된 앵커 생성
    create_missing_anchors()
    
    print("\n🎊 모든 앵커 링크 매칭 문제 해결 완료!")

if __name__ == "__main__":
    main()
