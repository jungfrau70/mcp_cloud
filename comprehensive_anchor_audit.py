#!/usr/bin/env python3
"""
제목 앵커 동작 전수 조사 도구
Top-down 및 Bottom-up 방식으로 앵커 링크 불일치 문제를 체계적으로 분석
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass
from datetime import datetime
import urllib.parse

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
    is_external: bool = False

@dataclass
class DocumentInfo:
    """문서 정보"""
    path: str
    content: str
    headings: List[Heading]
    anchor_links: List[AnchorLink]
    file_size: int
    has_toc: bool = False

class ComprehensiveAnchorAuditor:
    """포괄적 앵커 링크 감사 도구"""
    
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.documents: Dict[str, DocumentInfo] = {}
        self.issues: List[Dict] = []
        self.learning_paths = [
            "index.md",
            "curriculum.md", 
            "cloud_basic/learning-path.md",
            "cloud_container/learning-path.md",
            "cloud_master/learning-path.md"
        ]
    
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
    
    def extract_headings(self, content: str) -> List[Heading]:
        """문서에서 헤딩 추출"""
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
    
    def extract_anchor_links(self, content: str) -> List[AnchorLink]:
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
                    line_number=i,
                    is_external=False
                ))
        
        return anchor_links
    
    def load_document(self, file_path: Path) -> DocumentInfo:
        """단일 문서 로드"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            headings = self.extract_headings(content)
            anchor_links = self.extract_anchor_links(content)
            
            # 목차 존재 여부 확인
            has_toc = bool(re.search(r'<details>.*목차.*</details>', content, re.DOTALL | re.IGNORECASE))
            
            return DocumentInfo(
                path=str(file_path.relative_to(self.knowledge_base_path)),
                content=content,
                headings=headings,
                anchor_links=anchor_links,
                file_size=len(content),
                has_toc=has_toc
            )
        except Exception as e:
            print(f"문서 로드 실패: {file_path} - {e}")
            return None
    
    def load_all_documents(self):
        """모든 마크다운 문서 로드"""
        print("📚 모든 문서 로드 중...")
        
        for md_file in self.knowledge_base_path.rglob("*.md"):
            doc_info = self.load_document(md_file)
            if doc_info:
                self.documents[doc_info.path] = doc_info
        
        print(f"✅ {len(self.documents)}개 문서 로드 완료")
    
    def validate_anchor_links_in_document(self, doc_path: str) -> List[Dict]:
        """단일 문서의 앵커 링크 검증"""
        if doc_path not in self.documents:
            return [{"type": "error", "message": f"문서를 찾을 수 없음: {doc_path}"}]
        
        doc = self.documents[doc_path]
        issues = []
        
        # 헤딩 ID 집합 생성
        heading_ids = {heading.anchor_id for heading in doc.headings}
        
        # 앵커 링크 검증
        for anchor in doc.anchor_links:
            if anchor.href not in heading_ids:
                # 정확한 매칭 실패 시 부분 매칭 시도
                found_match = False
                for heading_id in heading_ids:
                    if anchor.href in heading_id or heading_id in anchor.href:
                        found_match = True
                        break
                
                if not found_match:
                    issues.append({
                        "type": "invalid_anchor",
                        "message": f"앵커 링크 '{anchor.href}'에 해당하는 헤딩을 찾을 수 없음",
                        "line": anchor.line_number,
                        "anchor_text": anchor.text,
                        "expected_heading": self._find_expected_heading(anchor.href, doc.headings)
                    })
        
        return issues
    
    def _find_expected_heading(self, anchor_href: str, headings: List[Heading]) -> Optional[str]:
        """앵커 링크에 가장 가까운 헤딩 찾기"""
        # 정확한 매칭 시도
        for heading in headings:
            if heading.anchor_id == anchor_href:
                return heading.text
        
        # 부분 매칭 시도
        for heading in headings:
            if anchor_href in heading.anchor_id or heading.anchor_id in anchor_href:
                return heading.text
        
        return None
    
    def top_down_validation(self) -> List[Dict]:
        """Top-down 검증: 학습 경로에서 참조하는 모든 문서의 앵커 링크 검증"""
        print("🔍 Top-down 검증 시작...")
        issues = []
        
        for learning_path in self.learning_paths:
            if learning_path in self.documents:
                print(f"  📋 {learning_path} 검증 중...")
                doc_issues = self.validate_anchor_links_in_document(learning_path)
                for issue in doc_issues:
                    issue["source"] = "top_down"
                    issue["learning_path"] = learning_path
                issues.extend(doc_issues)
        
        print(f"✅ Top-down 검증 완료: {len(issues)}개 문제 발견")
        return issues
    
    def bottom_up_validation(self) -> List[Dict]:
        """Bottom-up 검증: 모든 실제 문서의 앵커 링크 생성 및 매칭 검증"""
        print("🔍 Bottom-up 검증 시작...")
        issues = []
        
        for doc_path, doc in self.documents.items():
            print(f"  📄 {doc_path} 검증 중...")
            doc_issues = self.validate_anchor_links_in_document(doc_path)
            for issue in doc_issues:
                issue["source"] = "bottom_up"
                issue["document"] = doc_path
            issues.extend(doc_issues)
        
        print(f"✅ Bottom-up 검증 완료: {len(issues)}개 문제 발견")
        return issues
    
    def analyze_heading_patterns(self) -> Dict:
        """헤딩 패턴 분석"""
        print("📊 헤딩 패턴 분석 중...")
        
        patterns = {
            "total_headings": 0,
            "headings_by_level": {},
            "common_prefixes": {},
            "emoji_usage": 0,
            "korean_headings": 0,
            "special_characters": 0
        }
        
        for doc in self.documents.values():
            for heading in doc.headings:
                patterns["total_headings"] += 1
                
                # 레벨별 분류
                level = heading.level
                if level not in patterns["headings_by_level"]:
                    patterns["headings_by_level"][level] = 0
                patterns["headings_by_level"][level] += 1
                
                # 이모지 사용 확인
                if re.search(r'[\U0001F600-\U0001F64F]|[\U0001F300-\U0001F5FF]|[\U0001F680-\U0001F6FF]|[\U0001F1E0-\U0001F1FF]', heading.text):
                    patterns["emoji_usage"] += 1
                
                # 한글 헤딩 확인
                if re.search(r'[가-힣]', heading.text):
                    patterns["korean_headings"] += 1
                
                # 특수문자 확인
                if re.search(r'[^\w\s가-힣]', heading.text):
                    patterns["special_characters"] += 1
                
                # 공통 접두사 확인
                prefix = heading.text.split()[0] if heading.text.split() else ""
                if prefix and len(prefix) <= 10:
                    if prefix not in patterns["common_prefixes"]:
                        patterns["common_prefixes"][prefix] = 0
                    patterns["common_prefixes"][prefix] += 1
        
        return patterns
    
    def generate_report(self) -> Dict:
        """상세 보고서 생성"""
        print("📊 보고서 생성 중...")
        
        # Top-down 검증
        top_down_issues = self.top_down_validation()
        
        # Bottom-up 검증
        bottom_up_issues = self.bottom_up_validation()
        
        # 모든 문제 수집
        all_issues = top_down_issues + bottom_up_issues
        
        # 문제 유형별 분류
        issues_by_type = {}
        issues_by_file = {}
        
        for issue in all_issues:
            issue_type = issue.get("type", "unknown")
            if issue_type not in issues_by_type:
                issues_by_type[issue_type] = 0
            issues_by_type[issue_type] += 1
            
            file_key = issue.get("document", issue.get("learning_path", "unknown"))
            if file_key not in issues_by_file:
                issues_by_file[file_key] = []
            issues_by_file[file_key].append(issue)
        
        # 헤딩 패턴 분석
        heading_patterns = self.analyze_heading_patterns()
        
        # 통계 계산
        total_documents = len(self.documents)
        total_headings = sum(len(doc.headings) for doc in self.documents.values())
        total_anchor_links = sum(len(doc.anchor_links) for doc in self.documents.values())
        documents_with_toc = sum(1 for doc in self.documents.values() if doc.has_toc)
        
        report = {
            "timestamp": datetime.now().isoformat(),
            "summary": {
                "total_documents": total_documents,
                "total_headings": total_headings,
                "total_anchor_links": total_anchor_links,
                "documents_with_toc": documents_with_toc,
                "total_issues": len(all_issues),
                "top_down_issues": len(top_down_issues),
                "bottom_up_issues": len(bottom_up_issues),
                "learning_paths": self.learning_paths
            },
            "issues_by_type": issues_by_type,
            "issues_by_file": issues_by_file,
            "heading_patterns": heading_patterns,
            "detailed_issues": all_issues,
            "recommendations": self._generate_recommendations(all_issues, heading_patterns)
        }
        
        return report
    
    def _generate_recommendations(self, issues: List[Dict], patterns: Dict) -> List[str]:
        """개선 권장사항 생성"""
        recommendations = []
        
        if len(issues) > 0:
            recommendations.append(f"총 {len(issues)}개의 앵커 링크 문제가 발견되었습니다. 자동 수정 도구를 실행하세요.")
        
        if patterns["emoji_usage"] > 0:
            recommendations.append(f"{patterns['emoji_usage']}개의 헤딩에서 이모지를 사용하고 있습니다. 앵커 링크 생성 시 이모지 제거를 확인하세요.")
        
        if patterns["special_characters"] > 0:
            recommendations.append(f"{patterns['special_characters']}개의 헤딩에서 특수문자를 사용하고 있습니다. 앵커 링크 생성 시 특수문자 제거를 확인하세요.")
        
        if patterns["korean_headings"] > 0:
            recommendations.append(f"{patterns['korean_headings']}개의 한글 헤딩이 있습니다. 한글 처리 로직을 확인하세요.")
        
        return recommendations
    
    def save_report(self, report: Dict, filename: str = "comprehensive_anchor_audit_report.json"):
        """보고서 저장"""
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        print(f"📄 보고서 저장: {filename}")

