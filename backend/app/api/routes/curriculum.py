# backend/app/api/routes/slides.py
from fastapi import APIRouter, Depends, HTTPException
from typing import Any, Dict, List
from pathlib import Path
from security import get_api_key
from fastapi.responses import PlainTextResponse, FileResponse
import urllib.parse

router = APIRouter(prefix="/api/v1/curriculum", tags=["Curriculum"])

KB_ROOT = Path('../mcp_knowledge_base').resolve()
SELECTION_FILE = Path('../.slides_selection.json').resolve()
try:
    from utils.doc_convert import convert_pptx_to_pdf  # correct import within backend package
except Exception:
    convert_pptx_to_pdf = None

def _safe_path(rel: str) -> Path:
    rel = (rel or '').strip().lstrip('/\\')
    p = (KB_ROOT / rel).resolve()
    if not str(p).startswith(str(KB_ROOT)):
        raise HTTPException(status_code=400, detail='Invalid path')
    return p

def _encode_filename(filename: str) -> str:
    """
    RFC 5987 표준에 따라 파일명을 인코딩합니다.
    한글 파일명을 안전하게 처리할 수 있습니다.
    """
    try:
        # ASCII 문자만 포함된 경우 그대로 반환
        filename.encode('ascii')
        return f'"{filename}"'
    except UnicodeEncodeError:
        # 한글이나 다른 유니코드 문자가 포함된 경우 RFC 5987 표준으로 인코딩
        encoded = urllib.parse.quote(filename, safe='')
        return f"filename*=UTF-8''{encoded}"

def _clean_anchor_links_for_pdf(markdown_content: str) -> str:
    """PDF 변환을 위해 마크다운 콘텐츠의 앵커 링크 ID를 정리"""
    import re
    
    def generate_heading_id(text: str) -> str:
        """헤딩 텍스트에서 ID 생성"""
        # 이모지 제거
        text = re.sub(r'[^\w\s가-힣]', '', text)
        # 공백을 하이픈으로 변환
        text = re.sub(r'\s+', '-', text)
        # 앞뒤 하이픈 제거 및 소문자 변환
        return text.strip('-').lower()
    
    # 1단계: 헤딩에 명시적 ID 추가
    def add_heading_id(match):
        level = match.group(1)
        text = match.group(2).strip()
        
        # 이미 ID가 있는지 확인
        if '{#' in text and '}' in text:
            return match.group(0)
        
        # ID 생성
        heading_id = generate_heading_id(text)
        return f"{level} {text} {{#{heading_id}}}"
    
    # 헤딩 패턴 매칭 및 ID 추가
    heading_pattern = r'^(#{1,6})\s+(.+)$'
    cleaned_content = re.sub(heading_pattern, add_heading_id, markdown_content, flags=re.MULTILINE)
    print(f"DEBUG: Found {len(re.findall(heading_pattern, markdown_content, flags=re.MULTILINE))} headings")
    
    # 2단계: 앵커 링크 ID 정리
    def clean_anchor_id(match):
        text = match.group(1)
        anchor_id = match.group(2)
        
        # URL 디코딩
        try:
            decoded_id = urllib.parse.unquote(anchor_id)
        except:
            decoded_id = anchor_id
        
        # 앵커 ID 정리: 특수문자 제거, 공백을 하이픈으로 변환
        cleaned_id = re.sub(r'[^\w\s가-힣-]', '', decoded_id)
        cleaned_id = re.sub(r'\s+', '-', cleaned_id)
        cleaned_id = cleaned_id.strip('-').lower()
        
        return f'[{text}](#{cleaned_id})'
    
    # 앵커 링크 패턴 매칭 및 정리
    anchor_pattern = r'\[([^\]]+)\]\(#([^)]+)\)'
    anchor_matches = re.findall(anchor_pattern, cleaned_content)
    print(f"DEBUG: Found {len(anchor_matches)} anchor links")
    cleaned_content = re.sub(anchor_pattern, clean_anchor_id, cleaned_content)
    
    return cleaned_content


