#!/usr/bin/env python3
"""
간단한 PDF 교재 생성기
표준 라이브러리만 사용하여 HTML 교재를 생성합니다.
"""

import os
import re
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional

class SimpleTextbookGenerator:
    """간단한 교재 생성기"""
    
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.output_dir = Path("generated_textbooks")
        self.output_dir.mkdir(exist_ok=True)
    
    def read_file_safe(self, file_path: Path) -> str:
        """안전한 파일 읽기"""
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return f.read()
        except Exception as e:
            print(f"파일 읽기 오류 {file_path}: {e}")
            return ""
    
    def markdown_to_html_simple(self, markdown_text: str) -> str:
        """간단한 마크다운을 HTML로 변환"""
        html = markdown_text
        
        # 헤딩 변환
        html = re.sub(r'^# (.+)$', r'<h1>\1</h1>', html, flags=re.MULTILINE)
        html = re.sub(r'^## (.+)$', r'<h2>\1</h2>', html, flags=re.MULTILINE)
        html = re.sub(r'^### (.+)$', r'<h3>\1</h3>', html, flags=re.MULTILINE)
        html = re.sub(r'^#### (.+)$', r'<h4>\1</h4>', html, flags=re.MULTILINE)
        
        # 볼드/이탤릭
        html = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', html)
        html = re.sub(r'\*(.+?)\*', r'<em>\1</em>', html)
        
        # 코드 블록
        html = re.sub(r'```(\w+)?\n(.*?)\n```', r'<pre><code>\2</code></pre>', html, flags=re.DOTALL)
        html = re.sub(r'`(.+?)`', r'<code>\1</code>', html)
        
        # 링크
        html = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'<a href="\2">\1</a>', html)
        
        # 리스트
        html = re.sub(r'^- (.+)$', r'<li>\1</li>', html, flags=re.MULTILINE)
        html = re.sub(r'(<li>.*</li>)', r'<ul>\1</ul>', html, flags=re.DOTALL)
        
        # 단락
        paragraphs = html.split('\n\n')
        html_paragraphs = []
        for p in paragraphs:
            p = p.strip()
            if p and not p.startswith('<'):
                p = f'<p>{p}</p>'
            html_paragraphs.append(p)
        html = '\n\n'.join(html_paragraphs)
        
        return html
    
    def get_course_structure(self) -> Dict[str, Any]:
        """과정 구조 분석"""
        structure = {
            "cloud_basic": {
                "title": "Cloud Basic",
                "description": "클라우드 기초 과정",
                "days": 2,
                "total_documents": 0
            },
            "cloud_master": {
                "title": "Cloud Master", 
                "description": "클라우드 마스터 과정",
                "days": 3,
                "total_documents": 0
            },
            "cloud_container": {
                "title": "Cloud Container",
                "description": "클라우드 컨테이너 과정", 
                "days": 3,
                "total_documents": 0
            }
        }
        
        # 실제 문서 수 계산
        for course_name in structure.keys():
            course_path = self.knowledge_base_path / course_name
            if course_path.exists():
                total_docs = 0
                for day_dir in course_path.glob("textbook/Day*"):
                    if day_dir.is_dir():
                        md_files = list(day_dir.glob("*.md"))
                        total_docs += len(md_files)
                structure[course_name]["total_documents"] = total_docs
        
        return structure
    
    def generate_css(self) -> str:
        """CSS 스타일 생성"""
        return """
        <style>
        body {
            font-family: 'Malgun Gothic', 'Apple SD Gothic Neo', sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
            page-break-before: always;
        }
        
        h1:first-child {
            page-break-before: avoid;
        }
        
        h2 {
            color: #34495e;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 5px;
            margin-top: 30px;
        }
        
        h3 {
            color: #7f8c8d;
            margin-top: 25px;
        }
        
        .course-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            text-align: center;
        }
        
        .day-section {
            background: #f8f9fa;
            border-left: 5px solid #3498db;
            padding: 20px;
            margin: 20px 0;
            border-radius: 5px;
        }
        
        .document-item {
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 15px;
            margin: 10px 0;
            background: white;
        }
        
        .document-item h4 {
            margin-top: 0;
            color: #495057;
        }
        
        .badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            margin-right: 10px;
        }
        
        .badge-practice {
            background: #fff3e0;
            color: #f57c00;
        }
        
        .badge-guide {
            background: #fce4ec;
            color: #c2185b;
        }
        
        .badge-troubleshooting {
            background: #ffebee;
            color: #d32f2f;
        }
        
        .badge-comparison {
            background: #e8f5e8;
            color: #388e3c;
        }
        
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        
        .stat-card {
            background: white;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
        }
        
        .stat-number {
            font-size: 2em;
            font-weight: bold;
            color: #007bff;
        }
        
        .stat-label {
            color: #6c757d;
            margin-top: 5px;
        }
        
        .toc {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }
        
        .toc ul {
            list-style-type: none;
            padding-left: 0;
        }
        
        .toc li {
            margin: 5px 0;
        }
        
        .toc a {
            text-decoration: none;
            color: #495057;
        }
        
        .toc a:hover {
            color: #007bff;
        }
        
        pre {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 4px;
            padding: 15px;
            overflow-x: auto;
        }
        
        code {
            background: #f8f9fa;
            border-radius: 4px;
            padding: 2px 4px;
        }
        
        .alert {
            padding: 15px;
            margin: 15px 0;
            border-radius: 4px;
            border-left: 4px solid;
        }
        
        .alert-info {
            background: #d1ecf1;
            border-color: #17a2b8;
            color: #0c5460;
        }
        
        .alert-success {
            background: #d4edda;
            border-color: #28a745;
            color: #155724;
        }
        
        @media print {
            body { margin: 0; }
            .page-break { page-break-before: always; }
        }
        </style>
        """
    
    def get_document_badge(self, filename: str) -> str:
        """문서 유형 배지"""
        if "practice" in filename.lower():
            return '<span class="badge badge-practice">실습</span>'
        elif "guide" in filename.lower():
            return '<span class="badge badge-guide">가이드</span>'
        elif "troubleshooting" in filename.lower():
            return '<span class="badge badge-troubleshooting">문제해결</span>'
        elif "comparison" in filename.lower():
            return '<span class="badge badge-comparison">비교</span>'
        else:
            return '<span class="badge badge-guide">문서</span>'
    
    def generate_toc(self, structure: Dict[str, Any]) -> str:
        """목차 생성"""
        html = """
        <div class="toc">
            <h2>📋 목차</h2>
            <ul>
        """
        
        for course_name, course_info in structure.items():
            course_title = course_info["title"]
            html += f"""
                <li>
                    <a href="#{course_name}">{course_title} 과정</a>
                    <ul>
            """
            
            for day in range(1, course_info["days"] + 1):
                html += f'<li><a href="#{course_name}_day{day}">Day {day}</a></li>'
            
            html += """
                    </ul>
                </li>
            """
        
        html += """
            </ul>
        </div>
        """
        
        return html
    
    def generate_course_overview(self, course_name: str, course_info: Dict[str, Any]) -> str:
        """과정 개요 생성"""
        return f"""
        <div class="course-header">
            <h1>🎯 {course_info['title']} 과정</h1>
            <p>{course_info['description']}</p>
        </div>
        
        <div class="stats">
            <div class="stat-card">
                <div class="stat-number">{course_info['days']}</div>
                <div class="stat-label">교육 일수</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">{course_info['total_documents']}</div>
                <div class="stat-label">총 문서 수</div>
            </div>
        </div>
        """
    
    def generate_day_section(self, course_name: str, day_num: int) -> str:
        """Day 섹션 생성"""
        day_path = self.knowledge_base_path / course_name / "textbook" / f"Day{day_num}"
        
        if not day_path.exists():
            return ""
        
        html = f"""
        <div class="day-section" id="{course_name}_day{day_num}">
            <h2>📅 Day {day_num}</h2>
        """
        
        # README.md 파일 처리
        readme_path = day_path / "README.md"
        if readme_path.exists():
            content = self.read_file_safe(readme_path)
            if content:
                html_content = self.markdown_to_html_simple(content)
                html += f"""
                <div class="document-item">
                    <h3>📋 Day {day_num} 메인 가이드</h3>
                    <div>{html_content}</div>
                </div>
                """
        
        # practice 디렉토리 문서들
        practice_path = day_path / "practice"
        if practice_path.exists():
            for md_file in sorted(practice_path.glob("*.md")):
                content = self.read_file_safe(md_file)
                if content:
                    # 간단한 미리보기 (처음 300자)
                    preview = content[:300] + "..." if len(content) > 300 else content
                    html_content = self.markdown_to_html_simple(preview)
                    badge = self.get_document_badge(md_file.name)
                    
                    html += f"""
                    <div class="document-item">
                        <h4>{badge} {md_file.stem.replace('_', ' ').replace('-', ' ').title()}</h4>
                        <div>{html_content}</div>
                    </div>
                    """
        
        # 기타 마크다운 파일들
        for md_file in sorted(day_path.glob("*.md")):
            if md_file.name == "README.md":
                continue
                
            content = self.read_file_safe(md_file)
            if content:
                preview = content[:300] + "..." if len(content) > 300 else content
                html_content = self.markdown_to_html_simple(preview)
                badge = self.get_document_badge(md_file.name)
                
                html += f"""
                <div class="document-item">
                    <h4>{badge} {md_file.stem.replace('_', ' ').replace('-', ' ').title()}</h4>
                    <div>{html_content}</div>
                </div>
                """
        
        html += "</div>"
        return html
    
    def generate_complete_textbook(self) -> str:
        """완전한 교재 HTML 생성"""
        structure = self.get_course_structure()
        
        html = f"""
        <!DOCTYPE html>
        <html lang="ko">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>클라우드 실무력 강화 교재</title>
            {self.generate_css()}
        </head>
        <body>
            <div class="course-header">
                <h1>🎓 클라우드 실무력 강화 교재</h1>
                <p>체계적인 클라우드 교육을 위한 통합 교재</p>
                <p>생성일: {datetime.now().strftime('%Y년 %m월 %d일')}</p>
            </div>
            
            {self.generate_toc(structure)}
            
            <div class="alert alert-info">
                <strong>📚 교재 사용법:</strong> 이 교재는 클라우드 기초부터 고급까지의 체계적인 학습을 위해 구성되었습니다. 
                각 과정을 순서대로 학습하시기 바랍니다.
            </div>
        """
        
        # 각 과정별 섹션 생성
        for course_name, course_info in structure.items():
            html += f"""
            <div class="page-break" id="{course_name}">
                {self.generate_course_overview(course_name, course_info)}
            """
            
            for day in range(1, course_info["days"] + 1):
                html += self.generate_day_section(course_name, day)
            
            html += "</div>"
        
        # 마무리 섹션
        html += """
            <div class="page-break">
                <h1>🎯 학습 완료 후 다음 단계</h1>
                <div class="alert alert-success">
                    <h3>축하합니다! 모든 과정을 완료하셨습니다.</h3>
                    <p>이제 다음 단계로 진행하실 수 있습니다:</p>
                    <ul>
                        <li>실제 프로젝트에 클라우드 기술 적용</li>
                        <li>클라우드 자격증 취득</li>
                        <li>고급 클라우드 아키텍처 학습</li>
                        <li>팀 내 클라우드 기술 공유</li>
                    </ul>
                </div>
            </div>
        </body>
        </html>
        """
        
        return html
    
    def save_textbook(self) -> Path:
        """교재 저장"""
        html_content = self.generate_complete_textbook()
        output_path = self.output_dir / "cloud_textbook.html"
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(html_content)
        
        print(f"✅ 교재 생성 완료: {output_path}")
        print(f"📄 브라우저에서 열어서 PDF로 인쇄하세요!")
        
        return output_path

def main():
    """메인 실행 함수"""
    print("🎓 클라우드 실무력 강화 교재 생성기")
    print("=" * 50)
    
    generator = SimpleTextbookGenerator()
    
    try:
        output_path = generator.save_textbook()
        
        print("\n" + "=" * 50)
        print("📚 교재 생성 완료!")
        print("=" * 50)
        print(f"📄 HTML 파일: {output_path}")
        print("💡 PDF로 변환하려면:")
        print("   1. 브라우저에서 HTML 파일을 열기")
        print("   2. Ctrl+P (인쇄) → PDF로 저장 선택")
        print("   3. 또는 온라인 HTML to PDF 변환기 사용")
        print("=" * 50)
        
    except Exception as e:
        print(f"❌ 오류 발생: {e}")

if __name__ == "__main__":
    main()
