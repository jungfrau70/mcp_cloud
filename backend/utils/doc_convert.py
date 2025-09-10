from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
from pathlib import Path

from fastapi import HTTPException


def _which(cmd: str) -> str | None:
    """Return full path of executable if found in PATH, else None."""
    try:
        return shutil.which(cmd)
    except Exception:
        return None


def _libreoffice_cmd() -> list[str] | None:
    """Resolve LibreOffice (soffice) command for headless conversion."""
    # Allow override via env var
    explicit = os.environ.get("LIBREOFFICE_PATH") or os.environ.get("SOFFICE_PATH")
    if explicit:
        return [explicit]
    # Common commands
    for name in ("soffice", "libreoffice"):
        path = _which(name)
        if path:
            return [path]
    return None


def _ensure_cache_dir(root: Path) -> Path:
    cache = (root / ".cache_converted").resolve()
    cache.mkdir(parents=True, exist_ok=True)
    return cache


def convert_pptx_to_pdf(src: Path, kb_root: Path) -> Path:
    """Convert a .ppt/.pptx file to PDF using LibreOffice headless.

    - Caches result under <kb_root>/.cache_converted/<relative>.pdf
    - Re-converts when source mtime is newer than cached output
    - Raises HTTPException 501 if converter is unavailable
    - Raises HTTPException 500 on conversion failure
    """
    if not src.exists() or not src.is_file():
        raise HTTPException(status_code=404, detail="Source file not found")

    ext = src.suffix.lower()
    if ext not in (".ppt", ".pptx"):
        raise HTTPException(status_code=400, detail="Not a PowerPoint file")

    # Ensure src is within kb_root for safety
    kb_root = kb_root.resolve()
    src_resolved = src.resolve()
    if not str(src_resolved).startswith(str(kb_root)):
        raise HTTPException(status_code=400, detail="Invalid path")

    # Determine cache target path mirroring relative structure
    rel = src_resolved.relative_to(kb_root)
    cache_root = _ensure_cache_dir(kb_root)
    out_pdf = (cache_root / rel).with_suffix(".pdf")
    out_pdf.parent.mkdir(parents=True, exist_ok=True)

    # Reuse cached when fresh
    if out_pdf.exists() and src_resolved.stat().st_mtime <= out_pdf.stat().st_mtime:
        return out_pdf

    cmd_base = _libreoffice_cmd()
    if not cmd_base:
        # Converter not installed
        raise HTTPException(status_code=501, detail="LibreOffice (soffice) is not available on server")

    # Perform conversion in a temp dir to avoid partial outputs in cache on failure
    with tempfile.TemporaryDirectory() as tmpdir:
        tmpdir_path = Path(tmpdir)
        # Copy to temp dir to avoid LO creating side files next to original
        tmp_src = tmpdir_path / src_resolved.name
        try:
            shutil.copy2(src_resolved, tmp_src)
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to prepare source: {e}")

        cmd = (
            cmd_base
            + [
                "--headless",
                "--nologo",
                "--nofirststartwizard",
                "--convert-to",
                "pdf",
                "--outdir",
                str(tmpdir_path),
                str(tmp_src),
            ]
        )

        try:
            proc = subprocess.run(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                check=False,
                text=True,
                timeout=180,
            )
        except subprocess.TimeoutExpired as e:
            raise HTTPException(status_code=500, detail="Conversion timed out")
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Conversion failed to start: {e}")

        if proc.returncode != 0:
            raise HTTPException(status_code=500, detail=f"Conversion failed: {proc.stdout.strip()}")

        # LibreOffice names output with .pdf next to the file basename
        produced = tmpdir_path / (tmp_src.stem + ".pdf")
        if not produced.exists():
            # Some LO variants print success but do not produce file when fonts/filters missing
            raise HTTPException(status_code=500, detail="Conversion did not produce output PDF")

        # Move atomically into cache path
        try:
            shutil.move(str(produced), str(out_pdf))
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to store converted file: {e}")

    return out_pdf


