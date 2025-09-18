#!/usr/bin/env python3
"""
최종 남은 이슈 수정 도구
URL 인코딩, 존재하지 않는 파일, 경로 문제 등을 종합적으로 해결
"""

import os
import re
import json
from pathlib import Path
from urllib.parse import quote, unquote
from typing import Dict, List, Set, Tuple

class FinalIssuesFixer:
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
            
            # install → guides 이동
            "/mcp_knowledge_base/cloud_basic/install/": "/mcp_knowledge_base/cloud_basic/textbook/Day1/guides/",
            "/mcp_knowledge_base/cloud_container/install/": "/mcp_knowledge_base/cloud_container/textbook/Day1/guides/",
            "/mcp_knowledge_base/cloud_master/install/": "/mcp_knowledge_base/cloud_master/textbook/Day1/guides/",
        }
    
    def build_actual_files_map(self):
        """실제 존재하는 파일 매핑 구축"""
        print("🗂️ 실제 파일 위치 매핑 중...")
        
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                file_path = Path(root) / file
                relative_path = file_path.relative_to(self.knowledge_base_path)
                abs_path = f"/mcp_knowledge_base/{relative_path.as_posix()}"
                self.actual_files[abs_path] = file_path
                
                # URL 인코딩된 경로도 매핑
                encoded_path = f"/mcp_knowledge_base/{quote(str(relative_path), safe='/')}"
                self.actual_files[encoded_path] = file_path
                
                # 파일명으로도 매핑
                if file not in self.actual_files:
                    self.actual_files[file] = []
                self.actual_files[file].append(abs_path)
        
        print(f"📁 {len(self.actual_files)}개 실제 파일 매핑 완료")
    
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
        
        return path
    
    def fix_url_encoding_issues(self, content: str) -> Tuple[str, int]:
        """URL 인코딩 문제 수정"""
        fixes_count = 0
        
        # %5C (백슬래시) 제거
        if '%5C' in content:
            content = content.replace('%5C', '')
            fixes_count += content.count('%5C') - content.count('%5C')
            print(f"    🔧 URL 인코딩 문제 수정: %5C 제거")
        
        return content, fixes_count
    
    def fix_file_moves(self, content: str) -> Tuple[str, int]:
        """파일 이동에 따른 경로 수정"""
        fixes_count = 0
        
        # 파일 이동 매핑 적용
        for old_path, new_path in self.file_moves.items():
            if old_path in content:
                content = content.replace(old_path, new_path)
                fixes_count += content.count(new_path) - content.count(old_path)
                print(f"    🔧 파일 이동 경로 수정: {old_path} → {new_path}")
        
        return content, fixes_count
    
    def fix_specific_broken_links(self, content: str) -> Tuple[str, int]:
        """특정 깨진 링크 수정"""
        fixes_count = 0
        
        # 특정 링크 수정 매핑
        specific_fixes = {
            # 존재하지 않는 파일들을 올바른 경로로 수정
            "/mcp_knowledge_base/cloud_basic/textbook/Day1/scripts/aws-gcp-setup.sh": "/mcp_knowledge_base/cloud_basic/textbook/Day1/guides/aws-gcp-setup.sh",
            "/mcp_knowledge_base/cloud_basic/textbook/Day1/scripts/aws-setup-helper.sh": "/mcp_knowledge_base/cloud_basic/textbook/Day1/guides/aws-setup-helper.sh",
            "/mcp_knowledge_base/cloud_basic/textbook/Day1/scripts/gcp-setup-helper.sh": "/mcp_knowledge_base/cloud_basic/textbook/Day1/guides/gcp-setup-helper.sh",
            
            # Cloud Container 파일들
            "/mcp_knowledge_base/cloud_container/textbook/Day1/docker-compose.yml": "/mcp_knowledge_base/cloud_container/textbook/Day1/guides/docker-compose.yml",
            "/mcp_knowledge_base/cloud_container/textbook/Day1/container-demo-setup.sh": "/mcp_knowledge_base/cloud_container/textbook/Day1/guides/container-demo-setup.sh",
            "/mcp_knowledge_base/cloud_container/textbook/Day1/helm-chart-templates/Chart.yaml": "/mcp_knowledge_base/cloud_container/textbook/Day1/guides/helm-chart-templates/Chart.yaml",
            "/mcp_knowledge_base/cloud_container/textbook/Day1/istio-config/gateway.yaml": "/mcp_knowledge_base/cloud_container/textbook/Day1/guides/istio-config/gateway.yaml",
            "/mcp_knowledge_base/cloud_container/textbook/Day1/nginx/nginx.conf": "/mcp_knowledge_base/cloud_container/textbook/Day1/guides/nginx/nginx.conf",
            "/mcp_knowledge_base/cloud_container/textbook/Day1/monitoring-advanced/prometheus-config.yaml": "/mcp_knowledge_base/cloud_container/textbook/Day1/guides/monitoring-advanced/prometheus-config.yaml",
            
            # Cloud Master 파일들
            "/mcp_knowledge_base/cloud_master/repos/samples/day1/my-app/.dockerignore": "/mcp_knowledge_base/cloud_master/repos/samples/day1/my-app/.dockerignore",
            "/mcp_knowledge_base/cloud_master/repos/cloud-scripts/aws-ec2-create.sh": "/mcp_knowledge_base/cloud_master/repos/cloud-scripts/aws-ec2-create.sh",
            "/mcp_knowledge_base/cloud_master/repos/cloud-scripts/aws-resource-cleanup.sh": "/mcp_knowledge_base/cloud_master/repos/cloud-scripts/aws-resource-cleanup.sh",
            "/mcp_knowledge_base/cloud_master/repos/cloud-scripts/gcp-compute-create.sh": "/mcp_knowledge_base/cloud_master/repos/cloud-scripts/gcp-compute-create.sh",
            "/mcp_knowledge_base/cloud_master/repos/cloud-scripts/gcp-project-cleanup.sh": "/mcp_knowledge_base/cloud_master/repos/cloud-scripts/gcp-project-cleanup.sh",
            
            # 이미지 파일들 (존재하지 않는 경우 제거)
            "/mcp_knowledge_base/cloud_master/images/day1/container-vs-vm.svg": "",
            "/mcp_knowledge_base/cloud_master/images/day1/docker-architecture.svg": "",
            "/mcp_knowledge_base/cloud_master/images/day1/dockerfile-structure.svg": "",
            "/mcp_knowledge_base/cloud_master/images/day1/cicd-pipeline.svg": "",
            "/mcp_knowledge_base/cloud_master/images/day2/kubernetes-architecture.svg": "",
            "/mcp_knowledge_base/cloud_master/images/day2/kubernetes-resources.svg": "",
            "/mcp_knowledge_base/cloud_master/images/day3/load-balancing-algorithms.jpg": "",
            "/mcp_knowledge_base/cloud_master/images/day3/monitoring-architecture.png": "",
            "/mcp_knowledge_base/cloud_master/images/day3/cloudwatch-dashboard.png": "",
        }
        
        for old_path, new_path in specific_fixes.items():
            if old_path in content:
                if new_path:  # 새 경로가 있는 경우
                    content = content.replace(old_path, new_path)
                    fixes_count += 1
                    print(f"    🔧 특정 링크 수정: {old_path} → {new_path}")
                else:  # 새 경로가 없는 경우 (이미지 등) 링크 제거
                    # 링크 텍스트와 함께 제거
                    link_pattern = r'\[([^\]]+)\]\(' + re.escape(old_path) + r'\)'
                    content = re.sub(link_pattern, r'\1', content)
                    fixes_count += 1
                    print(f"    🔧 존재하지 않는 링크 제거: {old_path}")
        
        return content, fixes_count
    
    def fix_links_in_content(self, content: str) -> Tuple[str, int]:
        """콘텐츠의 링크 수정"""
        original_content = content
        total_fixes = 0
        
        # 1. URL 인코딩 문제 수정
        content, fixes = self.fix_url_encoding_issues(content)
        total_fixes += fixes
        
        # 2. 파일 이동에 따른 경로 수정
        content, fixes = self.fix_file_moves(content)
        total_fixes += fixes
        
        # 3. 특정 깨진 링크 수정
        content, fixes = self.fix_specific_broken_links(content)
        total_fixes += fixes
        
        return content, total_fixes
    
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
    
    def run_fix(self):
        """수정 실행"""
        print("🔧 최종 남은 이슈 수정 시작...")
        print("=" * 60)
        
        # 모든 마크다운 파일 수정
        md_files = self.find_markdown_files()
        print(f"📁 총 {len(md_files)}개 마크다운 파일 수정 중...")
        
        for file_path in md_files:
            print(f"📄 처리 중: {file_path.relative_to(self.base_path)}")
            self.fix_file(file_path)
        
        print("\n" + "=" * 60)
        print("📊 최종 남은 이슈 수정 완료!")
        print("=" * 60)
        print(f"📁 수정된 파일: {self.fixed_files}개")
        print(f"🔗 수정된 링크: {self.fixed_links}개")
        
        if self.fixed_files > 0:
            print("\n✅ 최종 이슈 수정이 완료되었습니다!")
        else:
            print("\n✅ 수정할 이슈가 없습니다!")

def main():
    """메인 함수"""
    base_path = Path.cwd()
    fixer = FinalIssuesFixer(base_path)
    fixer.run_fix()

if __name__ == "__main__":
    main()