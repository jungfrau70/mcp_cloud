#!/usr/bin/env python3
"""
Cloud Master Course Automation Script
    

  3   :
- Day 1: Docker, Git/GitHub, GitHub Actions 
- Day 2:  CI/CD  VM   
- Day 3:  , ,  
"""

import os
import sys
import json
import time
import subprocess
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from pathlib import Path
import yaml

#  
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('master_course_automation.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class CourseConfig:
    """  """
    course_name: str = "Cloud Master Course"
    duration_days: int = 3
    daily_hours: int = 7
    start_time: str = "09:00"
    end_time: str = "17:00"
    cloud_providers: List[str] = None
    required_tools: List[str] = None
    
    def __post_init__(self):
        if self.cloud_providers is None:
            self.cloud_providers = ["aws", "gcp"]
        if self.required_tools is None:
            self.required_tools = [
                "docker", "git", "github-cli", "aws-cli", "gcloud-cli"
            ]

@dataclass
class DayPlan:
    """ """
    day: int
    title: str
    topics: List[str]
    hands_on_labs: List[str]
    duration_hours: int
    prerequisites: List[str] = None

class MasterCourseAutomation:
    """   """
    
    def __init__(self, config: CourseConfig):
        self.config = config
        self.project_root = Path(__file__).parent.parent
        self.course_dir = self.project_root / "mcp_knowledge_base" / "cloud_master"
        self.scripts_dir = self.project_root / "automation_tests"
        self.results = {}
        
    def setup_environment(self) -> bool:
        """    """
        logger.info("  ...")
        
        try:
            #   
            missing_tools = self._check_required_tools()
            if missing_tools:
                logger.warning(f"누락된 도구: {missing_tools}")
                logger.info("일부 도구가 누락되었지만 계속 진행합니다...")
            
            #  
            self._create_directories()
            
            #   
            self._setup_environment_variables()
            
            logger.info("  ")
            return True
            
        except Exception as e:
            logger.error(f"  : {e}")
            return False
    
    def _check_required_tools(self) -> List[str]:
        """필수 도구 검증"""
        missing_tools = []
        
        # 필수 도구 검증
        for tool in self.config.required_tools:
            try:
                if tool == "github-cli":
                    result = subprocess.run(["gh", "--version"], 
                                          capture_output=True, text=True, check=True)
                elif tool == "aws-cli":
                    result = subprocess.run(["aws", "--version"], 
                                          capture_output=True, text=True, check=True)
                elif tool == "gcloud-cli":
                    result = subprocess.run(["gcloud", "--version"], 
                                          capture_output=True, text=True, check=True)
                else:
                    result = subprocess.run([tool, "--version"], 
                                          capture_output=True, text=True, check=True)
                logger.info(f"[OK] {tool} ")
            except (subprocess.CalledProcessError, FileNotFoundError):
                missing_tools.append(tool)
                logger.warning(f"[WARN] {tool} ")
        
        return missing_tools
    
    def _create_directories(self):
        """  """
        directories = [
            self.course_dir / "automation",
            self.course_dir / "automation" / "day1",
            self.course_dir / "automation" / "day2", 
            self.course_dir / "automation" / "day3",
            self.course_dir / "automation" / "scripts",
            self.course_dir / "automation" / "templates",
            self.course_dir / "automation" / "results"
        ]
        
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
            logger.info(f"[DIR]  : {directory}")
    
    def _setup_environment_variables(self):
        """  """
        env_vars = {
            "COURSE_NAME": self.config.course_name,
            "COURSE_DURATION": str(self.config.duration_days),
            "COURSE_START_TIME": self.config.start_time,
            "COURSE_END_TIME": self.config.end_time
        }
        
        for key, value in env_vars.items():
            os.environ[key] = value
            logger.info(f"[ENV]   : {key}={value}")
    
    def create_day_plans(self) -> List[DayPlan]:
        """  """
        day_plans = [
            DayPlan(
                day=1,
                title="Docker, Git/GitHub, GitHub Actions ",
                topics=[
                    "Docker    ",
                    "Git/GitHub   ", 
                    "GitHub Actions CI/CD ",
                    "VM    "
                ],
                hands_on_labs=[
                    "Node.js   ",
                    "GitHub Actions CI/CD  ",
                    "  VM  "
                ],
                duration_hours=7,
                prerequisites=["Cloud Basic  "]
            ),
            DayPlan(
                day=2,
                title=" CI/CD  VM   ",
                topics=[
                    "Docker    ",
                    "GitHub Actions  ",
                    "VM    ",
                    "   "
                ],
                hands_on_labs=[
                    " Docker    ",
                    " CI/CD  ",
                    "    "
                ],
                duration_hours=7,
                prerequisites=["Day 1 "]
            ),
            DayPlan(
                day=3,
                title=" , ,  ",
                topics=[
                    "   Auto Scaling",
                    "   ",
                    "    ",
                    "    "
                ],
                hands_on_labs=[
                    "VM     ",
                    "   ",
                    "     ",
                    "     "
                ],
                duration_hours=7,
                prerequisites=["Day 2 "]
            )
        ]
        
        return day_plans
    
    def generate_day1_scripts(self) -> bool:
        """Day 1  """
        logger.info("Day 1 스크립트 생성 중...")
        
        try:
            # Docker  
            self._create_docker_basics_script()
            
            # Git/GitHub 
            self._create_git_github_script()
            
            # GitHub Actions 
            self._create_github_actions_script()
            
            # VM  
            self._create_vm_deployment_script()
            
            logger.info("Day 1 스크립트 생성 완료")
            return True
            
        except Exception as e:
            logger.error(f"Day 1 스크립트 생성 실패: {e}")
            return False
    
    def _create_docker_basics_script(self):
        """Docker 기초 스크립트 생성"""
        script_content = '''#!/bin/bash
# Docker   

set -e

echo "Docker   ..."

# Docker  
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker  ."
    exit 1
fi

# Docker  
echo " Docker :"
docker --version

# Docker   
echo " Docker  :"
docker info

#    
echo "[TEST] Hello World  :"
docker run --rm hello-world

# Node.js  
echo " Node.js  ..."

#  Node.js   
mkdir -p sample-app
cd sample-app

# package.json 
cat > package.json << 'EOF'
{
  "name": "sample-app",
  "version": "1.0.0",
  "description": "Sample Node.js app for Docker practice",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

# app.js 
cat > app.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Docker!',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});
EOF

# Dockerfile 
cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --only=production

COPY . .

EXPOSE 3000

USER node

CMD ["npm", "start"]
EOF

# Docker  
echo " Docker   ..."
docker build -t sample-app:latest .

#  
echo "   :"
docker images | grep sample-app

#  
echo "   ..."
docker run -d --name sample-app-container -p 3000:3000 sample-app:latest

#   
echo "  :"
docker ps | grep sample-app

#  
echo "[TEST]  :"
sleep 5
curl -s http://localhost:3000/ | jq .

# Health check
curl -s http://localhost:3000/health | jq .

# 
echo "[CLEANUP]  ..."
docker stop sample-app-container
docker rm sample-app-container

echo " Docker   !"
'''
        
        script_path = self.course_dir / "automation" / "day1" / "docker_basics.sh"
        script_path.write_text(script_content, encoding='utf-8')
        script_path.chmod(0o755)
        logger.info(f"Docker   : {script_path}")
    
    def _create_git_github_script(self):
        """Git/GitHub 스크립트 생성"""
        script_content = '''#!/bin/bash
# Git/GitHub   

set -e

echo " Git/GitHub   ..."

# Git  
echo " Git  :"
git --version
git config --global user.name || echo " Git   ."
git config --global user.email || echo " Git   ."

# Git  ()
if [ -z "$(git config --global user.name)" ]; then
    echo " Git   ."
    read -p "Git  : " git_username
    git config --global user.name "$git_username"
fi

if [ -z "$(git config --global user.email)" ]; then
    echo " Git   ."
    read -p "Git  : " git_email
    git config --global user.email "$git_email"
fi

#   
echo "   ..."
mkdir -p git-practice
cd git-practice

# Git  
git init

# .gitignore 
cat > .gitignore << 'EOF'
node_modules/
.env
*.log
.DS_Store
dist/
build/
EOF

# README.md 
cat > README.md << 'EOF'
# Git Practice Repository

  Git/GitHub    .

##  
- Git  
-  
-  
- GitHub 

## 
```bash
git clone <repository-url>
cd git-practice
npm install
npm start
```
EOF

#   
git add .
git commit -m "Initial commit: Add README and .gitignore"

#    
echo "    ..."
git checkout -b feature/docker-setup

# Docker   
cat > Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF

cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
EOF

#   
git add .
git commit -m "Add Docker configuration"

#   
git checkout main

#  
git merge feature/docker-setup

#  
git branch -d feature/docker-setup

#   
echo "  :"
git log --oneline --graph

# GitHub  ()
echo " GitHub     ..."
echo "GitHub       :"
echo "git remote add origin <repository-url>"
echo "git push -u origin main"

echo " Git/GitHub   !"
'''
        
        script_path = self.course_dir / "automation" / "day1" / "git_github_basics.sh"
        script_path.write_text(script_content, encoding='utf-8')
        script_path.chmod(0o755)
        logger.info(f"Git/GitHub  : {script_path}")
    
    def _create_github_actions_script(self):
        """GitHub Actions  """
        script_content = '''#!/bin/bash
# GitHub Actions CI/CD   

set -e

echo " GitHub Actions CI/CD   ..."

# .github/workflows  
mkdir -p .github/workflows

#  CI/CD  
cat > .github/workflows/ci-cd.yml << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Run tests
      run: npm test
      
    - name: Run linting
      run: npm run lint
      
  build:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
      
    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
        
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: |
          ${{ secrets.DOCKER_USERNAME }}/sample-app:latest
          ${{ secrets.DOCKER_USERNAME }}/sample-app:${{ github.sha }}
          
  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Deploy to AWS EC2
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ${{ secrets.EC2_USERNAME }}
        key: ${{ secrets.EC2_SSH_KEY }}
        script: |
          docker pull ${{ secrets.DOCKER_USERNAME }}/sample-app:latest
          docker stop sample-app || true
          docker rm sample-app || true
          docker run -d --name sample-app -p 3000:3000 ${{ secrets.DOCKER_USERNAME }}/sample-app:latest
EOF

# package.json   
if [ -f package.json ]; then
    #  package.json 
    cp package.json package.json.backup
    
    # jq    (jq    )
    if command -v jq &> /dev/null; then
        jq '.scripts += {"test": "echo \\"No tests specified\\"", "lint": "echo \\"No linting specified\\""}' package.json > package.json.tmp
        mv package.json.tmp package.json
    else
        echo " jq  . package.json  ."
    fi
fi

# Dockerfile  ( )
cat > Dockerfile.optimized << 'EOF'
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
USER node
CMD ["npm", "start"]
EOF

# Docker Compose  
cat > docker-compose.prod.yml << 'EOF'
version: '3.8'
services:
  app:
    image: ${DOCKER_USERNAME}/sample-app:latest
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
EOF

#    
cat > .env.template << 'EOF'
# GitHub Secrets  
# Repository Settings > Secrets and variables > Actions   :

# Docker Hub
DOCKER_USERNAME=your-docker-username
DOCKER_PASSWORD=your-docker-password

# AWS EC2
EC2_HOST=your-ec2-public-ip
EC2_USERNAME=ec2-user
EC2_SSH_KEY=your-private-key

# GCP ()
GCP_PROJECT_ID=your-project-id
GCP_SA_KEY=your-service-account-key
EOF

echo " GitHub Actions  !"
echo "  :"
echo "1. GitHub   "
echo "2.  GitHub "
echo "3. Actions    "

echo " GitHub Actions CI/CD   !"
'''
        
        script_path = self.course_dir / "automation" / "day1" / "github_actions.sh"
        script_path.write_text(script_content, encoding='utf-8')
        script_path.chmod(0o755)
        logger.info(f"GitHub Actions  : {script_path}")
    
    def _create_vm_deployment_script(self):
        """VM   """
        script_content = '''#!/bin/bash
# VM     

set -e

echo " VM      ..."

# AWS EC2  
cat > deploy_aws.sh << 'EOF'
#!/bin/bash
# AWS EC2  

set -e

#   
if [ -z "$AWS_REGION" ]; then
    export AWS_REGION="us-west-2"
fi

if [ -z "$INSTANCE_TYPE" ]; then
    export INSTANCE_TYPE="t3.micro"
fi

echo " AWS EC2   ..."

#   
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name "sample-app-sg" \
    --description "Security group for sample app" \
    --query 'GroupId' \
    --output text)

echo "   : $SECURITY_GROUP_ID"

#    
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 3000 \
    --cidr 0.0.0.0/0

#   
aws ec2 create-key-pair \
    --key-name sample-app-key \
    --query 'KeyMaterial' \
    --output text > sample-app-key.pem

chmod 400 sample-app-key.pem

#  
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-0c02fb55956c7d316 \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name sample-app-key \
    --security-group-ids $SECURITY_GROUP_ID \
    --user-data file://user-data.sh \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "  : $INSTANCE_ID"

#   
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

#  IP 
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "  IP: $PUBLIC_IP"
echo "  URL: http://$PUBLIC_IP:3000"
EOF

# GCP Compute Engine  
cat > deploy_gcp.sh << 'EOF'
#!/bin/bash
# GCP Compute Engine  

set -e

#   
if [ -z "$PROJECT_ID" ]; then
    echo " PROJECT_ID   ."
    exit 1
fi

if [ -z "$ZONE" ]; then
    export ZONE="us-west1-a"
fi

echo " GCP Compute Engine   ..."

#  
gcloud config set project $PROJECT_ID

#   
gcloud compute firewall-rules create allow-sample-app \
    --allow tcp:3000 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow sample app traffic"

#  
gcloud compute instances create sample-app-instance \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB \
    --metadata-from-file startup-script=startup-script.sh

echo "   "

#  IP 
INSTANCE_IP=$(gcloud compute instances describe sample-app-instance \
    --zone=$ZONE \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo "  IP: $INSTANCE_IP"
echo "  URL: http://$INSTANCE_IP:3000"
EOF

# User Data  (AWS)
cat > user-data.sh << 'EOF'
#!/bin/bash
# AWS EC2 User Data Script

set -e

#  
apt-get update
apt-get upgrade -y

# Docker 
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu

# Docker Compose 
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

#   
mkdir -p /opt/sample-app
cd /opt/sample-app

# Docker Compose  
cat > docker-compose.yml << 'DOCKEREOF'
version: '3.8'
services:
  app:
    image: nginx:alpine
    ports:
      - "3000:80"
    volumes:
      - ./index.html:/usr/share/nginx/html/index.html
DOCKEREOF

#  HTML  
cat > index.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <title>Sample App</title>
</head>
<body>
    <h1>Hello from AWS EC2!</h1>
    <p>This is a sample application deployed on AWS EC2.</p>
    <p>Timestamp: <span id="timestamp"></span></p>
    <script>
        document.getElementById('timestamp').textContent = new Date().toISOString();
    </script>
</body>
</html>
HTMLEOF

# Docker Compose 
docker-compose up -d

#   
systemctl enable docker
EOF

# Startup Script (GCP)
cat > startup-script.sh << 'EOF'
#!/bin/bash
# GCP Compute Engine Startup Script

set -e

#  
apt-get update
apt-get upgrade -y

# Docker 
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Docker Compose 
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

#   
mkdir -p /opt/sample-app
cd /opt/sample-app

# Docker Compose  
cat > docker-compose.yml << 'DOCKEREOF'
version: '3.8'
services:
  app:
    image: nginx:alpine
    ports:
      - "3000:80"
    volumes:
      - ./index.html:/usr/share/nginx/html/index.html
DOCKEREOF

#  HTML  
cat > index.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <title>Sample App</title>
</head>
<body>
    <h1>Hello from GCP Compute Engine!</h1>
    <p>This is a sample application deployed on GCP Compute Engine.</p>
    <p>Timestamp: <span id="timestamp"></span></p>
    <script>
        document.getElementById('timestamp').textContent = new Date().toISOString();
    </script>
</body>
</html>
HTMLEOF

# Docker Compose 
docker-compose up -d
EOF

#   
chmod +x deploy_aws.sh deploy_gcp.sh

echo " VM    !"
echo " :"
echo "  AWS: ./deploy_aws.sh"
echo "  GCP: PROJECT_ID=your-project-id ./deploy_gcp.sh"

echo " VM      !"
'''
        
        script_path = self.course_dir / "automation" / "day1" / "vm_deployment.sh"
        script_path.write_text(script_content, encoding='utf-8')
        script_path.chmod(0o755)
        logger.info(f"VM   : {script_path}")
    
    def generate_day2_scripts(self) -> bool:
        """Day 2  """
        logger.info("Day 2 스크립트 생성 중...")
        
        try:
            # Day 2    import  
            from master_course_day2_scripts import (
                create_docker_advanced_script,
                create_advanced_cicd_script,
                create_container_orchestration_script
            )
            
            # Docker  
            create_docker_advanced_script(self.course_dir)
            
            #  CI/CD 
            create_advanced_cicd_script(self.course_dir)
            
            #   
            create_container_orchestration_script(self.course_dir)
            
            logger.info("Day 2 스크립트 생성 완료")
            return True
            
        except Exception as e:
            logger.error(f"Day 2 스크립트 생성 실패: {e}")
            return False
    
    def generate_day3_scripts(self) -> bool:
        """Day 3  """
        logger.info("Day 3 스크립트 생성 중...")
        
        try:
            # Day 3    import  
            from master_course_day3_scripts import (
                create_load_balancing_script,
                create_monitoring_script,
                create_cost_optimization_script
            )
            
            #   
            create_load_balancing_script(self.course_dir)
            
            #  
            create_monitoring_script(self.course_dir)
            
            #   
            create_cost_optimization_script(self.course_dir)
            
            logger.info("Day 3 스크립트 생성 완료")
            return True
            
        except Exception as e:
            logger.error(f"Day 3 스크립트 생성 실패: {e}")
            return False
    
    def run_course_automation(self) -> bool:
        """   """
        logger.info("    ...")
        
        try:
            #  
            if not self.setup_environment():
                return False
            
            #   
            day_plans = self.create_day_plans()
            
            #    
            if not self.generate_day1_scripts():
                return False
                
            if not self.generate_day2_scripts():
                return False
                
            if not self.generate_day3_scripts():
                return False
            
            #  
            self._save_results(day_plans)
            
            logger.info("    !")
            return True
            
        except Exception as e:
            logger.error(f"    : {e}")
            return False
    
    def _save_results(self, day_plans: List[DayPlan]):
        """ """
        results = {
            "course_name": self.config.course_name,
            "generated_at": datetime.now().isoformat(),
            "day_plans": [
                {
                    "day": plan.day,
                    "title": plan.title,
                    "topics": plan.topics,
                    "hands_on_labs": plan.hands_on_labs,
                    "duration_hours": plan.duration_hours,
                    "prerequisites": plan.prerequisites
                }
                for plan in day_plans
            ],
            "scripts_generated": [
                "docker_basics.sh",
                "git_github_basics.sh", 
                "github_actions.sh",
                "vm_deployment.sh"
            ]
        }
        
        results_file = self.course_dir / "automation" / "results" / "automation_results.json"
        results_file.write_text(json.dumps(results, indent=2, ensure_ascii=False), encoding='utf-8')
        
        logger.info(f"  : {results_file}")

def main():
    """ """
    #  
    config = CourseConfig()
    
    #  
    automation = MasterCourseAutomation(config)
    
    if automation.run_course_automation():
        print("     !")
        print("   mcp_knowledge_base/cloud_master/automation/    .")
    else:
        print("    .")
        sys.exit(1)

if __name__ == "__main__":
    main()
