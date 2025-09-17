#!/usr/bin/env python3
"""
고급 PDF 교재 생성기
문서 관계 분석을 기반으로 상세한 PDF 교재를 생성합니다.
"""

import os
import re
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional

class AdvancedTextbookGenerator:
    """고급 교재 생성기"""
    
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.output_dir = Path("generated_textbooks")
        self.output_dir.mkdir(exist_ok=True)
        
        # 문서 관계 분석 데이터
        self.analysis_data = {
            "cloud_basic": {
                "total_links": 77,
                "days": 2,
                "day1_links": 19,
                "day2_links": 11,
                "documents": {
                    "day1": 8,
                    "day2": 6
                }
            },
            "cloud_master": {
                "total_links": 115,
                "days": 3,
                "day1_links": 30,
                "day2_links": 13,
                "day3_links": 16,
                "documents": {
                    "day1": 15,
                    "day2": 5,
                    "day3": 9
                }
            },
            "cloud_container": {
                "total_links": 78,
                "days": 3,
                "day1_links": 23,
                "day2_links": 10,
                "day3_links": 1,
                "documents": {
                    "day1": 9,
                    "day2": 7,
                    "day3": 0
                }
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
    
    def markdown_to_html_advanced(self, markdown_text: str) -> str:
        """고급 마크다운을 HTML로 변환"""
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
        html = re.sub(r'^##### (.+)$', r'<h5>\1</h5>', html, flags=re.MULTILINE)
        html = re.sub(r'^###### (.+)$', r'<h6>\1</h6>', html, flags=re.MULTILINE)
        
        # 볼드/이탤릭
        html = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', html)
        html = re.sub(r'\*(.+?)\*', r'<em>\1</em>', html)
        
        # 링크
        html = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'<a href="\2">\1</a>', html)
        
        # 이미지
        html = re.sub(r'!\[([^\]]*)\]\(([^)]+)\)', r'<img src="\2" alt="\1" style="max-width: 100%; height: auto;">', html)
        
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
        
        # 테이블 처리 (간단한)
        html = re.sub(r'\|(.+)\|\n\|[-:]+\|\n((?:\|.+\|\n?)*)', 
                     lambda m: self.convert_table(m.group(1), m.group(2)), 
                     html, flags=re.MULTILINE)
        
        return html
    
    def convert_table(self, header: str, rows: str) -> str:
        """테이블 변환"""
        header_cells = [cell.strip() for cell in header.split('|') if cell.strip()]
        rows_list = [row.strip() for row in rows.split('\n') if row.strip()]
        
        html = '<table class="table">\n<thead>\n<tr>\n'
        for cell in header_cells:
            html += f'<th>{cell}</th>\n'
        html += '</tr>\n</thead>\n<tbody>\n'
        
        for row in rows_list:
            cells = [cell.strip() for cell in row.split('|') if cell.strip()]
            if cells:
                html += '<tr>\n'
                for cell in cells:
                    html += f'<td>{cell}</td>\n'
                html += '</tr>\n'
        
        html += '</tbody>\n</table>'
        return html
    
    def generate_advanced_css(self) -> str:
        """고급 CSS 스타일 생성"""
        return """
        <style>
        @page {
            margin: 1in;
            @top-center {
                content: "클라우드 실무력 강화 교재";
                font-size: 10pt;
                color: #666;
            }
            @bottom-center {
                content: counter(page);
                font-size: 10pt;
            }
        }
        
        body {
            font-family: 'Malgun Gothic', 'Apple SD Gothic Neo', 'Segoe UI', sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 100%;
            margin: 0;
            padding: 20px;
        }
        
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
            page-break-before: always;
            margin-top: 0;
            font-size: 2.2em;
        }
        
        h1:first-child {
            page-break-before: avoid;
        }
        
        h2 {
            color: #34495e;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 5px;
            margin-top: 30px;
            font-size: 1.8em;
        }
        
        h3 {
            color: #7f8c8d;
            margin-top: 25px;
            font-size: 1.4em;
        }
        
        h4 {
            color: #95a5a6;
            margin-top: 20px;
            font-size: 1.2em;
        }
        
        h5, h6 {
            color: #bdc3c7;
            margin-top: 15px;
        }
        
        .course-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            border-radius: 15px;
            margin-bottom: 40px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        
        .course-header h1 {
            border: none;
            margin: 0;
            font-size: 2.5em;
        }
        
        .day-section {
            background: #f8f9fa;
            border-left: 5px solid #3498db;
            padding: 25px;
            margin: 25px 0;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        
        .document-item {
            border: 1px solid #e9ecef;
            border-radius: 10px;
            padding: 20px;
            margin: 15px 0;
            background: white;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            transition: box-shadow 0.3s ease;
        }
        
        .document-item:hover {
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .document-item h4 {
            margin-top: 0;
            color: #495057;
            font-size: 1.3em;
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
            border: 1px solid #ffcc02;
        }
        
        .badge-guide {
            background: #fce4ec;
            color: #c2185b;
            border: 1px solid #e91e63;
        }
        
        .badge-troubleshooting {
            background: #ffebee;
            color: #d32f2f;
            border: 1px solid #f44336;
        }
        
        .badge-comparison {
            background: #e8f5e8;
            color: #388e3c;
            border: 1px solid #4caf50;
        }
        
        .badge-setup {
            background: #e3f2fd;
            color: #1976d2;
            border: 1px solid #2196f3;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 25px;
            margin: 30px 0;
        }
        
        .stat-card {
            background: white;
            border: 1px solid #dee2e6;
            border-radius: 12px;
            padding: 25px;
            text-align: center;
            box-shadow: 0 3px 10px rgba(0,0,0,0.05);
        }
        
        .stat-number {
            font-size: 2.5em;
            font-weight: bold;
            color: #007bff;
            margin-bottom: 10px;
        }
        
        .stat-label {
            color: #6c757d;
            font-size: 1.1em;
        }
        
        .toc {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 12px;
            padding: 30px;
            margin: 30px 0;
            box-shadow: 0 3px 10px rgba(0,0,0,0.05);
        }
        
        .toc h2 {
            margin-top: 0;
            color: #495057;
            text-align: center;
        }
        
        .toc ul {
            list-style-type: none;
            padding-left: 0;
        }
        
        .toc li {
            margin: 8px 0;
            padding: 5px 0;
        }
        
        .toc a {
            text-decoration: none;
            color: #495057;
            font-weight: 500;
            transition: color 0.3s ease;
        }
        
        .toc a:hover {
            color: #007bff;
        }
        
        .toc ul ul {
            margin-left: 20px;
            margin-top: 5px;
        }
        
        .toc ul ul li {
            margin: 4px 0;
        }
        
        .toc ul ul a {
            font-size: 0.9em;
            color: #6c757d;
        }
        
        pre {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 20px;
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
        
        .table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        
        .table th {
            background: #f8f9fa;
            color: #495057;
            font-weight: bold;
            padding: 15px;
            text-align: left;
            border-bottom: 2px solid #dee2e6;
        }
        
        .table td {
            padding: 15px;
            border-bottom: 1px solid #dee2e6;
        }
        
        .table tr:hover {
            background: #f8f9fa;
        }
        
        .alert {
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
            border-left: 5px solid;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
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
        
        .alert-warning {
            background: #fff3cd;
            border-color: #ffc107;
            color: #856404;
        }
        
        .page-break {
            page-break-before: always;
        }
        
        .no-break {
            page-break-inside: avoid;
        }
        
        .emoji {
            font-size: 1.2em;
            margin-right: 8px;
        }
        
        .content-preview {
            color: #6c757d;
            font-style: italic;
            margin-top: 10px;
            padding: 10px;
            background: #f8f9fa;
            border-radius: 5px;
            border-left: 3px solid #dee2e6;
        }
        
        .document-meta {
            font-size: 0.9em;
            color: #6c757d;
            margin-top: 10px;
            padding: 8px 0;
            border-top: 1px solid #e9ecef;
        }
        
        .link-count {
            background: #e3f2fd;
            color: #1976d2;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            margin-left: 10px;
        }
        
        .course-stats {
            display: flex;
            justify-content: space-around;
            margin: 20px 0;
            padding: 20px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        
        .course-stat {
            text-align: center;
        }
        
        .course-stat-number {
            font-size: 2em;
            font-weight: bold;
            color: #3498db;
        }
        
        .course-stat-label {
            color: #7f8c8d;
            margin-top: 5px;
        }
        
        @media print {
            body { margin: 0; padding: 15px; }
            .page-break { page-break-before: always; }
            .no-break { page-break-inside: avoid; }
            .document-item { page-break-inside: avoid; }
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
            course_title = course_name.replace('_', ' ').title()
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
        course_title = course_name.replace('_', ' ').title()
        
        return f"""
        <div class="course-header">
            <h1>🎯 {course_title} 과정</h1>
            <p>클라우드 실무력 강화를 위한 체계적인 교육 과정</p>
        </div>
        
        <div class="course-stats">
            <div class="course-stat">
                <div class="course-stat-number">{course_info['days']}</div>
                <div class="course-stat-label">교육 일수</div>
            </div>
            <div class="course-stat">
                <div class="course-stat-number">{course_info['total_links']}</div>
                <div class="course-stat-label">총 링크 수</div>
            </div>
            <div class="course-stat">
                <div class="course-stat-number">{sum(course_info['documents'].values())}</div>
                <div class="course-stat-label">총 문서 수</div>
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
        """
        
        # README.md 파일 처리
        readme_path = day_path / "README.md"
        if readme_path.exists():
            content = self.read_file_safe(readme_path)
            if content:
                html_content = self.markdown_to_html_advanced(content)
                html += f"""
                <div class="document-item no-break">
                    <h3>📋 Day {day_num} 메인 가이드</h3>
                    <div class="document-meta">
                        <span class="badge badge-guide">메인</span>
                        <span class="link-count">상세 가이드</span>
                    </div>
                    <div class="content">
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
                    # 간단한 미리보기 (처음 500자)
                    preview = content[:500] + "..." if len(content) > 500 else content
                    html_content = self.markdown_to_html_advanced(preview)
                    badge = self.get_document_badge(md_file.name)
                    
                    html += f"""
                    <div class="document-item no-break">
                        <h4>{badge} {md_file.stem.replace('_', ' ').replace('-', ' ').title()}</h4>
                        <div class="document-meta">
                            파일: {md_file.name}
                        </div>
                        <div class="content">
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
                preview = content[:500] + "..." if len(content) > 500 else content
                html_content = self.markdown_to_html_advanced(preview)
                badge = self.get_document_badge(md_file.name)
                
                html += f"""
                <div class="document-item no-break">
                    <h4>{badge} {md_file.stem.replace('_', ' ').replace('-', ' ').title()}</h4>
                    <div class="document-meta">
                        파일: {md_file.name}
                    </div>
                    <div class="content">
                        {html_content}
                    </div>
                </div>
                """
        
        html += "</div>"
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
            {self.generate_advanced_css()}
        </head>
        <body>
            <div class="course-header">
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
            <div class="page-break" id="{course_name}">
                {self.generate_course_overview(course_name)}
            """
            
            course_info = self.analysis_data[course_name]
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
        output_path = self.output_dir / "advanced_cloud_textbook.html"
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(html_content)
        
        print(f"✅ 고급 교재 생성 완료: {output_path}")
        print(f"📄 브라우저에서 열어서 PDF로 인쇄하세요!")
        
        return output_path

def main():
    """메인 실행 함수"""
    print("🎓 고급 클라우드 실무력 강화 교재 생성기")
    print("=" * 60)
    
    generator = AdvancedTextbookGenerator()
    
    try:
        output_path = generator.save_textbook()
        
        print("\n" + "=" * 60)
        print("📚 고급 교재 생성 완료!")
        print("=" * 60)
        print(f"📄 HTML 파일: {output_path}")
        print("💡 PDF로 변환하려면:")
        print("   1. 브라우저에서 HTML 파일을 열기")
        print("   2. Ctrl+P (인쇄) → PDF로 저장 선택")
        print("   3. 또는 온라인 HTML to PDF 변환기 사용")
        print("=" * 60)
        
    except Exception as e:
        print(f"❌ 오류 발생: {e}")

if __name__ == "__main__":
    main()
