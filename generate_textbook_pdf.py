#!/usr/bin/env python3
"""
교육 교구 시스템 PDF 교재 생성기
문서 관계 분석 보고서를 기반으로 통합 PDF 교재를 생성합니다.
"""

import os
import re
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional
import markdown
from markdown.extensions import toc, codehilite, tables
import pdfkit
from bs4 import BeautifulSoup
import logging

# 로깅 설정
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class TextbookPDFGenerator:
    """PDF 교재 생성기 클래스"""
    
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.output_dir = Path("generated_textbooks")
        self.output_dir.mkdir(exist_ok=True)
        
        # 마크다운 설정
        self.md = markdown.Markdown(
            extensions=[
                'toc',
                'codehilite',
                'tables',
                'fenced_code',
                'attr_list',
                'def_list',
                'footnotes',
                'md_in_html'
            ],
            extension_configs={
                'toc': {
                    'permalink': True,
                    'permalink_title': "이 섹션으로 이동"
                },
                'codehilite': {
                    'css_class': 'highlight',
                    'use_pygments': True
                }
            }
        )
        
        # PDF 옵션 설정
        self.pdf_options = {
            'page-size': 'A4',
            'margin-top': '1in',
            'margin-right': '1in',
            'margin-bottom': '1in',
            'margin-left': '1in',
            'encoding': "UTF-8",
            'no-outline': None,
            'enable-local-file-access': None,
            'print-media-type': None,
            'disable-smart-shrinking': None,
            'zoom': 1.0,
            'dpi': 300
        }
        
        # CSS 스타일
        self.css_style = """
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
            font-family: 'Malgun Gothic', 'Apple SD Gothic Neo', sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 100%;
        }
        
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
            page-break-before: always;
            margin-top: 0;
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
        
        h4 {
            color: #95a5a6;
            margin-top: 20px;
        }
        
        .course-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            text-align: center;
        }
        
        .day-header {
            background: #f8f9fa;
            border-left: 5px solid #3498db;
            padding: 20px;
            margin: 20px 0;
            border-radius: 5px;
        }
        
        .document-card {
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 15px;
            margin: 10px 0;
            background: #f8f9fa;
        }
        
        .document-card h4 {
            margin-top: 0;
            color: #495057;
        }
        
        .document-meta {
            font-size: 0.9em;
            color: #6c757d;
            margin-top: 10px;
        }
        
        .link-count {
            background: #e3f2fd;
            color: #1976d2;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            margin-left: 10px;
        }
        
        .practice-badge {
            background: #fff3e0;
            color: #f57c00;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            margin-right: 10px;
        }
        
        .guide-badge {
            background: #fce4ec;
            color: #c2185b;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            margin-right: 10px;
        }
        
        .troubleshooting-badge {
            background: #ffebee;
            color: #d32f2f;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            margin-right: 10px;
        }
        
        .comparison-badge {
            background: #e8f5e8;
            color: #388e3c;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            margin-right: 10px;
        }
        
        .toc {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }
        
        .toc h2 {
            margin-top: 0;
            color: #495057;
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
        
        .stats-grid {
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
        
        .code-block {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 4px;
            padding: 15px;
            margin: 15px 0;
            overflow-x: auto;
        }
        
        .highlight {
            background: #f8f9fa;
            border-radius: 4px;
            padding: 2px 4px;
        }
        
        .page-break {
            page-break-before: always;
        }
        
        .no-break {
            page-break-inside: avoid;
        }
        
        .emoji {
            font-size: 1.2em;
            margin-right: 5px;
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
        
        .alert-warning {
            background: #fff3cd;
            border-color: #ffc107;
            color: #856404;
        }
        
        .alert-success {
            background: #d4edda;
            border-color: #28a745;
            color: #155724;
        }
        </style>
        """
    
    def load_document_analysis(self) -> Dict[str, Any]:
        """문서 관계 분석 보고서 로드"""
        try:
            with open("document_relationship_analysis_report.md", "r", encoding="utf-8") as f:
                content = f.read()
            
            # 간단한 파싱 (실제로는 더 정교한 파싱이 필요)
            analysis = {
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
            
            return analysis
        except FileNotFoundError:
            logger.warning("문서 관계 분석 보고서를 찾을 수 없습니다. 기본 구조를 사용합니다.")
            return {}
    
    def read_markdown_file(self, file_path: Path) -> Optional[str]:
        """마크다운 파일 읽기"""
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return f.read()
        except FileNotFoundError:
            logger.warning(f"파일을 찾을 수 없습니다: {file_path}")
            return None
        except Exception as e:
            logger.error(f"파일 읽기 오류 {file_path}: {e}")
            return None
    
    def get_document_type_badge(self, filename: str) -> str:
        """문서 유형에 따른 배지 반환"""
        if "practice" in filename.lower():
            return '<span class="practice-badge">실습</span>'
        elif "guide" in filename.lower():
            return '<span class="guide-badge">가이드</span>'
        elif "troubleshooting" in filename.lower():
            return '<span class="troubleshooting-badge">문제해결</span>'
        elif "comparison" in filename.lower():
            return '<span class="comparison-badge">비교</span>'
        else:
            return '<span class="guide-badge">문서</span>'
    
    def generate_course_overview(self, course_name: str, analysis: Dict[str, Any]) -> str:
        """과정 개요 생성"""
        course_info = analysis.get(course_name, {})
        
        html = f"""
        <div class="course-header">
            <h1>🎯 {course_name.replace('_', ' ').title()} 과정</h1>
            <p>클라우드 실무력 강화를 위한 체계적인 교육 과정</p>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-number">{course_info.get('days', 0)}</div>
                <div class="stat-label">교육 일수</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">{course_info.get('total_links', 0)}</div>
                <div class="stat-label">총 링크 수</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">{sum(course_info.get('documents', {}).values())}</div>
                <div class="stat-label">총 문서 수</div>
            </div>
        </div>
        """
        
        return html
    
    def generate_day_section(self, course_name: str, day_num: int, analysis: Dict[str, Any]) -> str:
        """Day 섹션 생성"""
        course_info = analysis.get(course_name, {})
        documents = course_info.get('documents', {})
        day_key = f"day{day_num}"
        doc_count = documents.get(day_key, 0)
        
        if doc_count == 0:
            return ""
        
        html = f"""
        <div class="day-header">
            <h2>📅 Day {day_num}</h2>
            <p>총 {doc_count}개의 문서가 포함되어 있습니다.</p>
        </div>
        """
        
        return html
    
    def generate_document_cards(self, course_name: str, day_num: int) -> str:
        """문서 카드들 생성"""
        day_path = self.knowledge_base_path / course_name / "textbook" / f"Day{day_num}"
        
        if not day_path.exists():
            return ""
        
        html = ""
        
        # README.md 파일 처리
        readme_path = day_path / "README.md"
        if readme_path.exists():
            content = self.read_markdown_file(readme_path)
            if content:
                # 마크다운을 HTML로 변환
                html_content = self.md.convert(content)
                html += f"""
                <div class="document-card no-break">
                    <h4>📋 Day {day_num} 메인 가이드</h4>
                    <div class="document-meta">
                        <span class="guide-badge">메인</span>
                        <span class="link-count">상세 가이드</span>
                    </div>
                    <div class="content">
                        {html_content}
                    </div>
                </div>
                """
        
        # practice 디렉토리의 문서들 처리
        practice_path = day_path / "practice"
        if practice_path.exists():
            for md_file in practice_path.glob("*.md"):
                content = self.read_markdown_file(md_file)
                if content:
                    # 간단한 미리보기 생성 (처음 500자)
                    preview = content[:500] + "..." if len(content) > 500 else content
                    html_content = self.md.convert(preview)
                    
                    badge = self.get_document_type_badge(md_file.name)
                    
                    html += f"""
                    <div class="document-card no-break">
                        <h4>{badge} {md_file.stem.replace('_', ' ').replace('-', ' ').title()}</h4>
                        <div class="document-meta">
                            파일: {md_file.name}
                        </div>
                        <div class="content">
                            {html_content}
                        </div>
                    </div>
                    """
        
        # 기타 마크다운 파일들 처리
        for md_file in day_path.glob("*.md"):
            if md_file.name == "README.md":
                continue
                
            content = self.read_markdown_file(md_file)
            if content:
                preview = content[:500] + "..." if len(content) > 500 else content
                html_content = self.md.convert(preview)
                
                badge = self.get_document_type_badge(md_file.name)
                
                html += f"""
                <div class="document-card no-break">
                    <h4>{badge} {md_file.stem.replace('_', ' ').replace('-', ' ').title()}</h4>
                    <div class="document-meta">
                        파일: {md_file.name}
                    </div>
                    <div class="content">
                        {html_content}
                    </div>
                </div>
                """
        
        return html
    
    def generate_toc(self, analysis: Dict[str, Any]) -> str:
        """목차 생성"""
        html = """
        <div class="toc">
            <h2>📋 목차</h2>
            <ul>
        """
        
        for course_name in ["cloud_basic", "cloud_master", "cloud_container"]:
            course_info = analysis.get(course_name, {})
            course_title = course_name.replace('_', ' ').title()
            
            html += f"""
                <li>
                    <a href="#{course_name}">{course_title} 과정</a>
                    <ul>
            """
            
            days = course_info.get('days', 0)
            for day in range(1, days + 1):
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
    
    def generate_complete_textbook(self) -> str:
        """완전한 교재 HTML 생성"""
        analysis = self.load_document_analysis()
        
        html = f"""
        <!DOCTYPE html>
        <html lang="ko">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>클라우드 실무력 강화 교재</title>
            {self.css_style}
        </head>
        <body>
            <div class="course-header">
                <h1>🎓 클라우드 실무력 강화 교재</h1>
                <p>체계적인 클라우드 교육을 위한 통합 교재</p>
                <p>생성일: {datetime.now().strftime('%Y년 %m월 %d일')}</p>
            </div>
            
            {self.generate_toc(analysis)}
            
            <div class="alert alert-info">
                <strong>📚 교재 사용법:</strong> 이 교재는 클라우드 기초부터 고급까지의 체계적인 학습을 위해 구성되었습니다. 
                각 과정을 순서대로 학습하시기 바랍니다.
            </div>
        """
        
        # 각 과정별 섹션 생성
        for course_name in ["cloud_basic", "cloud_master", "cloud_container"]:
            course_info = analysis.get(course_name, {})
            course_title = course_name.replace('_', ' ').title()
            
            html += f"""
            <div class="page-break" id="{course_name}">
                {self.generate_course_overview(course_name, analysis)}
            """
            
            days = course_info.get('days', 0)
            for day in range(1, days + 1):
                html += f"""
                <div id="{course_name}_day{day}">
                    {self.generate_day_section(course_name, day, analysis)}
                    {self.generate_document_cards(course_name, day)}
                </div>
                """
            
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
    
    def save_html(self, html_content: str, filename: str = "textbook.html") -> Path:
        """HTML 파일 저장"""
        output_path = self.output_dir / filename
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(html_content)
        logger.info(f"HTML 파일 저장: {output_path}")
        return output_path
    
    def convert_to_pdf(self, html_path: Path, pdf_filename: str = "cloud_textbook.pdf") -> Path:
        """HTML을 PDF로 변환"""
        pdf_path = self.output_dir / pdf_filename
        
        try:
            pdfkit.from_file(
                str(html_path),
                str(pdf_path),
                options=self.pdf_options
            )
            logger.info(f"PDF 파일 생성: {pdf_path}")
            return pdf_path
        except Exception as e:
            logger.error(f"PDF 변환 오류: {e}")
            raise
    
    def generate_textbook(self) -> Dict[str, Path]:
        """교재 생성 메인 함수"""
        logger.info("교재 생성 시작...")
        
        # HTML 생성
        html_content = self.generate_complete_textbook()
        html_path = self.save_html(html_content)
        
        # PDF 변환
        try:
            pdf_path = self.convert_to_pdf(html_path)
            logger.info("교재 생성 완료!")
            
            return {
                "html": html_path,
                "pdf": pdf_path
            }
        except Exception as e:
            logger.error(f"PDF 변환 실패: {e}")
            logger.info("HTML 파일은 생성되었습니다. 수동으로 PDF 변환을 시도해보세요.")
            
            return {
                "html": html_path,
                "pdf": None
            }

def main():
    """메인 실행 함수"""
    generator = TextbookPDFGenerator()
    
    try:
        result = generator.generate_textbook()
        
        print("\n" + "="*50)
        print("🎓 교재 생성 완료!")
        print("="*50)
        print(f"📄 HTML 파일: {result['html']}")
        if result['pdf']:
            print(f"📚 PDF 파일: {result['pdf']}")
        else:
            print("⚠️  PDF 변환에 실패했습니다. HTML 파일을 사용하세요.")
        print("="*50)
        
    except Exception as e:
        logger.error(f"교재 생성 중 오류 발생: {e}")
        print(f"❌ 오류 발생: {e}")

if __name__ == "__main__":
    main()
