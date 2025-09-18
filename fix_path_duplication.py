#!/usr/bin/env python3
"""
경로 중복 문제 해결 도구
mcp_knowledge_base/mcp_knowledge_base/ 패턴 제거
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Tuple, Any
from urllib.parse import quote, unquote
from datetime import datetime

class PathDuplicationFixer:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.knowledge_base_path = self.base_path / "mcp_knowledge_base"
        self.fixed_files = []
        self.fix_count = 0
        
    def find_markdown_files(self) -> List[Path]:
        """모든 마크다운 파일 찾기"""
        md_files = []
        for root, dirs, files in os.walk(self.knowledge_base_path):
            for file in files:
                if file.endswith('.md'):
                    md_files.append(Path(root) / file)
        return md_files
    
    def fix_duplicate_paths(self, content: str) -> Tuple[str, int]:
        """경로 중복 문제 수정"""
        original_content = content
        fix_count = 0
        
        # 패턴 1: mcp_knowledge_base/mcp_knowledge_base/ 제거
        pattern1 = r'mcp_knowledge_base/mcp_knowledge_base/'
        if re.search(pattern1, content):
            content = re.sub(pattern1, 'mcp_knowledge_base/', content)
            fix_count += len(re.findall(pattern1, original_content))
        
        # 패턴 2: /mcp_knowledge_base/mcp_knowledge_base/ 제거
        pattern2 = r'/mcp_knowledge_base/mcp_knowledge_base/'
        if re.search(pattern2, content):
            content = re.sub(pattern2, '/mcp_knowledge_base/', content)
            fix_count += len(re.findall(pattern2, original_content))
        
        # 패턴 3: ../mcp_knowledge_base/../mcp_knowledge_base/ 제거
        pattern3 = r'\.\./mcp_knowledge_base/\.\./mcp_knowledge_base/'
        if re.search(pattern3, content):
            content = re.sub(pattern3, '/mcp_knowledge_base/', content)
            fix_count += len(re.findall(pattern3, original_content))
        
        # 패턴 4: mcp_knowledge_base/../mcp_knowledge_base/ 제거
        pattern4 = r'mcp_knowledge_base/\.\./mcp_knowledge_base/'
        if re.search(pattern4, content):
            content = re.sub(pattern4, 'mcp_knowledge_base/', content)
            fix_count += len(re.findall(pattern4, original_content))
        
        # 패턴 5: 복잡한 상대 경로 정리
        pattern5 = r'mcp_knowledge_base/\.\./\.\./mcp_knowledge_base/'
        if re.search(pattern5, content):
            content = re.sub(pattern5, '/mcp_knowledge_base/', content)
            fix_count += len(re.findall(pattern5, original_content))
        
        # 패턴 6: 연속된 ../ 정리
        pattern6 = r'\.\./\.\./\.\./mcp_knowledge_base/'
        if re.search(pattern6, content):
            content = re.sub(pattern6, '/mcp_knowledge_base/', content)
            fix_count += len(re.findall(pattern6, original_content))
        
        # 패턴 7: 백슬래시를 슬래시로 변환
        content = content.replace('\\', '/')
        
        # 패턴 8: 연속된 슬래시 정리
        content = re.sub(r'/+', '/', content)
        
        return content, fix_count
    
    def fix_file_paths(self, file_path: Path) -> bool:
        """파일의 경로 중복 문제 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            fixed_content, fix_count = self.fix_duplicate_paths(content)
            
            if fix_count > 0:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(fixed_content)
                
                self.fixed_files.append({
                    'file': str(file_path.relative_to(self.base_path)),
                    'fixes': fix_count
                })
                self.fix_count += fix_count
                return True
            
        except Exception as e:
            print(f"오류 발생 {file_path}: {e}")
            return False
        
        return False
    
    def process_all_files(self):
        """모든 파일 처리"""
        print("🔍 마크다운 파일 검색 중...")
        md_files = self.find_markdown_files()
        print(f"📁 총 {len(md_files)}개 파일 발견")
        
        print("\n🔧 경로 중복 문제 수정 시작...")
        fixed_count = 0
        
        for file_path in md_files:
            print(f"\n📄 처리 중: {file_path.relative_to(self.base_path)}")
            
            if self.fix_file_paths(file_path):
                fixed_count += 1
                print(f"  ✅ {self.fixed_files[-1]['fixes']}개 경로 수정")
            else:
                print(f"  ⏭️ 수정할 경로 없음")
        
        print(f"\n✅ 수정 완료: {fixed_count}개 파일")
        print(f"🔧 총 수정된 경로: {self.fix_count}개")
        
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
        
        with open("path_duplication_fix_report.json", "w", encoding="utf-8") as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        print(f"\n📊 보고서 생성: path_duplication_fix_report.json")

def main():
    """메인 함수"""
    print("🔧 경로 중복 문제 해결 도구")
    print("=" * 60)
    
    base_path = Path.cwd()
    fixer = PathDuplicationFixer(base_path)
    
    # 경로 중복 문제 수정 실행
    fixed_count = fixer.process_all_files()
    
    # 보고서 생성
    fixer.generate_report()
    
    print(f"\n🎉 경로 중복 문제 해결 완료! ({fixed_count}개 파일 수정)")

if __name__ == "__main__":
    main()