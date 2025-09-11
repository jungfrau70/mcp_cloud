#!/bin/bash
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
