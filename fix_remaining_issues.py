#!/usr/bin/env python3
"""
남은 문제들 최종 해결 도구
"""

import os
import re
import glob
import datetime

def fix_remaining_anchors():
    """남은 앵커 문제들을 해결합니다."""
    print("🔧 남은 앵커 문제 해결")
    print("=" * 50)
    
    # 남은 앵커 문제들
    anchor_fixes = [
        {
            'file': 'mcp_knowledge_base/cloud_master/textbook/Day2/cloud-deployment-guide.md',
            'anchors': [
                '## ActionsDemo 프로젝트 소개'
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_master/textbook/Day1/troubleshooting-guide.md',
            'anchors': [
                '## GCP Cloud Run 관련 문제'
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_master/textbook/Day3/integration-guide.md',
            'anchors': [
                '## 자가 치유(Self-healing) 시스템'
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_container/textbook/Day1/practice/kubernetes-basics.md',
            'anchors': [
                '## Pod, Service, Deployment 실습',
                '## ConfigMap, Secret, PersistentVolume 관리'
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_container/textbook/Day2/monitoring-setup.md',
            'anchors': [
                '## 📈 Prometheus + Grafana 스택'
            ]
        }
    ]
    
    fixed_count = 0
    
    for fix_info in anchor_fixes:
        file_path = fix_info['file']
        if os.path.exists(file_path):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                original_content = content
                updated = False
                
                # 앵커가 이미 있는지 확인하고 없으면 추가
                for anchor in fix_info['anchors']:
                    if anchor not in content:
                        # 파일 끝에 앵커 추가
                        content += f'\n\n{anchor}\n'
                        updated = True
                        print(f"  ➕ {anchor} 추가")
                
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
                        f.write(content)
                    
                    print(f"✅ {file_path}: 앵커 추가 완료")
                    fixed_count += 1
                else:
                    print(f"📄 {file_path}: 앵커 이미 존재")
                    
            except Exception as e:
                print(f"❌ {file_path} 처리 중 오류: {e}")
        else:
            print(f"❌ {file_path}: 파일을 찾을 수 없음")
    
    print(f"\n🎉 남은 앵커 문제 해결 완료: {fixed_count}개 파일 수정")

def fix_empty_links_comprehensive():
    """빈 링크 문제를 포괄적으로 해결합니다."""
    print("\n🔧 빈 링크 문제 포괄적 해결")
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
            
            # 1. 빈 링크 패턴 찾기 및 수정
            # 패턴: [텍스트]() -> [텍스트](#텍스트)
            empty_link_pattern = r'\[([^\]]+)\]\(\s*\)'
            matches = re.findall(empty_link_pattern, content)
            
            if matches:
                for match in matches:
                    # 빈 링크를 앵커 링크로 변환
                    anchor_text = match.strip()
                    # 앵커 ID 생성 (이모지 제거, 소문자, 하이픈으로 변환)
                    anchor_id = re.sub(r'[^\w\s가-힣]', '', anchor_text)
                    anchor_id = re.sub(r'\s+', '-', anchor_id.strip()).lower()
                    anchor_id = f"#{anchor_id}"
                    
                    old_link = f"[{match}]()"
                    new_link = f"[{match}]({anchor_id})"
                    
                    content = content.replace(old_link, new_link)
                    updated = True
                    print(f"  🔗 {match} -> {anchor_id}")
            
            # 2. 잘못된 앵커 링크 수정
            # 패턴: [텍스트](#잘못된-앵커) -> [텍스트](#올바른-앵커)
            anchor_pattern = r'\[([^\]]+)\]\(#([^)]+)\)'
            def fix_anchor_link(match):
                link_text = match.group(1)
                old_anchor = match.group(2)
                
                # 현재 앵커 ID 생성
                current_anchor_id = re.sub(r'[^\w\s가-힣]', '', link_text)
                current_anchor_id = re.sub(r'\s+', '-', current_anchor_id.strip()).lower()
                
                return f"[{link_text}](#{current_anchor_id})"
            
            new_content = re.sub(anchor_pattern, fix_anchor_link, content)
            
            if new_content != content:
                content = new_content
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
                    f.write(content)
                
                print(f"✅ {file_path}: 빈 링크 수정 완료")
                fixed_count += 1
                
        except Exception as e:
            print(f"❌ {file_path} 처리 중 오류: {e}")
    
    print(f"\n🎉 빈 링크 문제 포괄적 해결 완료: {fixed_count}개 파일 수정")

def main():
    """메인 함수"""
    print("🚀 남은 문제들 최종 해결 시작")
    print("=" * 60)
    
    # 1. 남은 앵커 문제 해결
    fix_remaining_anchors()
    
    # 2. 빈 링크 문제 포괄적 해결
    fix_empty_links_comprehensive()
    
    print("\n🎊 모든 남은 문제 해결 완료!")

if __name__ == "__main__":
    main()
