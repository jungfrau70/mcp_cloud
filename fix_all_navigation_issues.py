#!/usr/bin/env python3
"""
모든 네비게이션 링크 문제를 수정하는 스크립트
- 연속된 div 블록을 하나로 합치기
- 중복된 링크 제거
- 일관된 네비게이션 구조로 정리
"""

import os
import re
import json
from pathlib import Path

def fix_navigation_links(filepath):
    """개별 파일의 네비게이션 링크 문제를 수정"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # 1. 연속된 div align="center" 블록들을 찾아서 하나로 합치기
        # 더 정확한 패턴으로 연속된 div 블록 찾기
        consecutive_divs_pattern = re.compile(
            r'(<div align="center">\s*\[.*?\]\(.*?\)(?:\s*\|\s*\[.*?\]\(.*?\))*\s*</div>)\s*'
            r'(<div align="center">\s*\[.*?\]\(.*?\)(?:\s*\|\s*\[.*?\]\(.*?\))*\s*</div>)',
            re.DOTALL
        )
        
        # 연속된 div 블록들을 찾아서 하나로 합치기
        def merge_consecutive_divs(match):
            first_div = match.group(1)
            second_div = match.group(2)
            
            # 각 div에서 링크 추출
            first_links = re.findall(r'\[.*?\]\(.*?\)', first_div)
            second_links = re.findall(r'\[.*?\]\(.*?\)', second_div)
            
            # 링크를 합치고 중복 제거 (순서 유지)
            all_links = []
            seen_links = set()
            
            # 두 번째 div의 링크를 먼저 추가 (더 구체적인 링크가 있을 가능성)
            for link in second_links:
                if link not in seen_links:
                    all_links.append(link)
                    seen_links.add(link)
            
            # 첫 번째 div의 고유한 링크 추가
            for link in first_links:
                if link not in seen_links:
                    all_links.append(link)
                    seen_links.add(link)
            
            # 새로운 단일 div 블록 생성
            new_div = f'<div align="center">\n\n{" | ".join(all_links)}\n\n</div>'
            return new_div
        
        # 연속된 div 블록들을 하나로 합치기
        content = consecutive_divs_pattern.sub(merge_consecutive_divs, content)
        
        # 2. 단일 div 블록 내에서 중복된 링크 제거
        single_div_pattern = re.compile(
            r'(<div align="center">\s*)(.*?)(?=\s*</div>)',
            re.DOTALL
        )
        
        def remove_duplicates_in_div(match):
            prefix = match.group(1)
            links_text = match.group(2)
            
            # 링크 추출
            links = re.findall(r'\[.*?\]\(.*?\)', links_text)
            
            # 중복 제거 (순서 유지)
            unique_links = []
            seen = set()
            for link in links:
                if link not in seen:
                    unique_links.append(link)
                    seen.add(link)
            
            return prefix + ' | '.join(unique_links)
        
        content = single_div_pattern.sub(remove_duplicates_in_div, content)
        
        # 3. 3개 이상의 div 블록이 있는 경우 처리
        # 모든 div 블록을 찾아서 하나로 합치기
        all_divs_pattern = re.compile(r'<div align="center">.*?</div>', re.DOTALL)
        all_divs = all_divs_pattern.findall(content)
        
        if len(all_divs) > 1:
            # 모든 div에서 링크 추출
            all_links = []
            for div in all_divs:
                links = re.findall(r'\[.*?\]\(.*?\)', div)
                all_links.extend(links)
            
            # 중복 제거 (순서 유지)
            unique_links = []
            seen = set()
            for link in all_links:
                if link not in seen:
                    unique_links.append(link)
                    seen.add(link)
            
            # 모든 div 블록을 하나로 교체
            new_single_div = f'<div align="center">\n\n{" | ".join(unique_links)}\n\n</div>'
            content = all_divs_pattern.sub('', content)
            
            # 첫 번째 div 위치에 새로운 단일 div 삽입
            # 일반적으로 문서 상단에 위치하므로 첫 번째 div 위치를 찾아서 교체
            first_div_match = re.search(r'<div align="center">', content)
            if first_div_match:
                # 첫 번째 div 앞에 새로운 div 삽입
                content = content[:first_div_match.start()] + new_single_div + '\n\n' + content[first_div_match.start():]
            else:
                # div가 없다면 문서 시작 부분에 추가
                content = new_single_div + '\n\n' + content
        
        # 변경사항이 있으면 파일 저장
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        
        return False
        
    except Exception as e:
        print(f"❌ 오류 발생 {filepath}: {e}")
        return False

def process_all_files():
    """모든 마크다운 파일을 처리"""
    knowledge_base_path = 'mcp_knowledge_base'
    fixed_count = 0
    total_files = 0
    error_files = []
    
    print("🔧 모든 네비게이션 링크 문제 수정 시작...")
    print("=" * 60)
    
    for root, dirs, files in os.walk(knowledge_base_path):
        for file in files:
            if file.endswith('.md'):
                filepath = os.path.join(root, file)
                total_files += 1
                
                print(f"📝 처리 중: {filepath}")
                
                try:
                    if fix_navigation_links(filepath):
                        fixed_count += 1
                        print(f"  ✅ 수정 완료")
                    else:
                        print(f"  ⏭️  수정 불필요")
                except Exception as e:
                    error_files.append((filepath, str(e)))
                    print(f"  ❌ 오류: {e}")
    
    print("\n" + "=" * 60)
    print("🎉 수정 작업 완료!")
    print(f"📊 총 처리된 파일: {total_files}개")
    print(f"✅ 수정된 파일: {fixed_count}개")
    
    if error_files:
        print(f"❌ 오류 발생 파일: {len(error_files)}개")
        for filepath, error in error_files:
            print(f"  - {filepath}: {error}")
    
    return fixed_count, error_files

def verify_fixes():
    """수정 후 검증"""
    print("\n🔍 수정 결과 검증 중...")
    
    knowledge_base_path = 'mcp_knowledge_base'
    remaining_issues = []
    
    for root, dirs, files in os.walk(knowledge_base_path):
        for file in files:
            if file.endswith('.md'):
                filepath = os.path.join(root, file)
                
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    # div 개수 확인
                    div_count = len(re.findall(r'<div align="center">', content))
                    
                    if div_count > 1:
                        remaining_issues.append((filepath, div_count))
                        
                except Exception as e:
                    print(f"❌ 검증 오류 {filepath}: {e}")
    
    if remaining_issues:
        print(f"⚠️ 여전히 문제가 있는 파일 {len(remaining_issues)}개:")
        for filepath, count in remaining_issues:
            print(f"  - {filepath} ({count}개 div)")
    else:
        print("✅ 모든 파일이 정상입니다!")
    
    return remaining_issues

if __name__ == "__main__":
    # 1. 모든 파일 수정
    fixed_count, errors = process_all_files()
    
    # 2. 수정 결과 검증
    remaining_issues = verify_fixes()
    
    # 3. 최종 결과 출력
    print("\n" + "=" * 60)
    print("📋 최종 결과 요약")
    print("=" * 60)
    print(f"✅ 수정된 파일: {fixed_count}개")
    print(f"❌ 오류 발생: {len(errors)}개")
    print(f"⚠️ 남은 문제: {len(remaining_issues)}개")
    
    if remaining_issues:
        print("\n🔴 여전히 문제가 있는 파일들:")
        for filepath, count in remaining_issues:
            print(f"  - {filepath} ({count}개 div)")
