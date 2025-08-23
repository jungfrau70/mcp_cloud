마크다운(Markdown) 문서에서 표를 작성하는 것은 많은 작업자에게 번거롭고 직관적이지 않은 작업입니다. 특히 복잡한 표를 만들거나 수정할 때는 더욱 그렇습니다. FastAPI를 백엔드로, Nuxt3를 프론트엔드로 사용하는 환경에서 이 문제를 해결할 수 있는 몇 가지 개선 방법을 제시합니다.

### **핵심 개선 방향: 위지윅(WYSIWYG) 에디터 도입**

가장 효과적인 해결책은 마크다운 문법에 익숙하지 않은 사용자도 쉽게 표를 만들고 편집할 수 있는 \*\*시각적 표 편집기(WYSIWYG, What You See Is What You Get)\*\*를 도입하는 것입니다. 사용자는 마크다운 코드를 직접 작성하는 대신, 그래픽 사용자 인터페이스(GUI)를 통해 엑셀이나 구글 시트처럼 표를 편집하고, 시스템은 이를 자동으로 마크다운 형식으로 변환해주는 방식입니다.

-----

### **Nuxt3 프론트엔드 구현 방안**

프론트엔드에서는 사용자가 직접 표를 보고 편집할 수 있는 인터페이스를 제공하는 것이 중요합니다. 이를 위해 다음과 같은 오픈소스 라이브러리를 활용할 수 있습니다.

  * **Toast UI Editor**: 마크다운 에디터 중 가장 강력한 기능 중 하나로, 표 편집을 위한 뛰어난 위지윅 인터페이스를 제공합니다. 사용자는 GUI를 통해 행과 열을 추가/삭제하고, 셀 내용을 채우고, 정렬 방식을 지정할 수 있습니다.
  * **TipTap**: 확장성이 매우 뛰어난 에디터 프레임워크입니다. `tiptap-extension-table`과 같은 확장을 사용하면 손쉽게 커스텀 가능한 표 편집 기능을 구현할 수 있습니다. 보다 세밀한 제어가 필요할 때 유용합니다.
  * **Milkdown**: Prosemirror와 Remark를 기반으로 하는 플러그인 기반의 마크다운 에디터입니다. 위지윅 기능과 마크다운 소스 코드 편집을 동시에 지원하는 하이브리드 모드를 제공하여 숙련자와 비숙련자 모두를 만족시킬 수 있습니다.

**구현 단계:**

1.  **라이브러리 선택 및 설치**: Nuxt3 프로젝트에 위에서 언급한 에디터 라이브러리 중 하나를 `npm`이나 `yarn`을 통해 설치합니다.
2.  **컴포넌트 생성**: 에디터를 래핑하는 Vue 컴포넌트(`MarkdownEditor.vue`)를 생성합니다. 이 컴포넌트는 에디터의 초기화, 데이터 바인딩, 이벤트 처리 등을 담당합니다.
3.  **데이터 바인딩**: `v-model`을 사용하여 부모 컴포넌트의 데이터와 에디터의 콘텐츠를 양방향으로 바인딩합니다. 사용자가 에디터에서 표를 수정하면, 해당 내용이 실시간으로 마크다운 텍스트로 변환되어 데이터에 반영됩니다.
4.  **API 연동**: 사용자가 '저장' 버튼을 누르면, 컴포넌트는 현재 에디터의 마크다운 콘텐츠를 FastAPI 백엔드로 전송하는 API 요청을 보냅니다.

<!-- end list -->

```vue
<template>
  <div ref="editor"></div>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue';
import Editor from '@toast-ui/editor';
import '@toast-ui/editor/dist/toastui-editor.css';

const props = defineProps({
  modelValue: String,
});
const emit = defineEmits(['update:modelValue']);
const editor = ref(null);
const editorInstance = ref(null);

onMounted(() => {
  editorInstance.value = new Editor({
    el: editor.value,
    initialValue: props.modelValue,
    previewStyle: 'vertical',
    height: '500px',
    initialEditType: 'wysiwyg', // 위지윅 모드를 기본으로 설정
    events: {
      change: () => {
        emit('update:modelValue', editorInstance.value.getMarkdown());
      },
    },
  });
});

watch(() => props.modelValue, (newValue) => {
  if (editorInstance.value.getMarkdown() !== newValue) {
    editorInstance.value.setMarkdown(newValue);
  }
});
</script>
```