def _build_tree(show_hidden: bool = False) -> Dict[str, Any]:
    # Simple merge of selected dirs under KB_ROOT
    data: Dict[str, Any] = {}
    selected = get_selection().get('selected_dirs', [])

    def build(d: Path) -> Dict[str, Any]:
        tree: Dict[str, Any] = {}
        files = []
        for child in sorted(d.iterdir()):
            # Skip hidden files/directories unless show_hidden is True
            if not show_hidden and child.name.startswith('.'):
                continue
                
            if child.is_dir():
                tree[child.name] = build(child)
            else:
                files.append({"name": child.name, "path": str(child.relative_to(KB_ROOT)).replace('\\','/')})
        if files:
            tree['files'] = files
        return tree

    for rel in selected:
        p = (KB_ROOT / rel).resolve()
        if p.exists() and str(p).startswith(str(KB_ROOT)):
            # 전체 경로를 키로 사용하여 중복 방지
            data[rel] = build(p)
    return data

@router.get('/tree')
def curriculum_tree(show_hidden: bool = True):
    """
    커리큘럼의 디렉토리 구조를 JSON 형태로 반환합니다.
    show_hidden: 숨김 파일과 디렉토리(점으로 시작하는)를 포함할지 여부
    """
    return _build_tree(show_hidden=show_hidden)


@router.get('/selection')
def get_selection():
    print(f"DEBUG: SELECTION_FILE path: {SELECTION_FILE}")
    print(f"DEBUG: SELECTION_FILE absolute path: {SELECTION_FILE.absolute()}")
    print(f"DEBUG: SELECTION_FILE exists: {SELECTION_FILE.exists()}")
    print(f"DEBUG: Current working directory: {Path.cwd()}")
    if not SELECTION_FILE.exists():
        print("DEBUG: SELECTION_FILE does not exist, returning empty list")
        return {"selected_dirs": []}
    try:
        import json
        content = SELECTION_FILE.read_text()
        print(f"DEBUG: SELECTION_FILE content: {content}")
        result = json.loads(content)
        print(f"DEBUG: Parsed result: {result}")
        return {"selected_dirs": result}
    except Exception as e:
        print(f"DEBUG: Exception reading SELECTION_FILE: {e}")
        return {"selected_dirs": []}

@router.post('/selection', dependencies=[Depends(get_api_key)])
def set_selection(payload: Dict[str, List[str]]):
    selected = payload.get('selected_dirs') or []
    try:
        import json
        SELECTION_FILE.write_text(json.dumps(selected))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    return {"ok": True}

# @router.get('/`tree`')
# def slides_tree():
#     # Simple merge of selected dirs under KB_ROOT
#     data: Dict[str, Any] = {}
#     selected = get_selection().get('selected_dirs', [])

#     def build(d: Path) -> Dict[str, Any]:
#         tree: Dict[str, Any] = {}
#         files = []
#         for child in sorted(d.iterdir()):
#             if child.is_dir():
#                 tree[child.name] = build(child)
#             else:
#                 files.append({"name": child.name, "path": str(child.relative_to(KB_ROOT)).replace('\\','/')})
#         if files:
#             tree['files'] = files
#         return tree

#     for rel in selected:
#         p = (KB_ROOT / rel).resolve()
#         if p.exists() and str(p).startswith(str(KB_ROOT)):
#             data[rel.split('/')[-1]] = build(p)
#     return data

