#!/usr/bin/env python3
"""
남은 앵커 링크 문제 수동 수정 도구
주요 문제들을 수동으로 수정합니다.
"""

import os
import re
import glob

def fix_curriculum_links():
    """curriculum.md 링크 수정"""
    print("🔧 curriculum.md 링크 수정 중...")
    
    # 모든 마크다운 파일에서 curriculum.md 링크 수정
    md_files = glob.glob("mcp_knowledge_base/**/*.md", recursive=True)
    
    for file_path in md_files:
        if '.backup' in file_path:
            continue
            
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # 상대 경로 수정
            content = re.sub(r'\.\./\.\./\.\./curriculum\.md', '../curriculum.md', content)
            content = re.sub(r'\.\./\.\./curriculum\.md', '../../curriculum.md', content)
            content = re.sub(r'\.\./curriculum\.md', '../../../curriculum.md', content)
            
            if content != original_content:
                # 백업 생성
                backup_path = file_path + '.backup'
                with open(backup_path, 'w', encoding='utf-8') as f:
                    f.write(original_content)
                
                # 수정된 내용 저장
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                print(f"✅ {file_path}: curriculum.md 링크 수정 완료")
                
        except Exception as e:
            print(f"❌ {file_path} 처리 중 오류: {e}")

def fix_index_links():
    """index.md 링크 수정"""
    print("🔧 index.md 링크 수정 중...")
    
    md_files = glob.glob("mcp_knowledge_base/**/*.md", recursive=True)
    
    for file_path in md_files:
        if '.backup' in file_path:
            continue
            
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # 상대 경로 수정
            content = re.sub(r'\.\./\.\./\.\./index\.md', '../index.md', content)
            content = re.sub(r'\.\./\.\./index\.md', '../../index.md', content)
            content = re.sub(r'\.\./index\.md', '../../../index.md', content)
            
            if content != original_content:
                # 백업 생성
                backup_path = file_path + '.backup'
                with open(backup_path, 'w', encoding='utf-8') as f:
                    f.write(original_content)
                
                # 수정된 내용 저장
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                print(f"✅ {file_path}: index.md 링크 수정 완료")
                
        except Exception as e:
            print(f"❌ {file_path} 처리 중 오류: {e}")

def fix_learning_path_links():
    """learning-path.md 링크 수정"""
    print("🔧 learning-path.md 링크 수정 중...")
    
    md_files = glob.glob("mcp_knowledge_base/**/*.md", recursive=True)
    
    for file_path in md_files:
        if '.backup' in file_path or 'learning-path.md' in file_path:
            continue
            
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # 상대 경로 수정
            content = re.sub(r'\.\./\.\./\.\./learning-path\.md', '../learning-path.md', content)
            content = re.sub(r'\.\./\.\./learning-path\.md', '../../learning-path.md', content)
            content = re.sub(r'\.\./learning-path\.md', '../../../learning-path.md', content)
            
            if content != original_content:
                # 백업 생성
                backup_path = file_path + '.backup'
                with open(backup_path, 'w', encoding='utf-8') as f:
                    f.write(original_content)
                
                # 수정된 내용 저장
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                print(f"✅ {file_path}: learning-path.md 링크 수정 완료")
                
        except Exception as e:
            print(f"❌ {file_path} 처리 중 오류: {e}")

def fix_readme_links():
    """README.md 링크 수정"""
    print("🔧 README.md 링크 수정 중...")
    
    md_files = glob.glob("mcp_knowledge_base/**/*.md", recursive=True)
    
    for file_path in md_files:
        if '.backup' in file_path:
            continue
            
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # 상대 경로 수정
            content = re.sub(r'\.\./\.\./README\.md', '../../README.md', content)
            content = re.sub(r'\.\./README\.md', '../../../README.md', content)
            
            if content != original_content:
                # 백업 생성
                backup_path = file_path + '.backup'
                with open(backup_path, 'w', encoding='utf-8') as f:
                    f.write(original_content)
                
                # 수정된 내용 저장
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                print(f"✅ {file_path}: README.md 링크 수정 완료")
                
        except Exception as e:
            print(f"❌ {file_path} 처리 중 오류: {e}")

def main():
    print("🔧 남은 앵커 링크 문제 수동 수정 시작")
    print("=" * 50)
    
    fix_curriculum_links()
    fix_index_links()
    fix_learning_path_links()
    fix_readme_links()
    
    print("\n🎉 수동 수정 완료!")

if __name__ == "__main__":
    main()