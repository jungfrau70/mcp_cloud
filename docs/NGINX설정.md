
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

    1     # Authelia 인증을 위한 내부 통신 경로 설정
    2     location /authelia {
    3         internal;
    4         set $upstream_authelia http://mcp_authelia:9091/api/verify;
    5         proxy_pass $upstream_authelia;
    6         proxy_set_header Content-Length "";
    7         proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
    8         proxy_set_header X-Forwarded-For $remote_addr;
    9         proxy_set_header X-Forwarded-Proto $scheme;
   10         proxy_set_header X-Forwarded-Host $http_host;
   11         proxy_set_header X-Forwarded-Uri $request_uri;
   12     }
   13 
   14     # 모든 요청에 대해 Authelia 인증 적용 및 캐시 방지
   15     auth_request /authelia;
   16     auth_request_set $user $upstream_http_x_authelia_user;
   17     auth_request_set $groups $upstream_http_x_authelia_groups;
   18     auth_request_set $auth_cookie $upstream_http_set_cookie;
   19     add_header Set-Cookie $auth_cookie;
   20     proxy_set_header X-Authelia-User $user;
   21     proxy_set_header X-Authelia-Groups $groups;

   6. 마지막으로 Save 버튼을 눌러 모든 설정을 저장합니다.

  ---

  5단계: 최종 테스트

  모든 설정이 완료되었습니다. 브라우저 캐시와 쿠키를 한번 더 삭제한 후, https://app.gostock.us에 접속하여
  로그인을 진행하고 모든 기능이 정상적으로 동작하는지 최종 확인해 주세요.
