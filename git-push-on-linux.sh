#!/bin/bash

# Git 상태 확인
echo "🔍 Git 상태 확인 중..."
git status

# 변경사항 추가
echo "📝 변경사항 추가 중..."
git add .

# 변경된 파일 목록 가져오기 (첫 번째 파일만)
CHANGED_FILES=$(git diff --cached --name-only | head -1)
if [ -n "$CHANGED_FILES" ]; then
    CHANGED_FILES=" - $CHANGED_FILES"
    if [ $(git diff --cached --name-only | wc -l) -gt 1 ]; then
        CHANGED_FILES="${CHANGED_FILES} and $(($(git diff --cached --name-only | wc -l) - 1)) more files"
    fi
else
    CHANGED_FILES=""
fi

# 커밋 메시지 생성
COMMIT_MSG="Update: $(date +"%Y-%m-%d %H:%M:%S")${CHANGED_FILES}"
echo "💾 커밋 중: $COMMIT_MSG"
git commit -m "$COMMIT_MSG"

# 푸시 실행
echo "🚀 푸시 중..."
git push origin v2.0.0

echo "✅ 완료!"
