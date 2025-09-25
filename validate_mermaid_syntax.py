#!/usr/bin/env python3
"""
Mermaid 10.9.4 문법 검증 도구
실제 Mermaid 다이어그램이 올바르게 렌더링되는지 확인
"""

import re
import os
from pathlib import Path

class MermaidValidator:
    def __init__(self):
        self.errors = []
        self.warnings = []
        self.total_blocks = 0
        self.valid_blocks = 0
    
    def validate_mermaid_block(self, content: str, line_number: int, file_path: str) -> bool:
        """Mermaid 블록 문법 검증"""
        self.total_blocks += 1
        is_valid = True
        
        # Mermaid 내용 추출
        mermaid_content = content.replace('```mermaid', '').replace('```', '').strip()
        
        # 1. 빈 블록 확인
        if not mermaid_content:
            self.errors.append(f"{file_path}:{line_number} - 빈 Mermaid 블록")
            return False
        
        # 2. 다이어그램 타입 확인
        valid_types = ['flowchart', 'sequenceDiagram', 'classDiagram', 'stateDiagram-v2', 'erDiagram', 'gantt', 'pie', 'gitgraph']
        first_line = mermaid_content.split('\n')[0].strip()
        
        if not any(first_line.startswith(t) for t in valid_types):
            self.errors.append(f"{file_path}:{line_number} - 잘못된 다이어그램 타입: {first_line}")
            is_valid = False
        
        # 3. flowchart 특화 검증
        if first_line.startswith('flowchart'):
            is_valid &= self._validate_flowchart(mermaid_content, line_number, file_path)
        
        # 4. sequenceDiagram 특화 검증
        if first_line.startswith('sequenceDiagram'):
            is_valid &= self._validate_sequence(mermaid_content, line_number, file_path)
        
        if is_valid:
            self.valid_blocks += 1
        
        return is_valid
    
    def _validate_flowchart(self, content: str, line_number: int, file_path: str) -> bool:
        """Flowchart 문법 검증"""
        is_valid = True
        
        # 잘못된 노드 타입 확인
        invalid_nodes = ['(text)', '((text))', '>text]']
        for invalid_node in invalid_nodes:
            if invalid_node in content:
                self.errors.append(f"{file_path}:{line_number} - 잘못된 노드 타입: {invalid_node}")
                is_valid = False
        
        # 잘못된 화살표 확인 (굵은 화살표 표준)
        # ->, -->, <-, <-- 는 deprecated, ==> 사용해야 함
        invalid_arrows = ['->', '<-', '-->', '<--']
        for invalid_arrow in invalid_arrows:
            # 단, ==>가 아닌 경우에만 오류로 처리
            if invalid_arrow in content:
                # ==>가 포함된 경우는 제외
                if invalid_arrow == '-->' and '==>' in content:
                    continue
                if invalid_arrow == '->' and '==>' in content:
                    continue
                if invalid_arrow == '<--' and '<==' in content:
                    continue
                if invalid_arrow == '<-' and '<==' in content:
                    continue
                
                self.errors.append(f"{file_path}:{line_number} - 잘못된 화살표: {invalid_arrow}")
                is_valid = False
        
        return is_valid
    
    def _validate_sequence(self, content: str, line_number: int, file_path: str) -> bool:
        """Sequence diagram 문법 검증"""
        is_valid = True
        
        # 잘못된 화살표 확인 (굵은 화살표 표준)
        # ->, -->, <-, <-- 는 deprecated, ==> 사용해야 함
        invalid_arrows = ['->', '<-', '-->', '<--']
        for invalid_arrow in invalid_arrows:
            # 단, ==>가 아닌 경우에만 오류로 처리
            if invalid_arrow in content:
                # ==>가 포함된 경우는 제외
                if invalid_arrow == '-->' and '==>' in content:
                    continue
                if invalid_arrow == '->' and '==>' in content:
                    continue
                if invalid_arrow == '<--' and '<==' in content:
                    continue
                if invalid_arrow == '<-' and '<==' in content:
                    continue
                
                self.errors.append(f"{file_path}:{line_number} - 잘못된 화살표: {invalid_arrow}")
                is_valid = False
        
        return is_valid
    
    def validate_file(self, file_path: Path) -> dict:
        """파일의 Mermaid 블록 검증"""
        result = {
            'file': str(file_path),
            'is_valid': True,
            'errors': [],
            'warnings': []
        }
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Mermaid 블록 찾기
            mermaid_blocks = re.finditer(r'```mermaid\n(.*?)\n```', content, re.DOTALL)
            
            for match in mermaid_blocks:
                block_content = match.group(0)
                line_number = content[:match.start()].count('\n') + 1
                
                if not self.validate_mermaid_block(block_content, line_number, str(file_path)):
                    result['is_valid'] = False
                    result['errors'].extend(self.errors[-1:])  # 마지막 에러만 추가
        
        except Exception as e:
            result['is_valid'] = False
            result['errors'].append(f"파일 읽기 오류: {str(e)}")
        
        return result
    
    def validate_all_files(self, knowledge_base_path: Path):
        """모든 마크다운 파일 검증"""
        md_files = list(knowledge_base_path.rglob("*.md"))
        
        # node_modules 디렉토리 제외
        md_files = [f for f in md_files if "node_modules" not in str(f)]
        
        print(f"🔍 {len(md_files)}개 마크다운 파일 검증 중...")
        
        invalid_files = []
        
        for md_file in md_files:
            result = self.validate_file(md_file)
            if not result['is_valid']:
                invalid_files.append(result)
                print(f"❌ {result['file']}")
                for error in result['errors']:
                    print(f"  - {error}")
            else:
                print(f"✅ {result['file']}")
        
        print(f"\n📊 검증 결과:")
        print(f"  - 총 Mermaid 블록: {self.total_blocks}개")
        print(f"  - 유효한 블록: {self.valid_blocks}개")
        print(f"  - 오류가 있는 파일: {len(invalid_files)}개")
        
        if invalid_files:
            print(f"\n❌ 오류가 있는 파일들:")
            for file_result in invalid_files:
                print(f"  - {file_result['file']}")
                for error in file_result['errors']:
                    print(f"    {error}")
        else:
            print(f"\n✅ 모든 Mermaid 다이어그램이 올바른 문법을 사용하고 있습니다!")

def main():
    """메인 실행 함수"""
    validator = MermaidValidator()
    knowledge_base = Path("mcp_knowledge_base")
    
    if not knowledge_base.exists():
        print("❌ mcp_knowledge_base 디렉토리를 찾을 수 없습니다.")
        return
    
    print("🔍 Mermaid 10.9.4 문법 검증 시작")
    print("=" * 50)
    
    validator.validate_all_files(knowledge_base)
    
    print("=" * 50)
    print("✅ 검증 완료!")

if __name__ == "__main__":
    main()
