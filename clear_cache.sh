#!/bin/bash

# 현재 디렉토리부터 하위 폴더까지 모든 __pycache__ 디렉토리 및 .pyc 파일 삭제

echo "Deleting __pycache__ directories and *.pyc files..."

# __pycache__ 디렉토리 삭제
find . -type d -name "__pycache__" -exec rm -r {} +

# .pyc 파일 삭제
find . -type f -name "*.pyc" -exec rm -f {} +

rm -rf app/.ruff_cache/*

echo "Python cache cleanup complete."