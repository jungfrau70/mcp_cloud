#!/usr/bin/env python3
"""
커서룰 적정성 점검 및 현행화 도구
AI 활용 교육 교구 시스템에 특화된 분석을 수행합니다.
"""

import os
import re
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any

class CursorRulesAuditor:
    """커서룰 적정성 점검 도구"""
    
    def __init__(self, rules_path: str = ".cursor/rules"):
        self.rules_path = Path(rules_path)
        self.rules = {}
        self.issues = []
        self.recommendations = []
        
    def load_all_rules(self):
        """모든 커서룰 로드"""
        print("📚 모든 커서룰 로드 중...")
        
        for rule_file in self.rules_path.glob("*.mdc"):
            with open(rule_file, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # 메타데이터 추출
            metadata = self.extract_metadata(content)
            
            self.rules[rule_file.name] = {
                'path': rule_file,
                'content': content,
                'metadata': metadata,
                'size': len(content),
                'last_modified': rule_file.stat().st_mtime
            }
        
        print(f"✅ {len(self.rules)}개 커서룰 로드 완료")
    
    def extract_metadata(self, content: str) -> Dict[str, Any]:
        """커서룰 메타데이터 추출"""
        metadata = {}
        
        # YAML 프론트매터 추출
        yaml_match = re.search(r'^---\n(.*?)\n---', content, re.DOTALL)
        if yaml_match:
            yaml_content = yaml_match.group(1)
            for line in yaml_content.split('\n'):
                if ':' in line:
                    key, value = line.split(':', 1)
                    key = key.strip()
                    value = value.strip()
                    
                    # 배열 처리
                    if value.startswith('[') and value.endswith(']'):
                        value = [item.strip().strip('"\'') for item in value[1:-1].split(',')]
                    
                    # 불린 처리
                    elif value.lower() in ['true', 'false']:
                        value = value.lower() == 'true'
                    
                    metadata[key] = value
        
        return metadata
    
    def analyze_rule_quality(self):
        """커서룰 품질 분석"""
        print("\n🔍 커서룰 품질 분석 중...")
        
        for rule_name, rule_data in self.rules.items():
            issues = []
            
            # 1. 메타데이터 완성도 검사
            required_fields = ['description', 'globs']
            for field in required_fields:
                if field not in rule_data['metadata']:
                    issues.append(f"필수 메타데이터 누락: {field}")
            
            # 2. 교육 교구 시스템 관련성 검사
            content = rule_data['content'].lower()
            education_keywords = [
                '교육', '교구', '커리큘럼', '학습', '수강자', '교육자',
                'curriculum', 'education', 'learning', 'student', 'instructor'
            ]
            
            has_education_focus = any(keyword in content for keyword in education_keywords)
            if not has_education_focus and 'global' not in rule_name:
                issues.append("교육 교구 시스템 관련성 부족")
            
            # 3. 구식 패턴 검사
            outdated_patterns = [
                '멀티클라우드', '클라우드 리소스', 'aws', 'gcp', 'terraform',
                'infrastructure', 'deployment', 'devops'
            ]
            
            has_outdated_patterns = any(pattern in content for pattern in outdated_patterns)
            if has_outdated_patterns:
                issues.append("구식 패턴 포함 (클라우드 관리 관련)")
            
            # 4. 문서 연결 및 앵커 링크 관련성 검사
            if 'anchor' in rule_name or 'link' in rule_name or 'document' in rule_name:
                if 'anchor' not in content and 'link' not in content:
                    issues.append("문서 연결 관련 규칙이지만 앵커/링크 내용 부족")
            
            # 5. 코드 예시 품질 검사
            code_blocks = re.findall(r'```(\w+)?\n(.*?)\n```', content, re.DOTALL)
            if code_blocks and len(code_blocks) < 2:
                issues.append("코드 예시 부족 (최소 2개 권장)")
            
            # 6. 한글/영어 혼용 검사
            korean_count = len(re.findall(r'[가-힣]', content))
            english_count = len(re.findall(r'[a-zA-Z]', content))
            if korean_count > 0 and english_count > 0:
                if korean_count / (korean_count + english_count) < 0.3:
                    issues.append("한글 비율이 낮음 (교육 교구 시스템 특성상 한글 중심 권장)")
            
            if issues:
                self.issues.append({
                    'rule': rule_name,
                    'issues': issues,
                    'severity': 'high' if len(issues) > 3 else 'medium' if len(issues) > 1 else 'low'
                })
    
    def generate_recommendations(self):
        """개선 권장사항 생성"""
        print("\n💡 개선 권장사항 생성 중...")
        
        # 교육 교구 시스템 중심의 권장사항
        self.recommendations = [
            {
                'category': '교육 교구 시스템 특화',
                'priority': 'high',
                'recommendations': [
                    '모든 규칙에 교육/학습 관련 키워드 포함',
                    '수강자/교육자 관점에서의 사용성 강조',
                    '실습 무결성 유지를 위한 검증 규칙 강화',
                    '직관적이고 친절한 설명 가이드라인 추가'
                ]
            },
            {
                'category': '문서 연결 및 앵커 관리',
                'priority': 'high',
                'recommendations': [
                    '앵커 링크 자동 검증 규칙 강화',
                    '문서 간 연결 무결성 보장 규칙 추가',
                    '제목 앵커 일관성 관리 규칙 개선',
                    '한글/이모지 처리 규칙 표준화'
                ]
            },
            {
                'category': '현행화 및 정리',
                'priority': 'medium',
                'recommendations': [
                    '구식 클라우드 관리 관련 규칙 제거 또는 교육 도구로 전환',
                    '중복 규칙 통합 및 정리',
                    '최신 교육 도구 트렌드 반영',
                    'AI 활용 교육 도구 특화 규칙 추가'
                ]
            },
            {
                'category': '코드 품질 및 예시',
                'priority': 'medium',
                'recommendations': [
                    '교육 도구 사용 예시 코드 추가',
                    '실습 가이드 코드 템플릿 제공',
                    '오류 처리 및 사용자 안내 개선',
                    '접근성 및 사용성 고려사항 추가'
                ]
            }
        ]
    
    def generate_audit_report(self):
        """감사 보고서 생성"""
        print("\n📊 감사 보고서 생성 중...")
        
        report = {
            'audit_date': datetime.now().isoformat(),
            'total_rules': len(self.rules),
            'rules_analysis': {},
            'issues_summary': {
                'total_issues': len(self.issues),
                'high_severity': len([i for i in self.issues if i['severity'] == 'high']),
                'medium_severity': len([i for i in self.issues if i['severity'] == 'medium']),
                'low_severity': len([i for i in self.issues if i['severity'] == 'low'])
            },
            'recommendations': self.recommendations,
            'detailed_issues': self.issues
        }
        
        # 각 규칙별 분석
        for rule_name, rule_data in self.rules.items():
            report['rules_analysis'][rule_name] = {
                'size': rule_data['size'],
                'has_education_focus': any(keyword in rule_data['content'].lower() 
                                         for keyword in ['교육', '교구', '커리큘럼', '학습']),
                'has_outdated_patterns': any(pattern in rule_data['content'].lower() 
                                           for pattern in ['멀티클라우드', '클라우드 리소스', 'aws', 'gcp']),
                'metadata_completeness': len(rule_data['metadata']),
                'last_modified': datetime.fromtimestamp(rule_data['last_modified']).isoformat()
            }
        
        # 보고서 저장
        with open('cursor_rules_audit_report.json', 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        print("✅ 감사 보고서 생성 완료: cursor_rules_audit_report.json")
        return report
    
    def print_summary(self):
        """요약 정보 출력"""
        print("\n" + "="*60)
        print("🎯 커서룰 적정성 점검 결과")
        print("="*60)
        
        print(f"📊 총 커서룰 수: {len(self.rules)}개")
        print(f"⚠️ 발견된 문제: {len(self.issues)}개")
        
        if self.issues:
            print("\n🔍 주요 문제점:")
            for issue in self.issues[:5]:  # 상위 5개만 표시
                print(f"  • {issue['rule']}: {', '.join(issue['issues'][:2])}")
        
        print(f"\n💡 개선 권장사항: {len(self.recommendations)}개 카테고리")
        for rec in self.recommendations:
            print(f"  • {rec['category']}: {len(rec['recommendations'])}개 권장사항")

def main():
    """메인 실행 함수"""
    auditor = CursorRulesAuditor()
    
    # 1. 모든 커서룰 로드
    auditor.load_all_rules()
    
    # 2. 품질 분석
    auditor.analyze_rule_quality()
    
    # 3. 권장사항 생성
    auditor.generate_recommendations()
    
    # 4. 보고서 생성
    report = auditor.generate_audit_report()
    
    # 5. 요약 출력
    auditor.print_summary()

if __name__ == "__main__":
    main()
