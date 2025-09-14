#!/usr/bin/env python3
"""
최종 6개 문제 해결 도구
남은 문제들을 정확히 수정합니다.
"""

import os
import re
import json
from pathlib import Path

def fix_final_6_issues():
    """최종 6개 문제 해결"""
    
    print("🔧 최종 6개 문제 해결 시작")
    print("=" * 50)
    
    # 실제 헤딩을 확인하고 정확한 앵커 링크로 수정
    fixes = [
        {
            "file": "mcp_knowledge_base/cloud_container/textbook/Day1/practice/kubernetes-basics.md",
            "fixes": [
                {
                    "line": 23, 
                    "old": "pod-service-deployment-실습", 
                    "new": "📦-pod-service-deployment-실습",
                    "search_heading": "Pod, Service, Deployment"
                },
                {
                    "line": 24, 
                    "old": "configmap-secret-persistentvolume-관리", 
                    "new": "🔐-configmap-secret-persistentvolume-관리",
                    "search_heading": "ConfigMap, Secret, PersistentVolume"
                }
            ]
        },
        {
            "file": "mcp_knowledge_base/cloud_master/textbook/Day3/integration-guide.md",
            "fixes": [
                {
                    "line": 18, 
                    "old": "자가-치유-self-healing-시스템", 
                    "new": "자가-치유-self-healing-시스템",
                    "search_heading": "자가 치유(Self-Healing) 시스템"
                }
            ]
        },
        {
            "file": "mcp_knowledge_base/cloud_master/textbook/Day3/Day2_backup/README.md",
            "fixes": [
                {
                    "line": 15, 
                    "old": "docker-기초-및-컨테이너-기술", 
                    "new": "🐳-docker-기초-및-컨테이너-기술",
                    "search_heading": "Docker 기초 및 컨테이너 기술"
                },
                {
                    "line": 16, 
                    "old": "git-github-기초-및-협업", 
                    "new": "📝-git/github-기초-및-협업",
                    "search_heading": "Git/GitHub 기초 및 협업"
                },
                {
                    "line": 18, 
                    "old": "vm-기반-웹-애플리케이션-배포", 
                    "new": "🚀-vm-기반-웹-애플리케이션-배포",
                    "search_heading": "VM 기반 웹 애플리케이션 배포"
                }
            ]
        }
    ]
    
    total_fixes = 0
    
    for file_info in fixes:
        file_path = file_info["file"]
        file_fixes = file_info["fixes"]
        
        print(f"\n📄 {file_path} 수정 중...")
        
        if not os.path.exists(file_path):
            print(f"  ❌ 파일을 찾을 수 없음: {file_path}")
            continue
        
        # 파일 읽기
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        lines = content.split('\n')
        file_fixed = 0
        
        for fix in file_fixes:
            line_num = fix["line"]
            old_anchor = fix["old"]
            new_anchor = fix["new"]
            search_heading = fix["search_heading"]
            
            if line_num > len(lines):
                print(f"  ⚠️ 라인 {line_num}이 문서 길이를 초과함")
                continue
            
            # 실제 헤딩 찾기
            heading_found = False
            for i, line in enumerate(lines):
                if search_heading in line and line.strip().startswith('#'):
                    # 헤딩에서 정확한 앵커 ID 생성
                    heading_text = re.sub(r'^#{1,6}\s+', '', line).strip()
                    # 인라인 마크다운 정리
                    clean_heading = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', heading_text)
                    clean_heading = re.sub(r'[*_]{1,3}([^*_]+)[*_]{1,3}', r'\1', clean_heading)
                    clean_heading = re.sub(r'`([^`]+)`', r'\1', clean_heading)
                    clean_heading = re.sub(r'<[^>]+>', '', clean_heading)
                    clean_heading = clean_heading.strip()
                    
                    # 정확한 앵커 ID 생성
                    correct_anchor = normalize_anchor_id(clean_heading)
                    print(f"  🔍 헤딩 발견: {clean_heading}")
                    print(f"  🔍 생성된 앵커: {correct_anchor}")
                    
                    # 앵커 링크 수정
                    target_line = lines[line_num - 1]
                    if f"#{old_anchor}" in target_line:
                        new_line = target_line.replace(f"#{old_anchor}", f"#{correct_anchor}")
                        lines[line_num - 1] = new_line
                        print(f"  ✅ 라인 {line_num}: {old_anchor} → {correct_anchor}")
                        file_fixed += 1
                        heading_found = True
                        break
                    else:
                        print(f"  ⚠️ 라인 {line_num}에서 앵커 링크를 찾을 수 없음: {old_anchor}")
            
            if not heading_found:
                print(f"  ❌ 헤딩을 찾을 수 없음: {search_heading}")
        
        # 수정된 내용이 있으면 파일 저장
        if file_fixed > 0:
            new_content = '\n'.join(lines)
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            print(f"  📝 {file_fixed}개 앵커 링크 수정 완료")
            total_fixes += file_fixed
        else:
            print(f"  ❌ 수정할 내용이 없음")
    
    print(f"\n🎯 최종 수정 완료: 총 {total_fixes}개 앵커 링크 수정")

def normalize_anchor_id(text: str) -> str:
    """VS Code 마크다운 미리보기와 동일한 슬러그 생성"""
    import re
    return re.sub(r'^-+|-+$', '', 
           re.sub(r'-+', '-', 
           re.sub(r'\s+', '-', text.strip()))).lower()

if __name__ == "__main__":
    fix_final_6_issues()
