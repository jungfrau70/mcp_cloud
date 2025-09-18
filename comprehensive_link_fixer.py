#!/usr/bin/env python3
"""
종합 링크 수정 도구
모든 내부 링크를 올바른 절대 경로로 완전 수정
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Tuple, Any, Set
from urllib.parse import quote, unquote
from datetime import datetime

class ComprehensiveLinkFixer:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.knowledge_base_path = self.base_path / "mcp_knowledge_base"
        self.fixed_files = []
        self.fix_count = 0
        self.file_map = {}  # 파일명 -> 실제 경로 매핑
        
    def build_file_map(self):
        """파일 매핑 테이블 구축"""
        print("🗂️ 파일 매핑 테이블 구축 중...")
        
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                if file.endswith('.md'):
                    file_path = Path(root) / file
                    relative_path = file_path.relative_to(self.knowledge_base_path)
                    
                    # 파일명으로 매핑
                    if file not in self.file_map:
                        self.file_map[file] = []
                    self.file_map[file].append(relative_path.as_posix())
                    
                    # 상대 경로로도 매핑
                    path_key = relative_path.as_posix()
                    self.file_map[path_key] = [relative_path.as_posix()]
        
        print(f"📁 {len(self.file_map)}개 파일 매핑 완료")
    
    def find_markdown_files(self) -> List[Path]:
        """모든 마크다운 파일 찾기"""
        md_files = []
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                if file.endswith('.md'):
                    md_files.append(Path(root) / file)
        return md_files
    
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
    
    def resolve_relative_path(self, from_file: Path, link_path: str) -> Path:
        """상대 경로를 절대 경로로 변환"""
        if link_path.startswith('/'):
            # 절대 경로인 경우
            return self.knowledge_base_path / link_path.lstrip('/')
        else:
            # 상대 경로인 경우
            return from_file.parent / link_path
    
    def check_file_exists(self, file_path: Path) -> bool:
        """파일 존재 여부 확인"""
        return file_path.exists() and file_path.is_file()
    
    def find_correct_path(self, target_file: Path, from_file: Path) -> str:
        """올바른 경로 찾기"""
        # 1. 직접 경로 확인
        if target_file.exists():
            relative_path = target_file.relative_to(self.knowledge_base_path)
            return f"/mcp_knowledge_base/{relative_path.as_posix()}"
        
        # 2. 파일명으로 검색
        target_name = target_file.name
        if target_name in self.file_map:
            # 가장 적합한 경로 선택
            candidates = self.file_map[target_name]
            if len(candidates) == 1:
                return f"/mcp_knowledge_base/{candidates[0]}"
            else:
                # 상대 경로가 가장 가까운 것 선택
                from_relative = from_file.relative_to(self.knowledge_base_path)
                best_candidate = candidates[0]
                min_distance = float('inf')
                
                for candidate in candidates:
                    candidate_path = Path(candidate)
                    distance = len(candidate_path.parts) + len(from_relative.parts)
                    if distance < min_distance:
                        min_distance = distance
                        best_candidate = candidate
                
                return f"/mcp_knowledge_base/{best_candidate}"
        
        # 3. 부분 매칭으로 검색
        target_name_lower = target_name.lower()
        for file_name, paths in self.file_map.items():
            if target_name_lower in file_name.lower() or file_name.lower() in target_name_lower:
                if len(paths) == 1:
                    return f"/mcp_knowledge_base/{paths[0]}"
                else:
                    # 가장 적합한 경로 선택
                    from_relative = from_file.relative_to(self.knowledge_base_path)
                    best_candidate = paths[0]
                    min_distance = float('inf')
                    
                    for path in paths:
                        path_obj = Path(path)
                        distance = len(path_obj.parts) + len(from_relative.parts)
                        if distance < min_distance:
                            min_distance = distance
                            best_candidate = path
                    
                    return f"/mcp_knowledge_base/{best_candidate}"
        
        return None
    
    def fix_links_in_file(self, file_path: Path) -> Tuple[str, int]:
        """파일의 링크 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            fix_count = 0
            lines = content.split('\n')
            
            for i, line in enumerate(lines):
                # 마크다운 링크 패턴 찾기
                link_pattern = r'\[([^\]]+)\]\(([^)]+)\)'
                matches = list(re.finditer(link_pattern, line))
                
                for match in reversed(matches):  # 역순으로 처리하여 인덱스 변경 방지
                    text = match.group(1)
                    url = match.group(2)
                    
                    # 내부 링크인지 확인
                    if not url.startswith(('http://', 'https://', 'mailto:', 'tel:', '#')):
                        # 경로 정규화
                        normalized_url = self.normalize_path(url)
                        target_file = self.resolve_relative_path(file_path, normalized_url)
                        
                        # 파일 존재 여부 확인
                        if not self.check_file_exists(target_file):
                            # 올바른 경로 찾기
                            correct_path = self.find_correct_path(target_file, file_path)
                            
                            if correct_path:
                                # 링크 수정
                                old_link = f"[{text}]({url})"
                                new_link = f"[{text}]({correct_path})"
                                line = line.replace(old_link, new_link)
                                fix_count += 1
                                
                                print(f"    🔧 {url} → {correct_path}")
            
            new_content = '\n'.join(lines)
            return new_content, fix_count
            
        except Exception as e:
            print(f"오류 발생 {file_path}: {e}")
            return content, 0
    
    def fix_all_links(self):
        """모든 링크 수정"""
        # 파일 매핑 테이블 구축
        self.build_file_map()
        
        print("\n🔍 마크다운 파일 검색 중...")
        md_files = self.find_markdown_files()
        print(f"📁 총 {len(md_files)}개 파일 발견")
        
        print("\n🔧 종합 링크 수정 시작...")
        fixed_count = 0
        
        for file_path in md_files:
            print(f"\n📄 처리 중: {file_path.relative_to(self.base_path)}")
            
            try:
                new_content, fix_count = self.fix_links_in_file(file_path)
                
                if fix_count > 0:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    
                    self.fixed_files.append({
                        'file': str(file_path.relative_to(self.base_path)),
                        'fixes': fix_count
                    })
                    self.fix_count += fix_count
                    fixed_count += 1
                    print(f"  ✅ {fix_count}개 링크 수정")
                else:
                    print(f"  ⏭️ 수정할 링크 없음")
            
            except Exception as e:
                print(f"  ❌ 오류: {e}")
        
        print(f"\n✅ 수정 완료: {fixed_count}개 파일")
        print(f"🔧 총 수정된 링크: {self.fix_count}개")
        
        return fixed_count
    
    def generate_report(self):
        """수정 보고서 생성"""
        report = {
            "timestamp": datetime.now().isoformat(),
            "total_files_processed": len(self.find_markdown_files()),
            "files_modified": len(self.fixed_files),
            "total_fixes": self.fix_count,
            "modified_files": self.fixed_files
        }
        
        with open("comprehensive_link_fix_report.json", "w", encoding="utf-8") as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        print(f"\n📊 보고서 생성: comprehensive_link_fix_report.json")

def main():
    """메인 함수"""
    print("🔧 종합 링크 수정 도구")
    print("=" * 60)
    
    base_path = Path.cwd()
    fixer = ComprehensiveLinkFixer(base_path)
    
    # 종합 링크 수정 실행
    fixed_count = fixer.fix_all_links()
    
    # 보고서 생성
    fixer.generate_report()
    
    print(f"\n🎉 종합 링크 수정 완료! ({fixed_count}개 파일 수정)")

if __name__ == "__main__":
    main()