# Authelia 인증 요청
auth_request /authelia;
auth_request_set $target_url $scheme://$http_host$request_uri;
 
# Authelia로부터 받은 사용자 정보를 변수로 설정
auth_request_set $user $upstream_http_x_authelia_user;
auth_request_set $groups $upstream_http_x_authelia_groups;
auth_request_set $name $upstream_http_x_authelia_name;
auth_request_set $email $upstream_http_x_authelia_email;
 
# 백엔드로 전달할 헤더 설정 (기존 설정 + 인증 정보)
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Authelia-User $user;
proxy_set_header X-Authelia-Groups $groups;
proxy_set_header X-Authelia-Name $name;
proxy_set_header X-Authelia-Email $email;
 
# 타임아웃 설정
proxy_read_timeout 300;
proxy_connect_timeout 300;

---


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
 
# 모든 요청에 대해 Authelia 인증 적용
auth_request /authelia;
auth_request_set $user $upstream_http_x_authelia_user;
auth_request_set $groups $upstream_http_x_authelia_groups;
proxy_set_header X-Authelia-User $user;
proxy_set_header X-Authelia-Groups $groups;

---


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