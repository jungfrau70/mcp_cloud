#!/usr/bin/env python3
"""
HTML을 PDF로 변환하는 도구
여러 방법을 시도하여 PDF 변환을 수행합니다.
"""

import os
import subprocess
import webbrowser
from pathlib import Path
from typing import Optional

class PDFConverter:
    """PDF 변환기"""
    
    def __init__(self, html_file: Path):
        self.html_file = html_file
        self.pdf_file = html_file.with_suffix('.pdf')
    
    def convert_with_wkhtmltopdf(self) -> bool:
        """wkhtmltopdf를 사용한 변환"""
        try:
            cmd = [
                'wkhtmltopdf',
                '--page-size', 'A4',
                '--margin-top', '1in',
                '--margin-right', '1in',
                '--margin-bottom', '1in',
                '--margin-left', '1in',
                '--encoding', 'UTF-8',
                '--print-media-type',
                '--disable-smart-shrinking',
                '--zoom', '1.0',
                '--dpi', '300',
                str(self.html_file),
                str(self.pdf_file)
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0:
                print(f"✅ wkhtmltopdf로 PDF 생성 완료: {self.pdf_file}")
                return True
            else:
                print(f"❌ wkhtmltopdf 오류: {result.stderr}")
                return False
                
        except FileNotFoundError:
            print("⚠️ wkhtmltopdf가 설치되지 않았습니다.")
            return False
        except Exception as e:
            print(f"❌ wkhtmltopdf 변환 오류: {e}")
            return False
    
    def convert_with_chrome(self) -> bool:
        """Chrome을 사용한 변환"""
        try:
            cmd = [
                'chrome',
                '--headless',
                '--disable-gpu',
                '--print-to-pdf=' + str(self.pdf_file),
                '--print-to-pdf-no-header',
                '--run-all-compositor-stages-before-draw',
                '--disable-background-timer-throttling',
                '--disable-backgrounding-occluded-windows',
                '--disable-renderer-backgrounding',
                str(self.html_file)
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0:
                print(f"✅ Chrome으로 PDF 생성 완료: {self.pdf_file}")
                return True
            else:
                print(f"❌ Chrome 오류: {result.stderr}")
                return False
                
        except FileNotFoundError:
            print("⚠️ Chrome이 설치되지 않았습니다.")
            return False
        except Exception as e:
            print(f"❌ Chrome 변환 오류: {e}")
            return False
    
    def convert_with_edge(self) -> bool:
        """Edge를 사용한 변환"""
        try:
            cmd = [
                'msedge',
                '--headless',
                '--disable-gpu',
                '--print-to-pdf=' + str(self.pdf_file),
                '--print-to-pdf-no-header',
                '--run-all-compositor-stages-before-draw',
                '--disable-background-timer-throttling',
                '--disable-backgrounding-occluded-windows',
                '--disable-renderer-backgrounding',
                str(self.html_file)
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0:
                print(f"✅ Edge로 PDF 생성 완료: {self.pdf_file}")
                return True
            else:
                print(f"❌ Edge 오류: {result.stderr}")
                return False
                
        except FileNotFoundError:
            print("⚠️ Edge가 설치되지 않았습니다.")
            return False
        except Exception as e:
            print(f"❌ Edge 변환 오류: {e}")
            return False
    
    def open_in_browser(self) -> None:
        """브라우저에서 열기"""
        try:
            webbrowser.open(f'file://{self.html_file.absolute()}')
            print(f"🌐 브라우저에서 열기: {self.html_file}")
            print("💡 브라우저에서 Ctrl+P → PDF로 저장을 선택하세요.")
        except Exception as e:
            print(f"❌ 브라우저 열기 오류: {e}")
    
    def convert(self) -> bool:
        """PDF 변환 시도"""
        print(f"🔄 PDF 변환 시작: {self.html_file}")
        print("=" * 50)
        
        # 여러 방법 시도
        methods = [
            ("wkhtmltopdf", self.convert_with_wkhtmltopdf),
            ("Chrome", self.convert_with_chrome),
            ("Edge", self.convert_with_edge)
        ]
        
        for method_name, method_func in methods:
            print(f"🔍 {method_name} 시도 중...")
            if method_func():
                return True
        
        print("⚠️ 모든 자동 변환 방법이 실패했습니다.")
        print("🌐 브라우저에서 수동으로 변환하세요.")
        self.open_in_browser()
        return False

def main():
    """메인 실행 함수"""
    print("📄 HTML to PDF 변환기")
    print("=" * 30)
    
    # HTML 파일 찾기
    html_files = list(Path("generated_textbooks").glob("*.html"))
    
    if not html_files:
        print("❌ HTML 파일을 찾을 수 없습니다.")
        print("먼저 교재 생성기를 실행하세요: python advanced_textbook_generator.py")
        return
    
    # 가장 최근 파일 선택
    html_file = max(html_files, key=lambda f: f.stat().st_mtime)
    print(f"📄 변환할 파일: {html_file}")
    
    # PDF 변환
    converter = PDFConverter(html_file)
    success = converter.convert()
    
    if success:
        print("\n" + "=" * 50)
        print("🎉 PDF 변환 완료!")
        print(f"📚 PDF 파일: {converter.pdf_file}")
        print("=" * 50)
    else:
        print("\n" + "=" * 50)
        print("⚠️ 자동 변환 실패")
        print("💡 브라우저에서 수동으로 PDF 변환을 시도하세요.")
        print("=" * 50)

if __name__ == "__main__":
    main()
