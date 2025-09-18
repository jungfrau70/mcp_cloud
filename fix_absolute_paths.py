#!/usr/bin/env python3
"""
mcp_knowledge_base 디렉토리 내 모든 마크다운 파일의 내부 링크를 
절대 경로(/mcp_knowledge_base/...)로 변환하는 스크립트
"""

import os
import re
import glob
from pathlib import Path
from typing import List, Tuple, Dict

class PathConverter:
    def __init__(self, base_dir: str = "mcp_knowledge_base"):
        self.base_dir = Path(base_dir)
        self.changes_made = []
        
    def find_all_md_files(self) -> List[Path]:
        """모든 마크다운 파일 찾기"""
        pattern = str(self.base_dir / "**" / "*.md")
        files = glob.glob(pattern, recursive=True)
        return [Path(f) for f in files]
    
    def analyze_links_in_file(self, file_path: Path) -> List[Dict]:
        """파일 내의 모든 링크 분석"""
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
            
            # 절대 경로가 아닌 링크들 찾기
            if self.needs_conversion(url):
                issues.append({
                    'file': file_path,
                    'line_start': content[:match.start()].count('\n') + 1,
                    'text': text,
                    'original_url': url,
                    'suggested_url': self.convert_to_absolute_path(url, file_path),
                    'full_match': match.group(0)
                })
        
        return issues
    
    def needs_conversion(self, url: str) -> bool:
        """변환이 필요한 링크인지 판단"""
        # 이미 절대 경로인 경우
        if url.startswith('/mcp_knowledge_base/'):
            return False
        
        # 외부 링크인 경우 (http, https, mailto 등)
        if url.startswith(('http://', 'https://', 'mailto:', 'ftp://')):
            return False
        
        # 앵커만 있는 경우
        if url.startswith('#'):
            return False
        
        # 상대 경로이거나 파일명만 있는 경우
        if url.endswith('.md') or url.startswith('./') or url.startswith('../') or '/' in url:
            return True
            
        return False
    
    def convert_to_absolute_path(self, url: str, current_file: Path) -> str:
        """상대 경로를 절대 경로로 변환"""
        # 현재 파일의 디렉토리
        current_dir = current_file.parent
        
        # 상대 경로 처리
        if url.startswith('./'):
            # 현재 디렉토리
            target_path = current_dir / url[2:]
        elif url.startswith('../'):
            # 상위 디렉토리
            target_path = current_dir / url
        else:
            # 파일명만 있는 경우 (같은 디렉토리)
            target_path = current_dir / url
        
        # 절대 경로로 변환
        try:
            resolved_path = target_path.resolve()
            # mcp_knowledge_base 기준으로 상대 경로 생성
            relative_to_base = resolved_path.relative_to(self.base_dir.resolve())
            return f"/mcp_knowledge_base/{relative_to_base.as_posix()}"
        except (ValueError, OSError):
            # 경로 해석 실패 시 원본 반환
            print(f"⚠️ 경로 변환 실패: {url} in {current_file}")
            return url
    
    def fix_links_in_file(self, file_path: Path, issues: List[Dict]) -> bool:
        """파일의 링크들을 수정"""
        if not issues:
            return False
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"❌ 파일 읽기 실패: {file_path} - {e}")
            return False
        
        # 변경사항 적용
        modified_content = content
        changes_count = 0
        
        for issue in issues:
            old_link = issue['full_match']
            new_link = f"[{issue['text']}]({issue['suggested_url']})"
            
            if old_link in modified_content:
                modified_content = modified_content.replace(old_link, new_link, 1)
                changes_count += 1
                print(f"✅ 수정: {issue['original_url']} → {issue['suggested_url']}")
        
        # 파일 저장
        if changes_count > 0:
            try:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(modified_content)
                print(f"💾 파일 저장: {file_path} ({changes_count}개 링크 수정)")
                return True
            except Exception as e:
                print(f"❌ 파일 저장 실패: {file_path} - {e}")
                return False
        
        return False
    
    def process_all_files(self) -> Dict:
        """모든 파일 처리"""
        md_files = self.find_all_md_files()
        print(f"📁 발견된 마크다운 파일: {len(md_files)}개")
        
        results = {
            'total_files': len(md_files),
            'files_with_issues': 0,
            'files_modified': 0,
            'total_issues': 0,
            'total_fixes': 0,
            'issues_by_file': {}
        }
        
        for file_path in md_files:
            print(f"\n📄 분석 중: {file_path}")
            issues = self.analyze_links_in_file(file_path)
            
            if issues:
                results['files_with_issues'] += 1
                results['total_issues'] += len(issues)
                results['issues_by_file'][str(file_path)] = issues
                
                print(f"⚠️ 발견된 문제: {len(issues)}개")
                for issue in issues:
                    print(f"   라인 {issue['line_start']}: {issue['original_url']}")
                
                # 수정 적용
                if self.fix_links_in_file(file_path, issues):
                    results['files_modified'] += 1
                    results['total_fixes'] += len(issues)
            else:
                print("✅ 문제 없음")
        
        return results
    
    def generate_report(self, results: Dict):
        """결과 보고서 생성"""
        print("\n" + "="*60)
        print("📊 처리 결과 요약")
        print("="*60)
        print(f"전체 파일 수: {results['total_files']}")
        print(f"문제가 있는 파일: {results['files_with_issues']}")
        print(f"수정된 파일: {results['files_modified']}")
        print(f"발견된 문제 수: {results['total_issues']}")
        print(f"수정된 문제 수: {results['total_fixes']}")
        
        if results['total_issues'] > 0:
            success_rate = (results['total_fixes'] / results['total_issues']) * 100
            print(f"수정 성공률: {success_rate:.1f}%")
        
        print("\n📋 파일별 상세 결과:")
        for file_path, issues in results['issues_by_file'].items():
            print(f"  {file_path}: {len(issues)}개 문제")

def main():
    print("🚀 절대 경로 변환 스크립트 시작")
    print("=" * 60)
    
    converter = PathConverter()
    results = converter.process_all_files()
    converter.generate_report(results)
    
    print("\n✨ 처리 완료!")

if __name__ == "__main__":
    main()
