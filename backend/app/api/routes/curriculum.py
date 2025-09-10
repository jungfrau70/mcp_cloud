# backend/app/api/routes/slides.py
from fastapi import APIRouter, Depends, HTTPException
from typing import Any, Dict, List
from pathlib import Path
from security import get_api_key
from fastapi.responses import PlainTextResponse, FileResponse
import urllib.parse

router = APIRouter(prefix="/api/v1/curriculum", tags=["Curriculum"])

KB_ROOT = Path('/mcp_knowledge_base').resolve()
SELECTION_FILE = KB_ROOT / '.slides_selection.json'
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


def _build_tree() -> Dict[str, Any]:
    # Simple merge of selected dirs under KB_ROOT
    data: Dict[str, Any] = {}
    selected = get_selection().get('selected_dirs', [])

    def build(d: Path) -> Dict[str, Any]:
        tree: Dict[str, Any] = {}
        files = []
        for child in sorted(d.iterdir()):
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
            data[rel.split('/')[-1]] = build(p)
    return data

@router.get('/tree')
def curriculum_tree():
    return _build_tree()


@router.get('/selection')
def get_selection():
    if not SELECTION_FILE.exists():
        return {"selected_dirs": []}
    try:
        import json
        return {"selected_dirs": json.loads(SELECTION_FILE.read_text())}
    except Exception:
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

@router.get('')
def get_slide(textbook_path: str = None, curriculum_path: str = None):
    """Return slide content (text) for curriculum items.

    Accepts both 'curriculum_path' (new) and 'textbook_path' (legacy) for compatibility.
    """
    raw = curriculum_path if curriculum_path is not None else textbook_path
    if not raw:
        raise HTTPException(status_code=400, detail='Missing curriculum_path')
    # Accept paths with or without extension; default to .md
    rel = raw.strip().lstrip('/\\')
    # Consider common text and document extensions to avoid forcing .md
    if not any(rel.endswith(ext) for ext in ('.md', '.markdown', '.txt', '.log', '.json', '.yaml', '.yml', '.csv', '.sh', '.pdf', '.ppt', '.pptx')):
        rel = f"{rel}.md"
    fp = (KB_ROOT / rel).resolve()
    if not str(fp).startswith(str(KB_ROOT)):
        raise HTTPException(status_code=400, detail='Invalid path')
    if not fp.exists():
        raise HTTPException(status_code=404, detail='Not found')
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
    fp = _safe_path(path)
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
            # Import markdown_pdf if available
            try:
                from markdown_pdf import MarkdownPdf, Section
                from io import BytesIO
            except ImportError:
                # Fallback to plain text if markdown_pdf not available
                text = fp.read_text(encoding='utf-8', errors='ignore')
                filename = f"{stem.name}.md"
                encoded_filename = _encode_filename(filename)
                return PlainTextResponse(text, headers={'Content-Disposition': f'attachment; {encoded_filename}'})
            
            # Read markdown content
            markdown_content = fp.read_text(encoding='utf-8', errors='ignore')
            
            # Convert markdown to PDF
            pdf = MarkdownPdf()
            pdf.add_section(Section(markdown_content, toc=False))
            
            # Save PDF to a BytesIO object
            buffer = BytesIO()
            pdf.save(buffer)
            buffer.seek(0)
            
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


