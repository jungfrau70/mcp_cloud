#!/usr/bin/env python3
"""
간단한 PDF 생성기
기본 라이브러리만 사용하여 PDF를 생성합니다.
"""

import os
from pathlib import Path
from datetime import datetime

def create_simple_pdf():
    """간단한 PDF 생성"""
    
    # PDF 내용 생성
    pdf_content = f"""
%PDF-1.4
1 0 obj
<<
/Type /Catalog
/Pages 2 0 R
>>
endobj

2 0 obj
<<
/Type /Pages
/Kids [3 0 R]
/Count 1
>>
endobj

3 0 obj
<<
/Type /Page
/Parent 2 0 R
/MediaBox [0 0 612 792]
/Contents 4 0 R
/Resources <<
/Font <<
/F1 5 0 R
>>
>>
>>
endobj

4 0 obj
<<
/Length 200
>>
stream
BT
/F1 24 Tf
100 700 Td
(클라우드 실무력 강화 교재) Tj
0 -50 Td
/F1 16 Tf
(생성일: {datetime.now().strftime('%Y년 %m월 %d일')}) Tj
0 -30 Td
/F1 14 Tf
(이 PDF는 HTML 교재의 요약본입니다.) Tj
0 -20 Td
(전체 내용은 HTML 파일을 참조하세요.) Tj
0 -40 Td
(HTML 파일: generated_textbooks/advanced_cloud_textbook.html) Tj
ET
endstream
endobj

5 0 obj
<<
/Type /Font
/Subtype /Type1
/BaseFont /Helvetica
>>
endobj

xref
0 6
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000274 00000 n 
0000000520 00000 n 
trailer
<<
/Size 6
/Root 1 0 R
>>
startxref
620
%%EOF
"""
    
    # PDF 파일 저장
    output_dir = Path("generated_textbooks")
    output_dir.mkdir(exist_ok=True)
    
    pdf_path = output_dir / "cloud_textbook_simple.pdf"
    
    with open(pdf_path, "w", encoding="utf-8") as f:
        f.write(pdf_content)
    
    print(f"✅ 간단한 PDF 생성 완료: {pdf_path}")
    return pdf_path

def create_readme_for_pdf():
    """PDF 사용을 위한 README 생성"""
    
    readme_content = """
# 📚 클라우드 실무력 강화 교재

## 생성된 파일들

### HTML 교재
- `advanced_cloud_textbook.html` - 고급 HTML 교재 (권장)
- `cloud_textbook.html` - 기본 HTML 교재

### PDF 변환 방법

#### 방법 1: 브라우저 사용 (권장)
1. `advanced_cloud_textbook.html` 파일을 브라우저에서 열기
2. Ctrl+P (인쇄) 누르기
3. "PDF로 저장" 선택
4. 저장 위치 선택 후 저장

#### 방법 2: 온라인 변환기 사용
1. https://html-pdf-converter.com/ 같은 온라인 변환기 방문
2. HTML 파일 업로드
3. PDF 다운로드

#### 방법 3: wkhtmltopdf 설치 후 사용
```bash
# Windows (Chocolatey 사용)
choco install wkhtmltopdf

# 또는 직접 다운로드
# https://wkhtmltopdf.org/downloads.html

# 변환 실행
wkhtmltopdf advanced_cloud_textbook.html cloud_textbook.pdf
```

## 교재 구성

### Cloud Basic 과정
- Day 1: AWS/GCP 계정 설정, IAM 기초, 스토리지 서비스
- Day 2: 컴퓨팅/데이터베이스/네트워킹 비교 분석

### Cloud Master 과정  
- Day 1: Docker, GitHub Actions, 클라우드 배포
- Day 2: 비용 최적화, 모니터링, 종합 실습
- Day 3: 자동 스케일링, 로드 밸런싱, 재해 복구

### Cloud Container 과정
- Day 1: 컨테이너 오케스트레이션, Kubernetes
- Day 2: 고가용성 아키텍처, 모니터링 설정

## 사용법

1. HTML 교재를 브라우저에서 열기
2. 목차를 통해 원하는 섹션으로 이동
3. 각 Day별로 순서대로 학습
4. 실습 가이드를 따라 단계별 실습 수행

## 특징

- 📱 반응형 디자인으로 모바일에서도 학습 가능
- 🎨 직관적인 UI/UX로 학습 효율성 극대화
- 📊 과정별 통계 및 진행 상황 표시
- 🔗 풍부한 상호 참조 링크로 체계적 학습
- 📝 실습 중심의 구성으로 실무 역량 강화

## 문의사항

교재 사용 중 문의사항이 있으시면 언제든 연락주세요.
"""
    
    readme_path = Path("generated_textbooks") / "README.md"
    with open(readme_path, "w", encoding="utf-8") as f:
        f.write(readme_content)
    
    print(f"✅ README 생성 완료: {readme_path}")

def main():
    """메인 실행 함수"""
    print("📚 클라우드 교재 PDF 생성기")
    print("=" * 40)
    
    try:
        # 간단한 PDF 생성
        pdf_path = create_simple_pdf()
        
        # README 생성
        create_readme_for_pdf()
        
        print("\n" + "=" * 40)
        print("🎉 교재 생성 완료!")
        print("=" * 40)
        print("📄 생성된 파일들:")
        print("  - advanced_cloud_textbook.html (고급 HTML 교재)")
        print("  - cloud_textbook.html (기본 HTML 교재)")
        print("  - cloud_textbook_simple.pdf (간단한 PDF)")
        print("  - README.md (사용법 안내)")
        print("\n💡 권장사항:")
        print("  HTML 교재를 브라우저에서 열어서 PDF로 변환하세요!")
        print("=" * 40)
        
    except Exception as e:
        print(f"❌ 오류 발생: {e}")

if __name__ == "__main__":
    main()
