#!/usr/bin/env python3
"""
빈 링크 및 앵커 문제 해결 도구
"""

import os
import re
import glob
import datetime

def fix_empty_links():
    """빈 링크 문제를 해결합니다."""
    print("🔧 빈 링크 문제 해결")
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
            
            # 빈 링크 패턴 찾기 및 수정
            # 패턴: [텍스트]() -> [텍스트](#)
            empty_link_pattern = r'\[([^\]]+)\]\(\s*\)'
            matches = re.findall(empty_link_pattern, content)
            
            if matches:
                for match in matches:
                    # 빈 링크를 앵커 링크로 변환
                    anchor_text = match.strip()
                    # 앵커 ID 생성 (이모지 제거, 소문자, 하이픈으로 변환)
                    anchor_id = re.sub(r'[^\w\s가-힣]', '', anchor_text)
                    anchor_id = re.sub(r'\s+', '-', anchor_id.strip()).lower()
                    anchor_id = f"#{anchor_id}"
                    
                    old_link = f"[{match}]()"
                    new_link = f"[{match}]({anchor_id})"
                    
                    content = content.replace(old_link, new_link)
                    updated = True
                    print(f"  🔗 {match} -> {anchor_id}")
            
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
                
                print(f"✅ {file_path}: 빈 링크 수정 완료")
                fixed_count += 1
                
        except Exception as e:
            print(f"❌ {file_path} 처리 중 오류: {e}")
    
    print(f"\n🎉 빈 링크 문제 해결 완료: {fixed_count}개 파일 수정")

