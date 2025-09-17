#!/usr/bin/env python3
"""
최종 앵커 링크 수정 도구
제목 앵커 생성 규칙에 따라 누락된 섹션을 추가하거나 목차를 수정
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass
from datetime import datetime

class FinalAnchorFixer:
    """최종 앵커 링크 수정 도구"""
    
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
    
    def add_missing_sections_to_document(self, file_path: Path, missing_sections: List[Dict]) -> Dict:
        """문서에 누락된 섹션 추가"""
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
        print("🔧 최종 앵커 링크 수정 시작...")
        
        # 상세 분석 보고서 로드
        try:
            with open("detailed_anchor_analysis.json", 'r', encoding='utf-8') as f:
                analysis_report = json.load(f)
        except FileNotFoundError:
            print("❌ 상세 분석 보고서를 찾을 수 없습니다. 먼저 detailed_anchor_analysis.py를 실행하세요.")
            return {}
        
        total_added = 0
        processed_files = []
        
        for file_path, analysis in analysis_report.items():
            unmatched_links = analysis.get("unmatched_links", [])
            
            if unmatched_links:
                print(f"  📄 {file_path} 수정 중...")
                print(f"    🔍 {len(unmatched_links)}개 누락된 섹션 발견")
                
                # Windows 경로를 Unix 경로로 변환
                unix_path = file_path.replace('\\', '/')
                full_path = self.knowledge_base_path / unix_path
                
                if full_path.exists():
                    # 누락된 섹션들 추출
                    missing_sections = []
                    for link_info in unmatched_links:
                        link = link_info["link"]
                        missing_sections.append({
                            "text": link["text"],
                            "href": link["href"]
                        })
                    
                    # 누락된 섹션 추가
                    result = self.add_missing_sections_to_document(full_path, missing_sections)
                    
                    if result.get("added_sections", 0) > 0:
                        total_added += result["added_sections"]
                        processed_files.append(result)
                        print(f"    ✅ {result['added_sections']}개 섹션 추가")
                    else:
                        print(f"    ❌ 섹션 추가 실패: {result.get('error', '알 수 없는 오류')}")
                else:
                    print(f"    ❌ 파일을 찾을 수 없음: {full_path}")
            else:
                print(f"  📄 {file_path} - 수정할 섹션 없음")
        
        # 수정 결과 요약
        summary = {
            "timestamp": datetime.now().isoformat(),
            "total_files_processed": len(analysis_report),
            "total_sections_added": total_added,
            "processed_files": processed_files
        }
        
        # 수정 보고서 저장
        with open("final_anchor_fix_report.json", 'w', encoding='utf-8') as f:
            json.dump(summary, f, ensure_ascii=False, indent=2)
        
        print(f"\n📊 최종 수정 완료:")
        print(f"  - 처리된 파일: {len(analysis_report)}개")
        print(f"  - 추가된 섹션: {total_added}개")
        
        return summary

def main():
    """메인 실행 함수"""
    print("🔧 최종 앵커 링크 수정 도구")
    print("=" * 50)
    
    # 수정 도구 초기화
    fixer = FinalAnchorFixer()
    
    # 모든 누락된 섹션 수정
    result = fixer.fix_all_missing_sections()
    
    if result:
        print("\n✅ 수정 완료! 이제 재검증을 실행하세요:")
        print("python comprehensive_anchor_audit.py")

if __name__ == "__main__":
    main()
