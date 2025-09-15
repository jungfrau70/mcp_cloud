"""
자동화 기본 클래스
모든 과정의 자동화 스크립트가 상속받는 기본 클래스
"""

import json
import logging
import time
from abc import ABC, abstractmethod
from typing import Dict, List, Optional, Any
from pathlib import Path
from datetime import datetime

logger = logging.getLogger(__name__)

class AutomationBase(ABC):
    """자동화 기본 클래스"""
    
    def __init__(self, config: Dict[str, Any]):
        """
        AutomationBase 초기화
        
        Args:
            config: 자동화 설정 정보
        """
        self.config = config
        self.course_name = config.get('course_name', 'unknown')
        self.day = config.get('day', 1)
        self.project_prefix = config.get('project_prefix', 'cloud-training')
        self.start_time = datetime.now()
        
        # 로깅 설정
        self._setup_logging()
        
        # 결과 저장
        self.results = {
            'course_name': self.course_name,
            'day': self.day,
            'start_time': self.start_time.isoformat(),
            'end_time': None,
            'duration': None,
            'status': 'running',
            'steps': [],
            'errors': [],
            'warnings': []
        }
        
        logger.info(f"🚀 {self.course_name} Day{self.day} 자동화 시작")
    
    def _setup_logging(self):
        """로깅 설정"""
        log_format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        logging.basicConfig(
            level=logging.INFO,
            format=log_format,
            handlers=[
                logging.FileHandler(f'logs/{self.course_name}_day{self.day}_{self.start_time.strftime("%Y%m%d_%H%M%S")}.log'),
                logging.StreamHandler()
            ]
        )
    
    def log_step(self, step_name: str, status: str, message: str = "", details: Dict[str, Any] = None):
        """
        단계별 로그 기록
        
        Args:
            step_name: 단계명
            status: 상태 (success, error, warning, info)
            message: 메시지
            details: 상세 정보
        """
        step_info = {
            'step_name': step_name,
            'status': status,
            'message': message,
            'timestamp': datetime.now().isoformat(),
            'details': details or {}
        }
        
        self.results['steps'].append(step_info)
        
        if status == 'error':
            self.results['errors'].append(step_info)
            logger.error(f"❌ {step_name}: {message}")
        elif status == 'warning':
            self.results['warnings'].append(step_info)
            logger.warning(f"⚠️ {step_name}: {message}")
        else:
            logger.info(f"✅ {step_name}: {message}")
    
    def log_error(self, step_name: str, error: Exception, details: Dict[str, Any] = None):
        """
        오류 로그 기록
        
        Args:
            step_name: 단계명
            error: 오류 객체
            details: 상세 정보
        """
        self.log_step(
            step_name=step_name,
            status='error',
            message=str(error),
            details=details or {}
        )
    
    def log_warning(self, step_name: str, message: str, details: Dict[str, Any] = None):
        """
        경고 로그 기록
        
        Args:
            step_name: 단계명
            message: 경고 메시지
            details: 상세 정보
        """
        self.log_step(
            step_name=step_name,
            status='warning',
            message=message,
            details=details or {}
        )
    
    def log_success(self, step_name: str, message: str, details: Dict[str, Any] = None):
        """
        성공 로그 기록
        
        Args:
            step_name: 단계명
            message: 성공 메시지
            details: 상세 정보
        """
        self.log_step(
            step_name=step_name,
            status='success',
            message=message,
            details=details or {}
        )
    
    def log_info(self, step_name: str, message: str, details: Dict[str, Any] = None):
        """
        정보 로그 기록
        
        Args:
            step_name: 단계명
            message: 정보 메시지
            details: 상세 정보
        """
        self.log_step(
            step_name=step_name,
            status='info',
            message=message,
            details=details or {}
        )
    
    @abstractmethod
    def setup_environment(self) -> bool:
        """
        환경 설정 (추상 메서드)
        
        Returns:
            설정 성공 여부
        """
        pass
    
    @abstractmethod
    def run_practice(self) -> bool:
        """
        실습 실행 (추상 메서드)
        
        Returns:
            실습 성공 여부
        """
        pass
    
    @abstractmethod
    def cleanup_resources(self) -> bool:
        """
        리소스 정리 (추상 메서드)
        
        Returns:
            정리 성공 여부
        """
        pass
    
    def run_automation(self) -> bool:
        """
        전체 자동화 실행
        
        Returns:
            자동화 성공 여부
        """
        try:
            # 1. 환경 설정
            self.log_info("환경 설정", "환경 설정 시작")
            if not self.setup_environment():
                self.log_error("환경 설정", Exception("환경 설정 실패"))
                return False
            
            # 2. 실습 실행
            self.log_info("실습 실행", "실습 실행 시작")
            if not self.run_practice():
                self.log_error("실습 실행", Exception("실습 실행 실패"))
                return False
            
            # 3. 리소스 정리
            self.log_info("리소스 정리", "리소스 정리 시작")
            if not self.cleanup_resources():
                self.log_warning("리소스 정리", "리소스 정리 실패 (일부 리소스가 남을 수 있음)")
            
            # 4. 완료 처리
            self._finish_automation(success=True)
            return True
            
        except Exception as e:
            self.log_error("자동화 실행", e)
            self._finish_automation(success=False)
            return False
    
    def _finish_automation(self, success: bool):
        """
        자동화 완료 처리
        
        Args:
            success: 성공 여부
        """
        end_time = datetime.now()
        duration = (end_time - self.start_time).total_seconds()
        
        self.results['end_time'] = end_time.isoformat()
        self.results['duration'] = duration
        self.results['status'] = 'success' if success else 'failed'
        
        # 결과 저장
        self._save_results()
        
        if success:
            logger.info(f"🎉 {self.course_name} Day{self.day} 자동화 완료 (소요시간: {duration:.2f}초)")
        else:
            logger.error(f"❌ {self.course_name} Day{self.day} 자동화 실패 (소요시간: {duration:.2f}초)")
    
    def _save_results(self):
        """결과 저장"""
        try:
            results_dir = Path("automation_results")
            results_dir.mkdir(exist_ok=True)
            
            filename = f"{self.course_name}_day{self.day}_{self.start_time.strftime('%Y%m%d_%H%M%S')}.json"
            filepath = results_dir / filename
            
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(self.results, f, ensure_ascii=False, indent=2)
            
            logger.info(f"📊 결과 저장 완료: {filepath}")
            
        except Exception as e:
            logger.error(f"❌ 결과 저장 실패: {e}")
    
    def get_summary(self) -> Dict[str, Any]:
        """
        실행 결과 요약 반환
        
        Returns:
            결과 요약 딕셔너리
        """
        total_steps = len(self.results['steps'])
        success_steps = len([s for s in self.results['steps'] if s['status'] == 'success'])
        error_steps = len(self.results['errors'])
        warning_steps = len(self.results['warnings'])
        
        return {
            'course_name': self.course_name,
            'day': self.day,
            'status': self.results['status'],
            'duration': self.results['duration'],
            'total_steps': total_steps,
            'success_steps': success_steps,
            'error_steps': error_steps,
            'warning_steps': warning_steps,
            'success_rate': (success_steps / total_steps * 100) if total_steps > 0 else 0
        }
    
    def print_summary(self):
        """결과 요약 출력"""
        summary = self.get_summary()
        
        print("\n" + "="*60)
        print(f"📊 {summary['course_name'].upper()} DAY {summary['day']} 자동화 결과")
        print("="*60)
        print(f"상태: {summary['status']}")
        print(f"소요시간: {summary['duration']:.2f}초")
        print(f"총 단계: {summary['total_steps']}")
        print(f"성공: {summary['success_steps']}")
        print(f"오류: {summary['error_steps']}")
        print(f"경고: {summary['warning_steps']}")
        print(f"성공률: {summary['success_rate']:.1f}%")
        print("="*60)
        
        if summary['error_steps'] > 0:
            print("\n❌ 오류 목록:")
            for error in self.results['errors']:
                print(f"  - {error['step_name']}: {error['message']}")
        
        if summary['warning_steps'] > 0:
            print("\n⚠️ 경고 목록:")
            for warning in self.results['warnings']:
                print(f"  - {warning['step_name']}: {warning['message']}")
        
        print()
