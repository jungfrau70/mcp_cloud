#!/usr/bin/env python3
"""
학습 경로 업데이트 도구
누락된 문서를 학습 경로에 자동으로 추가합니다.
"""

import argparse
import os
import re
import glob
import sys
from pathlib import Path
from datetime import datetime

def categorize_document(file_path):
    """문서를 카테고리별로 분류"""
    categories = {
        'course_info': ['과정명.md', '과정상세.md'],
        'practice': ['practice/'],
        'guide': ['-guide.md', '-가이드.md'],
        'automation': ['automation/', 'automation_tests/'],
        'install': ['install/'],
        'presentation': ['presentation/'],
        'accounts': ['accounts/'],
        'textbook': ['textbook/']
    }
    
    for category, patterns in categories.items():
        for pattern in patterns:
            if pattern in file_path:
                return category
    
    return 'other'

def get_section_template(category):
    """카테고리별 섹션 템플릿 반환"""
    templates = {
        'course_info': {
            'title': '### 과정 상세 정보',
            'items': []
        },
        'practice': {
            'title': '#### 실습 가이드',
            'items': []
        },
        'guide': {
            'title': '#### 고급 가이드',
            'items': []
        },
        'automation': {
            'title': '### 자동화 가이드',
            'items': []
        },
        'install': {
            'title': '### 필수 도구 설치',
            'items': []
        },
        'presentation': {
            'title': '### 프레젠테이션 가이드',
            'items': []
        },
        'accounts': {
            'title': '#### 계정 관련 문서',
            'items': []
        },
        'textbook': {
            'title': '#### 교재 문서',
            'items': []
        }
    }
    
    return templates.get(category, {
        'title': '#### 기타 문서',
        'items': []
    })

def generate_document_link(file_path, course_name):
    """문서 링크 생성"""
    # 파일명에서 확장자 제거
    name_without_ext = os.path.splitext(os.path.basename(file_path))[0]
    
    # 한글 파일명 처리
    if re.search(r'[가-힣]', name_without_ext):
        display_name = name_without_ext
    else:
        # 영어 파일명을 한글로 변환 (간단한 매핑)
        name_mapping = {
            'aws-gcp-account-setup': 'AWS GCP 계정 설정',
            'docker-advanced-guide': 'Docker 고급 가이드',
            'kubernetes-advanced-guide': 'Kubernetes 고급 가이드',
            'container-orchestration-guide': '컨테이너 오케스트레이션 가이드',
            'auto-recovery-guide': '자동 복구 가이드',
            'comprehensive-practice-guide': '종합 실습 가이드',
            'master-integration-guide': 'Master 연계 가이드',
            'cost-optimization-guide': '비용 최적화 가이드',
            'security-policies-guide': '보안 정책 가이드',
            'high-availability-architecture': '고가용성 아키텍처',
            'monitoring-setup': '모니터링 설정',
            'load-balancing-guide': '로드 밸런싱 가이드',
            'auto-scaling-guide': 'Auto Scaling 가이드',
            'disaster-recovery-guide': '재해 복구 가이드',
            'integration-guide': '통합 가이드'
        }
        display_name = name_mapping.get(name_without_ext, name_without_ext)
    
    return f"- [{display_name}](./{file_path})"

def find_insertion_point(content, category):
    """문서를 삽입할 적절한 위치 찾기"""
    # 카테고리별 삽입 위치 매핑
    insertion_points = {
        'course_info': '## 📚 과정 개요',
        'practice': '### 📚 1일차 실습 자료',
        'guide': '### 📚 1일차 실습 자료',
        'automation': '## 🤖 자동화 및 테스트',
        'install': '## 🛠️ 설치 및 도구 가이드',
        'presentation': '## 📊 프레젠테이션 자료',
        'accounts': '### 1. 클라우드 개념 및 계정 생성',
        'textbook': '### 📚 1일차 실습 자료'
    }
    
    target_section = insertion_points.get(category, '## 📚 과정 개요')
    
    # 해당 섹션 찾기
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if line.strip() == target_section:
            return i + 1
    
    return len(lines)  # 파일 끝에 추가