def main():
    """메인 실행 함수"""
    print("🔍 제목 앵커 동작 전수 조사 시작")
    print("=" * 50)
    
    # 감사 도구 초기화
    auditor = ComprehensiveAnchorAuditor()
    
    # 모든 문서 로드
    auditor.load_all_documents()
    
    # 상세 보고서 생성
    report = auditor.generate_report()
    
    # 보고서 저장
    auditor.save_report(report)
    
    # 결과 요약 출력
    print("\n📊 검사 결과 요약")
    print("=" * 50)
    print(f"총 문서 수: {report['summary']['total_documents']}")
    print(f"총 헤딩 수: {report['summary']['total_headings']}")
    print(f"총 앵커 링크 수: {report['summary']['total_anchor_links']}")
    print(f"총 문제 수: {report['summary']['total_issues']}")
    print(f"  - Top-down 문제: {report['summary']['top_down_issues']}")
    print(f"  - Bottom-up 문제: {report['summary']['bottom_up_issues']}")
    
    if report['summary']['total_issues'] > 0:
        print("\n🚨 발견된 문제 유형:")
        for issue_type, count in report['issues_by_type'].items():
            print(f"  - {issue_type}: {count}개")
        
        print("\n📋 문제가 있는 파일:")
        for file_path, file_issues in report['issues_by_file'].items():
            if file_issues:
                print(f"  - {file_path}: {len(file_issues)}개 문제")
    else:
        print("\n✅ 모든 앵커 링크가 정상입니다!")
    
    print("\n💡 권장사항:")
    for rec in report['recommendations']:
        print(f"  - {rec}")

if __name__ == "__main__":
    main()
