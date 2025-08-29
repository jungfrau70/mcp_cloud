## MCP Cloud 사용자 가이드 (Cloudflare Tunnel + NPM + Authelia)

이 가이드는 외부 포트를 열지 않고 `mcp_frontend`를 안전하게 공개하기 위한 운영 절차를 설명합니다. 구성은 Cloudflare Tunnel → Nginx Proxy Manager(NPM) → Authelia → mcp_frontend 순으로 트래픽을 전달합니다.

### 요구 사항
- 도메인: gostock.us (Cloudflare에 등록 및 네임서버 위임 완료)
- Docker, Docker Compose v2
- Cloudflare 계정 (Tunnel 사용)

### 빠른 시작 (TL;DR)
1) 환경 파일 생성
```bash
copy docs\env.example cloudflared\env\.env
# .env 를 열어 다음 값을 확인/수정
# DOMAIN=gostock.us
# FRONTEND_HOST=app.gostock.us
# AUTH_HOST=auth.gostock.us
# CLOUDFLARE_TUNNEL_NAME=mcp-cloud
```

2) Cloudflare Tunnel 초기화(최초 1회)
```bash
mkdir cloudflared\data
docker run --rm -v %cd%/cloudflared/data:/home/nonroot/.cloudflared cloudflare/cloudflared:latest tunnel login
docker run --rm -v %cd%/cloudflared/data:/home/nonroot/.cloudflared cloudflare/cloudflared:latest tunnel create %CLOUDFLARE_TUNNEL_NAME%
```

3) 기동
```bash
docker compose up -d --build
```

4) NPM 프록시 호스트 등록
- Cloudflare Tunnel 템플릿(`cloudflared/config/config.tmpl.yml`)은 기본적으로 `${FRONTEND_HOST}` → `npm:80`, `${AUTH_HOST}` → `authelia:9091` 로 라우팅합니다.
- NPM Admin UI(포트 81)에 접근하려면 임시로 admin 호스트 매핑을 추가하세요(예: `npm.gostock.us` → `http://npm:81`). 템플릿에 아래 항목을 추가 후 재기동합니다.
```yaml
  - hostname: npm.${DOMAIN}
    service: http://npm:81
    originRequest:
      noTLSVerify: true
```
- 브라우저에서 `https://npm.gostock.us` 접속 → 로그인 후 Proxy Host를 생성합니다.
  - Domain Names: `app.gostock.us`
  - Scheme/Forward Hostname/IP: `http://mcp_frontend`
  - Forward Port: `3000`
  - Advanced: Authelia 리디렉션 스니펫 (예시)
    ```nginx
    error_page 401 =302 https://${AUTH_HOST}/?rd=$target_url;
    real_ip_header CF-Connecting-IP;
    real_ip_recursive on;
    ```

5) Authelia 사용자 등록
- 파일 `authelia/config/users_database.yml` 을 생성하고 사용자/비밀번호를 정의합니다.
```yaml
users:
  user1:
    password: "$argon2id$v=19$m=65536,t=3,p=2$..."  # 해시 권장
    displayname: "User One"
    email: "user1@${DOMAIN}"
    groups:
      - admins
```
- 컨테이너 재기동: `docker compose up -d`

6) 접속
- `https://app.gostock.us` → Authelia 로그인 → mcp_frontend 화면 접근

---

### 구성 요소와 경로
- `docker-compose.yml`:
  - `mcp_frontend`, `mcp_backend`는 내부 네트워크에만 `expose`
  - `npm`(80/81/443 내부), `authelia`(9091 내부), `cloudflared`(터널)
- 환경 변수: `.env` (예시는 `docs/env.example`)
- Cloudflare Tunnel 템플릿: `cloudflared/config/config.tmpl.yml`
- Authelia 템플릿: `authelia/config/configuration.tmpl.yml` → envsubst로 렌더 → `configuration.yml`

### 운영 절차(상세)
1) 환경 변수 관리
- `.env`로 다음을 관리합니다.
  - `DOMAIN=gostock.us`
  - `FRONTEND_HOST=app.${DOMAIN}`
  - `AUTH_HOST=auth.${DOMAIN}`
  - `CLOUDFLARE_TUNNEL_NAME=mcp-cloud`
- 필요 시 `NPM_INIT_EMAIL`, `NPM_INIT_PASS` 등도 함께 관리합니다.

2) Cloudflare Tunnel
- `cloudflared/data` 내에 `cert.pem`과 `<tunnel-name>.json`이 생성됩니다.
- 템플릿에 정의된 `ingress`로 호스트별 라우팅을 제어합니다.

3) NPM(Reverse Proxy)
- Proxy Host에서 `app.gostock.us` → `http://mcp_frontend:3000` 으로 연결합니다.
- Admin UI 접근은 임시 admin 호스트(예: `npm.gostock.us`)를 추가해 터널을 통해 접속합니다.

4) Authelia(SSO/2FA)
- `${FRONTEND_HOST}`에 `one_factor` 정책이 적용됩니다.
- 사용자 DB는 `authelia/config/users_database.yml` (파일 백엔드) 사용 예시 제공.

### 검증
- DNS: Cloudflare에 gostock.us가 연결되어 있는지 확인
- Tunnel: `docker logs cloudflared` 에서 연결 상태 확인
- NPM: Proxy Host가 `mcp_frontend:3000`으로 정상 프록시되는지 확인
- Authelia: `https://auth.gostock.us` 접속 테스트 및 로그인 성공
- Frontend: `https://app.gostock.us` 접속 후 UI 노출

### 장애 대응(Troubleshooting)
- 404(Not Found): 템플릿의 `hostname`과 실제 요청 호스트가 일치하는지 확인
- 502/504: NPM → mcp_frontend 연결 확인(컨테이너 네임, 포트, 헬스)
- 401: Authelia 정책/쿠키/시간차 확인, `AUTH_HOST`/`FRONTEND_HOST` 값 점검
- Tunnel 연결 실패: `<tunnel-name>.json` 존재 여부, Cloudflare 계정 권한 확인

### 보안 권고
- 호스트 포트는 열지 않습니다(모든 서비스 `expose`만 사용).
- Authelia 세션/암호는 강력한 값 사용, 사용자 비밀번호는 해시 저장
- Cloudflare 방화벽/Access Rule로 국가/봇 트래픽 제한 고려

### 백업/복구(중요 볼륨)
- `npm_data`, `npm_letsencrypt`, `authelia/config`, `cloudflared/data`
- (선택) `postgres_data`, `neo4j_data`, `terraform_modules_data`, `hf_cache`, `azure_config`, `aws_config`, `gcloud_config`

### 롤링 업데이트
```bash
docker compose pull
docker compose up -d --no-deps <service-name>
```

### 참고 자료
- Cloudflare Tunnel + NPM + Authelia 구성 아이디어: https://expbox77.tistory.com/12


