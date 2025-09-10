
Nginx Proxy Manager (NPM) 설정 가이드 (MentorAi 플랫폼)

개요:
NPM은 MentorAi 플랫폼에서 리버스 프록시 역할을 하며, 단일 도메인에서 프론트엔드(정적/SSR)와 백엔드 API를
분리하여 프록시하고, Cloudflared 터널과 연동됩니다.

주요 Proxy Hosts 설정:

  1. `app.mentorai.local` → `mcp_frontend:3000`
      * 도메인: app.mentorai.local
      * 포워드 대상: mcp_frontend:3000 (HTTP)
      * Websockets 지원: 활성화
      * Custom locations (API 경로만 백엔드로 전달):
          * Path: /api
          * 포워드 대상: mcp_backend:8000 (HTTP)
          * Websockets 지원: 활성화
      * Advanced: 사용자 정의 location/rewrite/cache 블록 추가 금지 (정적 경로 오류 방지)

  2. `api.mentorai.local` → `mcp_backend:8000`
      * 도메인: api.mentorai.local
      * 포워드 대상: mcp_backend:8000 (HTTP)
      * Websockets 지원: 활성화

  3. `npm.mentorai.local` → `npm:81` (NPM Admin)
      * 도메인: npm.mentorai.local
      * 포워드 대상: npm:81 (HTTP)
      * 접근 제어: 관리자만 접근하도록 제한 권장

Authelia 인증 통합 (Forward Auth):
Authelia를 통한 접근 제어를 적용하려면, 해당 Proxy Host의 Custom Nginx Configuration 탭에 다음 Nginx 설정을
추가해야 합니다. 이 설정은 모든 요청에 대해 Authelia 인증을 적용하고, 인증 정보를 백엔드로 전달합니다.

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

SSL:
Cloudflared 터널(에지)에서 TLS를 종료하며, NPM 내부 통신은 HTTP로 이루어집니다. 필요시 NPM에서 Let's
Encrypt를 적용할 수 있으나, 터널 레이어와의 충돌을 피하도록 관리해야 합니다.

프론트/백엔드 런타임 전제:
  * Frontend:
      * NUXT_PUBLIC_API_BASE_URL=/api
      * NUXT_PUBLIC_WS_BASE_URL=wss://api.mentorai.local/api
      * 프로덕션 환경: NODE_ENV=production, NITRO_HOST=0.0.0.0, NITRO_PORT=3000
  * Backend:
      * FastAPI 8000 포트 리스닝
      * CORS origins: https://app.mentorai.local, https://api.mentorai.local

NPM 재설정 및 구성 절차 (초기 설정 시):
  1. NPM 관리자 페이지(https://npm.mentorai.local 또는 설정된 주소)에 접속합니다.
  2. 초기 로그인 정보(admin@example.com, changeme)로 로그인 후 비밀번호를 변경합니다.
  3. Hosts > Proxy Hosts에서 Add Proxy Host 버튼을 클릭합니다.
  4. 위에서 설명된 Details 탭, Locations 탭, SSL 탭의 정보를 정확히 입력합니다.
  5. `Custom Nginx Configuration` 탭에 위에 제시된 Authelia 인증 통합 Nginx 코드를 복사하여 붙여넣습니다.
  6. Save 버튼을 눌러 설정을 저장합니다.

점검 절차:
  * NPM 컨테이너 내에서 curl 명령어로 프론트엔드 및 백엔드 서비스의 정상 동작 여부를 확인합니다.
  * 브라우저에서 https://app.mentorai.local에 접속하여 정적 파일 및 API 프록시가 정상적으로 동작하는지
    확인합니다.
