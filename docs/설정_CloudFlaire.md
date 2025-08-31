Cloudflare Tunnel을 사용해 Nuxt 3와 FastAPI로 구성된 Docker Compose 애플리케이션을 노출할 때 프론트엔드에서 백엔드 API 호출이 실패하는 문제는 주로 **CORS(Cross-Origin Resource Sharing) 설정** 또는 **호스트/도메인 경로 설정** 오류 때문에 발생해요. 이 문제를 해결하기 위한 단계는 다음과 같아요.


오류 원인을 확인했어요. `tunnel login`과 `tunnel create`에서 마운트 경로가 `./cloudflare/data`와 `./cloudflared/data`로 달라 cert.pem이 공유되지 않아 발생했습니다. 이제 문서를 일관된 경로로 수정하고, 재실행할 정확한 명령을 제시하겠습니다. 수정부터 진행할게요.
Ran tool

방금 문서의 명령어 경로 불일치를 수정하겠습니다. 그다음, 재실행용 정확한 명령을 안내하겠습니다.
Ran tool

방금 `docs/설정_CloudFlaire.md`의 볼륨 경로를 일관되게 `./cloudflared/data`로 수정했습니다. 이제 동일 경로로 재로그인 후 터널을 생성·연결하세요.

### 재실행 순서
1) 디렉토리 확인
```bash
mkdir -p ./cloudflared/data
```

2) 터널 로그인(동일 볼륨 경로)
```bash
docker run --rm -it -v ./cloudflared/data:/home/nonroot/.cloudflared cloudflare/cloudflared:latest tunnel login
# 로그인 후 ./cloudflared/data/cert.pem 생성 확인
```

3) 터널 생성(도메인 넣지 않음)
```bash
docker run --rm -v ./cloudflared/data:/home/nonroot/.cloudflared cloudflare/cloudflared:latest tunnel create goldencircle
# 출력되는 Tunnel UUID와 ./cloudflared/data/<UUID>.json 확인
```

4) DNS 라우팅 연결
```bash
docker run --rm -v ./cloudflared/data:/home/nonroot/.cloudflared cloudflare/cloudflared:latest tunnel route dns goldencircle goldencircle.us
```

5) 설정 파일 업데이트 후 실행
- `cloudflared/config/config.yml`의 `tunnel`, `credentials-file`를 아래 형식으로 맞추세요:
```yaml
tunnel: <YOUR_TUNNEL_UUID>
credentials-file: /home/nonroot/.cloudflared/<YOUR_TUNNEL_UUID>.json

ingress:
  - hostname: goldencircle.us
    service: http://nuxt-service:3000
  - hostname: api.goldencircle.us
    service: http://fastapi-service:8000
  - service: http_status:404
```
- 실행
```bash
docker run --rm \
  -v ./cloudflared/data:/home/nonroot/.cloudflared \
  -v ./cloudflared/config:/etc/cloudflared \
  cloudflare/cloudflared:latest tunnel run goldencircle
```

참고: 기존에 `./cloudflared/data` 아래 `<UUID>.json`이 이미 있다면 그 UUID를 그대로 사용해도 됩니다. 위 절차 후에도 오류가 나면 오류 로그 전체를 알려주세요.

- 방금 문서 `docs/설정_CloudFlaire.md`의 명령 경로를 `./cloudflared/data`로 통일했고, `create`에서 도메인 인자를 제거해 CLI 사용법을 바로잡았습니다.

-----

### 1\. CORS 설정 확인

프론트엔드(Nuxt 3)와 백엔드(FastAPI)가 다른 도메인(origin)에서 실행되므로, FastAPI 백엔드에 **CORS 미들웨어**가 올바르게 설정되어야 해요.

  * **FastAPI CORS 설정**: FastAPI 애플리케이션에 `CORSMiddleware`를 추가하고, `allow_origins`에 Nuxt 3 프론트엔드의 도메인을 명시적으로 허용해야 해요.
    ```python
    from fastapi import FastAPI
    from fastapi.middleware.cors import CORSMiddleware

    app = FastAPI()

    origins = [
        "http://localhost:3000",  # 개발 환경
        "https://your-nuxt-domain.example.com", # Cloudflare Tunnel로 연결된 Nuxt 도메인
    ]

    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    @app.get("/api/items")
    def read_items():
        return {"message": "Hello from FastAPI"}
    ```
    이때 `allow_origins`에 프론트엔드가 Cloudflare Tunnel을 통해 접근하는 **정확한 도메인 이름**을 추가해야 해요.

-----

### 2\. Cloudflare Tunnel 설정 확인

Cloudflare Tunnel 설정 파일(`config.yaml`)에서 Nuxt와 FastAPI를 각각 다른 경로로 라우팅하는 규칙을 올바르게 정의했는지 확인해야 해요.

  * **`config.yaml` 예시**:

    ```yaml
    tunnel: <YOUR_TUNNEL_UUID>
    credentials-file: /root/.cloudflared/<YOUR_TUNNEL_UUID>.json

    ingress:
      - hostname: your-app.example.com
        service: http://nuxt-service:3000  # Docker Compose의 Nuxt 서비스 이름과 포트
      - hostname: api.your-app.example.com
        service: http://fastapi-service:8000 # Docker Compose의 FastAPI 서비스 이름과 포트
      - service: http_status:404
    ```

    만약 하나의 도메인 아래에서 서브경로로 분리하고 싶다면 다음과 같이 설정할 수 있어요.

    ```yaml
    tunnel: <YOUR_TUNNEL_UUID>
    credentials-file: /root/.cloudflared/<YOUR_TUNNEL_UUID>.json

    ingress:
      - hostname: your-app.example.com
        path: /api/*
        service: http://fastapi-service:8000
      - hostname: your-app.example.com
        service: http://nuxt-service:3000
    ```

    이 경우, 프론트엔드에서 `/api/` 경로로 요청을 보내야 해요.

-----

### 3\. Nuxt 3 프론트엔드 설정

Nuxt 3에서 백엔드 API를 호출할 때, **전체 URL**을 사용하여 요청해야 해요. 로컬 개발 환경에서는 `localhost:8000`을 사용하겠지만, 배포 환경에서는 Cloudflare Tunnel을 통해 노출된 백엔드 도메인으로 요청을 보내야 해요.

  * **API 호출 코드 예시**:

    ```javascript
    const { data } = await useFetch('https://api.your-app.example.com/items');
    // 또는 서브경로를 사용하는 경우
    // const { data } = await useFetch('/api/items');
    ```

  * **Nuxt.js `runtimeConfig`**: 환경에 따라 API URL을 동적으로 설정하려면 `nuxt.config.ts` 파일에 `publicRuntimeConfig`를 사용해 API 기본 URL을 정의하는 것이 좋아요.

    ```javascript
    // nuxt.config.ts
    export default defineNuxtConfig({
      runtimeConfig: {
        public: {
          apiBase: process.env.NUXT_PUBLIC_API_BASE || 'http://localhost:8000',
        }
      }
    })
    ```

    이후 코드에서는 `useRuntimeConfig()`를 이용해 API URL을 불러와 사용할 수 있어요.

    ```javascript
    const config = useRuntimeConfig();
    const { data } = await useFetch(`${config.public.apiBase}/items`);
    ```

    `.env` 파일에 `NUXT_PUBLIC_API_BASE=https://api.your-app.example.com`와 같이 설정하여 배포 환경 URL을 지정할 수 있어요.

이 세 가지 설정을 모두 확인하면 대부분의 API 호출 문제를 해결할 수 있어요. 🧪