-----

### **FastAPI 백엔드 구현 방안**

백엔드는 프론트엔드로부터 받은 마크다운 텍스트를 안전하게 처리하고 데이터베이스에 저장하는 역할을 합니다. 또한, 저장된 데이터를 다시 프론트엔드로 전달하는 기능도 수행합니다.

  * **데이터 모델 정의**: Pydantic을 사용하여 요청 및 응답 본문의 데이터 구조를 정의합니다. 이를 통해 들어오는 데이터의 유효성을 검사할 수 있습니다.
  * **API 엔드포인트 생성**: 문서를 생성하고, 조회하고, 수정하는 등의 CRUD(Create, Read, Update, Delete) 작업을 위한 API 엔드포인트를 만듭니다.
  * **데이터베이스 저장**: ORM(예: SQLAlchemy)을 사용하여 클라이언트로부터 받은 마크다운 텍스트를 데이터베이스의 해당 필드에 저장합니다.
  * **보안**: 저장하기 전에 `DOMPurify`와 같은 라이브러리를 클라이언트 측에서, 또는 백엔드에서 HTML 태그를 필터링하여 XSS(Cross-Site Scripting) 공격을 방지하는 것이 중요합니다.

**구현 단계:**

1.  **Pydantic 모델 생성**: 문서의 내용을 담을 스키마를 정의합니다.

    ```python
    # schemas.py
    from pydantic import BaseModel

    class DocumentBase(BaseModel):
        title: str
        content: str

    class DocumentCreate(DocumentBase):
        pass

    class Document(DocumentBase):
        id: int
        owner_id: int

        class Config:
            orm_mode = True
    ```

2.  **API 라우터 구현**: 문서를 생성하고 업데이트하는 엔드포인트를 구현합니다. 프론트엔드에서 보낸 `content`(마크다운 텍스트)를 받아 데이터베이스에 저장합니다.

    ```python
    # main.py
    from fastapi import FastAPI, Depends
    from sqlalchemy.orm import Session
    from . import crud, models, schemas
    from .database import SessionLocal, engine

    models.Base.metadata.create_all(bind=engine)

    app = FastAPI()

    # Dependency
    def get_db():
        db = SessionLocal()
        try:
            yield db
        finally:
            db.close()

    @app.post("/documents/", response_model=schemas.Document)
    def create_document(document: schemas.DocumentCreate, db: Session = Depends(get_db)):
        # 받은 마크다운 콘텐츠(document.content)를 DB에 저장
        return crud.create_document(db=db, document=document)

    @app.put("/documents/{document_id}", response_model=schemas.Document)
    def update_document(document_id: int, document: schemas.DocumentCreate, db: Session = Depends(get_db)):
        # 받은 마크다운 콘텐츠로 기존 문서를 업데이트
        return crud.update_document(db=db, document_id=document_id, document=document)
    ```

### **결론**

마크다운 표 작성의 비직관적인 문제를 해결하기 위해 **Nuxt3 기반의 위지윅 에디터를 프론트엔드에 도입**하고, **FastAPI 백엔드에서는 이를 안정적으로 처리하여 저장**하는 시스템을 구축하는 것이 가장 효과적입니다. 이 방식을 통해 작업자는 마크다운 문법을 몰라도 워드 프로세서나 스프레드시트를 다루듯 쉽게 표를 생성하고 편집할 수 있어 생산성이 크게 향상될 것입니다. 🚀

---

## Phase 2 적용 계획 (TipTap 하이브리드)

목표: 현행 마크다운 파이프라인(버전·DIFF·Outline·AI·렌더·저장)을 유지하면서, 고급 편집 UX(표, 서식, 슬래시 명령, 붙여넣기/드래그앤드롭 업로드)를 제공하는 WYSIWYG 편집기를 추가한다.