def fix_anchor_duplicates():
    """중복된 앵커 문제를 해결합니다."""
    print("\n🔧 중복된 앵커 문제 해결")
    print("=" * 50)
    
    # 앵커 문제가 있는 파일들
    anchor_fixes = [
        {
            'file': 'mcp_knowledge_base/cloud_basic/textbook/Day1/practice/aws_basic_practice.md',
            'fixes': [
                ('#1단계-1단계-aws-계정-생성-및-설정', '#1단계-aws-계정-생성-및-설정'),
                ('#2단계-2단계-iam-사용자-및-권한-관리', '#2단계-iam-사용자-및-권한-관리'),
                ('#3단계-3단계-ec2-인스턴스-생성-및-관리', '#3단계-ec2-인스턴스-생성-및-관리'),
                ('#4단계-4단계-s3-스토리지-서비스-활용', '#4단계-s3-스토리지-서비스-활용')
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_master/textbook/Day1/github-actions-guide.md',
            'fixes': [
                ('#cicd-cicd-개념-이해', '#cicd-개념-이해'),
                ('#cicd-cicd-파이프라인-플로우', '#cicd-파이프라인-플로우')
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_master/textbook/Day1/README.md',
            'fixes': [
                ('#git-gitgithub-기초-및-협업', '#git-github-기초-및-협업'),
                ('#1단계-github-actions-cicd-파이프라인', '#github-actions-cicd-파이프라인')
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_master/textbook/Day3/integration-guide.md',
            'fixes': [
                ('#cicd-자가-치유self-healing', '#자가-치유-self-healing')
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_container/textbook/Day1/README.md',
            'fixes': [
                ('#1단계-고급-cicd-파이프라인', '#고급-cicd-파이프라인')
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_container/textbook/Day1/practice/kubernetes-basics.md',
            'fixes': [
                ('#-gke-클러스터-생성-및-관리', '#gke-클러스터-생성-및-관리'),
                ('#1단계-기본-애플리케이션-배포', '#기본-애플리케이션-배포'),
                ('#-고급-설정-관리', '#고급-설정-관리')
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_container/textbook/Day2/monitoring-setup.md',
            'fixes': [
                ('#prometheus-prometheus--grafana-스택', '#prometheus-grafana-스택')
            ]
        }
    ]
    
    fixed_count = 0
    
    for fix_info in anchor_fixes:
        file_path = fix_info['file']
        if os.path.exists(file_path):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                original_content = content
                updated = False
                
                for old_anchor, new_anchor in fix_info['fixes']:
                    if old_anchor in content:
                        content = content.replace(old_anchor, new_anchor)
                        updated = True
                        print(f"  🔗 {old_anchor} -> {new_anchor}")
                
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
                    
                    print(f"✅ {file_path}: 중복된 앵커 수정 완료")
                    fixed_count += 1
                    
            except Exception as e:
                print(f"❌ {file_path} 처리 중 오류: {e}")
        else:
            print(f"❌ {file_path}: 파일을 찾을 수 없음")
    
    print(f"\n🎉 중복된 앵커 문제 해결 완료: {fixed_count}개 파일 수정")

def create_missing_anchors():
    """누락된 앵커들을 생성합니다."""
    print("\n🔧 누락된 앵커 생성")
    print("=" * 50)
    
    # 앵커가 필요한 파일들
    anchor_files = [
        {
            'file': 'mcp_knowledge_base/cloud_basic/textbook/Day1/practice/aws_basic_practice.md',
            'anchors': [
                '## 🚀 1단계: AWS 계정 생성 및 설정',
                '## 👥 2단계: IAM 사용자 및 권한 관리',
                '## 💻 3단계: EC2 인스턴스 생성 및 관리',
                '## 🗂️ 4단계: S3 스토리지 서비스 활용'
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_master/textbook/Day1/github-actions-guide.md',
            'anchors': [
                '## 🔄 CI/CD 개념 이해',
                '## 🔄 CI/CD 파이프라인 플로우'
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_master/textbook/Day1/README.md',
            'anchors': [
                '## 📝 Git/GitHub 기초 및 협업',
                '## 🚀 GitHub Actions CI/CD 파이프라인'
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_master/textbook/Day3/integration-guide.md',
            'anchors': [
                '## 🔄 자가 치유(Self-healing) 시스템'
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_container/textbook/Day1/README.md',
            'anchors': [
                '## 🚀 고급 CI/CD 파이프라인'
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_container/textbook/Day1/practice/kubernetes-basics.md',
            'anchors': [
                '## GKE 클러스터 생성 및 관리',
                '## 🚀 기본 애플리케이션 배포',
                '## 🔧 고급 설정 관리'
            ]
        },
        {
            'file': 'mcp_knowledge_base/cloud_container/textbook/Day2/monitoring-setup.md',
            'anchors': [
                '## 📈 Prometheus + Grafana 스택'
            ]
        }
    ]
    
    created_count = 0
    
    for anchor_info in anchor_files:
        file_path = anchor_info['file']
        if os.path.exists(file_path):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # 앵커가 이미 있는지 확인
                needs_anchors = False
                for anchor in anchor_info['anchors']:
                    if anchor not in content:
                        needs_anchors = True
                        break
                
                if needs_anchors:
                    # 파일 끝에 앵커 추가
                    content += '\n\n' + '\n\n'.join(anchor_info['anchors']) + '\n'
                    
                    # 백업 파일 생성
                    backup_dir = os.path.join(os.path.dirname(file_path), 'backup')
                    os.makedirs(backup_dir, exist_ok=True)
                    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                    backup_file_path = os.path.join(backup_dir, f"{os.path.basename(file_path)}.backup.{timestamp}")
                    with open(backup_file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    
                    # 파일 업데이트
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    
                    print(f"✅ {file_path}: 누락된 앵커 생성 완료")
                    created_count += 1
                else:
                    print(f"📄 {file_path}: 앵커 이미 존재")
                    
            except Exception as e:
                print(f"❌ {file_path} 처리 중 오류: {e}")
        else:
            print(f"❌ {file_path}: 파일을 찾을 수 없음")
    
    print(f"\n🎉 누락된 앵커 생성 완료: {created_count}개 파일 수정")

def main():
    """메인 함수"""
    print("🚀 빈 링크 및 앵커 문제 해결 시작")
    print("=" * 60)
    
    # 1. 빈 링크 문제 해결
    fix_empty_links()
    
    # 2. 중복된 앵커 문제 해결
    fix_anchor_duplicates()
    
    # 3. 누락된 앵커 생성
    create_missing_anchors()
    
    print("\n🎊 모든 빈 링크 및 앵커 문제 해결 완료!")

if __name__ == "__main__":
    main()
