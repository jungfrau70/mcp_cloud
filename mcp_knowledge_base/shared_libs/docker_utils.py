"""
Docker 공통 유틸리티 함수
Master 과정의 Docker 실습을 위한 유틸리티 클래스
"""

import docker
import json
import logging
import time
from typing import Dict, List, Optional, Any
from pathlib import Path

logger = logging.getLogger(__name__)

class DockerUtils:
    """Docker 공통 유틸리티 클래스"""
    
    def __init__(self, config: Dict[str, Any]):
        """
        DockerUtils 초기화
        
        Args:
            config: Docker 설정 정보
        """
        self.config = config
        self.project_prefix = config.get('project_prefix', 'cloud-training')
        self.docker_registry = config.get('docker_registry', 'docker.io')
        
        # Docker 클라이언트 초기화
        try:
            self.client = docker.from_env()
            logger.info("✅ Docker 클라이언트 초기화 완료")
        except Exception as e:
            logger.error(f"❌ Docker 클라이언트 초기화 실패: {e}")
            self.client = None
    
    def create_sample_app(self, course_name: str, day: int) -> Optional[Path]:
        """
        샘플 애플리케이션 생성 (Master 과정 Day1 연계)
        
        Args:
            course_name: 과정명
            day: 일차
            
        Returns:
            애플리케이션 디렉토리 경로 또는 None
        """
        try:
            app_dir = Path(f"sample_apps/{course_name}_day{day}")
            app_dir.mkdir(parents=True, exist_ok=True)
            
            # package.json 생성
            package_json = {
                "name": f"{self.project_prefix}-{course_name}-day{day}",
                "version": "1.0.0",
                "description": f"Cloud Training {course_name.title()} Day {day} Sample App",
                "main": "server.js",
                "scripts": {
                    "start": "node server.js",
                    "dev": "nodemon server.js",
                    "test": "jest"
                },
                "dependencies": {
                    "express": "^4.18.0",
                    "cors": "^2.8.5",
                    "helmet": "^6.0.0"
                },
                "devDependencies": {
                    "nodemon": "^2.0.20",
                    "jest": "^29.0.0"
                }
            }
            
            with open(app_dir / "package.json", 'w') as f:
                json.dump(package_json, f, indent=2)
            
            # server.js 생성
            server_js = f'''const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const port = process.env.PORT || 3000;

// 미들웨어 설정
app.use(helmet());
app.use(cors());
app.use(express.json());

// 기본 라우트
app.get('/', (req, res) => {{
    res.json({{
        message: 'Cloud Training {course_name.title()} Day {day} Sample App',
        timestamp: new Date().toISOString(),
        course: '{course_name}',
        day: {day},
        status: 'running'
    }});
}});

// 헬스 체크 엔드포인트
app.get('/health', (req, res) => {{
    res.json({{
        status: 'healthy',
        timestamp: new Date().toISOString()
    }});
}});

// 준비 상태 체크 엔드포인트
app.get('/ready', (req, res) => {{
    res.json({{
        status: 'ready',
        timestamp: new Date().toISOString()
    }});
}});

// API 라우트
app.get('/api/info', (req, res) => {{
    res.json({{
        course: '{course_name}',
        day: {day},
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development'
    }});
}});

app.listen(port, '0.0.0.0', () => {{
    console.log(`🚀 {course_name.title()} Day {day} App running on port ${{port}}`);
    console.log(`📚 Course: {course_name}, Day: {day}`);
}});
'''
            
            with open(app_dir / "server.js", 'w') as f:
                f.write(server_js)
            
            # Dockerfile 생성
            dockerfile_content = f'''# Node.js 18 Alpine 이미지 사용
FROM node:18-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 패키지 파일 복사 (캐시 최적화)
COPY package*.json ./

# 의존성 설치
RUN npm ci --only=production

# 소스 코드 복사
COPY . .

# 포트 노출
EXPOSE 3000

# 헬스 체크
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
    CMD curl -f http://localhost:3000/health || exit 1

# 애플리케이션 실행
CMD ["npm", "start"]
'''
            
            with open(app_dir / "Dockerfile", 'w') as f:
                f.write(dockerfile_content)
            
            # .dockerignore 생성
            dockerignore_content = '''node_modules
npm-debug.log*
.npm
.env
.DS_Store
.git
.gitignore
README.md
Dockerfile
.dockerignore
'''
            
            with open(app_dir / ".dockerignore", 'w') as f:
                f.write(dockerignore_content)
            
            # docker-compose.yml 생성
            compose_content = f'''version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - app
    restart: unless-stopped
'''
            
            with open(app_dir / "docker-compose.yml", 'w') as f:
                f.write(compose_content)
            
            logger.info(f"✅ 샘플 애플리케이션 생성 완료: {app_dir}")
            return app_dir
            
        except Exception as e:
            logger.error(f"❌ 샘플 애플리케이션 생성 실패: {e}")
            return None
    
    def build_image(self, app_dir: Path, course_name: str, day: int) -> Optional[str]:
        """
        Docker 이미지 빌드 (Master 과정 Day1 연계)
        
        Args:
            app_dir: 애플리케이션 디렉토리
            course_name: 과정명
            day: 일차
            
        Returns:
            이미지 태그 또는 None
        """
        try:
            if not self.client:
                logger.error("❌ Docker 클라이언트가 초기화되지 않음")
                return None
            
            image_tag = f"{self.project_prefix}-{course_name}-day{day}:latest"
            
            image, build_logs = self.client.images.build(
                path=str(app_dir),
                tag=image_tag,
                rm=True,
                forcerm=True
            )
            
            logger.info(f"✅ Docker 이미지 빌드 완료: {image_tag}")
            return image_tag
            
        except Exception as e:
            logger.error(f"❌ Docker 이미지 빌드 실패: {e}")
            return None
    
    def run_container(self, image_tag: str, course_name: str, day: int) -> Optional[str]:
        """
        Docker 컨테이너 실행 (Master 과정 Day1 연계)
        
        Args:
            image_tag: 이미지 태그
            course_name: 과정명
            day: 일차
            
        Returns:
            컨테이너 ID 또는 None
        """
        try:
            if not self.client:
                logger.error("❌ Docker 클라이언트가 초기화되지 않음")
                return None
            
            container_name = f"{self.project_prefix}-{course_name}-day{day}-container"
            
            container = self.client.containers.run(
                image_tag,
                detach=True,
                ports={'3000/tcp': 3000},
                name=container_name,
                environment={
                    'NODE_ENV': 'production',
                    'COURSE': course_name,
                    'DAY': str(day)
                },
                restart_policy={"Name": "unless-stopped"}
            )
            
            logger.info(f"✅ Docker 컨테이너 실행 완료: {container_name}")
            return container.id
            
        except Exception as e:
            logger.error(f"❌ Docker 컨테이너 실행 실패: {e}")
            return None
    
    def cleanup_containers(self, course_name: str, day: int) -> bool:
        """
        과정별 컨테이너 정리
        
        Args:
            course_name: 과정명
            day: 일차
            
        Returns:
            정리 성공 여부
        """
        try:
            if not self.client:
                logger.error("❌ Docker 클라이언트가 초기화되지 않음")
                return False
            
            # 컨테이너 정리
            containers = self.client.containers.list(all=True)
            for container in containers:
                if f"{self.project_prefix}-{course_name}-day{day}" in container.name:
                    if container.status == 'running':
                        container.stop()
                    container.remove()
                    logger.info(f"✅ 컨테이너 삭제 완료: {container.name}")
            
            # 이미지 정리
            images = self.client.images.list()
            for image in images:
                if f"{self.project_prefix}-{course_name}-day{day}" in image.tags[0] if image.tags else False:
                    self.client.images.remove(image.id)
                    logger.info(f"✅ 이미지 삭제 완료: {image.tags[0]}")
            
            logger.info(f"✅ {course_name} Day{day} Docker 리소스 정리 완료")
            return True
            
        except Exception as e:
            logger.error(f"❌ Docker 리소스 정리 실패: {e}")
            return False
    
    def get_container_status(self, course_name: str, day: int) -> Dict[str, Any]:
        """
        컨테이너 상태 조회
        
        Args:
            course_name: 과정명
            day: 일차
            
        Returns:
            컨테이너 상태 정보
        """
        status = {
            'containers': [],
            'images': []
        }
        
        try:
            if not self.client:
                return status
            
            # 컨테이너 상태
            containers = self.client.containers.list(all=True)
            for container in containers:
                if f"{self.project_prefix}-{course_name}-day{day}" in container.name:
                    status['containers'].append({
                        'id': container.id,
                        'name': container.name,
                        'status': container.status,
                        'image': container.image.tags[0] if container.image.tags else 'unknown'
                    })
            
            # 이미지 상태
            images = self.client.images.list()
            for image in images:
                if f"{self.project_prefix}-{course_name}-day{day}" in image.tags[0] if image.tags else False:
                    status['images'].append({
                        'id': image.id,
                        'tags': image.tags,
                        'created': image.attrs['Created']
                    })
            
            return status
            
        except Exception as e:
            logger.error(f"❌ 컨테이너 상태 조회 실패: {e}")
            return status
