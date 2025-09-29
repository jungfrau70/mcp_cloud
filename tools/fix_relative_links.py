#!/usr/bin/env python3
"""
상대경로 링크를 절대경로로 변환하는 도구
./practice/file.md -> cloud_intermediate/textbook/Day1/practice/file.md
"""

import os
import re
import glob
from pathlib import Path

def find_markdown_files(directory):
    """마크다운 파일들을 재귀적으로 찾기"""
    pattern = os.path.join(directory, "**", "*.md")
    return glob.glob(pattern, recursive=True)

def convert_relative_to_absolute(content, file_path):
    """상대경로 링크를 절대경로로 변환"""
    # 파일의 디렉토리 경로 추출
    file_dir = os.path.dirname(file_path)
    
    # mcp_knowledge_base/ 제거
    if file_dir.startswith('mcp_knowledge_base/'):
        file_dir = file_dir[len('mcp_knowledge_base/'):]
    
    changes_made = []
    
    # 상대경로 링크 패턴들
    patterns = [
        # [텍스트](./파일) 형태
        (r'\[([^\]]+)\]\(\./([^)]+)\)', r'[\1](\2)'),
        # [텍스트](../파일) 형태  
        (r'\[([^\]]+)\]\(\.\./([^)]+)\)', r'[\1](\2)'),
    ]
    
    modified_content = content
    
    for pattern, replacement in patterns:
        matches = re.findall(pattern, modified_content)
        if matches:
            for match in matches:
                link_text = match[0]
                relative_path = match[1]
                
                # 상대경로를 절대경로로 변환
                if pattern.startswith(r'\[([^\]]+)\]\(\./'):
                    # ./파일 -> 현재 디렉토리/파일
                    absolute_path = f"{file_dir}/{relative_path}"
                else:
                    # ../파일 -> 상위 디렉토리/파일
                    parent_dir = os.path.dirname(file_dir)
                    absolute_path = f"{parent_dir}/{relative_path}"
                
                # 경로 정리 (중복 슬래시 제거)
                absolute_path = re.sub(r'/+', '/', absolute_path)
                
                # 원본 링크와 새 링크
                original_link = f'[{link_text}]({relative_path})'
                new_link = f'[{link_text}]({absolute_path})'
                
                # 링크 교체
                modified_content = modified_content.replace(original_link, new_link)
                
                changes_made.append({
                    'original': original_link,
                    'fixed': new_link
                })
    
    return modified_content, changes_made

def process_file(file_path):
    """단일 파일 처리"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        modified_content, changes = convert_relative_to_absolute(content, file_path)
        
        if changes:
            # 백업 파일 생성
            backup_path = file_path + '.backup'
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            # 수정된 내용 저장
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(modified_content)
            
            return {
                'file': file_path,
                'changes': changes,
                'backup': backup_path
            }
        else:
            return None
            
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return None

def main():
    """메인 실행 함수"""
    knowledge_base_dir = "mcp_knowledge_base"
    
    if not os.path.exists(knowledge_base_dir):
        print(f"Error: {knowledge_base_dir} directory not found")
        return
    
    print(f"🔍 {knowledge_base_dir} 디렉토리에서 상대경로 링크 검색 중...")
    
    markdown_files = find_markdown_files(knowledge_base_dir)
    print(f"📄 {len(markdown_files)}개의 마크다운 파일 발견")
    
    processed_files = []
    total_changes = 0
    
    for file_path in markdown_files:
        print(f"📝 처리 중: {file_path}")
        result = process_file(file_path)
        
        if result:
            processed_files.append(result)
            total_changes += len(result['changes'])
            print(f"  ✅ {len(result['changes'])}개 링크 수정됨")
        else:
            print(f"  ⏭️  수정할 링크 없음")
    
    # 결과 요약
    print(f"\n📊 수정 완료 요약:")
    print(f"  - 처리된 파일: {len(processed_files)}개")
    print(f"  - 총 수정된 링크: {total_changes}개")
    
    if processed_files:
        print(f"\n📋 수정된 파일 목록:")
        for result in processed_files:
            print(f"  - {result['file']}")
            print(f"    백업: {result['backup']}")
            for change in result['changes']:
                print(f"    {change['original']} → {change['fixed']}")
    
    # 수정 결과 보고서 생성
    report_content = f"""# 상대경로 링크 수정 보고서

## 수정 요약
- 처리된 파일: {len(processed_files)}개
- 총 수정된 링크: {total_changes}개
- 수정 시간: {os.popen('date').read().strip()}

## 수정된 파일 목록
"""
    
    for result in processed_files:
        report_content += f"\n### {result['file']}\n"
        report_content += f"- 백업 파일: {result['backup']}\n"
        report_content += f"- 수정된 링크 수: {len(result['changes'])}\n\n"
        
        for change in result['changes']:
            report_content += f"- `{change['original']}` → `{change['fixed']}`\n"
    
    with open("relative_links_fix_report.md", "w", encoding="utf-8") as f:
        f.write(report_content)
    
    print(f"\n📄 상세 보고서: relative_links_fix_report.md")

if __name__ == "__main__":
    main()

