#!/bin/bash

# Git 상태 확인
echo "🔍 Git 상태 확인 중..."
git status

# 변경사항 추가
echo "📝 변경사항 추가 중..."
git add .

# 커밋 메시지 생성
COMMIT_MSG="Update: $(date +"%Y-%m-%d %H:%M:%S")"
echo "💾 커밋 중: $COMMIT_MSG"
git commit -m "$COMMIT_MSG"

# 푸시 실행
echo "🚀 푸시 중..."
git push origin v1.0.9

echo "✅ 완료!"