def _clean_duplicate_path(path: str) -> str:
    """Remove duplicate path segments from curriculum path."""
    if not path:
        return path
    
    # Normalize path separators
    normalized = path.replace('\\', '/').strip('/')
    parts = normalized.split('/')
    
    if not parts:
        return path
    
    # Find root markers
    root_markers = ['cloud_basic', 'cloud_master', 'cloud_container']
    
    # More aggressive duplicate removal
    import re
    
    # First, remove any obvious infinite loops
    # Pattern: same segment repeated multiple times
    for marker in root_markers:
        # Remove patterns like: cloud_basic/textbook/Day1/scripts/cloud_basic/textbook/Day1/scripts/...
        pattern = f'({re.escape(marker)}/[^/]+/[^/]+/[^/]+/)\\1+'
        normalized = re.sub(pattern, r'\1', normalized)
        
        # Remove simpler patterns like: cloud_basic/cloud_basic/...
        pattern = f'({re.escape(marker)}/)\\1+'
        normalized = re.sub(pattern, r'\1', normalized)
    
    # Remove any repeated textbook/DayX patterns
    normalized = re.sub(r'(textbook/Day\d+/)(\1)+', r'\1', normalized)
    
    # Remove any repeated scripts/ patterns
    normalized = re.sub(r'(scripts/)(\1)+', r'\1', normalized)
    
    # Split again after regex cleanup
    parts = normalized.split('/')
    
    # Find the first occurrence of a root marker
    first_root_index = -1
    for i, part in enumerate(parts):
        if part in root_markers:
            first_root_index = i
            break
    
    if first_root_index == -1:
        return normalized
    
    # Keep only from the first root marker onwards
    cleaned_parts = parts[first_root_index:]
    
    # Additional cleanup: remove any remaining duplicates
    final_parts = []
    i = 0
    while i < len(cleaned_parts):
        current_part = cleaned_parts[i]
        
        # Check if we're starting a duplicate sequence
        if current_part in root_markers and i > 0:
            # Look ahead to see if this is a duplicate pattern
            if i + 3 < len(cleaned_parts):
                # Check if the next 3 parts match a previous pattern
                potential_duplicate = '/'.join(cleaned_parts[i:i+4])
                existing_pattern = '/'.join(final_parts[-4:]) if len(final_parts) >= 4 else ''
                
                if potential_duplicate in existing_pattern:
                    # Skip this duplicate
                    i += 4
                    continue
        
        final_parts.append(current_part)
        i += 1
    
    result = '/'.join(final_parts)
    
    # Final safety check: if result is still too long or has obvious duplicates, truncate
    if len(result) > 200 or result.count('/') > 10:
        # Find the first complete path and use only that
        for marker in root_markers:
            if marker in result:
                # Take only up to the first README.md or similar file
                if 'README.md' in result:
                    end_index = result.find('README.md') + len('README.md')
                    result = result[:end_index]
                    break
                # Or take only the first reasonable path
                parts = result.split('/')
                if len(parts) > 6:  # course/textbook/Day/file should be max 4-5 parts
                    result = '/'.join(parts[:6])
                break
    
    return result

@router.get('')
def get_slide(textbook_path: str = None, curriculum_path: str = None):
    """Return slide content (text) for curriculum items.

    Accepts both 'curriculum_path' (new) and 'textbook_path' (legacy) for compatibility.
    """
    raw = curriculum_path if curriculum_path is not None else textbook_path
    if not raw:
        raise HTTPException(status_code=400, detail='Missing curriculum_path')
    
    # URL 디코딩 처리 (한글 파일명 지원, 2중 인코딩 방지)
    try:
        rel = raw.strip().lstrip('/\\')
        # 재귀적 디코딩: 2중 인코딩된 경우를 처리
        while '%' in rel and rel != urllib.parse.unquote(rel):
            rel = urllib.parse.unquote(rel)
    except Exception:
        rel = raw.strip().lstrip('/\\')
    
    # Clean duplicate path segments
    rel = _clean_duplicate_path(rel)
    # Consider common text and document extensions to avoid forcing .md
    if not any(rel.endswith(ext) for ext in ('.md', '.markdown', '.txt', '.log', '.json', '.yaml', '.yml', '.csv', '.sh', '.pdf', '.ppt', '.pptx')):
        rel = f"{rel}.md"
    fp = (KB_ROOT / rel).resolve()
    print(f"DEBUG: KB_ROOT = {KB_ROOT}")
    print(f"DEBUG: rel = {rel}")
    print(f"DEBUG: fp = {fp}")
    print(f"DEBUG: fp.exists() = {fp.exists()}")
    if not str(fp).startswith(str(KB_ROOT)):
        raise HTTPException(status_code=400, detail='Invalid path')
    if not fp.exists():
        raise HTTPException(status_code=404, detail=f'Not found: {fp}')
    # If PDF file requested, stream as binary
    if fp.suffix.lower() == '.pdf':
        if not fp.exists():
            raise HTTPException(status_code=404, detail='Not found')
        return FileResponse(str(fp), media_type='application/pdf', filename=fp.name, content_disposition_type='inline')

    # If PPT/PPTX requested, convert to PDF and stream
    if fp.suffix.lower() in ('.ppt', '.pptx'):
        if convert_pptx_to_pdf is None:
            raise HTTPException(status_code=501, detail='PPTX conversion is not available on server')
        try:
            pdf_fp = convert_pptx_to_pdf(fp, KB_ROOT)
        except HTTPException as e:
            raise e
        except Exception as e:
            raise HTTPException(status_code=500, detail=f'Conversion error: {e}')
        return FileResponse(str(pdf_fp), media_type='application/pdf', filename=pdf_fp.name, content_disposition_type='inline')

    # Default: return text content
    try:
        text = fp.read_text(encoding='utf-8', errors='ignore')
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    return PlainTextResponse(text)

