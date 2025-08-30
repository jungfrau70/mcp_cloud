# Nginx Proxy Manager 설정 가이드 (현재 운영 구성)

## 개요
- Reverse Proxy: Nginx Proxy Manager (NPM)
- 목적: 단일 도메인(app)에서 API(`/api`)를 백엔드로 프록시, 정적/SSR은 프론트로 전달
- Cloudflared 터널과 연동: 외부 도메인 → NPM(80), NPM Admin → 81

## Proxy Hosts

### 1) app.gostock.us → mcp_frontend:3000
- Details
  - Domain Names: `app.gostock.us`
  - Scheme: `http`
  - Forward Hostname/IP: `mcp_frontend`
  - Forward Port: `3000`
  - Websockets Support: On
  - Access List: Publicly Accessible (검증 완료 후 필요한 경로만 보호 권장)
- Custom locations (API 경로만 백엔드로 전달)
  - Path: `/api`
  - Scheme: `http`
  - Forward Hostname/IP: `mcp_backend`
  - Forward Port: `8000`
  - Websockets Support: On
- Advanced
  - 사용자 정의 `location`/`rewrite`/`cache` 블록 추가 금지 (정적 경로 404/깨짐 유발)

### 2) api.gostock.us → mcp_backend:8000
- Domain Names: `api.gostock.us`
- Scheme: `http`
- Forward Hostname/IP: `mcp_backend`
- Forward Port: `8000`
- Websockets Support: On
- Access List: Publicly Accessible (운영 시 토큰/Authelia로 부분 보호 권장)

### 3) npm.gostock.us → NPM Admin (81)
- Domain Names: `npm.gostock.us`
- Scheme: `http`
- Forward Hostname/IP: `npm`
- Forward Port: `81`
- Access List: 제한 권장(사내/관리자)

## SSL
- Cloudflared 터널(에지)에서 TLS 종료. 내부는 http로 통신.
- NPM에서도 필요 시 Let’s Encrypt 적용 가능(현재 동작 확인됨). 단, 터널 레이어와 충돌 없도록 유지.

## 프론트/백엔드 런타임 전제
- Frontend
  - `NUXT_PUBLIC_API_BASE_URL=/api`
  - `NUXT_PUBLIC_WS_BASE_URL=wss://api.gostock.us/api`
  - 프로덕션: `NODE_ENV=production`, `NITRO_HOST=0.0.0.0`, `NITRO_PORT=3000`
- Backend
  - FastAPI 8000 listen
  - CORS origins: `https://app.gostock.us`, `https://api.gostock.us`

## 점검 절차
- NPM 컨테이너에서 원본 확인
  - `curl -I http://mcp_frontend:3000 | head -n1` → 200
  - `curl -I http://mcp_backend:8000/health | head -n1` → 200
- 브라우저/Cloudflare
  - `https://app.gostock.us/_nuxt/*.js` → 200 `application/javascript`
  - `https://app.gostock.us/_nuxt/*.css` → 200 `text/css`
  - `https://app.gostock.us/api/v1/...` → 백엔드로 정상 프록시됨

## 흔한 오류와 해결
- “민자 화면” (CSS/JS 미적용)
  - Advanced의 빈 `location` 블록 제거
  - Cloudflare 최적화/캐시 OFF + Cache Rules Bypass 후 Purge
- 401/302 루프
  - Access List(Forward Auth) 적용 범위를 경로 기반으로 축소(`/admin`, `/kb/manage` 등)
- 502 Bad Gateway
  - 원본 서비스 기동/포트/네트워크 확인, 프론트 빌드/기동 로그 확인


  4단계: Nginx Proxy Manager 재설정

  서비스가 모두 시작되면, 깨끗해진 Nginx Proxy Manager에 접속하여 프록시 설정을 처음부터 다시 만들어야 합니다.

   1. https://npm.gostock.us 또는 설정하신 NPM 주소로 접속합니다.
   2. 초기 로그인 정보를 사용하여 로그인합니다.
       * Email: admin@example.com
       * Password: changeme
   3. 로그인 후 비밀번호를 변경하라는 메시지가 나오면, 안내에 따라 새 비밀번호를 설정합니다.
   4. 상단 메뉴에서 Hosts > Proxy Hosts 로 이동한 후, Add Proxy Host 버튼을 클릭합니다.
   5. 아래 내용을 정확하게 입력하여 설정을 만듭니다.

      Details 탭:
       * Domain Names: app.gostock.us
       * Scheme: http
       * Forward Hostname / IP: mcp_frontend
       * Forward Port: 3000
       * Websockets Support: 스위치를 켜서 활성화

      Locations 탭:
       * Add Location 버튼을 클릭합니다.
       * Path: /api
       * Scheme: http
       * Forward Hostname / IP: mcp_backend
       * Forward Port: 8000
       * Save를 눌러 Location 설정을 저장합니다.

      SSL 탭:
       * SSL Certificate: 드롭다운 메뉴에서 Request a new SSL Certificate 선택
       * Force SSL: 스위치를 켜서 활성화
       * I Agree to the Let's Encrypt Terms of Service: 체크박스 선택
       * Save를 눌러 SSL 설정을 저장합니다. (인증서 발급에 1~2분 소요될 수 있습니다.)

      Custom Nginx Configuration 탭:
       * 아래 코드를 복사하여 그대로 붙여넣습니다.

# Authelia 인증을 위한 내부 통신 경로 설정
location /authelia {
    internal;
    set $upstream_authelia http://mcp_authelia:9091/api/verify;
    proxy_pass $upstream_authelia;
    proxy_set_header Content-Length "";
    proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $http_host;
    proxy_set_header X-Forwarded-Uri $request_uri;
}

# 모든 요청에 대해 Authelia 인증 적용 및 캐시 방지
auth_request /authelia;
auth_request_set $user $upstream_http_x_authelia_user;
auth_request_set $groups $upstream_http_x_authelia_groups;
auth_request_set $auth_cookie $upstream_http_set_cookie;
add_header Set-Cookie $auth_cookie;
proxy_set_header X-Authelia-User $user;
proxy_set_header X-Authelia-Groups $groups;

   6. 마지막으로 Save 버튼을 눌러 모든 설정을 저장합니다.

  ---

  5단계: 최종 테스트

  모든 설정이 완료되었습니다. 브라우저 캐시와 쿠키를 한번 더 삭제한 후, https://app.gostock.us에 접속하여
  로그인을 진행하고 모든 기능이 정상적으로 동작하는지 최종 확인해 주세요.