def add_missing_documents(learning_path_file, course_directory, dry_run=False):
    """누락된 문서를 학습 경로에 추가"""
    try:
        with open(learning_path_file, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"❌ 학습 경로 파일을 찾을 수 없습니다: {learning_path_file}")
        return False
    except Exception as e:
        print(f"❌ 파일 읽기 오류: {e}")
        return False
    
    # 현재 참조된 파일 목록
    referenced_files = set()
    links = re.findall(r'\[([^\]]+)\]\(\./([^)]+)\)', content)
    for link_text, file_path in links:
        referenced_files.add(file_path)
    
    # 실제 존재하는 마크다운 파일 목록
    actual_files = set()
    for md_file in glob.glob(os.path.join(course_directory, '**/*.md'), recursive=True):
        rel_path = os.path.relpath(md_file, course_directory)
        rel_path = rel_path.replace('\\', '/')
        # 백업 파일과 README 파일 제외
        if (not rel_path.endswith('.backup') 
            and not rel_path.endswith('README.md')
            and rel_path != 'learning-path.md'
            and 'backup' not in rel_path.lower()
            and 'Day2_backup' not in rel_path):
            actual_files.add(rel_path)
    
    # 누락된 파일 찾기
    missing_files = actual_files - referenced_files
    
    if not missing_files:
        print("✅ 누락된 문서가 없습니다. 학습 경로가 완전합니다!")
        return True
    
    print(f"📝 {len(missing_files)}개의 누락된 문서를 발견했습니다:")
    for file in sorted(missing_files):
        print(f"  - {file}")
    
    if dry_run:
        print("\n🔍 Dry-run 모드: 실제 변경사항은 적용되지 않습니다.")
        return True
    
    # 카테고리별로 문서 분류
    categorized_docs = {}
    for file_path in missing_files:
        category = categorize_document(file_path)
        if category not in categorized_docs:
            categorized_docs[category] = []
        categorized_docs[category].append(file_path)
    
    # 학습 경로에 문서 추가
    lines = content.split('\n')
    new_content = content
    
    for category, docs in categorized_docs.items():
        if not docs:
            continue
            
        print(f"\n📂 {category} 카테고리에 {len(docs)}개 문서 추가 중...")
        
        # 섹션 템플릿 가져오기
        template = get_section_template(category)
        
        # 문서 링크 생성
        doc_links = []
        for doc in sorted(docs):
            link = generate_document_link(doc, os.path.basename(course_directory))
            doc_links.append(link)
        
        # 삽입할 내용 생성
        section_content = f"\n{template['title']}\n" + "\n".join(doc_links) + "\n"
        
        # 적절한 위치에 삽입
        insertion_point = find_insertion_point(new_content, category)
        lines = new_content.split('\n')
        lines.insert(insertion_point, section_content)
        new_content = '\n'.join(lines)
    
    # 백업 생성
    backup_file = f"{learning_path_file}.backup.{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    try:
        with open(backup_file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"💾 백업 파일 생성: {backup_file}")
    except Exception as e:
        print(f"⚠️  백업 파일 생성 실패: {e}")
    
    # 업데이트된 내용 저장
    try:
        with open(learning_path_file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"✅ 학습 경로 업데이트 완료: {learning_path_file}")
        return True
    except Exception as e:
        print(f"❌ 파일 저장 오류: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='학습 경로 업데이트 도구')
    parser.add_argument('--course', choices=['cloud_basic', 'cloud_master', 'cloud_container'], required=True,
                       help='업데이트할 과정 선택')
    parser.add_argument('--add-missing', action='store_true',
                       help='누락된 문서를 학습 경로에 추가')
    parser.add_argument('--dry-run', action='store_true',
                       help='실제 변경사항을 적용하지 않고 미리보기만 실행')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='상세한 출력 표시')
    
    args = parser.parse_args()
    
    course_path = f"mcp_knowledge_base/{args.course}"
    learning_path_file = f"{course_path}/learning-path.md"
    
    if not os.path.exists(course_path):
        print(f"❌ 과정 디렉토리를 찾을 수 없습니다: {course_path}")
        sys.exit(1)
    
    if args.add_missing:
        print(f"🔧 {args.course} 과정의 학습 경로를 업데이트합니다...")
        success = add_missing_documents(learning_path_file, course_path, args.dry_run)
        
        if success:
            print("🎉 학습 경로 업데이트가 완료되었습니다!")
        else:
            print("❌ 학습 경로 업데이트에 실패했습니다.")
            sys.exit(1)
    else:
        print("ℹ️  --add-missing 옵션을 사용하여 누락된 문서를 추가하세요.")
        print("   --dry-run 옵션으로 미리보기를 확인할 수 있습니다.")

if __name__ == "__main__":
    main()
