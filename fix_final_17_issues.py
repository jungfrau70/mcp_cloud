#!/usr/bin/env python3
"""
최종 17개 이슈 수정 도구
URL 인코딩 문제와 존재하지 않는 가이드 파일 문제 해결
"""

import os
import re
import json
from pathlib import Path
from urllib.parse import quote, unquote
from typing import Dict, List, Set, Tuple

class Final17IssuesFixer:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.knowledge_base_path = self.base_path / "mcp_knowledge_base"
        self.fixed_files = 0
        self.fixed_links = 0
        self.broken_links = []
        
        # 실제 파일 매핑
        self.actual_files = {}
        self.build_actual_files_map()
        
        # 파일 이동 매핑
        self.file_moves = {
            # scripts → guides 이동
            "/mcp_knowledge_base/cloud_basic/textbook/Day1/scripts/": "/mcp_knowledge_base/cloud_basic/textbook/Day1/guides/",
            "/mcp_knowledge_base/cloud_container/textbook/Day1/scripts/": "/mcp_knowledge_base/cloud_container/textbook/Day1/guides/",
            "/mcp_knowledge_base/cloud_master/textbook/Day1/scripts/": "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/",
            "/mcp_knowledge_base/cloud_master/textbook/Day2/scripts/": "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/",
            "/mcp_knowledge_base/cloud_master/textbook/Day3/scripts/": "/mcp_knowledge_base/cloud_master/textbook/Day3/guides/",
            
            # install → guides 이동
            "/mcp_knowledge_base/cloud_basic/install/": "/mcp_knowledge_base/cloud_basic/textbook/Day1/guides/",
            "/mcp_knowledge_base/cloud_container/install/": "/mcp_knowledge_base/cloud_container/textbook/Day1/guides/",
            "/mcp_knowledge_base/cloud_master/install/": "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/",
        }
        
        # 존재하지 않는 파일들에 대한 대체 링크
        self.missing_file_replacements = {
            # Cloud Basic
            "/mcp_knowledge_base/cloud_basic/textbook/Day1/guides/install_gcp_cli.md": "/mcp_knowledge_base/cloud_basic/textbook/Day1/guides/install_glcoud_cli.md",
            
            # Cloud Master
            "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/github-actions-setup.md": "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/github-actions-guide.md",
            "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/GCP_SSH_KEY_GUIDE.md": "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/aws-gcp-deployment-guide.md",
            "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/github-actions-advanced-guide.md": "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/github-actions-complete-guide.md",
            
            # Cloud Master Day2
            "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/matrix-build-guide.md": "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/comprehensive-practice-guide.md",
            "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/kubernetes-guide.md": "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/comprehensive-practice-guide.md",
            "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/kubernetes-setup-guide.md": "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/comprehensive-practice-guide.md",
            "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/automated-deployment-guide.md": "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/comprehensive-practice-guide.md",
            "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/infrastructure-as-code-guide.md": "/mcp_knowledge_base/cloud_master/textbook/Day2/guides/comprehensive-practice-guide.md",
            
            # Cloud Master Day3
            "/mcp_knowledge_base/cloud_master/textbook/Day3/guides/elk-stack-guide.md": "/mcp_knowledge_base/cloud_master/textbook/Day3/guides/monitoring-setup-guide.md",
            "/mcp_knowledge_base/cloud_master/textbook/Day3/guides/operations-automation-guide.md": "/mcp_knowledge_base/cloud_master/textbook/Day3/guides/auto-scaling-guide.md",
        }
    
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
    
    def fix_url_encoding_issues(self, content: str) -> str:
        """URL 인코딩 문제 수정"""
        # URL 인코딩된 한글 파일명을 원래 이름으로 복원
        def decode_korean_filename(match):
            full_match = match.group(0)
            encoded_part = match.group(1)
            
            try:
                decoded = unquote(encoded_part)
                return full_match.replace(encoded_part, decoded)
            except:
                return full_match
        
        # URL 인코딩된 한글 파일명 패턴 찾기
        pattern = r'(/mcp_knowledge_base/[^/]+%[A-F0-9]{2}[^)]*\.md)'
        content = re.sub(pattern, decode_korean_filename, content)
        
        return content
    
    def fix_missing_guide_files(self, content: str) -> str:
        """존재하지 않는 가이드 파일 링크 수정"""
        for missing_file, replacement in self.missing_file_replacements.items():
            # 정확한 경로로 교체
            content = content.replace(missing_file, replacement)
            
            # URL 인코딩된 버전도 교체
            encoded_missing = quote(missing_file, safe='/')
            encoded_replacement = quote(replacement, safe='/')
            content = content.replace(encoded_missing, encoded_replacement)
        
        return content
    
    def fix_file_paths(self, content: str) -> str:
        """파일 경로 수정"""
        for old_path, new_path in self.file_moves.items():
            # 정확한 경로로 교체
            content = content.replace(old_path, new_path)
            
            # URL 인코딩된 버전도 교체
            encoded_old = quote(old_path, safe='/')
            encoded_new = quote(new_path, safe='/')
            content = content.replace(encoded_old, encoded_new)
        
        return content
    
    def fix_links_in_file(self, file_path: Path) -> bool:
        """파일 내 링크 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # 1. URL 인코딩 문제 수정
            content = self.fix_url_encoding_issues(content)
            
            # 2. 존재하지 않는 가이드 파일 링크 수정
            content = self.fix_missing_guide_files(content)
            
            # 3. 파일 경로 수정
            content = self.fix_file_paths(content)
            
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
        print("🔧 최종 17개 이슈 수정 시작...")
        
        # 모든 마크다운 파일 처리
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                if file.endswith(('.md', '.mdx')):
                    file_path = Path(root) / file
                    
                    if self.fix_links_in_file(file_path):
                        self.fixed_files += 1
                        print(f"✅ 수정됨: {file_path.relative_to(self.base_path)}")
        
        print(f"\n📊 수정 완료:")
        print(f"   - 수정된 파일: {self.fixed_files}개")
        print(f"   - 수정된 링크: {self.fixed_links}개")
    
    def generate_report(self):
        """수정 보고서 생성"""
        report = {
            "timestamp": "2025-09-18T21:50:00",
            "summary": {
                "fixed_files": self.fixed_files,
                "fixed_links": self.fixed_links,
                "issues_addressed": [
                    "URL 인코딩 문제 (한글 파일명)",
                    "존재하지 않는 가이드 파일 링크",
                    "파일 경로 수정"
                ]
            },
            "file_moves_applied": self.file_moves,
            "missing_file_replacements": self.missing_file_replacements
        }
        
        with open("final_17_issues_fix_report.json", 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        print(f"📊 보고서 생성: final_17_issues_fix_report.json")

def main():
    base_path = Path.cwd()
    fixer = Final17IssuesFixer(base_path)
    
    print("=" * 60)
    print("🔧 최종 17개 이슈 수정 도구")
    print("=" * 60)
    
    fixer.fix_all_files()
    fixer.generate_report()
    
    print("\n✅ 최종 17개 이슈 수정 완료!")

if __name__ == "__main__":
    main()