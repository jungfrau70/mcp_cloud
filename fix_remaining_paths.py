#!/usr/bin/env python3
"""
남은 경로 문제 해결 도구
복잡한 상대 경로 문제들을 해결합니다.
"""

import os
import re
import glob
import datetime

def fix_complex_paths():
    """복잡한 경로 문제들을 해결합니다."""
    print("🔧 복잡한 경로 문제 해결 시작")
    print("=" * 50)
    
    # 모든 마크다운 파일 찾기
    base_path = 'mcp_knowledge_base'
    md_files = [f for f in glob.glob(os.path.join(base_path, '**/*.md'), recursive=True)
                if not f.endswith('.backup') and 'backup' not in f.lower()]
    
    print(f"📊 총 {len(md_files)}개의 마크다운 파일 처리")
    
    fixed_count = 0
    
    for file_path in md_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            updated = False
            
            # 1. ../../../curriculum.md -> /curriculum.md
            if '../../../curriculum.md' in content:
                content = content.replace('../../../curriculum.md', '/curriculum.md')
                updated = True
            
            # 2. ../../../index.md -> /index.md  
            if '../../../index.md' in content:
                content = content.replace('../../../index.md', '/index.md')
                updated = True
            
            # 3. ../../../../curriculum.md -> /curriculum.md
            if '../../../../curriculum.md' in content:
                content = content.replace('../../../../curriculum.md', '/curriculum.md')
                updated = True
            
            # 4. ../../../../index.md -> /index.md
            if '../../../../index.md' in content:
                content = content.replace('../../../../index.md', '/index.md')
                updated = True
            
            # 5. ../../README.md -> ../README.md (상대 경로 수정)
            if '../../README.md' in content:
                content = content.replace('../../README.md', '../README.md')
                updated = True
            
            # 6. 한글 파일명 문제 해결
            # './presentation/클라우드실무력강화_활용법(기초' -> './presentation/README.md'
            if './presentation/클라우드실무력강화_활용법(기초' in content:
                content = content.replace('./presentation/클라우드실무력강화_활용법(기초', './presentation/README.md')
                updated = True
            
            if updated:
                # 백업 파일 생성
                backup_dir = os.path.join(os.path.dirname(file_path), 'backup')
                os.makedirs(backup_dir, exist_ok=True)
                timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                backup_file_path = os.path.join(backup_dir, f"{os.path.basename(file_path)}.backup.{timestamp}")
                with open(backup_file_path, 'w', encoding='utf-8') as f:
                    f.write(original_content)
                
                # 파일 업데이트
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                print(f"✅ {file_path}: 복잡한 경로 수정 완료")
                fixed_count += 1
                
        except Exception as e:
            print(f"❌ {file_path} 처리 중 오류: {e}")
    
    print(f"\n🎉 복잡한 경로 문제 해결 완료: {fixed_count}개 파일 수정")

def create_missing_presentation_files():
    """누락된 프레젠테이션 파일들을 생성합니다."""
    print("\n🔧 누락된 프레젠테이션 파일 생성")
    print("=" * 50)
    
    # Cloud Basic 프레젠테이션 파일 생성
    presentation_files = [
        'mcp_knowledge_base/cloud_basic/presentation/클라우드실무력강화_활용법(기초).md',
        'mcp_knowledge_base/cloud_basic/presentation/클라우드실무력강화_활용법(기초)_교재.md',
        'mcp_knowledge_base/cloud_basic/presentation/클라우드실무력강화_활용법(기초)_실습.md'
    ]
    
    created_count = 0
    
    for file_path in presentation_files:
        if not os.path.exists(file_path):
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            
            # 파일명에서 제목 추출
            filename = os.path.basename(file_path).replace('.md', '')
            title = filename.replace('_', ' ').replace('(', ' (').replace(')', ')')
            
            content = f"""# {title}

이 문서는 {title}에 대한 프레젠테이션 자료입니다.

## 📚 내용 개요

- 클라우드 기초 개념
- 실무 활용 방법
- 실습 가이드

## 🔗 관련 링크

- [📚 전체 커리큘럼](/curriculum.md)
- [🏠 학습 경로로 돌아가기](/index.md)
- [📖 Cloud Basic 학습 경로](./learning-path.md)
"""
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"✅ {file_path} 생성 완료")
            created_count += 1
        else:
            print(f"📄 {file_path} 이미 존재")
    
    print(f"\n🎉 프레젠테이션 파일 생성 완료: {created_count}개 파일 생성")

def main():
    """메인 함수"""
    print("🚀 남은 경로 문제 해결 시작")
    print("=" * 60)
    
    # 1. 복잡한 경로 문제 해결
    fix_complex_paths()
    
    # 2. 누락된 프레젠테이션 파일 생성
    create_missing_presentation_files()
    
    print("\n🎊 모든 경로 문제 해결 완료!")

if __name__ == "__main__":
    main()
