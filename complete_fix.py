#!/usr/bin/env python3
"""
완전한 링크 수정 스크립트 - 모든 상대 경로를 절대 경로로 변환
"""
import os
import re
from pathlib import Path

def fix_all_relative_links():
    """모든 상대 경로 링크를 절대 경로로 변환"""
    root_dir = Path("mcp_knowledge_base")
    md_files = list(root_dir.rglob("*.md"))
    
    fixed_count = 0
    
    for file_path in md_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # 상대 경로 패턴들을 절대 경로로 변환
            patterns = [
                # ../README.md -> /mcp_knowledge_base/.../README.md
                (r'\[([^\]]+)\]\(\.\./README\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/README.md)'),
                (r'\[([^\]]+)\]\(\.\./learning-path\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/learning-path.md)'),
                (r'\[([^\]]+)\]\(\.\./curriculum\.md\)', r'[\1](/mcp_knowledge_base/curriculum.md)'),
                (r'\[([^\]]+)\]\(\.\./index\.md\)', r'[\1](/mcp_knowledge_base/index.md)'),
                
                # ../Day2/README.md -> /mcp_knowledge_base/cloud_master/textbook/Day2/README.md
                (r'\[([^\]]+)\]\(\.\./Day2/README\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/textbook/Day2/README.md)'),
                (r'\[([^\]]+)\]\(\.\./Day3/README\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/textbook/Day3/README.md)'),
                (r'\[([^\]]+)\]\(\.\./Day1/README\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)'),
                
                # ../Day2/README -> /mcp_knowledge_base/cloud_master/textbook/Day2/README.md
                (r'\[([^\]]+)\]\(\.\./Day2/README\)', r'[\1](/mcp_knowledge_base/cloud_master/textbook/Day2/README.md)'),
                (r'\[([^\]]+)\]\(\.\./Day3/README\)', r'[\1](/mcp_knowledge_base/cloud_master/textbook/Day3/README.md)'),
                (r'\[([^\]]+)\]\(\.\./Day1/README\)', r'[\1](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)'),
                
                # ../../cloud_basic/... -> /mcp_knowledge_base/cloud_basic/...
                (r'\[([^\]]+)\]\(\.\./\.\./cloud_basic/([^)]+)\)', r'[\1](/mcp_knowledge_base/cloud_basic/\2)'),
                (r'\[([^\]]+)\]\(\.\./\.\./cloud_container/([^)]+)\)', r'[\1](/mcp_knowledge_base/cloud_container/\2)'),
                (r'\[([^\]]+)\]\(\.\./\.\./cloud_master/([^)]+)\)', r'[\1](/mcp_knowledge_base/cloud_master/\2)'),
                
                # ../../../... -> /mcp_knowledge_base/...
                (r'\[([^\]]+)\]\(\.\./\.\./\.\./([^)]+)\)', r'[\1](/mcp_knowledge_base/\2)'),
                
                # ../../learning-path.md -> /mcp_knowledge_base/cloud_master/learning-path.md
                (r'\[([^\]]+)\]\(\.\./\.\./learning-path\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/learning-path.md)'),
                (r'\[([^\]]+)\]\(\.\./\.\./curriculum\.md\)', r'[\1](/mcp_knowledge_base/curriculum.md)'),
                (r'\[([^\]]+)\]\(\.\./\.\./index\.md\)', r'[\1](/mcp_knowledge_base/index.md)'),
                
                # ../../README.md -> /mcp_knowledge_base/cloud_master/README.md
                (r'\[([^\]]+)\]\(\.\./\.\./README\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/README.md)'),
                
                # ../../과정상세.md -> /mcp_knowledge_base/cloud_master/과정상세.md
                (r'\[([^\]]+)\]\(\.\./\.\./과정상세\.md\)', r'[\1](/mcp_knowledge_base/cloud_master/과정상세.md)'),
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
    
    print(f"\n=== 수정 완료 ===")
    print(f"수정된 파일 수: {fixed_count}")

if __name__ == "__main__":
    fix_all_relative_links()
