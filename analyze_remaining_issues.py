#!/usr/bin/env python3
"""
남은 15개 문제 분석 도구
문제 유형별로 분류하고 해결 방안을 제시합니다.
"""

import json
from collections import defaultdict

def analyze_remaining_issues():
    """남은 문제들 분석"""
    
    # 감사 보고서 로드
    with open("anchor_link_audit_report.json", 'r', encoding='utf-8') as f:
        report = json.load(f)
    
    issues_by_file = report['issues_by_file']
    
    print("🔍 남은 15개 문제 분석")
    print("=" * 50)
    
    # 문제 유형별 분류
    issue_types = defaultdict(list)
    
    for file_path, issues in issues_by_file.items():
        for issue in issues:
            href = issue['href']
            link_text = issue['link_text']
            
            # 문제 유형 분류
            if href.startswith('-'):
                issue_types['앞에_하이픈'].append(issue)
            elif '(' in href and ')' in href:
                issue_types['특수문자_괄호'].append(issue)
            elif 'self-healing' in href.lower():
                issue_types['영어_하이픈'].append(issue)
            elif 'cicd' in href.lower():
                issue_types['CI/CD_슬래시'].append(issue)
            elif 'gitgithub' in href.lower():
                issue_types['GitHub_슬래시'].append(issue)
            elif 'gcp-cloud-run' in href.lower():
                issue_types['GCP_하이픈'].append(issue)
            else:
                issue_types['기타'].append(issue)
    
    # 각 유형별 분석
    for issue_type, issues in issue_types.items():
        print(f"\n📊 {issue_type} ({len(issues)}개)")
        print("-" * 30)
        
        for issue in issues[:3]:  # 처음 3개만 표시
            print(f"  📄 {issue['file']}")
            print(f"     링크: {issue['link_text']}")
            print(f"     앵커: {issue['href']}")
            print(f"     사용 가능한 헤딩: {issue['available_headings'][:3]}")
            print()
        
        if len(issues) > 3:
            print(f"  ... 및 {len(issues) - 3}개 추가")
    
    # 해결 방안 제시
    print("\n🛠️ 해결 방안")
    print("=" * 50)
    
    for issue_type, issues in issue_types.items():
        if issue_type == '앞에_하이픈':
            print(f"1. {issue_type}: 앞에 하이픈 제거 로직 추가")
        elif issue_type == '특수문자_괄호':
            print(f"2. {issue_type}: 괄호 내 특수문자 처리 로직 추가")
        elif issue_type == '영어_하이픈':
            print(f"3. {issue_type}: 영어-하이픈 정규화 로직 추가")
        elif issue_type == 'CI/CD_슬래시':
            print(f"4. {issue_type}: CI/CD 슬래시 처리 로직 추가")
        elif issue_type == 'GitHub_슬래시':
            print(f"5. {issue_type}: GitHub 슬래시 처리 로직 추가")
        elif issue_type == 'GCP_하이픈':
            print(f"6. {issue_type}: GCP 하이픈 처리 로직 추가")
        else:
            print(f"7. {issue_type}: 일반적인 매칭 로직 개선")

if __name__ == "__main__":
    analyze_remaining_issues()
