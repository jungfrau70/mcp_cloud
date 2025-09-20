# 📘 MCP Cloud 데이터베이스 백업 및 복구 절차서

## 🗂️ 기본 정보

- **DB 이름**: `mcp_db`
- **DB 사용자**: `mcpuser`
- **Docker Compose 파일**: `docker-compose.base.yml`
- **PostgreSQL 컨테이너 이름**: `mcp_postgres`
- **백업 파일 이름**: `mcp_db_backup.sql`

---

## ✅ 1. 백업 절차

### 1-1. 전체 데이터베이스 백업
```bash
docker exec -t mcp_postgres pg_dump -U mcpuser --encoding=UTF8 mcp_db > mcp_db_backup.sql
```

### 1-2. 스키마만 백업 (구조만)
```bash
docker exec -t mcp_postgres pg_dump -U mcpuser --schema-only --encoding=UTF8 mcp_db > mcp_db_schema.sql
```

### 1-3. 데이터만 백업 (데이터만)
```bash
docker exec -t mcp_postgres pg_dump -U mcpuser --data-only --encoding=UTF8 mcp_db > mcp_db_data.sql
```

---

## ✅ 2. 복구 절차

### 2-1. 기존 데이터베이스 삭제 (주의!)
```bash
docker exec -it mcp_postgres psql -U mcpuser -d postgres -c "DROP DATABASE IF EXISTS mcp_db;"
```

### 2-2. 새 데이터베이스 생성
```bash
docker exec -it mcp_postgres psql -U mcpuser -d postgres -c "CREATE DATABASE mcp_db;"
```

### 2-3. 백업 파일로 복구
```bash
cat mcp_db_backup.sql | docker exec -i mcp_postgres psql -U mcpuser mcp_db
```

---

## ✅ 3. 운영체제 간 이관 (Windows ↔ Ubuntu)

### 3-1. Windows → Ubuntu
```powershell
# Windows PowerShell에서
copy mcp_db_backup.sql \\wsl$\Ubuntu\home\youruser\
```

### 3-2. Ubuntu → Windows
```bash
# Ubuntu에서
cp mcp_db_backup.sql /mnt/c/Users/youruser/Desktop/
```

### 3-3. 줄바꿈 문제 해결 (필요시)
```bash
# CRLF → LF 변환
dos2unix mcp_db_backup.sql
```

---

## ✅ 4. 자동화 스크립트

### 4-1. 백업 스크립트 (backup.sh)
```bash
#!/bin/bash
# MCP Cloud 데이터베이스 백업 스크립트

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/mcp_db_backup_${DATE}.sql"

# 백업 디렉토리 생성
mkdir -p $BACKUP_DIR

# 데이터베이스 백업
echo "📤 데이터베이스 백업 시작..."
docker exec -t mcp_postgres pg_dump -U mcpuser --encoding=UTF8 mcp_db > $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "✅ 백업 완료: $BACKUP_FILE"
    echo "📊 파일 크기: $(du -h $BACKUP_FILE | cut -f1)"
else
    echo "❌ 백업 실패"
    exit 1
fi
```

### 4-2. 복구 스크립트 (restore.sh)
```bash
#!/bin/bash
# MCP Cloud 데이터베이스 복구 스크립트

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "사용법: $0 <백업파일>"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ 백업 파일을 찾을 수 없습니다: $BACKUP_FILE"
    exit 1
fi

echo "📥 데이터베이스 복구 시작..."
echo "📁 백업 파일: $BACKUP_FILE"

# 기존 DB 삭제 및 새로 생성
echo "🗑️ 기존 데이터베이스 삭제..."
docker exec -it mcp_postgres psql -U mcpuser -d postgres -c "DROP DATABASE IF EXISTS mcp_db;"

echo "🏗️ 새 데이터베이스 생성..."
docker exec -it mcp_postgres psql -U mcpuser -d postgres -c "CREATE DATABASE mcp_db;"

# 백업 파일로 복구
echo "📥 데이터 복구 중..."
cat $BACKUP_FILE | docker exec -i mcp_postgres psql -U mcpuser mcp_db

if [ $? -eq 0 ]; then
    echo "✅ 복구 완료!"
else
    echo "❌ 복구 실패"
    exit 1
fi
```

---

## ✅ 5. 정기 백업 설정

### 5-1. Cron 작업 설정 (Ubuntu)
```bash
# 매일 새벽 2시에 백업 실행
0 2 * * * /path/to/backup.sh

# 매주 일요일 새벽 3시에 전체 백업
0 3 * * 0 /path/to/backup.sh
```

### 5-2. Windows 작업 스케줄러
- 작업 스케줄러에서 `backup.bat` 파일 실행 설정
- 매일 특정 시간에 자동 백업 실행

---

## ✅ 6. 백업 검증

### 6-1. 백업 파일 무결성 확인
```bash
# 백업 파일이 올바른 SQL인지 확인
head -n 10 mcp_db_backup.sql
tail -n 10 mcp_db_backup.sql
```

### 6-2. 복구 후 데이터 확인
```bash
# 테이블 목록 확인
docker exec -it mcp_postgres psql -U mcpuser mcp_db -c "\dt"

# 레코드 수 확인
docker exec -it mcp_postgres psql -U mcpuser mcp_db -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';"
```

---

## 📊 전체 명령어 요약

| 작업 | 명령어 |
|------|--------|
| 📤 백업 | `docker exec -t mcp_postgres pg_dump -U mcpuser --encoding=UTF8 mcp_db > mcp_db_backup.sql` |
| 🧹 DB 삭제 | `docker exec -it mcp_postgres psql -U mcpuser -d postgres -c "DROP DATABASE IF EXISTS mcp_db;"` |
| 🏗️ DB 생성 | `docker exec -it mcp_postgres psql -U mcpuser -d postgres -c "CREATE DATABASE mcp_db;"` |
| 📥 복구 | `cat mcp_db_backup.sql \| docker exec -i mcp_postgres psql -U mcpuser mcp_db` |

---

## 🚨 주의사항

1. **백업 전 확인**: 컨테이너가 실행 중인지 확인
2. **복구 전 백업**: 복구 전에 현재 데이터 백업 권장
3. **권한 확인**: Docker 컨테이너 접근 권한 확인
4. **디스크 공간**: 백업 파일 저장 공간 충분한지 확인
5. **네트워크**: 원격 백업 시 네트워크 연결 상태 확인

---

**작성일**: 2025-01-20  
**작성자**: MCP Cloud Team  
**버전**: 2.0