### 1) 범위(Scope)
- SplitEditor에 TipTap 모드 추가(토글 가능): Markdown | TipTap
- 표(Table) 고급 편집(행/열 추가·삭제, 병합/분할, 정렬)
- 코드블록 + 구문강조, mermaid 프리뷰(펜스 코드 유지)
- 이미지 업로드(붙여넣기/드래그앤드롭) → 기존 `uploadAsset` API 연동
- 슬래시 메뉴(/) 및 기본 서식 핫키(B/I/U/Heading/List)
- Markdown ↔ ProseMirror Round-trip 변환
- 버전/DIFF/Outline/AI 변환/저장 동작 유지

Out-of-Scope(본 단계 제외)
- 실시간 협업(OT/CRDT), 주석/리뷰, 다중 사용자 커서
- 서버 측 렌더러 교체(현행 유지)

### 2) 아키텍처/연동
- TipTap 에디터를 Nuxt 플러그인으로 동적 import(SSR 가드)
- Markdown <-> ProseMirror 변환
  - 우선 Remark/Remark-GFM + prosemirror-markdown 조합으로 MVP
  - fenced code/mermaid/vega-lite는 토글 가능한 커스텀 노드 또는 MD 보존 전략으로 유지
- 저장 시점: TipTap → MD 직렬화 → 기존 저장 API 사용
- 이미지 업로드 훅: TipTap paste/drop 이벤트 → `uploadAsset(file, 'assets')` → 상대 경로 삽입
- Feature Flag로 안전 배포: `EDITOR_MODE=tiptap|markdown`

### 3) 구현 항목 (Checklist)
- [ ] TipTap 및 필수 확장 설치(테이블/코드/링크/히스토리/플레이스홀더 등)
- [ ] `TipTapEditor.vue` 래퍼 컴포넌트(SSR 가드, v-model, onSave 훅)
- [ ] Markdown → TipTap 초기화 파이프라인(remark 기반)
- [ ] TipTap → Markdown 저장 파이프라인(prosemirror-markdown 기반)
- [ ] 표 확장: 툴바(행/열 추가/삭제, 병합/분할, 헤더/정렬)
- [ ] 코드블록 + 구문강조(Shiki/Prism 중 택1), mermaid 블록 프리뷰
- [ ] 이미지 붙여넣기/드롭 업로드 연동 및 진행 상태 UI
- [ ] 슬래시 메뉴(/) + 서식 핫키
- [ ] SplitEditor 토글 + 마지막 사용 모드 저장(localStorage)
- [ ] 버전/DIFF/Outline/AI 변환 연동 회귀 테스트
- [ ] E2E: open/edit/save/round-trip fidelity/rollback

### 4) 작업 일정(안)
- Day 1: 설치/플러그인 구성, 기본 에디터 표시, v-model 연동
- Day 2: 표 확장/툴바, 이미지 업로드 훅, 코드블록/구문강조
- Day 3: mermaid/vega-lite 블록 프리뷰, 슬래시 메뉴 & 핫키
- Day 4: MD Round-trip 품질 개선(헤딩/리스트/표 보존), 회귀 테스트
- Day 5: Feature Flag 배포, 사용자 검증, 안정화(버그픽스)

### 5) 리스크 & 대응
- Round-trip 손실(서식/표/특수 블록)
  - 대응: 단위 테스트 + 샘플 문서 스냅샷 비교, 문제 구간은 fenced MD 원형 보존
- 번들 크기/SSR 이슈
  - 대응: 동적 import, 에디터 모드 진입 시 로딩, 크리티컬 렌더 경로 분리
- Mermaids/Vega 실행 오류
  - 대응: try/catch + 사용성 안내, 가능 시 웹워커/비동기 렌더링

### 6) 성공 기준
- 표 편집(병합/분할/헤더/정렬) 100% 동작
- 기존 저장/버전/DIFF/Outline/AI 기능 회귀 테스트 통과
- 라운드트립 품질: 기존 MD 문서 95% 이상 무손실 변환

### 7) 롤백 전략
- Feature Flag로 즉시 Markdown 모드로 고정
- TipTap 관련 라우트/컴포넌트 비활성화
- 저장 포맷은 MD만 사용하므로 데이터 롤백 불필요

### 8) 승인/거버넌스
- MVP 완료 후 튜터/PM 사용자 검증(표 작업 시나리오 중심)
- 이슈 지표: 저장 실패율, 라운드트립 차이 건수, 성능(TTI, 입력 지연)