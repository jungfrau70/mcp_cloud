#!/usr/bin/env python3
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(__file__), '..')
TARGET = os.path.abspath(os.path.join(ROOT, '..'))

md_pattern = re.compile(r"\]\(([^)]+\.md)\)")

def find_md_files(root):
    for base, _, files in os.walk(root):
        for f in files:
            if f.endswith('.md'):
                yield os.path.join(base, f)

def validate():
    errors = []
    for path in find_md_files(TARGET):
        rel_dir = os.path.dirname(path)
        try:
            with open(path, 'r', encoding='utf-8') as fh:
                content = fh.read()
        except Exception:
            continue
        for m in md_pattern.finditer(content):
            link = m.group(1)
            link_path = link if os.path.isabs(link) else os.path.normpath(os.path.join(rel_dir, link))
            if not os.path.exists(link_path):
                errors.append(f"Broken link in {os.path.relpath(path, TARGET)} -> {link}")
    if errors:
        print("\n".join(errors))
        return 1
    print("All markdown links OK")
    return 0

if __name__ == '__main__':
    sys.exit(validate())

