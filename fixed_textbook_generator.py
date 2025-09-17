#!/usr/bin/env python3
"""
수정된 PDF 교재 생성기
레이아웃 문제를 해결하고 더 깔끔한 구조로 교재를 생성합니다.
"""

import os
import re
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional

class FixedTextbookGenerator:
    """수정된 교재 생성기"""
    
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.output_dir = Path("generated_textbooks")
        self.output_dir.mkdir(exist_ok=True)
        
        # 문서 관계 분석 데이터
        self.analysis_data = {
            "cloud_basic": {
                "title": "Cloud Basic",
                "description": "클라우드 기초 과정",
                "total_links": 77,
                "days": 2,
                "documents": {"day1": 8, "day2": 6}
            },
            "cloud_master": {
                "title": "Cloud Master",
                "description": "클라우드 마스터 과정",
                "total_links": 115,
                "days": 3,
                "documents": {"day1": 15, "day2": 5, "day3": 9}
            },
            "cloud_container": {
                "title": "Cloud Container",
                "description": "클라우드 컨테이너 과정",
                "total_links": 78,
                "days": 3,
                "documents": {"day1": 9, "day2": 7, "day3": 0}
            }
        }
    
    def read_file_safe(self, file_path: Path) -> str:
        """안전한 파일 읽기"""
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return f.read()
        except Exception as e:
            print(f"파일 읽기 오류 {file_path}: {e}")
            return ""
    
    def markdown_to_html_clean(self, markdown_text: str) -> str:
        """깔끔한 마크다운을 HTML로 변환"""
        html = markdown_text
        
        # 코드 블록 처리 (먼저)
        html = re.sub(r'```(\w+)?\n(.*?)\n```', r'<pre><code class="language-\1">\2</code></pre>', html, flags=re.DOTALL)
        
        # 인라인 코드
        html = re.sub(r'`([^`]+)`', r'<code>\1</code>', html)
        
        # 헤딩 변환
        html = re.sub(r'^# (.+)$', r'<h1>\1</h1>', html, flags=re.MULTILINE)
        html = re.sub(r'^## (.+)$', r'<h2>\1</h2>', html, flags=re.MULTILINE)
        html = re.sub(r'^### (.+)$', r'<h3>\1</h3>', html, flags=re.MULTILINE)
        html = re.sub(r'^#### (.+)$', r'<h4>\1</h4>', html, flags=re.MULTILINE)
        
        # 볼드/이탤릭
        html = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', html)
        html = re.sub(r'\*(.+?)\*', r'<em>\1</em>', html)
        
        # 링크
        html = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'<a href="\2">\1</a>', html)
        
        # 리스트 처리
        lines = html.split('\n')
        in_list = False
        result_lines = []
        
        for line in lines:
            if re.match(r'^\s*[-*+]\s+', line):
                if not in_list:
                    result_lines.append('<ul>')
                    in_list = True
                content = re.sub(r'^\s*[-*+]\s+', '', line)
                result_lines.append(f'<li>{content}</li>')
            elif re.match(r'^\s*\d+\.\s+', line):
                if not in_list:
                    result_lines.append('<ol>')
                    in_list = True
                content = re.sub(r'^\s*\d+\.\s+', '', line)
                result_lines.append(f'<li>{content}</li>')
            else:
                if in_list:
                    result_lines.append('</ul>' if 'ol>' not in ''.join(result_lines[-10:]) else '</ol>')
                    in_list = False
                result_lines.append(line)
        
        if in_list:
            result_lines.append('</ul>')
        
        html = '\n'.join(result_lines)
        
        # 단락 처리
        paragraphs = html.split('\n\n')
        html_paragraphs = []
        for p in paragraphs:
            p = p.strip()
            if p and not p.startswith('<') and not p.startswith('#'):
                p = f'<p>{p}</p>'
            html_paragraphs.append(p)
        html = '\n\n'.join(html_paragraphs)
        
        return html
    
    def generate_clean_css(self) -> str:
        """깔끔한 CSS 스타일 생성"""
        return """
        <style>
        * {
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Malgun Gothic', 'Apple SD Gothic Neo', 'Segoe UI', sans-serif;
            line-height: 1.6;
            color: #333;
            margin: 0;
            padding: 0;
            background: #f8f9fa;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background: white;
            min-height: 100vh;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            border-radius: 15px;
            margin-bottom: 30px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        
        .header h1 {
            margin: 0;
            font-size: 2.5em;
            border: none;
            padding: 0;
        }
        
        .header p {
            margin: 10px 0 0 0;
            font-size: 1.2em;
            opacity: 0.9;
        }
        
        .toc {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 12px;
            padding: 30px;
            margin: 30px 0;
        }
        
        .toc h2 {
            margin-top: 0;
            color: #495057;
            text-align: center;
            border: none;
            padding: 0;
        }
        
        .toc ul {
            list-style: none;
            padding: 0;
        }
        
        .toc li {
            margin: 8px 0;
        }
        
        .toc a {
            text-decoration: none;
            color: #495057;
            font-weight: 500;
            display: block;
            padding: 8px 0;
            border-bottom: 1px solid #e9ecef;
        }
        
        .toc a:hover {
            color: #007bff;
        }
        
        .toc ul ul {
            margin-left: 20px;
            margin-top: 5px;
        }
        
        .toc ul ul a {
            font-size: 0.9em;
            color: #6c757d;
            border: none;
            padding: 4px 0;
        }
        
        .course-section {
            margin: 40px 0;
            padding: 30px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        
        .course-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            text-align: center;
        }
        
        .course-header h1 {
            margin: 0;
            font-size: 2.2em;
            border: none;
            padding: 0;
        }
        
        .course-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        
        .stat-card {
            background: white;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        
        .stat-number {
            font-size: 2em;
            font-weight: bold;
            color: #007bff;
            margin-bottom: 10px;
        }
        
        .stat-label {
            color: #6c757d;
            font-size: 1em;
        }
        
        .day-section {
            background: #f8f9fa;
            border-left: 5px solid #3498db;
            padding: 25px;
            margin: 25px 0;
            border-radius: 8px;
        }
        
        .day-section h2 {
            margin-top: 0;
            color: #34495e;
            border: none;
            padding: 0;
            font-size: 1.8em;
        }
        
        .document-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        
        .document-card {
            background: white;
            border: 1px solid #e9ecef;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            transition: box-shadow 0.3s ease;
        }
        
        .document-card:hover {
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .document-card h3,
        .document-card h4 {
            margin-top: 0;
            color: #495057;
            font-size: 1.2em;
        }
        
        .badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 15px;
            font-size: 0.8em;
            font-weight: bold;
            margin-right: 10px;
            text-transform: uppercase;
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
        
        .badge-setup {
            background: #e3f2fd;
            color: #1976d2;
        }
        
        .document-meta {
            font-size: 0.9em;
            color: #6c757d;
            margin-top: 10px;
            padding: 8px 0;
            border-top: 1px solid #e9ecef;
        }
        
        .content-preview {
            color: #6c757d;
            font-style: italic;
            margin-top: 10px;
            padding: 10px;
            background: #f8f9fa;
            border-radius: 5px;
            border-left: 3px solid #dee2e6;
            max-height: 200px;
            overflow-y: auto;
        }
        
        pre {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 15px;
            overflow-x: auto;
            font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
            font-size: 0.9em;
            line-height: 1.4;
        }
        
        code {
            background: #f8f9fa;
            border-radius: 4px;
            padding: 2px 6px;
            font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
            font-size: 0.9em;
        }
        
        pre code {
            background: none;
            padding: 0;
        }
        
        .alert {
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
            border-left: 5px solid;
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
        
        h1, h2, h3, h4, h5, h6 {
            margin: 20px 0 10px 0;
        }
        
        p {
            margin: 10px 0;
        }
        
        ul, ol {
            margin: 10px 0;
            padding-left: 20px;
        }
        
        li {
            margin: 5px 0;
        }
        
        a {
            color: #007bff;
            text-decoration: none;
        }
        
        a:hover {
            text-decoration: underline;
        }
        
        @media print {
            body { background: white; }
            .container { max-width: none; padding: 0; }
            .document-grid { grid-template-columns: 1fr; }
        }
        </style>
        """
    
    def get_document_badge(self, filename: str) -> str:
        """문서 유형 배지"""
        filename_lower = filename.lower()
        
        if "practice" in filename_lower:
            return '<span class="badge badge-practice">실습</span>'
        elif "guide" in filename_lower:
            return '<span class="badge badge-guide">가이드</span>'
        elif "troubleshooting" in filename_lower:
            return '<span class="badge badge-troubleshooting">문제해결</span>'
        elif "comparison" in filename_lower:
            return '<span class="badge badge-comparison">비교</span>'
        elif "setup" in filename_lower or "install" in filename_lower:
            return '<span class="badge badge-setup">설정</span>'
        else:
            return '<span class="badge badge-guide">문서</span>'
    
    def generate_toc(self) -> str:
        """목차 생성"""
        html = """
        <div class="toc">
            <h2>📋 목차</h2>
            <ul>
        """
        
        for course_name, course_info in self.analysis_data.items():
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
    
    def generate_course_overview(self, course_name: str) -> str:
        """과정 개요 생성"""
        course_info = self.analysis_data[course_name]
        
        return f"""
        <div class="course-header">
            <h1>🎯 {course_info['title']} 과정</h1>
            <p>{course_info['description']}</p>
        </div>
        
        <div class="course-stats">
            <div class="stat-card">
                <div class="stat-number">{course_info['days']}</div>
                <div class="stat-label">교육 일수</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">{course_info['total_links']}</div>
                <div class="stat-label">총 링크 수</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">{sum(course_info['documents'].values())}</div>
                <div class="stat-label">총 문서 수</div>
            </div>
        </div>
        """
    
    def generate_day_section(self, course_name: str, day_num: int) -> str:
        """Day 섹션 생성"""
        course_info = self.analysis_data[course_name]
        day_key = f"day{day_num}"
        doc_count = course_info["documents"].get(day_key, 0)
        
        if doc_count == 0:
            return ""
        
        day_path = self.knowledge_base_path / course_name / "textbook" / f"Day{day_num}"
        
        if not day_path.exists():
            return ""
        
        html = f"""
        <div class="day-section" id="{course_name}_day{day_num}">
            <h2>📅 Day {day_num}</h2>
            <p>총 {doc_count}개의 문서가 포함되어 있습니다.</p>
            
            <div class="document-grid">
        """
        
        # README.md 파일 처리
        readme_path = day_path / "README.md"
        if readme_path.exists():
            content = self.read_file_safe(readme_path)
            if content:
                # 간단한 미리보기 (처음 300자)
                preview = content[:300] + "..." if len(content) > 300 else content
                html_content = self.markdown_to_html_clean(preview)
                
                html += f"""
                <div class="document-card">
                    <h3>📋 Day {day_num} 메인 가이드</h3>
                    <div class="document-meta">
                        <span class="badge badge-guide">메인</span>
                    </div>
                    <div class="content-preview">
                        {html_content}
                    </div>
                </div>
                """
        
        # practice 디렉토리 문서들
        practice_path = day_path / "practice"
        if practice_path.exists():
            for md_file in sorted(practice_path.glob("*.md")):
                content = self.read_file_safe(md_file)
                if content:
                    # 간단한 미리보기 (처음 200자)
                    preview = content[:200] + "..." if len(content) > 200 else content
                    html_content = self.markdown_to_html_clean(preview)
                    badge = self.get_document_badge(md_file.name)
                    
                    html += f"""
                    <div class="document-card">
                        <h4>{badge} {md_file.stem.replace('_', ' ').replace('-', ' ').title()}</h4>
                        <div class="document-meta">
                            파일: {md_file.name}
                        </div>
                        <div class="content-preview">
                            {html_content}
                        </div>
                    </div>
                    """
        
        # 기타 마크다운 파일들
        for md_file in sorted(day_path.glob("*.md")):
            if md_file.name == "README.md":
                continue
                
            content = self.read_file_safe(md_file)
            if content:
                preview = content[:200] + "..." if len(content) > 200 else content
                html_content = self.markdown_to_html_clean(preview)
                badge = self.get_document_badge(md_file.name)
                
                html += f"""
                <div class="document-card">
                    <h4>{badge} {md_file.stem.replace('_', ' ').replace('-', ' ').title()}</h4>
                    <div class="document-meta">
                        파일: {md_file.name}
                    </div>
                    <div class="content-preview">
                        {html_content}
                    </div>
                </div>
                """
        
        html += """
            </div>
        </div>
        """
        
        return html
    
    def generate_complete_textbook(self) -> str:
        """완전한 교재 HTML 생성"""
        html = f"""
        <!DOCTYPE html>
        <html lang="ko">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>클라우드 실무력 강화 교재</title>
            {self.generate_clean_css()}
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🎓 클라우드 실무력 강화 교재</h1>
                    <p>체계적인 클라우드 교육을 위한 통합 교재</p>
                    <p>생성일: {datetime.now().strftime('%Y년 %m월 %d일')}</p>
                </div>
                
                {self.generate_toc()}
                
                <div class="alert alert-info">
                    <strong>📚 교재 사용법:</strong> 이 교재는 클라우드 기초부터 고급까지의 체계적인 학습을 위해 구성되었습니다. 
                    각 과정을 순서대로 학습하시기 바랍니다.
                </div>
        """
        
        # 각 과정별 섹션 생성
        for course_name in self.analysis_data.keys():
            html += f"""
            <div class="course-section" id="{course_name}">
                {self.generate_course_overview(course_name)}
            """
            
            course_info = self.analysis_data[course_name]
            for day in range(1, course_info["days"] + 1):
                html += self.generate_day_section(course_name, day)
            
            html += "</div>"
        
        # 마무리 섹션
        html += """
                <div class="course-section">
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
            </div>
        </body>
        </html>
        """
        
        return html
    
    def save_textbook(self) -> Path:
        """교재 저장"""
        html_content = self.generate_complete_textbook()
        output_path = self.output_dir / "fixed_cloud_textbook.html"
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(html_content)
        
        print(f"✅ 수정된 교재 생성 완료: {output_path}")
        return output_path

def main():
    """메인 실행 함수"""
    print("🔧 수정된 클라우드 실무력 강화 교재 생성기")
    print("=" * 60)
    
    generator = FixedTextbookGenerator()
    
    try:
        output_path = generator.save_textbook()
        
        print("\n" + "=" * 60)
        print("📚 수정된 교재 생성 완료!")
        print("=" * 60)
        print(f"📄 HTML 파일: {output_path}")
        print("💡 이제 레이아웃 문제가 해결되었습니다!")
        print("=" * 60)
        
    except Exception as e:
        print(f"❌ 오류 발생: {e}")

if __name__ == "__main__":
    main()
