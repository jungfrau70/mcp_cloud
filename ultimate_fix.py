#!/usr/bin/env python3
"""
최종 완전한 링크 수정 스크립트 - 모든 상대 경로를 절대 경로로 변환
"""
import os
import re
from pathlib import Path

def fix_all_remaining_relative_links():
    """남은 모든 상대 경로 링크를 절대 경로로 변환"""
    root_dir = Path("mcp_knowledge_base")
    md_files = list(root_dir.rglob("*.md"))
    
    fixed_count = 0
    
    for file_path in md_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # 모든 상대 경로 패턴을 절대 경로로 변환
            patterns = [
                # ../README.md -> /mcp_knowledge_base/cloud_*/README.md
                (r'\[([^\]]+)\]\(\.\./README\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/README.md)'),
                (r'\[([^\]]+)\]\(\.\./learning-path\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/learning-path.md)'),
                (r'\[([^\]]+)\]\(\.\./curriculum\.md\)', r'[\1](/mcp_knowledge_base/curriculum.md)'),
                (r'\[([^\]]+)\]\(\.\./index\.md\)', r'[\1](/mcp_knowledge_base/index.md)'),
                
                # ../Day*/README.md -> /mcp_knowledge_base/cloud_*/textbook/Day*/README.md
                (r'\[([^\]]+)\]\(\.\./Day1/README\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)'),
                (r'\[([^\]]+)\]\(\.\./Day2/README\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/textbook/Day2/README.md)'),
                (r'\[([^\]]+)\]\(\.\./Day3/README\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/textbook/Day3/README.md)'),
                
                # ../Day*/README -> /mcp_knowledge_base/cloud_*/textbook/Day*/README.md
                (r'\[([^\]]+)\]\(\.\./Day1/README\)', r'[\1](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)'),
                (r'\[([^\]]+)\]\(\.\./Day2/README\)', r'[\1](/mcp_knowledge_base/cloud_master/textbook/Day2/README.md)'),
                (r'\[([^\]]+)\]\(\.\./Day3/README\)', r'[\1](/mcp_knowledge_base/cloud_master/textbook/Day3/README.md)'),
                
                # ../../cloud_*/... -> /mcp_knowledge_base/cloud_*/...
                (r'\[([^\]]+)\]\(\.\./\.\./cloud_basic/([^)]+)\)', r'[\1](/mcp_knowledge_base/cloud_basic/\2)'),
                (r'\[([^\]]+)\]\(\.\./\.\./cloud_container/([^)]+)\)', r'[\1](/mcp_knowledge_base/cloud_container/\2)'),
                (r'\[([^\]]+)\]\(\.\./\.\./cloud_master/([^)]+)\)', r'[\1](/mcp_knowledge_base/cloud_master/\2)'),
                
                # ../../../... -> /mcp_knowledge_base/...
                (r'\[([^\]]+)\]\(\.\./\.\./\.\./([^)]+)\)', r'[\1](/mcp_knowledge_base/\2)'),
                
                # ../../learning-path.md -> /mcp_knowledge_base/cloud_*/learning-path.md
                (r'\[([^\]]+)\]\(\.\./\.\./learning-path\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/learning-path.md)'),
                (r'\[([^\]]+)\]\(\.\./\.\./curriculum\.md\)', r'[\1](/mcp_knowledge_base/curriculum.md)'),
                (r'\[([^\]]+)\]\(\.\./\.\./index\.md\)', r'[\1](/mcp_knowledge_base/index.md)'),
                
                # ../../README.md -> /mcp_knowledge_base/cloud_*/README.md
                (r'\[([^\]]+)\]\(\.\./\.\./README\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/README.md)'),
                
                # ../../과정상세.md -> /mcp_knowledge_base/cloud_*/과정상세.md
                (r'\[([^\]]+)\]\(\.\./\.\./과정상세\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/과정상세.md)'),
                
                # ../cloud_*/... -> /mcp_knowledge_base/cloud_*/...
                (r'\[([^\]]+)\]\(\.\./cloud_master/([^)]+)\)', r'[\1](/mcp_knowledge_base/cloud_master/\2)'),
                (r'\[([^\]]+)\]\(\.\./cloud_container/([^)]+)\)', r'[\1](/mcp_knowledge_base/cloud_container/\2)'),
                (r'\[([^\]]+)\]\(\.\./cloud_basic/([^)]+)\)', r'[\1](/mcp_knowledge_base/cloud_basic/\2)'),
                
                # ../Day2/troubleshooting/... -> /mcp_knowledge_base/cloud_*/textbook/Day2/troubleshooting/...
                (r'\[([^\]]+)\]\(\.\./Day2/troubleshooting/([^)]+)\)', r'[\1](/mcp_knowledge_base/cloud_container/textbook/Day2/troubleshooting/\2)'),
                
                # ../integrated_automation/... -> /mcp_knowledge_base/integrated_automation/...
                (r'\[([^\]]+)\]\(\.\./integrated_automation/([^)]+)\)', r'[\1](/mcp_knowledge_base/integrated_automation/\2)'),
            ]
            
            for pattern, replacement in patterns:
                content = re.sub(pattern, replacement, content)
            
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"수정됨: {file_path}")
                fixed_count += 1
                
        except Exception as e:
            print(f"오류 발생: {file_path} - {e}")
    
    print(f"\n=== 최종 완전 수정 완료 ===")
    print(f"수정된 파일 수: {fixed_count}")

if __name__ == "__main__":
    fix_all_remaining_relative_links()
