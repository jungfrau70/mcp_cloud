#!/usr/bin/env python3
"""
앵커 링크 자동 수정 도구 (고급)
제목 앵커 생성 규칙에 따라 본문 레벨의 헤딩과 목차 링크를 일치시킴
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass
from datetime import datetime

@dataclass
class Heading:
    """헤딩 정보"""
    level: int
    text: str
    line_number: int
    anchor_id: str

@dataclass
class AnchorLink:
    """앵커 링크 정보"""
    text: str
    href: str
    line_number: int

class AdvancedAnchorLinkFixer:
    """고급 앵커 링크 수정 도구"""
    
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.fixed_files = []
        self.fix_report = []
    
    def normalize_anchor_id(self, text: str) -> str:
        """VS Code 마크다운 미리보기와 동일한 앵커 ID 생성"""
        # 1. 앞뒤 공백 제거
        text = text.strip()
        
        # 2. 이모지와 특수문자 제거 (VS Code는 이모지를 제거함)
        text = re.sub(r'[^\w\s가-힣]', '', text)
        
        # 3. 공백을 하이픈으로 변환
        text = re.sub(r'\s+', '-', text)
        
        # 4. 연속된 하이픈을 하나로 변환
        text = re.sub(r'-+', '-', text)
        
        # 5. 앞뒤 하이픈 제거
        text = text.strip('-')
        
        # 6. 소문자로 변환
        return text.lower()
    
    def extract_headings_from_content(self, content: str) -> List[Heading]:
        """문서에서 실제 헤딩 추출 (본문 레벨)"""
        headings = []
        lines = content.split('\n')
        
        for i, line in enumerate(lines, 1):
            # ATX 스타일 헤딩 (# ## ### 등)
            match = re.match(r'^(#{1,6})\s+(.+)$', line.strip())
            if match:
                level = len(match.group(1))
                text = match.group(2).strip()
                anchor_id = self.normalize_anchor_id(text)
                
                headings.append(Heading(
                    level=level,
                    text=text,
                    line_number=i,
                    anchor_id=anchor_id
                ))
        
        return headings
    
    def extract_anchor_links_from_content(self, content: str) -> List[AnchorLink]:
        """문서에서 앵커 링크 추출"""
        anchor_links = []
        lines = content.split('\n')
        
        for i, line in enumerate(lines, 1):
            # 마크다운 링크 패턴 [text](#anchor)
            matches = re.finditer(r'\[([^\]]+)\]\(#([^)]+)\)', line)
            for match in matches:
                text = match.group(1)
                href = match.group(2)
                
                anchor_links.append(AnchorLink(
                    text=text,
                    href=href,
                    line_number=i
                ))
        
        return anchor_links
    
    def find_best_matching_heading(self, anchor_href: str, headings: List[Heading]) -> Optional[Heading]:
        """앵커 링크에 가장 적합한 헤딩 찾기"""
        # 1. 정확한 매칭 시도
        for heading in headings:
            if heading.anchor_id == anchor_href:
                return heading
        
        # 2. 텍스트 내용 기반 매칭 (이모지 제거 후)
        anchor_text_clean = re.sub(r'[^\w\s가-힣]', '', anchor_href)
        for heading in headings:
            heading_text_clean = re.sub(r'[^\w\s가-힣]', '', heading.text)
            if anchor_text_clean.lower() in heading_text_clean.lower() or heading_text_clean.lower() in anchor_text_clean.lower():
                return heading
        
        # 3. 부분 매칭 시도
        for heading in headings:
            if anchor_href in heading.anchor_id or heading.anchor_id in anchor_href:
                return heading
        
        return None
    
    def fix_document_anchors(self, file_path: Path) -> Dict:
        """단일 문서의 앵커 링크 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 실제 헤딩 추출 (본문 레벨)
            headings = self.extract_headings_from_content(content)
            
            # 앵커 링크 추출
            anchor_links = self.extract_anchor_links_from_content(content)
            
            # 수정할 내용 추적
            fixes = []
            new_content = content
            
            # 각 앵커 링크 검사 및 수정
            for anchor in reversed(anchor_links):  # 뒤에서부터 수정 (라인 번호 유지)
                # 해당 앵커에 맞는 헤딩 찾기
                matching_heading = self.find_best_matching_heading(anchor.href, headings)
                
                if matching_heading:
                    # 올바른 앵커 ID로 수정
                    old_anchor = f"[{anchor.text}](#{anchor.href})"
                    new_anchor = f"[{anchor.text}](#{matching_heading.anchor_id})"
                    
                    if old_anchor != new_anchor:
                        # 라인별로 수정
                        lines = new_content.split('\n')
                        if anchor.line_number <= len(lines):
                            lines[anchor.line_number - 1] = lines[anchor.line_number - 1].replace(old_anchor, new_anchor)
                            new_content = '\n'.join(lines)
                            
                            fixes.append({
                                "line": anchor.line_number,
                                "old_anchor": old_anchor,
                                "new_anchor": new_anchor,
                                "matched_heading": matching_heading.text
                            })
                else:
                    # 매칭되는 헤딩이 없는 경우
                    fixes.append({
                        "line": anchor.line_number,
                        "old_anchor": f"[{anchor.text}](#{anchor.href})",
                        "new_anchor": "NO_MATCH_FOUND",
                        "matched_heading": None,
                        "error": "매칭되는 헤딩을 찾을 수 없음"
                    })
            
            # 파일 수정
            if fixes:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                
                self.fixed_files.append(str(file_path.relative_to(self.knowledge_base_path)))
            
            return {
                "file": str(file_path.relative_to(self.knowledge_base_path)),
                "total_fixes": len(fixes),
                "successful_fixes": len([f for f in fixes if f.get("new_anchor") != "NO_MATCH_FOUND"]),
                "failed_fixes": len([f for f in fixes if f.get("new_anchor") == "NO_MATCH_FOUND"]),
                "fixes": fixes
            }
            
        except Exception as e:
            return {
                "file": str(file_path.relative_to(self.knowledge_base_path)),
                "error": str(e),
                "total_fixes": 0,
                "successful_fixes": 0,
                "failed_fixes": 0,
                "fixes": []
            }
    
    def fix_all_remaining_issues(self) -> Dict:
        """감사 보고서를 기반으로 모든 문제 수정"""
        print("🔧 앵커 링크 자동 수정 시작...")
        
        # 감사 보고서 로드
        try:
            with open("comprehensive_anchor_audit_report.json", 'r', encoding='utf-8') as f:
                audit_report = json.load(f)
        except FileNotFoundError:
            print("❌ 감사 보고서를 찾을 수 없습니다. 먼저 comprehensive_anchor_audit.py를 실행하세요.")
            return {}
        
        # 문제가 있는 파일들 수정
        files_with_issues = audit_report.get("issues_by_file", {})
        total_fixes = 0
        successful_fixes = 0
        failed_fixes = 0
        
        for file_path, issues in files_with_issues.items():
            if issues:  # 문제가 있는 파일만 처리
                print(f"  📄 {file_path} 수정 중...")
                
                # Windows 경로를 Unix 경로로 변환
                unix_path = file_path.replace('\\', '/')
                full_path = self.knowledge_base_path / unix_path
                
                if full_path.exists():
                    result = self.fix_document_anchors(full_path)
                    
                    total_fixes += result.get("total_fixes", 0)
                    successful_fixes += result.get("successful_fixes", 0)
                    failed_fixes += result.get("failed_fixes", 0)
                    
                    self.fix_report.append(result)
                    
                    print(f"    ✅ {result.get('successful_fixes', 0)}개 수정, {result.get('failed_fixes', 0)}개 실패")
                else:
                    print(f"    ❌ 파일을 찾을 수 없음: {full_path}")
        
        # 수정 결과 요약
        summary = {
            "timestamp": datetime.now().isoformat(),
            "total_files_processed": len(files_with_issues),
            "total_fixes": total_fixes,
            "successful_fixes": successful_fixes,
            "failed_fixes": failed_fixes,
            "fixed_files": self.fixed_files,
            "fix_report": self.fix_report
        }
        
        # 수정 보고서 저장
        with open("anchor_fix_report.json", 'w', encoding='utf-8') as f:
            json.dump(summary, f, ensure_ascii=False, indent=2)
        
        print(f"\n📊 수정 완료:")
        print(f"  - 처리된 파일: {len(files_with_issues)}개")
        print(f"  - 총 수정 시도: {total_fixes}개")
        print(f"  - 성공: {successful_fixes}개")
        print(f"  - 실패: {failed_fixes}개")
        print(f"  - 수정된 파일: {len(self.fixed_files)}개")
        
        return summary

def main():
    """메인 실행 함수"""
    print("🔧 앵커 링크 자동 수정 도구 (고급)")
    print("=" * 50)
    
    # 수정 도구 초기화
    fixer = AdvancedAnchorLinkFixer()
    
    # 모든 문제 수정
    result = fixer.fix_all_remaining_issues()
    
    if result:
        print("\n✅ 수정 완료! 이제 재검증을 실행하세요:")
        print("python comprehensive_anchor_audit.py")

if __name__ == "__main__":
    main()
