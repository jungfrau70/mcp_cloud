#!/usr/bin/env python3
"""
커리큘럼 및 지식베이스 앵커 링크 전수 조사 도구
Top-down 및 Bottom-up 방식을 병행하여 모든 문서의 앵커 링크 동작을 검증합니다.
"""

import os
import re
import json
import glob
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass
from urllib.parse import unquote

@dataclass
class AnchorLink:
    """앵커 링크 정보"""
    text: str
    href: str
    file_path: str
    line_number: int
    is_valid: bool = True
    error_message: str = ""

@dataclass
class Heading:
    """헤딩 정보"""
    text: str
    level: int
    generated_id: str
    file_path: str
    line_number: int

@dataclass
class DocumentInfo:
    """문서 정보"""
    path: str
    content: str
    headings: List[Heading]
    anchor_links: List[AnchorLink]
    file_size: int
    has_toc: bool = False

class AnchorLinkAuditor:
    """앵커 링크 감사 도구"""
    
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.kb_path = Path(knowledge_base_path)
        self.documents: Dict[str, DocumentInfo] = {}
        self.learning_paths = []
        self.issues: List[Dict] = []
        
    def normalize_anchor_id(self, text: str) -> str:
        """VS Code 마크다운 미리보기와 동일한 슬러그 생성"""
        import re
        return re.sub(r'^-+|-+$', '', 
               re.sub(r'-+', '-', 
               re.sub(r'\s+', '-', text.strip()))).lower()
    
    def extract_headings(self, content: str, file_path: str) -> List[Heading]:
        """문서에서 헤딩 추출"""
        headings = []
        lines = content.split('\n')
        
        for i, line in enumerate(lines):
            # ATX 스타일 헤딩 감지
            match = re.match(r'^\s{0,3}(#{1,6})\s+(.*?)\s*#*\s*$', line)
            if match and match.group(2):
                level = len(match.group(1))
                text = match.group(2).strip()
                
                # 인라인 마크다운 정리
                clean_text = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', text)  # [text](url)
                clean_text = re.sub(r'[*_]{1,3}([^*_]+)[*_]{1,3}', r'\1', clean_text)  # *em* _em_ **strong**
                clean_text = re.sub(r'`([^`]+)`', r'\1', clean_text)  # `code`
                clean_text = re.sub(r'<[^>]+>', '', clean_text)  # inline html
                clean_text = clean_text.strip()
                
                if clean_text:
                    generated_id = self.normalize_anchor_id(clean_text)
                    headings.append(Heading(
                        text=clean_text,
                        level=level,
                        generated_id=generated_id,
                        file_path=file_path,
                        line_number=i + 1
                    ))
        
        return headings
    
    def extract_anchor_links(self, content: str, file_path: str) -> List[AnchorLink]:
        """문서에서 앵커 링크 추출"""
        anchor_links = []
        lines = content.split('\n')
        
        for i, line in enumerate(lines):
            # 앵커 링크 패턴 찾기
            matches = re.finditer(r'\[([^\]]+)\]\(#([^)]+)\)', line)
            for match in matches:
                link_text = match.group(1)
                href = match.group(2)
                
                anchor_links.append(AnchorLink(
                    text=link_text,
                    href=href,
                    file_path=file_path,
                    line_number=i + 1
                ))
        
        return anchor_links
    
    def load_document(self, file_path: Path) -> Optional[DocumentInfo]:
        """문서 로드 및 정보 추출"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            relative_path = str(file_path.relative_to(self.kb_path))
            headings = self.extract_headings(content, relative_path)
            anchor_links = self.extract_anchor_links(content, relative_path)
            
            # 목차 존재 여부 확인
            has_toc = bool(re.search(r'<details>\s*<summary>.*목차.*</summary>', content, re.IGNORECASE))
            
            return DocumentInfo(
                path=relative_path,
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
        
        md_files = list(self.kb_path.rglob("*.md"))
        print(f"발견된 마크다운 파일: {len(md_files)}개")
        
        for file_path in md_files:
            doc_info = self.load_document(file_path)
            if doc_info:
                self.documents[doc_info.path] = doc_info
        
        print(f"로드된 문서: {len(self.documents)}개")
    
    def find_learning_paths(self):
        """학습 경로 문서 찾기"""
        learning_path_patterns = [
            "**/learning-path.md",
            "**/curriculum.md",
            "**/index.md"
        ]
        
        for pattern in learning_path_patterns:
            files = list(self.kb_path.glob(pattern))
            for file_path in files:
                relative_path = str(file_path.relative_to(self.kb_path))
                if relative_path in self.documents:
                    self.learning_paths.append(relative_path)
        
        print(f"발견된 학습 경로 문서: {len(self.learning_paths)}개")
        for path in self.learning_paths:
            print(f"  - {path}")
    
    def validate_anchor_links_in_document(self, doc_path: str) -> List[Dict]:
        """단일 문서의 앵커 링크 검증"""
        if doc_path not in self.documents:
            return []
        
        doc = self.documents[doc_path]
        issues = []
        
        # 헤딩 ID 맵 생성
        heading_ids = {h.generated_id: h for h in doc.headings}
        
        for link in doc.anchor_links:
            # URL 디코딩 시도
            try:
                decoded_href = unquote(link.href)
            except:
                decoded_href = link.href
            
            # 정확한 매칭 확인
            if decoded_href in heading_ids:
                link.is_valid = True
            else:
                # 부분 매칭 시도 (한글 헤더용)
                found = False
                for heading_id, heading in heading_ids.items():
                    if heading_id in decoded_href or decoded_href in heading_id:
                        found = True
                        break
                
                if not found:
                    link.is_valid = False
                    link.error_message = f"헤딩을 찾을 수 없음: {decoded_href}"
                    
                    issues.append({
                        'type': 'invalid_anchor',
                        'file': doc_path,
                        'line': link.line_number,
                        'link_text': link.text,
                        'href': link.href,
                        'decoded_href': decoded_href,
                        'available_headings': list(heading_ids.keys())[:5],  # 처음 5개만 표시
                        'message': link.error_message
                    })
        
        return issues
    
    def top_down_validation(self):
        """Top-down 검증: 학습 경로에서 참조하는 모든 문서의 앵커 링크 검증"""
        print("\n🔍 Top-down 검증 시작...")
        
        total_issues = 0
        
        for learning_path in self.learning_paths:
            print(f"\n📋 {learning_path} 검증 중...")
            
            # 학습 경로 문서의 앵커 링크 검증
            issues = self.validate_anchor_links_in_document(learning_path)
            total_issues += len(issues)
            
            if issues:
                print(f"  ❌ {len(issues)}개 문제 발견")
                for issue in issues[:3]:  # 처음 3개만 표시
                    print(f"    - 라인 {issue['line']}: {issue['link_text']} -> {issue['href']}")
                    print(f"      오류: {issue['message']}")
            else:
                print(f"  ✅ 앵커 링크 정상")
            
            # 학습 경로에서 참조하는 다른 문서들 찾기
            doc = self.documents[learning_path]
            referenced_docs = set()
            
            # 상대 경로 링크 찾기
            for line in doc.content.split('\n'):
                matches = re.finditer(r'\[([^\]]+)\]\(([^#)]+)(?:#[^)]+)?\)', line)
                for match in matches:
                    file_path = match.group(2)
                    if not file_path.startswith('http') and not file_path.startswith('#'):
                        # 상대 경로를 절대 경로로 변환
                        if file_path.startswith('./'):
                            file_path = file_path[2:]
                        elif file_path.startswith('../'):
                            # 상대 경로 해결 로직 (간단화)
                            continue
                        
                        if file_path.endswith('.md'):
                            referenced_docs.add(file_path)
            
            # 참조된 문서들의 앵커 링크 검증
            for ref_doc in referenced_docs:
                if ref_doc in self.documents:
                    print(f"  📄 {ref_doc} 검증 중...")
                    ref_issues = self.validate_anchor_links_in_document(ref_doc)
                    total_issues += len(ref_issues)
                    
                    if ref_issues:
                        print(f"    ❌ {len(ref_issues)}개 문제 발견")
                    else:
                        print(f"    ✅ 앵커 링크 정상")
        
        print(f"\n📊 Top-down 검증 완료: 총 {total_issues}개 문제 발견")
        return total_issues
    
    def bottom_up_validation(self):
        """Bottom-up 검증: 모든 문서의 앵커 링크 생성 및 매칭 검증"""
        print("\n🔍 Bottom-up 검증 시작...")
        
        total_issues = 0
        documents_with_issues = 0
        
        for doc_path, doc in self.documents.items():
            issues = self.validate_anchor_links_in_document(doc_path)
            
            if issues:
                documents_with_issues += 1
                total_issues += len(issues)
                
                print(f"\n📄 {doc_path}")
                print(f"  📊 통계: 헤딩 {len(doc.headings)}개, 앵커 링크 {len(doc.anchor_links)}개")
                
                if doc.has_toc:
                    print(f"  📋 목차 포함")
                
                for issue in issues[:5]:  # 처음 5개만 표시
                    print(f"    ❌ 라인 {issue['line']}: {issue['link_text']} -> {issue['href']}")
                    print(f"       오류: {issue['message']}")
                
                if len(issues) > 5:
                    print(f"    ... 및 {len(issues) - 5}개 추가 문제")
        
        print(f"\n📊 Bottom-up 검증 완료:")
        print(f"  - 검증된 문서: {len(self.documents)}개")
        print(f"  - 문제가 있는 문서: {documents_with_issues}개")
        print(f"  - 총 문제 수: {total_issues}개")
        
        return total_issues
    
    def analyze_korean_and_emoji_handling(self):
        """한글 및 이모지 처리 분석"""
        print("\n🔍 한글 및 이모지 처리 분석...")
        
        korean_docs = 0
        emoji_docs = 0
        korean_headings = 0
        emoji_headings = 0
        korean_links = 0
        emoji_links = 0
        
        for doc_path, doc in self.documents.items():
            has_korean = False
            has_emoji = False
            
            # 한글 파일명 확인
            if re.search(r'[가-힣]', doc_path):
                korean_docs += 1
                has_korean = True
            
            # 헤딩 분석
            for heading in doc.headings:
                if re.search(r'[가-힣]', heading.text):
                    korean_headings += 1
                    has_korean = True
                
                if re.search(r'[\U0001F600-\U0001F64F]|[\U0001F300-\U0001F5FF]|[\U0001F680-\U0001F6FF]|[\U0001F1E0-\U0001F1FF]', heading.text):
                    emoji_headings += 1
                    has_emoji = True
            
            # 앵커 링크 분석
            for link in doc.anchor_links:
                if re.search(r'[가-힣]', link.text):
                    korean_links += 1
                    has_korean = True
                
                if re.search(r'[\U0001F600-\U0001F64F]|[\U0001F300-\U0001F5FF]|[\U0001F680-\U0001F6FF]|[\U0001F1E0-\U0001F1FF]', link.text):
                    emoji_links += 1
                    has_emoji = True
            
            if has_emoji:
                emoji_docs += 1
        
        print(f"📊 한글 처리 통계:")
        print(f"  - 한글 파일명 문서: {korean_docs}개")
        print(f"  - 한글 헤딩: {korean_headings}개")
        print(f"  - 한글 앵커 링크: {korean_links}개")
        
        print(f"📊 이모지 처리 통계:")
        print(f"  - 이모지 포함 문서: {emoji_docs}개")
        print(f"  - 이모지 헤딩: {emoji_headings}개")
        print(f"  - 이모지 앵커 링크: {emoji_links}개")
    
    def generate_report(self):
        """상세 보고서 생성"""
        print("\n📊 상세 분석 보고서 생성 중...")
        
        # 전체 통계
        total_docs = len(self.documents)
        total_headings = sum(len(doc.headings) for doc in self.documents.values())
        total_links = sum(len(doc.anchor_links) for doc in self.documents.values())
        docs_with_toc = sum(1 for doc in self.documents.values() if doc.has_toc)
        
        # 문제 통계
        all_issues = []
        for doc_path in self.documents:
            issues = self.validate_anchor_links_in_document(doc_path)
            all_issues.extend(issues)
        
        # 보고서 생성
        report = {
            "summary": {
                "total_documents": total_docs,
                "total_headings": total_headings,
                "total_anchor_links": total_links,
                "documents_with_toc": docs_with_toc,
                "total_issues": len(all_issues),
                "learning_paths": self.learning_paths
            },
            "issues_by_type": {},
            "issues_by_file": {},
            "recommendations": []
        }
        
        # 문제 유형별 분류
        for issue in all_issues:
            issue_type = issue['type']
            if issue_type not in report["issues_by_type"]:
                report["issues_by_type"][issue_type] = 0
            report["issues_by_type"][issue_type] += 1
            
            file_path = issue['file']
            if file_path not in report["issues_by_file"]:
                report["issues_by_file"][file_path] = []
            report["issues_by_file"][file_path].append(issue)
        
        # 권장사항 생성
        if len(all_issues) > 0:
            report["recommendations"].append("앵커 링크 매칭 로직 개선 필요")
        
        if docs_with_toc < total_docs * 0.5:
            report["recommendations"].append("목차 추가 권장")
        
        # 보고서 저장
        with open("anchor_link_audit_report.json", "w", encoding="utf-8") as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        print(f"📄 보고서 저장: anchor_link_audit_report.json")
        return report
    
    def run_full_audit(self):
        """전체 감사 실행"""
        print("🚀 앵커 링크 전수 조사 시작")
        print("=" * 50)
        
        # 1. 모든 문서 로드
        self.load_all_documents()
        
        # 2. 학습 경로 찾기
        self.find_learning_paths()
        
        # 3. Top-down 검증
        top_down_issues = self.top_down_validation()
        
        # 4. Bottom-up 검증
        bottom_up_issues = self.bottom_up_validation()
        
        # 5. 한글 및 이모지 처리 분석
        self.analyze_korean_and_emoji_handling()
        
        # 6. 보고서 생성
        report = self.generate_report()
        
        print("\n" + "=" * 50)
        print("🎯 감사 완료")
        print(f"📊 Top-down 문제: {top_down_issues}개")
        print(f"📊 Bottom-up 문제: {bottom_up_issues}개")
        print(f"📊 총 문제: {top_down_issues + bottom_up_issues}개")
        
        return report

def main():
    """메인 실행 함수"""
    auditor = AnchorLinkAuditor()
    report = auditor.run_full_audit()
    
    print(f"\n📄 상세 보고서: anchor_link_audit_report.json")
    print("🔧 문제 수정을 위해 개별 문서를 검토하세요.")

if __name__ == "__main__":
    main()
