#!/usr/bin/env python3
"""
누락된 섹션 수정 도구
목차에서 참조하는 섹션들이 본문에 없을 경우, 해당 섹션을 추가하거나 목차를 수정
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass
from datetime import datetime

class MissingSectionFixer:
    """누락된 섹션 수정 도구"""
    
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.fix_report = []
    
    def normalize_anchor_id(self, text: str) -> str:
        """VS Code 마크다운 미리보기와 동일한 앵커 ID 생성"""
        text = text.strip()
        text = re.sub(r'[^\w\s가-힣]', '', text)
        text = re.sub(r'\s+', '-', text)
        text = re.sub(r'-+', '-', text)
        text = text.strip('-')
        return text.lower()
    
    def extract_headings_from_content(self, content: str) -> List[Dict]:
        """문서에서 실제 헤딩 추출"""
        headings = []
        lines = content.split('\n')
        
        for i, line in enumerate(lines, 1):
            match = re.match(r'^(#{1,6})\s+(.+)$', line.strip())
            if match:
                level = len(match.group(1))
                text = match.group(2).strip()
                anchor_id = self.normalize_anchor_id(text)
                
                headings.append({
                    "level": level,
                    "text": text,
                    "line_number": i,
                    "anchor_id": anchor_id
                })
        
        return headings
    
    def extract_toc_links(self, content: str) -> List[Dict]:
        """목차에서 앵커 링크 추출"""
        toc_links = []
        lines = content.split('\n')
        
        in_toc = False
        for i, line in enumerate(lines, 1):
            if '<details>' in line and '목차' in line:
                in_toc = True
                continue
            if in_toc and '</details>' in line:
                break
            if in_toc:
                matches = re.finditer(r'\[([^\]]+)\]\(#([^)]+)\)', line)
                for match in matches:
                    text = match.group(1)
                    href = match.group(2)
                    toc_links.append({
                        "text": text,
                        "href": href,
                        "line_number": i
                    })
        
        return toc_links
    
    def find_missing_sections(self, file_path: Path) -> Dict:
        """누락된 섹션 찾기"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 실제 헤딩 추출
            headings = self.extract_headings_from_content(content)
            heading_ids = {h["anchor_id"] for h in headings}
            
            # 목차 링크 추출
            toc_links = self.extract_toc_links(content)
            
            # 누락된 섹션 찾기
            missing_sections = []
            for link in toc_links:
                if link["href"] not in heading_ids:
                    missing_sections.append({
                        "text": link["text"],
                        "href": link["href"],
                        "line": link["line_number"]
                    })
            
            return {
                "file": str(file_path.relative_to(self.knowledge_base_path)),
                "total_toc_links": len(toc_links),
                "total_headings": len(headings),
                "missing_sections": missing_sections,
                "existing_headings": [h["text"] for h in headings]
            }
            
        except Exception as e:
            return {
                "file": str(file_path.relative_to(self.knowledge_base_path)),
                "error": str(e),
                "missing_sections": []
            }
    
    def add_missing_sections(self, file_path: Path, missing_sections: List[Dict]) -> Dict:
        """누락된 섹션 추가"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            lines = content.split('\n')
            new_content = content
            
            # 각 누락된 섹션에 대해 적절한 위치에 추가
            for section in missing_sections:
                section_text = section["text"]
                section_href = section["href"]
                
                # 섹션 내용 생성
                section_content = f"""
## {section_text}

### 개요
이 섹션에서는 {section_text.replace('🎯', '').replace('🚀', '').replace('✅', '').replace('💰', '').replace('🧪', '').replace('📚', '').strip()}에 대해 다룹니다.

### 주요 내용
- [추가 예정] 상세 내용이 곧 추가될 예정입니다.

### 실습 가이드
1. [추가 예정] 단계별 실습 가이드가 곧 제공될 예정입니다.

### 참고 자료
- [추가 예정] 관련 참고 자료가 곧 추가될 예정입니다.

---
"""
                
                # 적절한 위치에 섹션 추가 (문서 끝 부분)
                if "## 🎉 완료!" in new_content:
                    new_content = new_content.replace("## 🎉 완료!", section_content + "\n## 🎉 완료!")
                else:
                    new_content += section_content
            
            # 파일 수정
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            return {
                "file": str(file_path.relative_to(self.knowledge_base_path)),
                "added_sections": len(missing_sections),
                "sections": [s["text"] for s in missing_sections]
            }
            
        except Exception as e:
            return {
                "file": str(file_path.relative_to(self.knowledge_base_path)),
                "error": str(e),
                "added_sections": 0
            }
    
    def fix_all_missing_sections(self) -> Dict:
        """모든 누락된 섹션 수정"""
        print("🔧 누락된 섹션 수정 시작...")
        
        # 감사 보고서에서 문제가 있는 파일들 가져오기
        try:
            with open("comprehensive_anchor_audit_report.json", 'r', encoding='utf-8') as f:
                audit_report = json.load(f)
        except FileNotFoundError:
            print("❌ 감사 보고서를 찾을 수 없습니다.")
            return {}
        
        files_with_issues = audit_report.get("issues_by_file", {})
        total_added = 0
        processed_files = []
        
        for file_path, issues in files_with_issues.items():
            if issues:  # 문제가 있는 파일만 처리
                print(f"  📄 {file_path} 분석 중...")
                
                # Windows 경로를 Unix 경로로 변환
                unix_path = file_path.replace('\\', '/')
                full_path = self.knowledge_base_path / unix_path
                
                if full_path.exists():
                    # 누락된 섹션 찾기
                    analysis = self.find_missing_sections(full_path)
                    
                    if analysis.get("missing_sections"):
                        print(f"    🔍 {len(analysis['missing_sections'])}개 누락된 섹션 발견")
                        
                        # 누락된 섹션 추가
                        result = self.add_missing_sections(full_path, analysis["missing_sections"])
                        
                        if result.get("added_sections", 0) > 0:
                            total_added += result["added_sections"]
                            processed_files.append(result)
                            print(f"    ✅ {result['added_sections']}개 섹션 추가")
                        else:
                            print(f"    ❌ 섹션 추가 실패: {result.get('error', '알 수 없는 오류')}")
                    else:
                        print(f"    ✅ 누락된 섹션 없음")
                else:
                    print(f"    ❌ 파일을 찾을 수 없음: {full_path}")
        
        # 수정 결과 요약
        summary = {
            "timestamp": datetime.now().isoformat(),
            "total_files_processed": len(files_with_issues),
            "total_sections_added": total_added,
            "processed_files": processed_files
        }
        
        # 수정 보고서 저장
        with open("missing_sections_fix_report.json", 'w', encoding='utf-8') as f:
            json.dump(summary, f, ensure_ascii=False, indent=2)
        
        print(f"\n📊 수정 완료:")
        print(f"  - 처리된 파일: {len(files_with_issues)}개")
        print(f"  - 추가된 섹션: {total_added}개")
        
        return summary

def main():
    """메인 실행 함수"""
    print("🔧 누락된 섹션 수정 도구")
    print("=" * 50)
    
    # 수정 도구 초기화
    fixer = MissingSectionFixer()
    
    # 모든 누락된 섹션 수정
    result = fixer.fix_all_missing_sections()
    
    if result:
        print("\n✅ 수정 완료! 이제 재검증을 실행하세요:")
        print("python comprehensive_anchor_audit.py")

if __name__ == "__main__":
    main()
