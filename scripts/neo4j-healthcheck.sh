#!/bin/bash
# Neo4j healthcheck script

# 환경변수에서 사용자명과 비밀번호 추출
USER=$(echo "$NEO4J_AUTH" | cut -d'/' -f1)
PASS=$(echo "$NEO4J_AUTH" | cut -d'/' -f2)

# Neo4j 연결 테스트
cypher-shell -a bolt://localhost:7687 -u "$USER" -p "$PASS" 'RETURN 1' > /dev/null 2>&1 || exit 1
