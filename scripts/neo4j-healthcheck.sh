#!/bin/bash

# Neo4j 헬스 체크 스크립트
# Neo4j가 완전히 시작되었는지 확인

set -e

# Neo4j HTTP API 엔드포인트 확인 (가장 안정적인 방법)
if curl -f -s http://localhost:7474/db/data/ > /dev/null 2>&1; then
    echo "Neo4j HTTP API is ready"
    exit 0
fi

# Neo4j 서버 상태 확인 (대안)
if curl -f -s http://localhost:7474/ > /dev/null 2>&1; then
    echo "Neo4j server is ready"
    exit 0
fi

# Neo4j Bolt 프로토콜 확인 (마지막 대안)
# NEO4J_AUTH 환경변수에서 비밀번호 추출
if [ -n "$NEO4J_AUTH" ]; then
    PASSWORD="${NEO4J_AUTH#*/}"
    if timeout 5 cypher-shell -u neo4j -p "$PASSWORD" "RETURN 1 AS test" > /dev/null 2>&1; then
        echo "Neo4j Bolt protocol is ready"
        exit 0
    fi
fi

echo "Neo4j is not ready yet"
exit 1