#!/bin/bash

# Neo4j 헬스 체크 스크립트
# Neo4j가 완전히 시작되었는지 확인

set -e

# Neo4j HTTP API 엔드포인트 확인
if curl -f -s http://localhost:7474/db/data/ > /dev/null 2>&1; then
    echo "Neo4j HTTP API is ready"
    exit 0
fi

# Neo4j Bolt 프로토콜 확인 (대안)
if timeout 5 cypher-shell -u neo4j -p "${NEO4J_AUTH#*/}" "RETURN 1" > /dev/null 2>&1; then
    echo "Neo4j Bolt protocol is ready"
    exit 0
fi

echo "Neo4j is not ready yet"
exit 1