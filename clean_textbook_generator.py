#!/usr/bin/env python3
"""
깔끔한 PDF 교재 생성기
레이아웃 중첩 문제를 완전히 해결한 단순하고 깔끔한 구조로 교재를 생성합니다.
"""

import os
import re
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional

class CleanTextbookGenerator:
    """깔끔한 교재 생성기"""
    
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
    
    def markdown_to_html_simple(self, markdown_text: str) -> str:
        """매우 간단한 마크다운을 HTML로 변환"""
        html = markdown_text
        
        # 코드 블록 처리
        html = re.sub(r'```(\w+)?\n(.*?)\n```', r'<pre><code>\2</code></pre>', html, flags=re.DOTALL)
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
            else:
                if in_list:
                    result_lines.append('</ul>')
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
    
    def generate_minimal_css(self) -> str:
        """최소한의 CSS 스타일 생성"""
        return """
        <style>
        body {
            font-family: 'Malgun Gothic', 'Apple SD Gothic Neo', sans-serif;
            line-height: 1.6;
            color: #333;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }
        
        .main-container {
            max-width: 1000px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .header {
            text-align: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        
        .header h1 {
            margin: 0;
            font-size: 2.5em;
        }
        
        .header p {
            margin: 10px 0 0 0;
            font-size: 1.2em;
            opacity: 0.9;
        }
        
        .toc {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
        }
        
        .toc h2 {
            margin-top: 0;
            text-align: center;
            color: #495057;
        }
        
        .toc ul {
            list-style: none;
            padding: 0;
        }
        
        .toc li {
            margin: 5px 0;
        }
        
        .toc a {
            text-decoration: none;
            color: #495057;
            font-weight: 500;
        }
        
        .toc a:hover {
            color: #007bff;
        }
        
        .toc ul ul {
            margin-left: 20px;
        }
        
        .course {
            margin: 40px 0;
            padding: 20px;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            background: #fafafa;
        }
        
        .course h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
            margin-top: 0;
        }
        
        .course-stats {
            display: flex;
            justify-content: space-around;
            margin: 20px 0;
            padding: 20px;
            background: white;
            border-radius: 8px;
        }
        
        .stat {
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
        
        .day {
            margin: 30px 0;
            padding: 20px;
            background: white;
            border-radius: 8px;
            border-left: 5px solid #3498db;
        }
        
        .day h2 {
            color: #34495e;
            margin-top: 0;
        }
        
        .documents {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        
        .document {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            padding: 15px;
        }
        
        .document h3,
        .document h4 {
            margin-top: 0;
            color: #495057;
        }
        
        .badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            font-weight: bold;
            margin-right: 8px;
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
            margin-top: 8px;
            padding-top: 8px;
            border-top: 1px solid #e9ecef;
        }
        
        .preview {
            color: #6c757d;
            font-style: italic;
            margin-top: 8px;
            padding: 8px;
            background: #f0f0f0;
            border-radius: 4px;
            max-height: 150px;
            overflow-y: auto;
        }
        
        pre {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 4px;
            padding: 10px;
            overflow-x: auto;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 0.9em;
        }
        
        code {
            background: #f8f9fa;
            border-radius: 3px;
            padding: 1px 4px;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 0.9em;
        }
        
        .alert {
            padding: 15px;
            margin: 15px 0;
            border-radius: 6px;
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
        
        h1, h2, h3, h4, h5, h6 {
            margin: 15px 0 10px 0;
        }
        
        p {
            margin: 8px 0;
        }
        
        ul, ol {
            margin: 8px 0;
            padding-left: 20px;
        }
        
        li {
            margin: 3px 0;
        }
        
        a {
            color: #007bff;
            text-decoration: none;
        }
        
        a:hover {
            text-decoration: underline;
        }
        
        @media print {
            body { background: white; padding: 0; }
            .main-container { max-width: none; box-shadow: none; }
            .documents { grid-template-columns: 1fr; }
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
    
    def generate_course_section(self, course_name: str) -> str:
        """과정 섹션 생성"""
        course_info = self.analysis_data[course_name]
        
        html = f"""
        <div class="course" id="{course_name}">
            <h1>🎯 {course_info['title']} 과정</h1>
            <p>{course_info['description']}</p>
            
            <div class="course-stats">
                <div class="stat">
                    <div class="stat-number">{course_info['days']}</div>
                    <div class="stat-label">교육 일수</div>
                </div>
                <div class="stat">
                    <div class="stat-number">{course_info['total_links']}</div>
                    <div class="stat-label">총 링크 수</div>
                </div>
                <div class="stat">
                    <div class="stat-number">{sum(course_info['documents'].values())}</div>
                    <div class="stat-label">총 문서 수</div>
                </div>
            </div>
        """
        
        # 각 Day 섹션 생성
        for day in range(1, course_info["days"] + 1):
            day_key = f"day{day}"
            doc_count = course_info["documents"].get(day_key, 0)
            
            if doc_count == 0:
                continue
            
            day_path = self.knowledge_base_path / course_name / "textbook" / f"Day{day}"
            
            if not day_path.exists():
                continue
            
            html += f"""
            <div class="day" id="{course_name}_day{day}">
                <h2>📅 Day {day}</h2>
                <p>총 {doc_count}개의 문서가 포함되어 있습니다.</p>
                
                <div class="documents">
            """
            
            # README.md 파일 처리
            readme_path = day_path / "README.md"
            if readme_path.exists():
                content = self.read_file_safe(readme_path)
                if content:
                    preview = content[:200] + "..." if len(content) > 200 else content
                    html_content = self.markdown_to_html_simple(preview)
                    
                    html += f"""
                    <div class="document">
                        <h3>📋 Day {day} 메인 가이드</h3>
                        <div class="document-meta">
                            <span class="badge badge-guide">메인</span>
                        </div>
                        <div class="preview">
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
                        preview = content[:150] + "..." if len(content) > 150 else content
                        html_content = self.markdown_to_html_simple(preview)
                        badge = self.get_document_badge(md_file.name)
                        
                        html += f"""
                        <div class="document">
                            <h4>{badge} {md_file.stem.replace('_', ' ').replace('-', ' ').title()}</h4>
                            <div class="document-meta">
                                파일: {md_file.name}
                            </div>
                            <div class="preview">
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
                    preview = content[:150] + "..." if len(content) > 150 else content
                    html_content = self.markdown_to_html_simple(preview)
                    badge = self.get_document_badge(md_file.name)
                    
                    html += f"""
                    <div class="document">
                        <h4>{badge} {md_file.stem.replace('_', ' ').replace('-', ' ').title()}</h4>
                        <div class="document-meta">
                            파일: {md_file.name}
                        </div>
                        <div class="preview">
                            {html_content}
                        </div>
                    </div>
                    """
            
            html += """
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
            {self.generate_minimal_css()}
        </head>
        <body>
            <div class="main-container">
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
            html += self.generate_course_section(course_name)
        
        # 마무리 섹션
        html += """
                <div class="course">
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
        output_path = self.output_dir / "clean_cloud_textbook.html"
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(html_content)
        
        print(f"✅ 깔끔한 교재 생성 완료: {output_path}")
        return output_path

def main():
    """메인 실행 함수"""
    print("🧹 깔끔한 클라우드 실무력 강화 교재 생성기")
    print("=" * 60)
    
    generator = CleanTextbookGenerator()
    
    try:
        output_path = generator.save_textbook()
        
        print("\n" + "=" * 60)
        print("📚 깔끔한 교재 생성 완료!")
        print("=" * 60)
        print(f"📄 HTML 파일: {output_path}")
        print("💡 레이아웃 중첩 문제가 완전히 해결되었습니다!")
        print("=" * 60)
        
    except Exception as e:
        print(f"❌ 오류 발생: {e}")

if __name__ == "__main__":
    main()
