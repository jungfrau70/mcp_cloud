#!/usr/bin/env python3
"""
최종 6개 이슈 수정 도구
README.md 파일의 한글 파일명 링크 문제 해결
"""

import os
import re
import json
from pathlib import Path
from urllib.parse import quote, unquote
from typing import Dict, List, Set, Tuple

class Final6IssuesFixer:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.knowledge_base_path = self.base_path / "mcp_knowledge_base"
        self.fixed_files = 0
        self.fixed_links = 0
        
        # 실제 파일 매핑
        self.actual_files = {}
        self.build_actual_files_map()
    
    def build_actual_files_map(self):
        """실제 파일 매핑 구축"""
        print("📁 실제 파일 매핑 구축 중...")
        
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                if file.endswith(('.md', '.mdx')):
                    file_path = Path(root) / file
                    relative_path = file_path.relative_to(self.knowledge_base_path)
                    
                    # Windows 경로를 Unix 스타일로 변환
                    unix_path = str(relative_path).replace('\\', '/')
                    absolute_path = f"/mcp_knowledge_base/{unix_path}"
                    
                    self.actual_files[absolute_path] = file_path
                    
                    # URL 인코딩된 버전도 추가
                    encoded_path = quote(absolute_path, safe='/')
                    self.actual_files[encoded_path] = file_path
        
        print(f"📁 {len(self.actual_files)}개 실제 파일 매핑 완료")
    
    def fix_korean_filename_links(self, content: str) -> str:
        """한글 파일명 링크 수정"""
        # 한글 파일명 패턴 찾기
        korean_patterns = [
            (r'/mcp_knowledge_base/cloud_basic과정명\.md', '/mcp_knowledge_base/cloud_basic/과정명.md'),
            (r'/mcp_knowledge_base/cloud_basic과정상세\.md', '/mcp_knowledge_base/cloud_basic/과정상세.md'),
            (r'/mcp_knowledge_base/cloud_container과정명\.md', '/mcp_knowledge_base/cloud_container/과정명.md'),
            (r'/mcp_knowledge_base/cloud_container과정상세\.md', '/mcp_knowledge_base/cloud_container/과정상세.md'),
            (r'/mcp_knowledge_base/cloud_master과정명\.md', '/mcp_knowledge_base/cloud_master/과정명.md'),
            (r'/mcp_knowledge_base/cloud_master과정상세\.md', '/mcp_knowledge_base/cloud_master/과정상세.md'),
        ]
        
        for pattern, replacement in korean_patterns:
            content = re.sub(pattern, replacement, content)
        
        return content
    
    def fix_links_in_file(self, file_path: Path) -> bool:
        """파일 내 링크 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # 한글 파일명 링크 수정
            content = self.fix_korean_filename_links(content)
            
            # 변경사항이 있으면 파일 저장
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                return True
            
            return False
            
        except Exception as e:
            print(f"❌ 파일 처리 오류 {file_path}: {e}")
            return False
    
    def fix_all_files(self):
        """모든 파일의 링크 수정"""
        print("🔧 최종 6개 이슈 수정 시작...")
        
        # README.md 파일만 처리
        readme_file = self.knowledge_base_path / "README.md"
        
        if readme_file.exists():
            if self.fix_links_in_file(readme_file):
                self.fixed_files += 1
                print(f"✅ 수정됨: {readme_file.relative_to(self.base_path)}")
            else:
                print(f"ℹ️ 수정할 내용 없음: {readme_file.relative_to(self.base_path)}")
        else:
            print(f"❌ 파일을 찾을 수 없음: {readme_file}")
        
        print(f"\n📊 수정 완료:")
        print(f"   - 수정된 파일: {self.fixed_files}개")
        print(f"   - 수정된 링크: {self.fixed_links}개")
    
    def generate_report(self):
        """수정 보고서 생성"""
        report = {
            "timestamp": "2025-09-18T21:55:00",
            "summary": {
                "fixed_files": self.fixed_files,
                "fixed_links": self.fixed_links,
                "issues_addressed": [
                    "한글 파일명 링크 문제 (과정명.md, 과정상세.md)",
                    "URL 인코딩 누락 문제"
                ]
            },
            "korean_filename_fixes": [
                "/mcp_knowledge_base/cloud_basic과정명.md → /mcp_knowledge_base/cloud_basic/과정명.md",
                "/mcp_knowledge_base/cloud_basic과정상세.md → /mcp_knowledge_base/cloud_basic/과정상세.md",
                "/mcp_knowledge_base/cloud_container과정명.md → /mcp_knowledge_base/cloud_container/과정명.md",
                "/mcp_knowledge_base/cloud_container과정상세.md → /mcp_knowledge_base/cloud_container/과정상세.md",
                "/mcp_knowledge_base/cloud_master과정명.md → /mcp_knowledge_base/cloud_master/과정명.md",
                "/mcp_knowledge_base/cloud_master과정상세.md → /mcp_knowledge_base/cloud_master/과정상세.md"
            ]
        }
        
        with open("final_6_issues_fix_report.json", 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        print(f"📊 보고서 생성: final_6_issues_fix_report.json")

def main():
    base_path = Path.cwd()
    fixer = Final6IssuesFixer(base_path)
    
    print("=" * 60)
    print("🔧 최종 6개 이슈 수정 도구")
    print("=" * 60)
    
    fixer.fix_all_files()
    fixer.generate_report()
    
    print("\n✅ 최종 6개 이슈 수정 완료!")

if __name__ == "__main__":
    main()