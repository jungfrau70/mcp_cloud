#!/usr/bin/env python3
"""
내부 링크를 절대경로로 변경하는 스크립트
mcp_knowledge_base/ 접두사를 제거하여 절대경로로 변경
"""

import os
import re
import glob
from pathlib import Path
from typing import List, Tuple, Dict

class InternalLinkFixer:
    def __init__(self, knowledge_base_root: str = "mcp_knowledge_base"):
        self.knowledge_base_root = knowledge_base_root
        self.fixed_files = []
        self.total_replacements = 0
        
    def find_markdown_files(self) -> List[str]:
        """모든 마크다운 파일 찾기"""
        pattern = os.path.join(self.knowledge_base_root, "**", "*.md")
        return glob.glob(pattern, recursive=True)
    
    def fix_links_in_file(self, file_path: str) -> Tuple[int, List[str]]:
        """파일 내의 링크 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            replacements = []
            
            # 패턴 1: mcp_knowledge_base/로 시작하는 링크
            pattern1 = r'\[([^\]]+)\]\(mcp_knowledge_base/([^)]+)\)'
            matches1 = re.findall(pattern1, content)
            for match in matches1:
                old_link = f'[{match[0]}](mcp_knowledge_base/{match[1]})'
                new_link = f'[{match[0]}]({match[1]})'
                content = content.replace(old_link, new_link)
                replacements.append(f"패턴1: {old_link} → {new_link}")
            
            # 패턴 2: mcp_knowledge_base/로 시작하는 이미지 링크
            pattern2 = r'!\[([^\]]*)\]\(mcp_knowledge_base/([^)]+)\)'
            matches2 = re.findall(pattern2, content)
            for match in matches2:
                old_link = f'![{match[0]}](mcp_knowledge_base/{match[1]})'
                new_link = f'![{match[0]}]({match[1]})'
                content = content.replace(old_link, new_link)
                replacements.append(f"패턴2: {old_link} → {new_link}")
            
            # 패턴 3: mcp_knowledge_base/로 시작하는 단순 링크 (링크 텍스트 없음)
            pattern3 = r'\(mcp_knowledge_base/([^)]+)\)'
            matches3 = re.findall(pattern3, content)
            for match in matches3:
                old_link = f'(mcp_knowledge_base/{match})'
                new_link = f'({match})'
                content = content.replace(old_link, new_link)
                replacements.append(f"패턴3: {old_link} → {new_link}")
            
            # 패턴 4: mcp_knowledge_base/로 시작하는 앵커 링크
            pattern4 = r'\[([^\]]+)\]\(#mcp_knowledge_base/([^)]+)\)'
            matches4 = re.findall(pattern4, content)
            for match in matches4:
                old_link = f'[{match[0]}](#mcp_knowledge_base/{match[1]})'
                new_link = f'[{match[0]}](#{match[1]})'
                content = content.replace(old_link, new_link)
                replacements.append(f"패턴4: {old_link} → {new_link}")
            
            # 변경사항이 있으면 파일 저장
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                return len(replacements), replacements
            else:
                return 0, []
                
        except Exception as e:
            print(f"❌ 파일 처리 오류 {file_path}: {e}")
            return 0, []
    
    def fix_all_links(self) -> Dict[str, any]:
        """모든 파일의 링크 수정"""
        print("🔍 마크다운 파일 검색 중...")
        markdown_files = self.find_markdown_files()
        print(f"📁 총 {len(markdown_files)}개의 마크다운 파일 발견")
        
        results = {
            'total_files': len(markdown_files),
            'fixed_files': 0,
            'total_replacements': 0,
            'file_details': []
        }
        
        for file_path in markdown_files:
            print(f"🔧 처리 중: {file_path}")
            replacement_count, replacements = self.fix_links_in_file(file_path)
            
            if replacement_count > 0:
                results['fixed_files'] += 1
                results['total_replacements'] += replacement_count
                results['file_details'].append({
                    'file': file_path,
                    'replacements': replacement_count,
                    'details': replacements
                })
                print(f"  ✅ {replacement_count}개 링크 수정됨")
            else:
                print(f"  ⏭️  변경사항 없음")
        
        return results
    
    def generate_report(self, results: Dict[str, any]) -> str:
        """수정 결과 보고서 생성"""
        report = f"""
# 내부 링크 절대경로 변경 보고서

## 📊 전체 결과
- **처리된 파일**: {results['total_files']}개
- **수정된 파일**: {results['fixed_files']}개
- **총 수정된 링크**: {results['total_replacements']}개

## 📁 수정된 파일 상세
"""
        
        for detail in results['file_details']:
            report += f"\n### {detail['file']}\n"
            report += f"- **수정된 링크**: {detail['replacements']}개\n"
            for replacement in detail['details']:
                report += f"  - {replacement}\n"
        
        return report

def main():
    print("🚀 내부 링크 절대경로 변경 시작")
    print("=" * 50)
    
    fixer = InternalLinkFixer()
    results = fixer.fix_all_links()
    
    print("\n" + "=" * 50)
    print("📊 수정 완료!")
    print(f"✅ 수정된 파일: {results['fixed_files']}개")
    print(f"🔗 총 수정된 링크: {results['total_replacements']}개")
    
    # 보고서 생성
    report = fixer.generate_report(results)
    with open('internal_links_fix_report.md', 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"📄 상세 보고서: internal_links_fix_report.md")
    
    if results['total_replacements'] > 0:
        print("\n🎉 모든 내부 링크가 절대경로로 변경되었습니다!")
        print("   - mcp_knowledge_base/ 접두사가 제거되었습니다")
        print("   - 링크가 상대경로에서 절대경로로 변경되었습니다")
    else:
        print("\n✅ 변경할 링크가 없습니다. 모든 링크가 이미 올바른 형태입니다.")

if __name__ == "__main__":
    main()
