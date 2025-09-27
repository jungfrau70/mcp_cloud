# Frontend와 Backend에서 디렉토리 링크 동작 분석

## 🎯 개요

`mcp_knowledge_base` 내의 마크다운 문서에서 디렉토리로 끝나는 링크가 frontend와 backend에서 어떻게 처리되는지 분석합니다.

## 🔍 현재 발견된 디렉토리 링크

### 1. Cloud Intermediate Day1 강의안
```markdown
- ["실습 코드"](cloud_intermediate/samples/day1/)
- ["자동화 스크립트"](cloud_intermediate/scripts/)
```

### 2. 실제 디렉토리 구조
```
mcp_knowledge_base/cloud_intermediate/
├── repo/
│   ├── samples/
│   │   ├── day1/
│   │   └── day2/
│   └── scripts/
│       ├── cloud-intermediate-advanced.sh
│       ├── day1-practice.sh
│       └── README.md
```

## 🖥️ Frontend에서의 처리

### 1. ContentView.vue의 링크 처리
```typescript
// frontend/components/ContentView.vue
contentContainer.value.addEventListener('click', (event) => {
  const link = event.target.closest('a');
  if (!link) return;

  const href = link.getAttribute('href');
  if (!href) return;

  // 링크 클릭 시 시각적 피드백
  link.style.opacity = '0.6';
  link.style.transform = 'scale(0.98)';
  setTimeout(() => {
    link.style.opacity = '';
    link.style.transform = '';
  }, 150);
});
```

### 2. 디렉토리 링크 처리 방식

#### A. 상대 경로 처리
- `cloud_intermediate/samples/day1/` → 상대 경로로 처리
- 현재 파일 위치를 기준으로 경로 해석

#### B. 라우팅 처리
- Nuxt.js의 파일 기반 라우팅 시스템 사용
- `/knowledge-base?path=cloud_intermediate/samples/day1/` 형태로 변환

#### C. 파일 탐색기 연동
```typescript
const navigateToFileTree = () => {
  if (!props.path) return;
  
  // FileTree에서 해당 파일 위치로 이동하는 이벤트 발생
  emit('navigate-to-file-tree', props.path);
};
```

## 🔧 Backend에서의 처리

### 1. Curriculum API 라우팅
```python
# backend/app/api/routes/curriculum.py
@router.get("/file/{path:path}")
def curriculum_get_file(path: str):
    """Binary/static file fetch for curriculum"""
    if not path:
        raise HTTPException(status_code=400, detail='path is required')
    
    fp = _safe_path(path)
    if not fp.exists():
        raise HTTPException(status_code=404, detail='File not found')
    
    # 디렉토리인 경우 처리
    if fp.is_dir():
        # README.md 파일이 있는지 확인
        readme_path = fp / "README.md"
        if readme_path.exists():
            return FileResponse(readme_path)
        else:
            # 디렉토리 목록 반환
            return {"type": "directory", "path": str(fp), "files": list(fp.iterdir())}
```

### 2. 안전한 경로 처리
```python
def _safe_path(rel: str) -> Path:
    rel = (rel or '').strip().lstrip('/\\')
    p = (KB_ROOT / rel).resolve()
    
    # 보안 검증: KB_ROOT 밖으로 나가는 경로 차단
    if not str(p).startswith(str(KB_ROOT)):
        raise HTTPException(status_code=400, detail='Invalid path')
    return p
```

## 🚨 현재 문제점

### 1. 디렉토리 링크 처리 부족
- 디렉토리로 끝나는 링크에 대한 명확한 처리 로직 없음
- README.md 파일이 없는 디렉토리의 경우 404 에러 발생 가능

### 2. Frontend 라우팅 문제
- 디렉토리 링크 클릭 시 적절한 페이지로 이동하지 않음
- 파일 탐색기에서만 해당 위치로 이동

### 3. 사용자 경험 문제
- 디렉토리 링크 클릭 시 예상과 다른 동작
- 명확한 피드백 부족

## 💡 해결 방안

### 1. Backend 개선
```python
@router.get("/directory/{path:path}")
def get_directory_content(path: str):
    """디렉토리 내용 조회"""
    fp = _safe_path(path)
    
    if not fp.exists():
        raise HTTPException(status_code=404, detail='Directory not found')
    
    if not fp.is_dir():
        raise HTTPException(status_code=400, detail='Not a directory')
    
    # README.md 파일 우선 확인
    readme_path = fp / "README.md"
    if readme_path.exists():
        return FileResponse(readme_path)
    
    # 디렉토리 인덱스 생성
    files = []
    for item in fp.iterdir():
        files.append({
            "name": item.name,
            "type": "directory" if item.is_dir() else "file",
            "path": str(item.relative_to(KB_ROOT))
        })
    
    return {
        "type": "directory",
        "path": str(fp.relative_to(KB_ROOT)),
        "files": files
    }
```

### 2. Frontend 개선
```typescript
// ContentView.vue에서 디렉토리 링크 처리
const handleDirectoryLink = async (href: string) => {
  try {
    // 디렉토리 내용 조회
    const response = await $fetch(`/api/v1/curriculum/directory/${href}`);
    
    if (response.type === 'directory') {
      // 디렉토리 목록 표시
      showDirectoryContents(response.files);
    } else {
      // 파일 내용 표시
      navigateToFile(response.path);
    }
  } catch (error) {
    console.error('디렉토리 링크 처리 오류:', error);
    // 파일 탐색기로 이동
    navigateToFileTree(href);
  }
};
```

### 3. 자동 README.md 생성
```python
def create_directory_readme(directory_path: Path) -> None:
    """디렉토리에 README.md 파일 자동 생성"""
    readme_path = directory_path / "README.md"
    
    if not readme_path.exists():
        content = f"""# {directory_path.name}

## 📁 디렉토리 개요
이 디렉토리는 {directory_path.name} 관련 파일들을 포함합니다.

## 📄 파일 목록
{generate_file_list(directory_path)}

## 🔗 관련 링크
- [상위 디렉토리](../README.md)
- [전체 프로젝트](../../README.md)
"""
        
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(content)
```

## 🎯 권장사항

### 1. 즉시 적용 가능한 해결책
- 모든 디렉토리에 README.md 파일 생성
- 디렉토리 링크를 구체적인 파일 링크로 변경

### 2. 중장기 개선 방안
- Backend에 디렉토리 처리 API 추가
- Frontend에 디렉토리 링크 처리 로직 추가
- 자동화된 디렉토리 인덱스 생성

### 3. 사용자 경험 개선
- 디렉토리 링크 클릭 시 명확한 피드백 제공
- 파일 탐색기와의 연동 강화
- 일관된 네비게이션 경험 제공

## 📊 구현 우선순위

1. **높음**: README.md 파일 자동 생성
2. **중간**: Backend 디렉토리 처리 API 추가
3. **낮음**: Frontend 디렉토리 링크 처리 로직 개선

이 분석을 통해 디렉토리 링크의 문제점을 파악하고 체계적인 해결 방안을 제시할 수 있습니다.
