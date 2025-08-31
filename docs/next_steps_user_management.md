## 사용자 관리 기능 구현 - 다음 단계

MentorAi 플랫폼의 사용자 관리 기능 구현을 위한 다음 단계는 다음과 같습니다.

### Phase 1 - 접근 제어 강화 (남은 단계)

1.  **수동 작업: NPM Forward Auth 설정**
    *   Nginx Proxy Manager(NPM) UI를 통해 수동으로 Forward Auth 설정을 완료해야 합니다.
    *   자세한 설정 방법은 `docs/설정_NPM.md` 문서를 참조하십시오. 특히, "Custom Nginx Configuration" 섹션의 Nginx 설정 스니펫을 해당 Proxy Host에 추가해야 합니다.
    *   NPM 설정 시, 도메인을 `goldencircle.us`에서 `mentorai.local`로 업데이트하는 것을 잊지 마십시오.

2.  **검증 단계: 백엔드 테스트 실행**
    *   FastAPI RBAC 가드 변경 사항이 올바르게 적용되었는지 확인하기 위해 백엔드 테스트를 실행하는 것을 권장합니다.
    *   다음 명령어를 사용하여 관련 테스트를 실행할 수 있습니다:
        ```bash
        pytest backend/tests/test_auth_and_user.py
        ```
    *   이 테스트는 지식 베이스 API에 대한 관리자 전용 접근이 올바르게 작동하는지 검증하는 데 도움이 됩니다.

### Phase 2 - 소셜 로그인 (다음 주요 단계)

Phase 1의 NPM 설정 및 검증이 완료되면, 다음 주요 단계는 소셜 로그인(Google) 통합입니다.

1.  **oauth2-proxy 또는 Authelia OIDC 설정:**
    *   Google Client/Secret을 설정하여 소셜 로그인을 위한 기반을 마련합니다.

---

**다음 진행:**

NPM 설정이 완료되면 알려주십시오. 그 후 테스트를 실행할지, 아니면 바로 Phase 2로 진행할지 결정할 수 있습니다.
