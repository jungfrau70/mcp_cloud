#!/usr/bin/env python3
"""
Cloud Master 과정 자동화 스크립트
Docker, Git/GitHub, CI/CD 자동화
"""

import os
import sys
import json
import time
import subprocess
import logging
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Any, Optional
import docker
import requests
from github import Github

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('master_course_automation.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class MasterCourseAutomation:
    """Cloud Master 과정 자동화 클래스"""
    
    def __init__(self, base_path: Path):
        self.base_path = base_path
        self.course_name = "cloud_master"
        self.duration_days = 3
        self.status = "not_started"
        self.completed_days = []
        self.created_resources = []
        
        # 클라이언트 초기화
        self.docker_client = None
        self.github_client = None
        
        # 설정 로드
        self.config = self.load_config()
    
    def load_config(self) -> Dict[str, Any]:
        """설정 파일 로드"""
        config_file = self.base_path / "automation_tests" / "config.json"
        
        default_config = {
            "docker_registry": "docker.io",
            "github_org": "cloud-training-org",
            "project_prefix": "cloud-training-master",
            "enable_ci_cd": True,
            "enable_monitoring": True,
            "enable_logging": True,
            "shared_resources": True
        }
        
        if config_file.exists():
            try:
                with open(config_file, 'r', encoding='utf-8') as f:
                    config = json.load(f)
                logger.info("✅ 설정 파일 로드 완료")
                return {**default_config, **config}
            except Exception as e:
                logger.warning(f"⚠️ 설정 파일 로드 실패: {e}")
        
        return default_config
    
    def initialize_clients(self) -> bool:
        """클라이언트 초기화"""
        logger.info("🔧 클라이언트 초기화 중...")
        
        success = True
        
        # Docker 클라이언트 초기화
        try:
            self.docker_client = docker.from_env()
            logger.info("✅ Docker 클라이언트 초기화 완료")
        except Exception as e:
            logger.warning(f"⚠️ Docker 클라이언트 초기화 실패: {e}")
            success = False
        
        # GitHub 클라이언트 초기화
        try:
            github_token = os.getenv('GITHUB_TOKEN')
            if github_token:
                self.github_client = Github(github_token)
                logger.info("✅ GitHub 클라이언트 초기화 완료")
            else:
                logger.warning("⚠️ GitHub 토큰이 설정되지 않음")
        except Exception as e:
            logger.warning(f"⚠️ GitHub 클라이언트 초기화 실패: {e}")
        
        return success
    
    def day1_docker_basics(self) -> bool:
        """1일차: Docker 기초 실습"""
        logger.info("🌅 1일차: Docker 기초 실습 시작")
        
        try:
            # Docker 이미지 빌드
            image_name = f"{self.config['project_prefix']}-app"
            image_tag = "latest"
            
            # 간단한 Dockerfile 생성
            dockerfile_content = """
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
"""
            
            dockerfile_path = self.base_path / "automation_tests" / "Dockerfile"
            with open(dockerfile_path, 'w') as f:
                f.write(dockerfile_content)
            
            # package.json 생성
            package_json = {
                "name": "cloud-training-app",
                "version": "1.0.0",
                "scripts": {
                    "start": "node server.js"
                },
                "dependencies": {
                    "express": "^4.18.0"
                }
            }
            
            package_path = self.base_path / "automation_tests" / "package.json"
            with open(package_path, 'w') as f:
                json.dump(package_json, f, indent=2)
            
            # 간단한 서버 파일 생성
            server_js = """
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
    res.send('Hello from Cloud Training App!');
});

app.listen(port, () => {
    console.log(`App running on port ${port}`);
});
"""
            
            server_path = self.base_path / "automation_tests" / "server.js"
            with open(server_path, 'w') as f:
                f.write(server_js)
            
            # Docker 이미지 빌드
            image, build_logs = self.docker_client.images.build(
                path=str(self.base_path / "automation_tests"),
                tag=f"{image_name}:{image_tag}",
                rm=True
            )
            
            self.created_resources.append(f"Docker Image: {image_name}:{image_tag}")
            logger.info(f"✅ Docker 이미지 빌드 완료: {image_name}:{image_tag}")
            
            # 컨테이너 실행
            container = self.docker_client.containers.run(
                f"{image_name}:{image_tag}",
                detach=True,
                ports={'3000/tcp': 3000},
                name=f"{self.config['project_prefix']}-container"
            )
            
            self.created_resources.append(f"Docker Container: {container.name}")
            logger.info(f"✅ Docker 컨테이너 실행 완료: {container.name}")
            
            self.completed_days.append("day1")
            logger.info("✅ 1일차 Docker 기초 실습 완료")
            return True
            
        except Exception as e:
            logger.error(f"❌ 1일차 Docker 기초 실습 실패: {e}")
            return False
    
    def day2_git_github(self) -> bool:
        """2일차: Git/GitHub 실습"""
        logger.info("🌅 2일차: Git/GitHub 실습 시작")
        
        try:
            # Git 저장소 초기화
            repo_path = self.base_path / "automation_tests" / "sample-repo"
            repo_path.mkdir(exist_ok=True)
            
            # Git 초기화
            subprocess.run(['git', 'init'], cwd=repo_path, check=True)
            logger.info("✅ Git 저장소 초기화 완료")
            
            # README.md 생성
            readme_content = f"""# {self.config['project_prefix']} Sample Repository

이 저장소는 Cloud Master 과정의 Git/GitHub 실습을 위한 샘플 저장소입니다.

## 기능
- Docker 컨테이너화된 Node.js 애플리케이션
- GitHub Actions CI/CD 파이프라인
- 자동화된 테스트 및 배포

## 사용법
```bash
docker build -t {self.config['project_prefix']}-app .
docker run -p 3000:3000 {self.config['project_prefix']}-app
```
"""
            
            readme_path = repo_path / "README.md"
            with open(readme_path, 'w', encoding='utf-8') as f:
                f.write(readme_content)
            
            # .gitignore 생성
            gitignore_content = """
node_modules/
npm-debug.log*
.npm
.env
.DS_Store
"""
            
            gitignore_path = repo_path / ".gitignore"
            with open(gitignore_path, 'w') as f:
                f.write(gitignore_content)
            
            # Git 커밋
            subprocess.run(['git', 'add', '.'], cwd=repo_path, check=True)
            subprocess.run(['git', 'commit', '-m', 'Initial commit'], cwd=repo_path, check=True)
            
            self.created_resources.append(f"Git Repository: {repo_path}")
            logger.info("✅ Git 저장소 설정 완료")
            
            # GitHub 저장소 생성 (시뮬레이션)
            if self.github_client:
                try:
                    repo_name = f"{self.config['project_prefix']}-sample-repo"
                    repo = self.github_client.get_user().create_repo(
                        repo_name,
                        description="Cloud Training Sample Repository",
                        private=False
                    )
                    self.created_resources.append(f"GitHub Repository: {repo.html_url}")
                    logger.info(f"✅ GitHub 저장소 생성 완료: {repo.html_url}")
                except Exception as e:
                    logger.warning(f"⚠️ GitHub 저장소 생성 실패: {e}")
            
            self.completed_days.append("day2")
            logger.info("✅ 2일차 Git/GitHub 실습 완료")
            return True
            
        except Exception as e:
            logger.error(f"❌ 2일차 Git/GitHub 실습 실패: {e}")
            return False
    
    def day3_ci_cd(self) -> bool:
        """3일차: CI/CD 파이프라인 실습"""
        logger.info("🌅 3일차: CI/CD 파이프라인 실습 시작")
        
        try:
            # GitHub Actions 워크플로우 생성
            workflows_dir = self.base_path / "automation_tests" / ".github" / "workflows"
            workflows_dir.mkdir(parents=True, exist_ok=True)
            
            workflow_content = f"""name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Build Docker image
      run: docker build -t {self.config['project_prefix']}-app:${{{{ github.sha }}}} .
    
    - name: Run container tests
      run: |
        docker run --name test-container -d -p 3000:3000 {self.config['project_prefix']}-app:${{{{ github.sha }}}}
        sleep 10
        curl -f http://localhost:3000 || exit 1
        docker stop test-container
        docker rm test-container

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to production
      run: |
        echo "Deploying to production..."
        # 실제 배포 로직은 여기에 구현
"""
            
            workflow_path = workflows_dir / "ci-cd.yml"
            with open(workflow_path, 'w') as f:
                f.write(workflow_content)
            
            self.created_resources.append(f"GitHub Actions Workflow: {workflow_path}")
            logger.info("✅ GitHub Actions 워크플로우 생성 완료")
            
            # Docker Compose 파일 생성
            docker_compose_content = f"""version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
    
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - app
    restart: unless-stopped
"""
            
            compose_path = self.base_path / "automation_tests" / "docker-compose.yml"
            with open(compose_path, 'w') as f:
                f.write(docker_compose_content)
            
            self.created_resources.append(f"Docker Compose: {compose_path}")
            logger.info("✅ Docker Compose 파일 생성 완료")
            
            self.completed_days.append("day3")
            logger.info("✅ 3일차 CI/CD 파이프라인 실습 완료")
            return True
            
        except Exception as e:
            logger.error(f"❌ 3일차 CI/CD 파이프라인 실습 실패: {e}")
            return False
    
    def cleanup_resources(self) -> bool:
        """생성된 리소스 정리"""
        logger.info("🧹 리소스 정리 시작")
        
        try:
            # Docker 컨테이너 정리
            if self.docker_client:
                containers = self.docker_client.containers.list(all=True)
                for container in containers:
                    if self.config['project_prefix'] in container.name:
                        container.stop()
                        container.remove()
                        logger.info(f"✅ Docker 컨테이너 삭제 완료: {container.name}")
            
            # Docker 이미지 정리
            if self.docker_client:
                images = self.docker_client.images.list()
                for image in images:
                    if self.config['project_prefix'] in image.tags[0] if image.tags else False:
                        self.docker_client.images.remove(image.id)
                        logger.info(f"✅ Docker 이미지 삭제 완료: {image.tags[0]}")
            
            logger.info("✅ 리소스 정리 완료")
            return True
            
        except Exception as e:
            logger.error(f"❌ 리소스 정리 실패: {e}")
            return False
    
    def generate_report(self) -> Dict[str, Any]:
        """실습 보고서 생성"""
        report = {
            "course_name": self.course_name,
            "duration_days": self.duration_days,
            "status": self.status,
            "completed_days": self.completed_days,
            "created_resources": self.created_resources,
            "completion_rate": len(self.completed_days) / self.duration_days * 100,
            "timestamp": datetime.now().isoformat()
        }
        
        # 보고서 파일 저장
        report_file = self.base_path / "automation_tests" / "master_course_report.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        logger.info(f"📄 보고서 저장: {report_file}")
        return report
    
    def run_course(self) -> bool:
        """전체 과정 실행"""
        logger.info(f"🚀 {self.course_name} 과정 시작")
        self.status = "in_progress"
        
        # 클라이언트 초기화
        if not self.initialize_clients():
            logger.error("❌ 클라이언트 초기화 실패")
            return False
        
        # 1일차 실습
        if not self.day1_docker_basics():
            logger.error("❌ 1일차 실습 실패")
            return False
        
        # 2일차 실습
        if not self.day2_git_github():
            logger.error("❌ 2일차 실습 실패")
            return False
        
        # 3일차 실습
        if not self.day3_ci_cd():
            logger.error("❌ 3일차 실습 실패")
            return False
        
        # 보고서 생성
        report = self.generate_report()
        
        # 과정 완료
        self.status = "completed"
        logger.info(f"🎉 {self.course_name} 과정 완료!")
        logger.info(f"📊 완료율: {report['completion_rate']:.1f}%")
        
        return True

def main():
    """메인 함수"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Cloud Master 과정 자동화')
    parser.add_argument('--base-path', type=str, default='.', 
                       help='기본 경로 (기본값: 현재 디렉토리)')
    parser.add_argument('--cleanup', action='store_true',
                       help='생성된 리소스 정리')
    parser.add_argument('--report-only', action='store_true',
                       help='보고서만 생성')
    
    args = parser.parse_args()
    
    base_path = Path(args.base_path).resolve()
    automation = MasterCourseAutomation(base_path)
    
    if args.cleanup:
        success = automation.cleanup_resources()
    elif args.report_only:
        report = automation.generate_report()
        print(json.dumps(report, ensure_ascii=False, indent=2))
        success = True
    else:
        success = automation.run_course()
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())