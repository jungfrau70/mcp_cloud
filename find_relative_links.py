#!/usr/bin/env python3
"""
mcp_knowledge_base 디렉토리 내 모든 마크다운 파일에서 
상대 경로나 잘못된 경로를 찾는 스크립트
"""

import os
import re
import glob
from pathlib import Path
from typing import List, Dict

class RelativeLinkFinder:
    def __init__(self, base_dir: str = "mcp_knowledge_base"):
        self.base_dir = Path(base_dir)
        
    def find_all_md_files(self) -> List[Path]:
        """모든 마크다운 파일 찾기"""
        pattern = str(self.base_dir / "**" / "*.md")
        files = glob.glob(pattern, recursive=True)
        return [Path(f) for f in files]
    
    def find_relative_links_in_file(self, file_path: Path) -> List[Dict]:
        """파일 내의 상대 경로 링크 찾기"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"❌ 파일 읽기 실패: {file_path} - {e}")
            return []
        
        # 마크다운 링크 패턴 찾기: [텍스트](링크)
        link_pattern = r'\[([^\]]*)\]\(([^)]+)\)'
        matches = re.finditer(link_pattern, content)
        
        issues = []
        for match in matches:
            text = match.group(1)
            url = match.group(2)
            line_num = content[:match.start()].count('\n') + 1
            
            # 문제가 있는 링크 판단
            issue_type = self.classify_link_issue(url)
            if issue_type:
                issues.append({
                    'file': file_path,
                    'line': line_num,
                    'text': text,
                    'url': url,
                    'issue_type': issue_type,
                    'full_match': match.group(0)
                })
        
        return issues
    
    def classify_link_issue(self, url: str) -> str:
        """링크 문제 분류"""
        # 외부 링크는 문제 없음
        if url.startswith(('http://', 'https://', 'mailto:', 'ftp://')):
            return None
        
        # 앵커만 있는 경우는 문제 없음
        if url.startswith('#'):
            return None
        
        # 상대 경로 패턴들
        if url.startswith('./'):
            return "relative_current_dir"
        
        if url.startswith('../'):
            return "relative_parent_dir"
        
        # 절대 경로이지만 /mcp_knowledge_base로 시작하지 않는 경우
        if url.startswith('/') and not url.startswith('/mcp_knowledge_base/'):
            return "wrong_absolute_path"
        
        # 파일명만 있는 경우 (확장자가 .md인 경우)
        if url.endswith('.md') and '/' not in url:
            return "filename_only"
        
        # 이미 올바른 절대 경로
        if url.startswith('/mcp_knowledge_base/'):
            return None
        
        # 기타 의심스러운 패턴
        if url.endswith('.md') and not url.startswith('/mcp_knowledge_base/'):
            return "suspicious_md_link"
        
        return None
    
    def scan_all_files(self) -> Dict:
        """모든 파일 스캔"""
        md_files = self.find_all_md_files()
        print(f"📁 발견된 마크다운 파일: {len(md_files)}개")
        
        all_issues = []
        issue_counts = {
            'relative_current_dir': 0,
            'relative_parent_dir': 0,
            'wrong_absolute_path': 0,
            'filename_only': 0,
            'suspicious_md_link': 0
        }
        
        for file_path in md_files:
            issues = self.find_relative_links_in_file(file_path)
            if issues:
                all_issues.extend(issues)
                for issue in issues:
                    issue_counts[issue['issue_type']] += 1
        
        return {
            'total_files': len(md_files),
            'files_with_issues': len(set(issue['file'] for issue in all_issues)),
            'total_issues': len(all_issues),
            'issue_counts': issue_counts,
            'issues': all_issues
        }
    
    def print_report(self, results: Dict):
        """결과 보고서 출력"""
        print("\n" + "="*60)
        print("📊 상대 경로 링크 스캔 결과")
        print("="*60)
        print(f"전체 파일 수: {results['total_files']}")
        print(f"문제가 있는 파일: {results['files_with_issues']}")
        print(f"총 문제 수: {results['total_issues']}")
        
        print("\n📋 문제 유형별 통계:")
        for issue_type, count in results['issue_counts'].items():
            if count > 0:
                type_names = {
                    'relative_current_dir': '현재 디렉토리 상대 경로 (./)',
                    'relative_parent_dir': '상위 디렉토리 상대 경로 (../)',
                    'wrong_absolute_path': '잘못된 절대 경로',
                    'filename_only': '파일명만 있는 링크',
                    'suspicious_md_link': '의심스러운 .md 링크'
                }
                print(f"  {type_names[issue_type]}: {count}개")
        
        if results['total_issues'] > 0:
            print("\n📝 상세 문제 목록:")
            for issue in results['issues'][:20]:  # 최대 20개만 출력
                print(f"  📄 {issue['file']}")
                print(f"     라인 {issue['line']}: [{issue['text']}]({issue['url']})")
                print(f"     문제: {issue['issue_type']}")
                print()
            
            if len(results['issues']) > 20:
                print(f"  ... 및 {len(results['issues']) - 20}개 더")

def main():
    print("🔍 상대 경로 링크 스캐너 시작")
    print("=" * 60)
    
    finder = RelativeLinkFinder()
    results = finder.scan_all_files()
    finder.print_report(results)
    
    print("\n✨ 스캔 완료!")

if __name__ == "__main__":
    main()
