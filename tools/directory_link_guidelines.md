
# 디렉토리 링크 처리 가이드라인

## 🎯 목적
내부 링크가 디렉토리에 걸린 경우의 처리 방안을 정의합니다.

## 📋 디렉토리 링크 처리 규칙

### 1. 디렉토리 링크의 정의
- 링크 URL이 `/`로 끝나는 경우
- 외부 링크가 아닌 경우
- 예: `[실습 코드](cloud_intermediate/samples/day1/)`

### 2. 디렉토리 링크 처리 방안

#### A. README.md 파일이 있는 경우
```markdown
<!-- ✅ DO: README.md 파일로 링크 -->
[실습 코드](cloud_intermediate/samples/day1/README.md)
```

#### B. README.md 파일이 없는 경우
```markdown
<!-- ✅ DO: 대표 파일로 링크 -->
[실습 코드](cloud_intermediate/samples/day1/main.md)
```

#### C. 여러 파일이 있는 경우
```markdown
<!-- ✅ DO: 인덱스 파일 생성 후 링크 -->
[실습 코드](cloud_intermediate/samples/day1/index.md)
```

### 3. 자동 처리 방안

#### A. README.md 파일 자동 생성
```python
def create_directory_readme(directory_path: Path) -> None:
    """디렉토리에 README.md 파일 생성"""
    readme_path = directory_path / "README.md"
    
    if not readme_path.exists():
        content = f"""# {directory_path.name}
        
## 📁 디렉토리 개요
이 디렉토리는 {directory_path.name} 관련 파일들을 포함합니다.

## 📄 파일 목록
{self._generate_file_list(directory_path)}

## 🔗 관련 링크
- [상위 디렉토리](../README.md)
- [전체 프로젝트](../../README.md)
"""
        
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(content)
```

#### B. 디렉토리 링크 자동 수정
```python
def fix_directory_links(file_path: Path) -> None:
    """디렉토리 링크를 적절한 파일 링크로 수정"""
    # 디렉토리 링크 찾기
    # README.md 파일 존재 확인
    # 적절한 파일로 링크 수정
```

### 4. 품질 보장

#### A. 디렉토리 링크 검증
- 모든 디렉토리 링크가 실제 디렉토리를 가리키는지 확인
- 디렉토리에 적절한 인덱스 파일이 있는지 확인
- 링크가 깨지지 않는지 확인

#### B. 자동화 도구
- 디렉토리 링크 자동 감지
- README.md 파일 자동 생성
- 링크 자동 수정

## 🚨 주의사항

### 절대 금지사항
- ❌ 존재하지 않는 디렉토리로 링크
- ❌ 디렉토리 링크를 그대로 두기
- ❌ 외부 링크를 내부 링크로 잘못 분류

### 권장사항
- ✅ 모든 디렉토리에 README.md 파일 생성
- ✅ 디렉토리 링크를 구체적인 파일 링크로 변경
- ✅ 정기적인 링크 검증 및 수정
