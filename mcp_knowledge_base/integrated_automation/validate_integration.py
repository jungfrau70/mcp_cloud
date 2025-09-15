#!/usr/bin/env python3
"""
통합 자동화 시스템 검증 도구
과정 간 연결성 및 리소스 공유 상태 검증
"""

import os
import sys
import json
import yaml
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple
import subprocess
import logging
from datetime import datetime

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class IntegrationValidator:
    """통합 자동화 시스템 검증자"""
    
    def __init__(self, base_path: Path):
        self.base_path = base_path
        # base_path가 이미 integrated_automation 디렉토리인 경우 처리
        if base_path.name == "integrated_automation":
            self.integrated_path = base_path
        else:
            self.integrated_path = base_path / "integrated_automation"
        self.results_path = self.integrated_path / "results"
        self.shared_path = self.integrated_path / "shared_resources"
        
        # 과정별 경로
        if base_path.name == "integrated_automation":
            parent_path = base_path.parent
        else:
            parent_path = base_path
            
        self.courses = {
            "cloud_basic": parent_path / "cloud_basic",
            "cloud_master": parent_path / "cloud_master", 
            "cloud_container": parent_path / "cloud_container"
        }
    
    def validate_directory_structure(self) -> Dict[str, Any]:
        """디렉토리 구조 검증"""
        logger.info("📁 디렉토리 구조 검증 중...")
        
        required_dirs = [
            self.integrated_path,
            self.results_path,
            self.shared_path,
            self.integrated_path / "bridge_scripts"
        ]
        
        required_files = [
            self.integrated_path / "integrated_course_automation.py",
            self.integrated_path / "shared_resource_manager.py",
            self.integrated_path / "integrated_config.json",
            self.integrated_path / "README.md",
            self.integrated_path / "bridge_scripts" / "basic_to_master_bridge.sh",
            self.integrated_path / "bridge_scripts" / "master_to_container_bridge.sh"
        ]
        
        results = {
            "directories": {},
            "files": {},
            "overall_status": "passed"
        }
        
        # 디렉토리 검증
        for dir_path in required_dirs:
            exists = dir_path.exists()
            results["directories"][str(dir_path)] = exists
            if not exists:
                logger.warning(f"❌ 누락된 디렉토리: {dir_path}")
                results["overall_status"] = "failed"
            else:
                logger.info(f"✅ 디렉토리 존재: {dir_path}")
        
        # 파일 검증
        for file_path in required_files:
            exists = file_path.exists()
            results["files"][str(file_path)] = exists
            if not exists:
                logger.warning(f"❌ 누락된 파일: {file_path}")
                results["overall_status"] = "failed"
            else:
                logger.info(f"✅ 파일 존재: {file_path}")
        
        return results
    
    def validate_course_connections(self) -> Dict[str, Any]:
        """과정 간 연결성 검증"""
        logger.info("🔗 과정 간 연결성 검증 중...")
        
        results = {
            "course_automation_scripts": {},
            "bridge_scripts": {},
            "shared_resources": {},
            "overall_status": "passed"
        }
        
        # 각 과정의 자동화 스크립트 확인
        for course_name, course_path in self.courses.items():
            automation_script = course_path / "automation_tests" / f"{course_name}_course_automation.py"
            exists = automation_script.exists()
            results["course_automation_scripts"][course_name] = exists
            
            if exists:
                logger.info(f"✅ {course_name} 자동화 스크립트 존재")
            else:
                logger.warning(f"❌ {course_name} 자동화 스크립트 누락")
                results["overall_status"] = "failed"
        
        # 브리지 스크립트 검증
        bridge_scripts = [
            "basic_to_master_bridge.sh",
            "master_to_container_bridge.sh"
        ]
        
        for script_name in bridge_scripts:
            script_path = self.integrated_path / "bridge_scripts" / script_name
            exists = script_path.exists()
            results["bridge_scripts"][script_name] = exists
            
            if exists:
                logger.info(f"✅ 브리지 스크립트 존재: {script_name}")
            else:
                logger.warning(f"❌ 브리지 스크립트 누락: {script_name}")
                results["overall_status"] = "failed"
        
        return results
    
    def validate_shared_resources(self) -> Dict[str, Any]:
        """공유 리소스 상태 검증"""
        logger.info("📦 공유 리소스 상태 검증 중...")
        
        results = {
            "shared_directories": {},
            "state_files": {},
            "config_files": {},
            "overall_status": "passed"
        }
        
        # 공유 리소스 디렉토리 확인
        if self.shared_path.exists():
            logger.info("✅ 공유 리소스 디렉토리 존재")
            results["shared_directories"]["shared_resources"] = True
        else:
            logger.warning("❌ 공유 리소스 디렉토리 누락")
            results["shared_directories"]["shared_resources"] = False
            results["overall_status"] = "failed"
        
        # 상태 파일 확인
        state_files = [
            "shared_state.json",
            "shared_resources.json"
        ]
        
        for state_file in state_files:
            file_path = self.shared_path / state_file
            exists = file_path.exists()
            results["state_files"][state_file] = exists
            
            if exists:
                logger.info(f"✅ 상태 파일 존재: {state_file}")
            else:
                logger.warning(f"⚠️ 상태 파일 누락: {state_file} (자동 생성됨)")
        
        return results
    
    def validate_configuration(self) -> Dict[str, Any]:
        """설정 파일 검증"""
        logger.info("⚙️ 설정 파일 검증 중...")
        
        results = {
            "integrated_config": {},
            "course_configs": {},
            "overall_status": "passed"
        }
        
        # 통합 설정 파일 검증
        config_file = self.integrated_path / "integrated_config.json"
        if config_file.exists():
            try:
                with open(config_file, 'r', encoding='utf-8') as f:
                    config = json.load(f)
                
                required_keys = [
                    "total_duration_days",
                    "cloud_providers", 
                    "required_tools",
                    "environment_setup"
                ]
                
                for key in required_keys:
                    if key in config:
                        results["integrated_config"][key] = True
                        logger.info(f"✅ 설정 키 존재: {key}")
                    else:
                        results["integrated_config"][key] = False
                        logger.warning(f"❌ 설정 키 누락: {key}")
                        results["overall_status"] = "failed"
                
            except json.JSONDecodeError as e:
                logger.error(f"❌ 설정 파일 JSON 파싱 오류: {e}")
                results["overall_status"] = "failed"
        else:
            logger.warning("❌ 통합 설정 파일 누락")
            results["overall_status"] = "failed"
        
        return results
    
    def validate_tools_installation(self) -> Dict[str, Any]:
        """필요한 도구 설치 상태 검증"""
        logger.info("🛠️ 도구 설치 상태 검증 중...")
        
        required_tools = [
            "aws", "gcloud", "docker", "git", 
            "gh", "kubectl", "helm", "terraform"
        ]
        
        results = {
            "tools": {},
            "overall_status": "passed"
        }
        
        for tool in required_tools:
            try:
                # 도구 버전 확인
                result = subprocess.run(
                    [tool, "--version"], 
                    capture_output=True, 
                    text=True, 
                    timeout=10
                )
                
                if result.returncode == 0:
                    version = result.stdout.strip().split('\n')[0]
                    results["tools"][tool] = {
                        "installed": True,
                        "version": version
                    }
                    logger.info(f"✅ {tool} 설치됨: {version}")
                else:
                    results["tools"][tool] = {
                        "installed": False,
                        "error": result.stderr
                    }
                    logger.warning(f"❌ {tool} 설치되지 않음")
                    results["overall_status"] = "failed"
                    
            except (subprocess.TimeoutExpired, FileNotFoundError) as e:
                results["tools"][tool] = {
                    "installed": False,
                    "error": str(e)
                }
                logger.warning(f"❌ {tool} 설치되지 않음: {e}")
                results["overall_status"] = "failed"
        
        return results
    
    def generate_validation_report(self, all_results: Dict[str, Any]) -> str:
        """검증 보고서 생성"""
        report = f"""# 통합 자동화 시스템 검증 보고서

**생성 시간**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## 📊 검증 결과 요약

"""
        
        # 전체 상태
        overall_status = "✅ 통과" if all_results.get("overall_status") == "passed" else "❌ 실패"
        report += f"**전체 상태**: {overall_status}\n\n"
        
        # 각 검증 항목별 결과
        for category, results in all_results.items():
            if category == "overall_status":
                continue
                
            report += f"### {category.replace('_', ' ').title()}\n\n"
            
            if isinstance(results, dict):
                for item, status in results.items():
                    if isinstance(status, bool):
                        status_icon = "✅" if status else "❌"
                        report += f"- {status_icon} {item}\n"
                    elif isinstance(status, dict):
                        report += f"- **{item}**:\n"
                        for sub_item, sub_status in status.items():
                            if isinstance(sub_status, bool):
                                sub_icon = "✅" if sub_status else "❌"
                                report += f"  - {sub_icon} {sub_item}\n"
                            else:
                                report += f"  - {sub_item}: {sub_status}\n"
            
            report += "\n"
        
        # 권장사항
        report += """## 🔧 권장사항

1. **누락된 파일/디렉토리 생성**
2. **필요한 도구 설치**
3. **설정 파일 검증 및 수정**
4. **정기적인 검증 실행**

## 📞 지원

문제가 발생한 경우 다음을 확인하세요:
- 각 과정의 README.md 파일
- 통합 자동화 시스템 로그
- GitHub Issues

---
*이 보고서는 자동으로 생성되었습니다.*
"""
        
        return report
    
    def run_full_validation(self) -> Dict[str, Any]:
        """전체 검증 실행"""
        logger.info("🚀 통합 자동화 시스템 전체 검증 시작...")
        
        all_results = {}
        
        # 각 검증 단계 실행
        all_results["directory_structure"] = self.validate_directory_structure()
        all_results["course_connections"] = self.validate_course_connections()
        all_results["shared_resources"] = self.validate_shared_resources()
        all_results["configuration"] = self.validate_configuration()
        all_results["tools_installation"] = self.validate_tools_installation()
        
        # 전체 상태 결정
        overall_status = "passed"
        for category, results in all_results.items():
            if isinstance(results, dict) and results.get("overall_status") == "failed":
                overall_status = "failed"
        
        all_results["overall_status"] = overall_status
        
        # 보고서 생성 및 저장
        report = self.generate_validation_report(all_results)
        report_file = self.results_path / f"validation_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
        
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(report)
        
        logger.info(f"📄 검증 보고서 저장: {report_file}")
        
        return all_results

def main():
    """메인 함수"""
    import argparse
    
    parser = argparse.ArgumentParser(description='통합 자동화 시스템 검증 도구')
    parser.add_argument('--base-path', type=str, default='.', 
                       help='기본 경로 (기본값: 현재 디렉토리)')
    parser.add_argument('--output-format', choices=['json', 'markdown'], default='markdown',
                       help='출력 형식 (기본값: markdown)')
    
    args = parser.parse_args()
    
    base_path = Path(args.base_path).resolve()
    validator = IntegrationValidator(base_path)
    
    # 전체 검증 실행
    results = validator.run_full_validation()
    
    # 결과 출력
    if args.output_format == 'json':
        print(json.dumps(results, ensure_ascii=False, indent=2))
    else:
        print(f"\n🎯 검증 완료! 전체 상태: {results['overall_status']}")
        print(f"📄 상세 보고서: {validator.results_path}/validation_report_*.md")

if __name__ == "__main__":
    main()
