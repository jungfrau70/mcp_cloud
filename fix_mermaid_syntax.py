#!/usr/bin/env python3
"""
Mermaid 10.9.4 문법 자동 수정 도구
mcp_knowledge_base 디렉토리 내 모든 Mermaid 다이어그램을 최신 문법으로 업그레이드
"""

import re
import os
from pathlib import Path

class MermaidFixer:
    def __init__(self):
        self.fixes_applied = 0
        self.files_modified = 0
        self.total_blocks_fixed = 0
    
    def fix_mermaid_blocks(self, content: str) -> tuple[str, int]:
        """Mermaid 블록 자동 수정"""
        original_content = content
        blocks_fixed = 0
        
        # 1. graph -> flowchart 변환
        content = re.sub(r'^graph\s+', 'flowchart ', content, flags=re.MULTILINE)
        if content != original_content:
            blocks_fixed += content.count('flowchart ') - original_content.count('flowchart ')
        
        # 2. 화살표 문법 수정 (굵은 화살표로 가독성 향상)
        # -> 를 ==> 로 (단, 이미 ==> 인 경우는 제외)
        content = re.sub(r'->(?!>)', '==>', content)
        # <- 를 <== 로 (단, 이미 <== 인 경우는 제외)
        content = re.sub(r'<-(?!<)', '<==', content)
        # --> 를 ==> 로 (단, 이미 ==> 인 경우는 제외)
        content = re.sub(r'-->(?!>)', '==>', content)
        # <-- 를 <== 로 (단, 이미 <== 인 경우는 제외)
        content = re.sub(r'<--(?!<)', '<==', content)
        
        # 3. 노드 문법 수정
        # (text) 를 [text] 로 (단, 이미 [text] 인 경우는 제외)
        content = re.sub(r'\(([^)]+)\)(?!\])', r'[\1]', content)
        # ((text)) 를 [(text)] 로
        content = re.sub(r'\(\(([^)]+)\)\)', r'[(\1)]', content)
        
        # 4. 한글 텍스트 따옴표 처리 (이미 따옴표가 있는 경우는 제외)
        # 한글이 포함된 노드 텍스트에 따옴표 추가
        korean_pattern = r'\[([^\[\]]*[가-힣][^\[\]]*)\]'
        def add_quotes_to_korean(match):
            text = match.group(1)
            if not (text.startswith('"') and text.endswith('"')):
                return f'["{text}"]'
            return match.group(0)
        
        content = re.sub(korean_pattern, add_quotes_to_korean, content)
        
        # 5. 기본 스타일링 자동 추가
        content = self._add_default_styling(content)
        
        # 6. 시퀀스 다이어그램 화살표 수정
        # sequenceDiagram 내에서 화살표 수정
        def fix_sequence_arrows(match):
            diagram_content = match.group(1)
            # -> 를 ->> 로
            diagram_content = re.sub(r'->(?!>)', '->>', diagram_content)
            # --> 를 -->> 로
            diagram_content = re.sub(r'-->(?!>)', '-->>', diagram_content)
            return f'sequenceDiagram\n{diagram_content}'
        
        content = re.sub(r'sequenceDiagram\n(.*?)(?=\n```|\Z)', fix_sequence_arrows, content, flags=re.DOTALL)
        
        return content, blocks_fixed
    
    def _add_default_styling(self, content: str) -> str:
        """기본 스타일링 자동 추가"""
        # 이미 스타일이 있는지 확인
        if 'style ' in content:
            return content
        
        # flowchart 다이어그램에만 스타일 추가
        if not content.strip().startswith('flowchart'):
            return content
        
        # 노드 ID 추출
        node_ids = re.findall(r'(\w+)\[', content)
        if not node_ids:
            return content
        
        # 기본 스타일 추가
        styles = []
        for i, node_id in enumerate(node_ids):
            if i == 0:  # 첫 번째 노드 (시작점)
                styles.append(f'    style {node_id} fill:#1976d2,color:#ffffff')
            elif i == len(node_ids) - 1:  # 마지막 노드 (종료점)
                styles.append(f'    style {node_id} fill:#d32f2f,color:#ffffff')
            elif '{' in content and node_id in content:  # 결정점
                styles.append(f'    style {node_id} fill:#f57c00,color:#ffffff')
            else:  # 일반 프로세스
                styles.append(f'    style {node_id} fill:#388e3c,color:#ffffff')
        
        # 스타일을 다이어그램 끝에 추가
        if styles:
            content += '\n\n' + '\n'.join(styles)
        
        return content
    
    def fix_file(self, file_path: Path) -> bool:
        """파일의 Mermaid 블록 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()
            
            fixed_content, blocks_fixed = self.fix_mermaid_blocks(original_content)
            
            if original_content != fixed_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(fixed_content)
                
                self.files_modified += 1
                self.total_blocks_fixed += blocks_fixed
                print(f"✅ 수정됨: {file_path} ({blocks_fixed}개 블록 수정)")
                return True
            else:
                print(f"⏭️ 변경사항 없음: {file_path}")
                return False
        
        except Exception as e:
            print(f"❌ 오류: {file_path} - {str(e)}")
            return False
    
    def fix_all_files(self, knowledge_base_path: Path):
        """모든 마크다운 파일 수정"""
        md_files = list(knowledge_base_path.rglob("*.md"))
        
        # node_modules 디렉토리 제외
        md_files = [f for f in md_files if "node_modules" not in str(f)]
        
        print(f"🔧 {len(md_files)}개 마크다운 파일 검사 중...")
        
        for md_file in md_files:
            self.fix_file(md_file)
        
        print(f"\n📊 수정 완료:")
        print(f"  - 수정된 파일: {self.files_modified}개")
        print(f"  - 수정된 Mermaid 블록: {self.total_blocks_fixed}개")

def main():
    """메인 실행 함수"""
    fixer = MermaidFixer()
    knowledge_base = Path("mcp_knowledge_base")
    
    if not knowledge_base.exists():
        print("❌ mcp_knowledge_base 디렉토리를 찾을 수 없습니다.")
        return
    
    print("🚀 Mermaid 10.9.4 문법 자동 수정 시작")
    print("=" * 50)
    
    fixer.fix_all_files(knowledge_base)
    
    print("=" * 50)
    print("✅ 모든 수정 작업이 완료되었습니다!")

if __name__ == "__main__":
    main()
