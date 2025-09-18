#!/usr/bin/env python3
"""
최종 종합 수정 도구
모든 링크 문제를 한 번에 해결
"""

import os
import re
import json
from pathlib import Path
from urllib.parse import quote, unquote
from typing import Dict, List, Set, Tuple

class FinalComprehensiveFixer:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.knowledge_base_path = self.base_path / "mcp_knowledge_base"
        self.fixed_files = 0
        self.fixed_links = 0
        self.file_map = {}  # 실제 파일 매핑
        self.broken_links = []  # 깨진 링크 목록
        
    def build_file_map(self):
        """실제 파일 매핑 테이블 구축"""
        print("🗂️ 실제 파일 매핑 테이블 구축 중...")
        
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                if file.endswith('.md') or file.endswith('.sh'):
                    file_path = Path(root) / file
                    relative_path = file_path.relative_to(self.knowledge_base_path)
                    
                    # 절대 경로로 매핑
                    abs_path = f"/mcp_knowledge_base/{relative_path.as_posix()}"
                    self.file_map[abs_path] = file_path
                    
                    # URL 인코딩된 경로도 매핑
                    encoded_path = f"/mcp_knowledge_base/{quote(str(relative_path), safe='/')}"
                    self.file_map[encoded_path] = file_path
                    
                    # 파일명으로도 매핑
                    if file not in self.file_map:
                        self.file_map[file] = []
                    self.file_map[file].append(abs_path)
        
        print(f"📁 {len(self.file_map)}개 파일 매핑 완료")
    
    def find_markdown_files(self) -> List[Path]:
        """모든 마크다운 파일 찾기"""
        md_files = []
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                if file.endswith('.md'):
                    md_files.append(Path(root) / file)
        return md_files
    
    def extract_links_from_content(self, content: str) -> List[Tuple[str, str, int]]:
        """문서에서 모든 링크 추출"""
        links = []
        lines = content.split('\n')
        
        for i, line in enumerate(lines):
            # 마크다운 링크 패턴
            link_pattern = r'\[([^\]]+)\]\(([^)]+)\)'
            for match in re.finditer(link_pattern, line):
                text = match.group(1)
                url = match.group(2)
                links.append((text, url, i+1))
        
        return links
    
    def is_internal_link(self, url: str) -> bool:
        """내부 링크인지 확인"""
        if url.startswith(('http://', 'https://', 'mailto:', 'tel:')):
            return False
        if url.startswith('#'):
            return False
        return True
    
    def normalize_path(self, path: str) -> str:
        """경로 정규화"""
        # 백슬래시를 슬래시로 변환
        path = path.replace('\\', '/')
        
        # 상대 경로를 절대 경로로 변환
        if not path.startswith('/'):
            path = '/' + path
        
        # mcp_knowledge_base 경로 정리
        if '/mcp_knowledge_base/' in path:
            # 중복된 mcp_knowledge_base 제거
            path = re.sub(r'/mcp_knowledge_base/.*?/mcp_knowledge_base/', '/mcp_knowledge_base/', path)
            # ../mcp_knowledge_base/ 패턴 제거
            path = re.sub(r'\.\./mcp_knowledge_base/', '/mcp_knowledge_base/', path)
        
        return path
    
    def find_alternative_file(self, broken_path: str) -> str:
        """깨진 링크의 대안 파일 찾기"""
        # URL 디코딩 시도
        try:
            decoded_path = unquote(broken_path)
            if decoded_path in self.file_map:
                return decoded_path
        except:
            pass
        
        # 파일명만 추출해서 검색
        filename = Path(broken_path).name
        if filename in self.file_map:
            return self.file_map[filename][0]
        
        # 유사한 파일명 검색
        for mapped_path in self.file_map:
            if filename in mapped_path:
                return mapped_path
        
        return None
    
    def fix_links_in_content(self, content: str) -> Tuple[str, int]:
        """콘텐츠의 링크 수정"""
        original_content = content
        fixes_count = 0
        
        # 모든 링크 추출
        links = self.extract_links_from_content(content)
        
        for text, url, line_num in links:
            if not self.is_internal_link(url):
                continue
            
            # 경로 정규화
            normalized_url = self.normalize_path(url)
            
            # 파일 존재 확인
            if normalized_url not in self.file_map:
                # 대안 파일 찾기
                alternative = self.find_alternative_file(normalized_url)
                if alternative:
                    # 링크 수정
                    old_link = f"[{text}]({url})"
                    new_link = f"[{text}]({alternative})"
                    content = content.replace(old_link, new_link)
                    fixes_count += 1
                    print(f"    🔧 링크 수정: {url} → {alternative}")
                else:
                    # 깨진 링크로 기록
                    self.broken_links.append({
                        "text": text,
                        "url": url,
                        "normalized_url": normalized_url,
                        "line": line_num
                    })
                    print(f"    ❌ 깨진 링크: {url}")
        
        return content, fixes_count
    
    def fix_file(self, file_path: Path) -> bool:
        """파일 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            content, fixes_count = self.fix_links_in_content(content)
            
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                self.fixed_files += 1
                self.fixed_links += fixes_count
                print(f"  ✅ {file_path.relative_to(self.base_path)}: {fixes_count}개 링크 수정")
                return True
            else:
                print(f"  ⏭️ {file_path.relative_to(self.base_path)}: 수정할 링크 없음")
                return False
                
        except Exception as e:
            print(f"  ❌ {file_path.relative_to(self.base_path)}: 오류 - {e}")
            return False
    
    def generate_broken_links_report(self):
        """깨진 링크 보고서 생성"""
        if not self.broken_links:
            return
        
        report = {
            "timestamp": "2025-09-18T21:10:00",
            "total_broken_links": len(self.broken_links),
            "broken_links": self.broken_links
        }
        
        with open("broken_links_report.json", "w", encoding="utf-8") as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        print(f"\n📋 깨진 링크 보고서 생성: broken_links_report.json")
    
    def run_comprehensive_fix(self):
        """종합 수정 실행"""
        print("🔧 최종 종합 링크 수정 시작...")
        print("=" * 60)
        
        # 파일 매핑 테이블 구축
        self.build_file_map()
        
        # 모든 마크다운 파일 수정
        md_files = self.find_markdown_files()
        print(f"📁 총 {len(md_files)}개 마크다운 파일 수정 중...")
        
        for file_path in md_files:
            print(f"📄 처리 중: {file_path.relative_to(self.base_path)}")
            self.fix_file(file_path)
        
        # 깨진 링크 보고서 생성
        self.generate_broken_links_report()
        
        print("\n" + "=" * 60)
        print("📊 최종 수정 완료!")
        print("=" * 60)
        print(f"📁 수정된 파일: {self.fixed_files}개")
        print(f"🔗 수정된 링크: {self.fixed_links}개")
        print(f"❌ 깨진 링크: {len(self.broken_links)}개")
        
        if self.fixed_files > 0:
            print("\n✅ 링크 수정이 완료되었습니다!")
        else:
            print("\n✅ 수정할 링크가 없습니다!")

def main():
    """메인 함수"""
    base_path = Path.cwd()
    fixer = FinalComprehensiveFixer(base_path)
    fixer.run_comprehensive_fix()

if __name__ == "__main__":
    main()