@router.get('/file')
def curriculum_get_file(path: str):
    """Binary/static file fetch for curriculum, mirroring KB /file.

    - Streams PDF/images/video/audio inline
    - Converts PPT/PPTX to PDF inline when possible
    - Other types are served as attachments
    """
    if not path:
        raise HTTPException(status_code=400, detail='path is required')
    fp = _safe_path(path)
    if not fp.exists():
        raise HTTPException(status_code=404, detail='Not found')
    if fp.is_dir():
        raise HTTPException(status_code=400, detail='Path is a directory')

    ext = (fp.suffix or '').lstrip('.').lower()
    # PPT/PPTX → PDF
    if ext in {'ppt','pptx'}:
        if convert_pptx_to_pdf is None:
            raise HTTPException(status_code=501, detail='PPTX conversion is not available on server')
        try:
            pdf_fp = convert_pptx_to_pdf(fp, KB_ROOT)
        except HTTPException as e:
            raise e
        except Exception as e:
            raise HTTPException(status_code=500, detail=f'Conversion error: {e}')
        return FileResponse(str(pdf_fp), media_type='application/pdf', filename=pdf_fp.name, content_disposition_type='inline')

    # Guess type and serve
    import mimetypes
    ctype, _ = mimetypes.guess_type(fp.name)
    media_type = ctype or 'application/octet-stream'
    inline_exts = {'pdf','png','jpg','jpeg','gif','svg','webp','mp4','webm','mp3','wav'}
    disposition = 'inline' if ext in inline_exts else 'attachment'
    return FileResponse(str(fp), media_type=media_type, filename=fp.name, content_disposition_type=disposition)

@router.get('/item')
def curriculum_get_item(path: str):
    """Read-only item fetch compatible with knowledge-base/item shape.

    Returns JSON: { path, type: 'file'|'directory', content? }
    """
    # URL 디코딩 처리 (한글 파일명 지원, 2중 인코딩 방지)
    try:
        decoded_path = path
        # 재귀적 디코딩: 2중 인코딩된 경우를 처리
        while '%' in decoded_path and decoded_path != urllib.parse.unquote(decoded_path):
            decoded_path = urllib.parse.unquote(decoded_path)
    except Exception:
        decoded_path = path
    fp = _safe_path(decoded_path)
    if not fp.exists():
        raise HTTPException(status_code=404, detail='Not found')
    if fp.is_dir():
        return {"path": path, "type": "directory"}
    try:
        content = fp.read_text(encoding='utf-8', errors='ignore')
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Failed to read file: {e}')
    return {"path": path, "type": "file", "content": content}

