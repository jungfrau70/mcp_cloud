#!/usr/bin/env python3
"""
자기 참조 링크 찾기 및 수정 도구
문서가 자기 자신을 참조하는 링크를 찾아서 수정하거나 제거
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass
from datetime import datetime

class SelfReferencingLinkFixer:
    """자기 참조 링크 수정 도구"""
    
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.self_referencing_links = []
        self.fix_report = []
    
    def find_self_referencing_links(self, file_path: Path) -> List[Dict]:
        """문서에서 자기 참조 링크 찾기"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            lines = content.split('\n')
            self_ref_links = []
            
            # 상대 경로 링크 패턴들
            patterns = [
                r'\[([^\]]+)\]\(\./([^)]+)\)',  # ./filename.md
                r'\[([^\]]+)\]\(\.\./([^)]+)\)',  # ../filename.md
                r'\[([^\]]+)\]\(([^/)]+\.md)\)',  # filename.md
                r'\[([^\]]+)\]\(/([^)]+)\)',  # /path/filename.md
            ]
            
            for i, line in enumerate(lines, 1):
                for pattern in patterns:
                    matches = re.finditer(pattern, line)
                    for match in matches:
                        link_text = match.group(1)
                        link_path = match.group(2)
                        
                        # 현재 파일명과 비교
                        current_file = file_path.name
                        current_file_no_ext = file_path.stem
                        
                        # 자기 참조 링크인지 확인
                        is_self_ref = False
                        if link_path.endswith(current_file):
                            is_self_ref = True
                        elif link_path.endswith(current_file_no_ext + '.md'):
                            is_self_ref = True
                        elif link_path == current_file_no_ext:
                            is_self_ref = True
                        
                        if is_self_ref:
                            self_ref_links.append({
                                "line_number": i,
                                "line_content": line.strip(),
                                "link_text": link_text,
                                "link_path": link_path,
                                "full_match": match.group(0)
                            })
            
            return self_ref_links
            
        except Exception as e:
            print(f"파일 읽기 오류: {file_path} - {e}")
            return []
    
    def fix_self_referencing_links(self, file_path: Path, self_ref_links: List[Dict]) -> Dict:
        """자기 참조 링크 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            lines = content.split('\n')
            new_content = content
            fixes_applied = []
            
            # 뒤에서부터 수정 (라인 번호 유지)
            for link_info in reversed(self_ref_links):
                line_num = link_info["line_number"]
                old_line = link_info["line_content"]
                full_match = link_info["full_match"]
                link_text = link_info["link_text"]
                
                # 수정 방안 결정
                fix_strategy = self._determine_fix_strategy(link_text, old_line)
                
                if fix_strategy["action"] == "remove":
                    # 링크 제거하고 텍스트만 남기기
                    new_line = old_line.replace(full_match, link_text)
                    lines[line_num - 1] = new_line
                    fixes_applied.append({
                        "line": line_num,
                        "action": "removed_link",
                        "old": full_match,
                        "new": link_text,
                        "reason": fix_strategy["reason"]
                    })
                
                elif fix_strategy["action"] == "replace":
                    # 다른 링크로 교체
                    new_line = old_line.replace(full_match, fix_strategy["replacement"])
                    lines[line_num - 1] = new_line
                    fixes_applied.append({
                        "line": line_num,
                        "action": "replaced_link",
                        "old": full_match,
                        "new": fix_strategy["replacement"],
                        "reason": fix_strategy["reason"]
                    })
                
                elif fix_strategy["action"] == "keep":
                    # 유지 (특별한 경우)
                    fixes_applied.append({
                        "line": line_num,
                        "action": "kept",
                        "old": full_match,
                        "new": full_match,
                        "reason": fix_strategy["reason"]
                    })
            
            # 파일 수정
            if fixes_applied:
                new_content = '\n'.join(lines)
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
            
            return {
                "file": str(file_path.relative_to(self.knowledge_base_path)),
                "total_self_ref_links": len(self_ref_links),
                "fixes_applied": len(fixes_applied),
                "fixes": fixes_applied
            }
            
        except Exception as e:
            return {
                "file": str(file_path.relative_to(self.knowledge_base_path)),
                "error": str(e),
                "total_self_ref_links": 0,
                "fixes_applied": 0,
                "fixes": []
            }
    
    def _determine_fix_strategy(self, link_text: str, line_content: str) -> Dict:
        """수정 전략 결정"""
        # 네비게이션 링크인지 확인
        nav_keywords = [
            "이전", "다음", "돌아가기", "메인", "홈", "목차", "커리큘럼", "학습 경로"
        ]
        
        is_nav_link = any(keyword in link_text for keyword in nav_keywords)
        
        if is_nav_link:
            # 네비게이션 링크는 제거
            return {
                "action": "remove",
                "reason": "네비게이션 링크에서 자기 참조 제거"
            }
        
        # 섹션 링크인지 확인
        if link_text.startswith(('#', '##', '###')):
            return {
                "action": "remove",
                "reason": "섹션 링크에서 자기 참조 제거"
            }
        
        # 일반적인 경우 링크 제거하고 텍스트만 남기기
        return {
            "action": "remove",
            "reason": "자기 참조 링크 제거"
        }
    
    def scan_all_documents(self) -> Dict:
        """모든 문서에서 자기 참조 링크 스캔"""
        print("🔍 자기 참조 링크 스캔 시작...")
        
        all_self_ref_links = []
        total_files = 0
        files_with_self_ref = 0
        
        # 모든 마크다운 파일 스캔
        for md_file in self.knowledge_base_path.rglob("*.md"):
            total_files += 1
            self_ref_links = self.find_self_referencing_links(md_file)
            
            if self_ref_links:
                files_with_self_ref += 1
                file_info = {
                    "file": str(md_file.relative_to(self.knowledge_base_path)),
                    "self_ref_links": self_ref_links
                }
                all_self_ref_links.append(file_info)
                print(f"  📄 {file_info['file']}: {len(self_ref_links)}개 자기 참조 링크 발견")
        
        print(f"\n📊 스캔 완료:")
        print(f"  - 총 파일: {total_files}개")
        print(f"  - 자기 참조 링크가 있는 파일: {files_with_self_ref}개")
        print(f"  - 총 자기 참조 링크: {sum(len(f['self_ref_links']) for f in all_self_ref_links)}개")
        
        return {
            "total_files": total_files,
            "files_with_self_ref": files_with_self_ref,
            "total_self_ref_links": sum(len(f['self_ref_links']) for f in all_self_ref_links),
            "files": all_self_ref_links
        }
    
    def fix_all_self_referencing_links(self) -> Dict:
        """모든 자기 참조 링크 수정"""
        print("🔧 자기 참조 링크 수정 시작...")
        
        # 스캔 결과 로드 또는 새로 스캔
        scan_result = self.scan_all_documents()
        
        total_fixes = 0
        processed_files = []
        
        for file_info in scan_result["files"]:
            file_path = self.knowledge_base_path / file_info["file"]
            self_ref_links = file_info["self_ref_links"]
            
            print(f"  📄 {file_info['file']} 수정 중...")
            
            result = self.fix_self_referencing_links(file_path, self_ref_links)
            processed_files.append(result)
            
            if result.get("fixes_applied", 0) > 0:
                total_fixes += result["fixes_applied"]
                print(f"    ✅ {result['fixes_applied']}개 링크 수정")
            else:
                print(f"    ℹ️ 수정할 링크 없음")
        
        # 수정 결과 요약
        summary = {
            "timestamp": datetime.now().isoformat(),
            "total_files_processed": len(processed_files),
            "total_fixes_applied": total_fixes,
            "processed_files": processed_files
        }
        
        # 수정 보고서 저장
        with open("self_referencing_links_fix_report.json", 'w', encoding='utf-8') as f:
            json.dump(summary, f, ensure_ascii=False, indent=2)
        
        print(f"\n📊 수정 완료:")
        print(f"  - 처리된 파일: {len(processed_files)}개")
        print(f"  - 수정된 링크: {total_fixes}개")
        
        return summary

def main():
    """메인 실행 함수"""
    print("🔧 자기 참조 링크 수정 도구")
    print("=" * 50)
    
    # 수정 도구 초기화
    fixer = SelfReferencingLinkFixer()
    
    # 모든 자기 참조 링크 수정
    result = fixer.fix_all_self_referencing_links()
    
    if result:
        print("\n✅ 수정 완료! 보고서: self_referencing_links_fix_report.json")

if __name__ == "__main__":
    main()
