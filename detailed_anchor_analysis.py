#!/usr/bin/env python3
"""
상세 앵커 링크 분석 도구
목차와 본문 헤딩의 정확한 매칭 분석
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass
from datetime import datetime

class DetailedAnchorAnalyzer:
    """상세 앵커 링크 분석 도구"""
    
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
    
    def normalize_anchor_id(self, text: str) -> str:
        """VS Code 마크다운 미리보기와 동일한 앵커 ID 생성"""
        text = text.strip()
        text = re.sub(r'[^\w\s가-힣]', '', text)
        text = re.sub(r'\s+', '-', text)
        text = re.sub(r'-+', '-', text)
        text = text.strip('-')
        return text.lower()
    
    def analyze_document_detailed(self, file_path: Path) -> Dict:
        """문서의 상세 분석"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            lines = content.split('\n')
            
            # 실제 헤딩 추출
            headings = []
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
            
            # 목차 링크 추출
            toc_links = []
            in_toc = False
            for i, line in enumerate(lines, 1):
                if '<details>' in line and '목차' in line:
                    in_toc = True
                    continue
                if in_toc and '</details>' in line:
                    break
                if in_toc:
                    # 목차 내의 모든 앵커 링크 추출
                    matches = re.finditer(r'\[([^\]]+)\]\(#([^)]+)\)', line)
                    for match in matches:
                        text = match.group(1)
                        href = match.group(2)
                        toc_links.append({
                            "text": text,
                            "href": href,
                            "line_number": i
                        })
            
            # 목차가 없는 경우, 문서 전체에서 앵커 링크 찾기
            if not toc_links:
                for i, line in enumerate(lines, 1):
                    matches = re.finditer(r'\[([^\]]+)\]\(#([^)]+)\)', line)
                    for match in matches:
                        text = match.group(1)
                        href = match.group(2)
                        toc_links.append({
                            "text": text,
                            "href": href,
                            "line_number": i
                        })
            
            # 매칭 분석
            heading_ids = {h["anchor_id"] for h in headings}
            matching_analysis = []
            
            for link in toc_links:
                if link["href"] in heading_ids:
                    matching_analysis.append({
                        "link": link,
                        "status": "MATCHED",
                        "matched_heading": next(h for h in headings if h["anchor_id"] == link["href"])
                    })
                else:
                    # 부분 매칭 시도
                    possible_matches = []
                    for heading in headings:
                        if (link["href"] in heading["anchor_id"] or 
                            heading["anchor_id"] in link["href"] or
                            link["href"].replace('-', '') in heading["anchor_id"].replace('-', '')):
                            possible_matches.append(heading)
                    
                    matching_analysis.append({
                        "link": link,
                        "status": "NO_MATCH" if not possible_matches else "PARTIAL_MATCH",
                        "possible_matches": possible_matches
                    })
            
            return {
                "file": str(file_path.relative_to(self.knowledge_base_path)),
                "total_headings": len(headings),
                "total_toc_links": len(toc_links),
                "headings": headings,
                "toc_links": toc_links,
                "matching_analysis": matching_analysis,
                "unmatched_links": [a for a in matching_analysis if a["status"] == "NO_MATCH"],
                "partial_matches": [a for a in matching_analysis if a["status"] == "PARTIAL_MATCH"]
            }
            
        except Exception as e:
            return {
                "file": str(file_path.relative_to(self.knowledge_base_path)),
                "error": str(e)
            }
    
    def analyze_problematic_files(self) -> Dict:
        """문제가 있는 파일들 상세 분석"""
        print("🔍 문제가 있는 파일들 상세 분석 중...")
        
        # 감사 보고서에서 문제가 있는 파일들 가져오기
        try:
            with open("comprehensive_anchor_audit_report.json", 'r', encoding='utf-8') as f:
                audit_report = json.load(f)
        except FileNotFoundError:
            print("❌ 감사 보고서를 찾을 수 없습니다.")
            return {}
        
        files_with_issues = audit_report.get("issues_by_file", {})
        detailed_analysis = {}
        
        for file_path, issues in files_with_issues.items():
            if issues:  # 문제가 있는 파일만 처리
                print(f"  📄 {file_path} 상세 분석 중...")
                
                # Windows 경로를 Unix 경로로 변환
                unix_path = file_path.replace('\\', '/')
                full_path = self.knowledge_base_path / unix_path
                
                if full_path.exists():
                    analysis = self.analyze_document_detailed(full_path)
                    detailed_analysis[file_path] = analysis
                    
                    print(f"    📊 헤딩: {analysis.get('total_headings', 0)}개, 목차 링크: {analysis.get('total_toc_links', 0)}개")
                    print(f"    ❌ 매칭 실패: {len(analysis.get('unmatched_links', []))}개")
                    print(f"    ⚠️ 부분 매칭: {len(analysis.get('partial_matches', []))}개")
                else:
                    print(f"    ❌ 파일을 찾을 수 없음: {full_path}")
        
        # 상세 분석 보고서 저장
        with open("detailed_anchor_analysis.json", 'w', encoding='utf-8') as f:
            json.dump(detailed_analysis, f, ensure_ascii=False, indent=2)
        
        return detailed_analysis

def main():
    """메인 실행 함수"""
    print("🔍 상세 앵커 링크 분석 도구")
    print("=" * 50)
    
    # 분석 도구 초기화
    analyzer = DetailedAnchorAnalyzer()
    
    # 문제가 있는 파일들 상세 분석
    result = analyzer.analyze_problematic_files()
    
    print(f"\n📊 분석 완료: {len(result)}개 파일 분석")
    print("📄 상세 보고서: detailed_anchor_analysis.json")

if __name__ == "__main__":
    main()
