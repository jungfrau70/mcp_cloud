#!/usr/bin/env python3
"""
남은 13개 문제 수동 수정 도구
실제 헤딩을 확인하고 정확한 앵커 링크로 수정합니다.
"""

import os
import re
import json
from pathlib import Path

def fix_remaining_issues():
    """남은 문제들을 수동으로 수정"""
    
    print("🔧 남은 13개 문제 수동 수정 시작")
    print("=" * 50)
    
    # 수정할 파일들과 정확한 앵커 링크 매핑
    fixes = [
        {
            "file": "mcp_knowledge_base/cloud_basic/textbook/Day1/practice/aws_basic_practice.md",
            "fixes": [
                {"line": 21, "old": "1단계-aws-계정-생성-및-설정", "new": "🚀-1단계:-aws-계정-생성-및-설정"},
                {"line": 22, "old": "2단계-iam-사용자-및-권한-관리", "new": "👥-2단계:-iam-사용자-및-권한-관리"},
                {"line": 23, "old": "3단계-ec2-인스턴스-생성-및-관리", "new": "💻-3단계:-ec2-인스턴스-생성-및-관리"}
            ]
        },
        {
            "file": "mcp_knowledge_base/cloud_container/textbook/Day1/practice/kubernetes-basics.md",
            "fixes": [
                {"line": 23, "old": "-pod-service-deployment-실습", "new": "pod-service-deployment-실습"},
                {"line": 24, "old": "-configmap-secret-persistentvolume-관리", "new": "configmap-secret-persistentvolume-관리"}
            ]
        },
        {
            "file": "mcp_knowledge_base/cloud_master/textbook/Day1/github-actions-guide.md",
            "fixes": [
                {"line": 16, "old": "cicd-개념-이해", "new": "🔄-ci/cd-개념-이해"}
            ]
        },
        {
            "file": "mcp_knowledge_base/cloud_master/textbook/Day1/README.md",
            "fixes": [
                {"line": 18, "old": "gitgithub-기초-및-협업", "new": "📝-git/github-기초-및-협업"}
            ]
        },
        {
            "file": "mcp_knowledge_base/cloud_master/textbook/Day3/integration-guide.md",
            "fixes": [
                {"line": 18, "old": "자가-치유self-healing-시스템", "new": "자가-치유-self-healing-시스템"}
            ]
        },
        {
            "file": "mcp_knowledge_base/cloud_master/textbook/Day3/Day2_backup/github-actions-guide.md",
            "fixes": [
                {"line": 10, "old": "cicd-개념-이해", "new": "🔄-ci/cd-개념-이해"}
            ]
        },
        {
            "file": "mcp_knowledge_base/cloud_master/textbook/Day3/Day2_backup/README.md",
            "fixes": [
                {"line": 15, "old": "-docker-기초-및-컨테이너-기술", "new": "docker-기초-및-컨테이너-기술"},
                {"line": 16, "old": "-gitgithub-기초-및-협업", "new": "git-github-기초-및-협업"},
                {"line": 17, "old": "-github-actions-cicd-파이프라인", "new": "github-actions-ci/cd-파이프라인"},
                {"line": 18, "old": "-vm-기반-웹-애플리케이션-배포", "new": "vm-기반-웹-애플리케이션-배포"}
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
            
            if line_num > len(lines):
                print(f"  ⚠️ 라인 {line_num}이 문서 길이를 초과함")
                continue
            
            target_line = lines[line_num - 1]
            
            # 앵커 링크 수정
            if f"#{old_anchor}" in target_line:
                new_line = target_line.replace(f"#{old_anchor}", f"#{new_anchor}")
                lines[line_num - 1] = new_line
                print(f"  ✅ 라인 {line_num}: {old_anchor} → {new_anchor}")
                file_fixed += 1
            else:
                print(f"  ⚠️ 라인 {line_num}에서 앵커 링크를 찾을 수 없음: {old_anchor}")
        
        # 수정된 내용이 있으면 파일 저장
        if file_fixed > 0:
            new_content = '\n'.join(lines)
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            print(f"  📝 {file_fixed}개 앵커 링크 수정 완료")
            total_fixes += file_fixed
        else:
            print(f"  ❌ 수정할 내용이 없음")
    
    print(f"\n🎯 수정 완료: 총 {total_fixes}개 앵커 링크 수정")

if __name__ == "__main__":
    fix_remaining_issues()
