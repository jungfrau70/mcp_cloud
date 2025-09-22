-- Day2 - Database Initialization Script
-- Cloud Master Day2 강의안 기반

-- 데이터베이스 생성 (이미 생성되어 있음)
-- CREATE DATABASE github_actions_demo;

-- 사용자 테이블 생성
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 로그 테이블 생성
CREATE TABLE IF NOT EXISTS logs (
    id SERIAL PRIMARY KEY,
    level VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    service VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 메트릭 테이블 생성
CREATE TABLE IF NOT EXISTS metrics (
    id SERIAL PRIMARY KEY,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(10,4) NOT NULL,
    labels JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_logs_level ON logs(level);
CREATE INDEX IF NOT EXISTS idx_logs_service ON logs(service);
CREATE INDEX IF NOT EXISTS idx_logs_created_at ON logs(created_at);
CREATE INDEX IF NOT EXISTS idx_metrics_name ON metrics(metric_name);
CREATE INDEX IF NOT EXISTS idx_metrics_created_at ON metrics(created_at);

-- 샘플 데이터 삽입
INSERT INTO users (username, email) VALUES 
    ('admin', 'admin@github-actions-demo.com'),
    ('user1', 'user1@github-actions-demo.com'),
    ('user2', 'user2@github-actions-demo.com')
ON CONFLICT (username) DO NOTHING;

INSERT INTO logs (level, message, service) VALUES 
    ('INFO', 'Application started', 'web'),
    ('INFO', 'Database connected', 'web'),
    ('INFO', 'Redis connected', 'web'),
    ('INFO', 'Prometheus metrics enabled', 'web')
ON CONFLICT DO NOTHING;

-- 함수 생성 (업데이트 시간 자동 갱신)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 트리거 생성
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 뷰 생성 (사용자 통계)
CREATE OR REPLACE VIEW user_stats AS
SELECT 
    COUNT(*) as total_users,
    COUNT(CASE WHEN created_at >= CURRENT_DATE THEN 1 END) as new_users_today,
    COUNT(CASE WHEN created_at >= CURRENT_DATE - INTERVAL '7 days' THEN 1 END) as new_users_week,
    COUNT(CASE WHEN created_at >= CURRENT_DATE - INTERVAL '30 days' THEN 1 END) as new_users_month
FROM users;

-- 뷰 생성 (로그 통계)
CREATE OR REPLACE VIEW log_stats AS
SELECT 
    level,
    service,
    COUNT(*) as count,
    MAX(created_at) as last_occurrence
FROM logs
WHERE created_at >= CURRENT_DATE - INTERVAL '24 hours'
GROUP BY level, service
ORDER BY count DESC;

-- 권한 설정
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO postgres;