#!/usr/bin/env python3
"""
모든 마크다운 문서의 링크를 전수 조사하고 분석하는 스크립트
"""
import os
import re
import json
from pathlib import Path
from typing import Dict, List, Tuple, Set
from collections import defaultdict

class LinkAnalyzer:
    def __init__(self, root_dir: str = "mcp_knowledge_base"):
        self.root_dir = Path(root_dir)
        self.link_patterns = {
            'absolute_paths': [],      # /로 시작하는 절대 경로
            'relative_paths': [],      # 상대 경로 (../, ./, 또는 파일명만)
            'external_links': [],      # http://, https:// 외부 링크
            'anchor_links': [],        # #로 시작하는 앵커 링크
            'mdc_links': [],          # mdc:로 시작하는 링크
            'broken_links': []         # 깨진 링크
        }
        self.file_links = defaultdict(list)  # 파일별 링크 목록
        self.all_files = set()  # 모든 파일 경로
        
    def find_all_md_files(self) -> List[Path]:
        """모든 마크다운 파일 찾기"""
        md_files = []
        for file_path in self.root_dir.rglob("*.md"):
            md_files.append(file_path)
            # 상대 경로로 변환하여 저장
            rel_path = file_path.relative_to(self.root_dir)
            self.all_files.add(str(rel_path).replace('\\', '/'))
        return md_files
    
    def extract_links_from_content(self, content: str, file_path: Path) -> List[Dict]:
        """마크다운 내용에서 링크 추출"""
        links = []
        
        # 마크다운 링크 패턴: [text](url)
        markdown_links = re.findall(r'\[([^\]]+)\]\(([^)]+)\)', content)
        
        # HTML 링크 패턴: <a href="url">text</a>
        html_links = re.findall(r'<a[^>]+href=["\']([^"\']+)["\'][^>]*>([^<]+)</a>', content)
        
        # 모든 링크 수집
        for text, url in markdown_links:
            links.append({
                'type': 'markdown',
                'text': text,
                'url': url,
                'file': str(file_path.relative_to(self.root_dir)).replace('\\', '/'),
                'line': content[:content.find(f'[{text}]({url})')].count('\n') + 1
            })
        
        for url, text in html_links:
            links.append({
                'type': 'html',
                'text': text,
                'url': url,
                'file': str(file_path.relative_to(self.root_dir)).replace('\\', '/'),
                'line': content[:content.find(f'href="{url}"')].count('\n') + 1
            })
        
        return links
    
    def categorize_link(self, link: Dict) -> str:
        """링크를 카테고리별로 분류"""
        url = link['url']
        
        if url.startswith('#'):
            return 'anchor_links'
        elif url.startswith('http://') or url.startswith('https://'):
            return 'external_links'
        elif url.startswith('mdc:'):
            return 'mdc_links'
        elif url.startswith('/'):
            return 'absolute_paths'
        else:
            return 'relative_paths'
    
    def check_link_validity(self, link: Dict, current_file: Path) -> bool:
        """링크 유효성 검사"""
        url = link['url']
        
        if url.startswith('#') or url.startswith('http'):
            return True  # 앵커 링크와 외부 링크는 유효성 검사 생략
        
        if url.startswith('mdc:'):
            # mdc: 링크 처리
            mdc_path = url.replace('mdc:', '').replace('mcp_knowledge_base/', '')
            return mdc_path in self.all_files
        
        if url.startswith('/'):
            # 절대 경로 처리
            abs_path = url.lstrip('/')
            return abs_path in self.all_files
        
        # 상대 경로 처리
        current_dir = current_file.parent
        target_path = current_dir / url
        rel_path = target_path.relative_to(self.root_dir)
        return str(rel_path).replace('\\', '/') in self.all_files
    
    def analyze_all_files(self):
        """모든 파일 분석"""
        md_files = self.find_all_md_files()
        print(f"총 {len(md_files)}개의 마크다운 파일을 분석합니다...")
        
        for file_path in md_files:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                links = self.extract_links_from_content(content, file_path)
                self.file_links[str(file_path.relative_to(self.root_dir)).replace('\\', '/')] = links
                
                for link in links:
                    category = self.categorize_link(link)
                    self.link_patterns[category].append(link)
                    
                    # 링크 유효성 검사
                    if not self.check_link_validity(link, file_path):
                        self.link_patterns['broken_links'].append(link)
                        
            except Exception as e:
                print(f"파일 분석 중 오류 발생: {file_path} - {e}")
    
    def generate_report(self) -> Dict:
        """분석 보고서 생성"""
        report = {
            'summary': {
                'total_files': len(self.file_links),
                'total_links': sum(len(links) for links in self.file_links.values()),
                'absolute_paths': len(self.link_patterns['absolute_paths']),
                'relative_paths': len(self.link_patterns['relative_paths']),
                'external_links': len(self.link_patterns['external_links']),
                'anchor_links': len(self.link_patterns['anchor_links']),
                'mdc_links': len(self.link_patterns['mdc_links']),
                'broken_links': len(self.link_patterns['broken_links'])
            },
            'patterns': self.link_patterns,
            'file_links': dict(self.file_links)
        }
        return report
    
    def print_summary(self):
        """요약 정보 출력"""
        print("\n=== 링크 분석 결과 ===")
        print(f"총 파일 수: {len(self.file_links)}")
        print(f"총 링크 수: {sum(len(links) for links in self.file_links.values())}")
        print(f"절대 경로 링크: {len(self.link_patterns['absolute_paths'])}")
        print(f"상대 경로 링크: {len(self.link_patterns['relative_paths'])}")
        print(f"외부 링크: {len(self.link_patterns['external_links'])}")
        print(f"앵커 링크: {len(self.link_patterns['anchor_links'])}")
        print(f"MDC 링크: {len(self.link_patterns['mdc_links'])}")
        print(f"깨진 링크: {len(self.link_patterns['broken_links'])}")
        
        if self.link_patterns['broken_links']:
            print("\n=== 깨진 링크 목록 ===")
            for link in self.link_patterns['broken_links']:
                print(f"파일: {link['file']}:{link['line']}")
                print(f"  링크: [{link['text']}]({link['url']})")
                print()

def main():
    analyzer = LinkAnalyzer()
    analyzer.analyze_all_files()
    analyzer.print_summary()
    
    # 상세 보고서를 JSON 파일로 저장
    report = analyzer.generate_report()
    with open('link_analysis_report.json', 'w', encoding='utf-8') as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    
    print(f"\n상세 보고서가 'link_analysis_report.json'에 저장되었습니다.")

if __name__ == "__main__":
    main()