@router.get('/pdf')
def download_pdf(path: str):
    """Download PDF for a given curriculum path.

    If path points to a markdown/text file, tries to find a sibling .pdf with the same basename.
    If a .pdf is directly requested, serves it. Otherwise falls back to returning the source text as attachment.
    """
    if not path:
        raise HTTPException(status_code=400, detail='path is required')
    
    # URL 디코딩 처리 (한글 파일명 지원)
    try:
        rel = urllib.parse.unquote(path.strip().lstrip('\\/'))
    except Exception:
        rel = path.strip().lstrip('\\/')
    fp = (KB_ROOT / rel).resolve()
    if not str(fp).startswith(str(KB_ROOT)):
        raise HTTPException(status_code=400, detail='Invalid path')

    # If direct PDF requested
    if fp.suffix.lower() == '.pdf' and fp.exists():
        return FileResponse(str(fp), media_type='application/pdf', filename=fp.name, content_disposition_type='attachment')

    # Try sibling PDF with same stem
    stem = fp.with_suffix('')
    pdf_fp = stem.with_suffix('.pdf')
    if pdf_fp.exists():
        return FileResponse(str(pdf_fp), media_type='application/pdf', filename=pdf_fp.name, content_disposition_type='attachment')

    # Check if it's a markdown file and try to convert to PDF
    if fp.suffix.lower() in ('.md', '.markdown'):
        try:
            # Try weasyprint first, then fallback to markdown_pdf
            try:
                import markdown
                from weasyprint import HTML, CSS
                from weasyprint.text.fonts import FontConfiguration
                from io import BytesIO
                
                # Read markdown content
                markdown_content = fp.read_text(encoding='utf-8', errors='ignore')
                print(f"DEBUG: Read markdown content, length: {len(markdown_content)}")
                
                # Clean anchor links for PDF conversion
                cleaned_content = _clean_anchor_links_for_pdf(markdown_content)
                print(f"DEBUG: Cleaned markdown content for PDF conversion")
                
                # Convert markdown to HTML
                md = markdown.Markdown(extensions=['toc', 'tables', 'fenced_code'])
                html_content = md.convert(cleaned_content)
                
                # Add basic CSS for better PDF formatting
                css_content = """
                body { font-family: Arial, sans-serif; line-height: 1.6; margin: 40px; }
                h1, h2, h3, h4, h5, h6 { color: #333; margin-top: 30px; }
                code { background-color: #f4f4f4; padding: 2px 4px; border-radius: 3px; }
                pre { background-color: #f4f4f4; padding: 15px; border-radius: 5px; overflow-x: auto; }
                table { border-collapse: collapse; width: 100%; }
                th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                th { background-color: #f2f2f2; }
                """
                
                # Create full HTML document
                full_html = f"""
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="utf-8">
                    <title>{stem.name}</title>
                </head>
                <body>
                    {html_content}
                </body>
                </html>
                """
                
                # Convert HTML to PDF
                print(f"DEBUG: Starting HTML to PDF conversion for {fp}")
                font_config = FontConfiguration()
                html_doc = HTML(string=full_html)
                css_doc = CSS(string=css_content, font_config=font_config)
                
                buffer = BytesIO()
                html_doc.write_pdf(buffer, stylesheets=[css_doc], font_config=font_config)
                buffer.seek(0)
                print(f"DEBUG: HTML to PDF conversion completed, buffer size: {buffer.getbuffer().nbytes}")
                
            except ImportError as e:
                print(f"DEBUG: weasyprint not available, trying markdown_pdf: {e}")
                
                # Fallback to markdown_pdf
                try:
                    from markdown_pdf import MarkdownPdf, Section
                    from io import BytesIO
                except ImportError as e:
                    # Final fallback to plain text
                    print(f"DEBUG: markdown_pdf import failed: {e}")
                    text = fp.read_text(encoding='utf-8', errors='ignore')
                    filename = f"{stem.name}.md"
                    encoded_filename = _encode_filename(filename)
                    return PlainTextResponse(text, headers={'Content-Disposition': f'attachment; {encoded_filename}'})
                
                # Read markdown content
                markdown_content = fp.read_text(encoding='utf-8', errors='ignore')
                print(f"DEBUG: Read markdown content, length: {len(markdown_content)}")
                
                # Clean anchor links for PDF conversion
                cleaned_content = _clean_anchor_links_for_pdf(markdown_content)
                print(f"DEBUG: Cleaned markdown content for PDF conversion")
                
                # Convert markdown to PDF
                print(f"DEBUG: Starting PDF conversion for {fp}")
                pdf = MarkdownPdf()
                pdf.add_section(Section(cleaned_content, toc=False))
                
                # Save PDF to a BytesIO object
                buffer = BytesIO()
                pdf.save(buffer)
                buffer.seek(0)
                print(f"DEBUG: PDF conversion completed, buffer size: {buffer.getbuffer().nbytes}")
            
            # Return PDF with proper filename encoding
            pdf_filename = f"{stem.name}.pdf"
            encoded_filename = _encode_filename(pdf_filename)
            
            return PlainTextResponse(
                buffer.getvalue(),
                media_type="application/pdf",
                headers={'Content-Disposition': f'attachment; {encoded_filename}'}
            )
            
        except Exception as e:
            # If PDF conversion fails, fallback to markdown text
            print(f"DEBUG: PDF conversion failed for {fp}: {e}")
            text = fp.read_text(encoding='utf-8', errors='ignore')
            filename = f"{stem.name}.md"
            encoded_filename = _encode_filename(filename)
            return PlainTextResponse(text, headers={'Content-Disposition': f'attachment; {encoded_filename}'})
    
    # Fallback: return original text as attachment for non-markdown files
    try:
        text = fp.read_text(encoding='utf-8', errors='ignore')
    except Exception as e:
        raise HTTPException(status_code=404, detail=f'Not found or unreadable: {e}')
    
    # 한글 파일명을 안전하게 인코딩
    filename = f"{stem.name}.txt"
    encoded_filename = _encode_filename(filename)
    
    return PlainTextResponse(text, headers={'Content-Disposition': f'attachment; {encoded_filename}'})


