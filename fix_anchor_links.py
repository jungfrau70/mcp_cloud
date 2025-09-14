#!/usr/bin/env python3
"""
앵커 링크 자동 수정 도구
검증된 21개 문제를 자동으로 수정합니다.
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Tuple
from anchor_link_audit import AnchorLinkAuditor

class AnchorLinkFixer:
    """앵커 링크 자동 수정 도구"""
    
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.kb_path = Path(knowledge_base_path)
        self.auditor = AnchorLinkAuditor(knowledge_base_path)
        self.fixes_applied = 0
        self.files_modified = 0
        
    def load_audit_report(self, report_path: str = "anchor_link_audit_report.json") -> Dict:
        """감사 보고서 로드"""
        with open(report_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def normalize_anchor_id(self, text: str) -> str:
        """VS Code 마크다운 미리보기와 동일한 슬러그 생성"""
        import re
        return re.sub(r'^-+|-+$', '', 
               re.sub(r'-+', '-', 
               re.sub(r'\s+', '-', text.strip()))).lower()
    
    def find_matching_heading(self, doc_content: str, target_anchor: str) -> Tuple[str, int]:
        """문서에서 매칭되는 헤딩 찾기"""
        lines = doc_content.split('\n')
        
        for i, line in enumerate(lines):
            # ATX 스타일 헤딩 감지
            match = re.match(r'^\s{0,3}(#{1,6})\s+(.*?)\s*#*\s*$', line)
            if match and match.group(2):
                text = match.group(2).strip()
                
                # 인라인 마크다운 정리
                clean_text = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', text)  # [text](url)
                clean_text = re.sub(r'[*_]{1,3}([^*_]+)[*_]{1,3}', r'\1', clean_text)  # *em* _em_ **strong**
                clean_text = re.sub(r'`([^`]+)`', r'\1', clean_text)  # `code`
                clean_text = re.sub(r'<[^>]+>', '', clean_text)  # inline html
                clean_text = clean_text.strip()
                
                if clean_text:
                    # 1. 정확한 매칭
                    exact_id = self.normalize_anchor_id(clean_text)
                    if exact_id == target_anchor:
                        return clean_text, i + 1
                    
                    # 2. 이모지 제거 후 매칭
                    without_emoji = re.sub(r'[\U0001F600-\U0001F64F]|[\U0001F300-\U0001F5FF]|[\U0001F680-\U0001F6FF]|[\U0001F1E0-\U0001F1FF]', '', clean_text)
                    emoji_removed_id = self.normalize_anchor_id(without_emoji)
                    if emoji_removed_id == target_anchor:
                        return clean_text, i + 1
                    
                    # 3. 특수문자 제거 후 매칭
                    without_special = re.sub(r'[^\w\s가-힣]', '', clean_text)
                    special_removed_id = self.normalize_anchor_id(without_special)
                    if special_removed_id == target_anchor:
                        return clean_text, i + 1
                    
                    # 4. 부분 매칭
                    if target_anchor in exact_id or exact_id in target_anchor:
                        return clean_text, i + 1
        
        return None, -1
    
    def fix_document_anchors(self, file_path: str, issues: List[Dict]) -> bool:
        """문서의 앵커 링크 수정"""
        full_path = self.kb_path / file_path
        
        if not full_path.exists():
            print(f"❌ 파일을 찾을 수 없음: {file_path}")
            return False
        
        # 문서 로드
        with open(full_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        fixes_in_file = 0
        
        # 각 문제에 대해 수정
        for issue in issues:
            line_num = issue['line']
            link_text = issue['link_text']
            old_href = issue['href']
            
            # 해당 라인 찾기
            lines = content.split('\n')
            if line_num > len(lines):
                print(f"  ⚠️ 라인 {line_num}이 문서 길이를 초과함")
                continue
            
            target_line = lines[line_num - 1]
            
            # 앵커 링크 패턴 찾기
            link_pattern = rf'\[{re.escape(link_text)}\]\(#{re.escape(old_href)}\)'
            match = re.search(link_pattern, target_line)
            
            if not match:
                print(f"  ⚠️ 라인 {line_num}에서 앵커 링크를 찾을 수 없음: {link_text}")
                continue
            
            # 매칭되는 헤딩 찾기
            heading_text, heading_line = self.find_matching_heading(content, old_href)
            
            if heading_text is None:
                print(f"  ❌ 매칭되는 헤딩을 찾을 수 없음: {old_href}")
                continue
            
            # 올바른 앵커 ID 생성
            correct_anchor = self.normalize_anchor_id(heading_text)
            
            # 앵커 링크 수정
            new_line = target_line.replace(f'#{old_href}', f'#{correct_anchor}')
            lines[line_num - 1] = new_line
            
            print(f"  ✅ 라인 {line_num}: {old_href} → {correct_anchor}")
            print(f"     헤딩: {heading_text}")
            fixes_in_file += 1
        
        # 수정된 내용이 있으면 파일 저장
        if fixes_in_file > 0:
            new_content = '\n'.join(lines)
            with open(full_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            print(f"  📝 {fixes_in_file}개 앵커 링크 수정 완료")
            self.fixes_applied += fixes_in_file
            self.files_modified += 1
            return True
        
        return False
    
    def fix_all_issues(self, report_path: str = "anchor_link_audit_report.json"):
        """모든 문제 수정"""
        print("🔧 앵커 링크 자동 수정 시작")
        print("=" * 50)
        
        # 감사 보고서 로드
        report = self.load_audit_report(report_path)
        
        if 'issues_by_file' not in report:
            print("❌ 감사 보고서에서 문제 정보를 찾을 수 없음")
            return
        
        total_issues = sum(len(issues) for issues in report['issues_by_file'].values())
        print(f"📊 총 {total_issues}개 문제 발견")
        
        # 각 파일별로 수정
        for file_path, issues in report['issues_by_file'].items():
            print(f"\n📄 {file_path} 수정 중...")
            print(f"  📊 {len(issues)}개 문제")
            
            success = self.fix_document_anchors(file_path, issues)
            
            if success:
                print(f"  ✅ 수정 완료")
            else:
                print(f"  ❌ 수정 실패")
        
        print("\n" + "=" * 50)
        print("🎯 수정 완료")
        print(f"📊 수정된 파일: {self.files_modified}개")
        print(f"📊 수정된 앵커 링크: {self.fixes_applied}개")
    
    def verify_fixes(self):
        """수정 결과 검증"""
        print("\n🔍 수정 결과 검증 중...")
        
        # 감사 도구로 재검증
        self.auditor.load_all_documents()
        bottom_up_issues = self.auditor.bottom_up_validation()
        
        if bottom_up_issues == 0:
            print("✅ 모든 앵커 링크가 정상 작동합니다!")
        else:
            print(f"⚠️ {bottom_up_issues}개 문제가 남아있습니다.")

def main():
    """메인 실행 함수"""
    fixer = AnchorLinkFixer()
    
    # 1. 모든 문제 수정
    fixer.fix_all_issues()
    
    # 2. 수정 결과 검증
    fixer.verify_fixes()

if __name__ == "__main__":
    main()
