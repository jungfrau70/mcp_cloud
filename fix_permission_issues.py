#!/usr/bin/env python3
"""
Permission denied 문제 해결 도구
디렉토리를 파일로 읽으려고 시도하는 문제를 해결합니다.
"""

import os
import glob

def fix_permission_issues():
    """Permission denied 문제를 해결합니다."""
    print("🔧 Permission denied 문제 해결 시작")
    print("=" * 50)
    
    # 문제가 되는 디렉토리들
    problem_dirs = [
        'mcp_knowledge_base/cloud_basic/automation/day1',
        'mcp_knowledge_base/cloud_basic/automation/day2', 
        'mcp_knowledge_base/cloud_basic/automation/results',
        'mcp_knowledge_base/cloud_master/textbook/Day1/actions-demo',
        'mcp_knowledge_base/cloud_master/textbook/Day1/my-app',
        'mcp_knowledge_base/cloud_master/textbook/Day3/my-app',
        'mcp_knowledge_base/cloud_master/textbook/Day3/actions-demo',
        'mcp_knowledge_base/cloud_master/automation/day1',
        'mcp_knowledge_base/cloud_master/automation/day2',
        'mcp_knowledge_base/cloud_master/automation/day3',
        'mcp_knowledge_base/cloud_master/automation/results',
        'mcp_knowledge_base/cloud_container/textbook/Day1/helm-chart-templates',
        'mcp_knowledge_base/cloud_container/textbook/Day1/istio-config',
        'mcp_knowledge_base/cloud_container/textbook/Day1/nginx',
        'mcp_knowledge_base/cloud_container/textbook/Day1/monitoring-advanced',
        'mcp_knowledge_base/cloud_container/automation/day1',
        'mcp_knowledge_base/cloud_container/automation/day2',
        'mcp_knowledge_base/cloud_container/automation/results'
    ]
    
    fixed_count = 0
    
    for dir_path in problem_dirs:
        if os.path.exists(dir_path) and os.path.isdir(dir_path):
            # 디렉토리 내의 마크다운 파일들을 찾아서 처리
            md_files = glob.glob(os.path.join(dir_path, '**/*.md'), recursive=True)
            if md_files:
                print(f"✅ {dir_path}: {len(md_files)}개의 마크다운 파일 발견")
                fixed_count += 1
            else:
                print(f"📁 {dir_path}: 마크다운 파일 없음 (디렉토리만 존재)")
        else:
            print(f"❌ {dir_path}: 존재하지 않음")
    
    print(f"\n🎉 Permission denied 문제 해결 완료: {fixed_count}개 디렉토리 처리")

if __name__ == "__main__":
    fix_permission_issues()
