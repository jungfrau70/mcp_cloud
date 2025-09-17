#!/usr/bin/env python3
"""
제목 앵커(섹션) 자동 수정 도구
- 하단 링크를 섹션으로 작성하여 항상 OPEN 상태로 본문 1레벨에 위치
- 섹션 오픈 상태 파악 및 전체 펼치기
- 찾기 및 이동 기능
- 다른 섹션은 원상태로 되돌리기
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass
from datetime import datetime

@dataclass
class SectionInfo:
    """섹션 정보"""
    title: str
    anchor_id: str
    level: int
    line_number: int
    is_open: bool = False
    content: str = ""

class AdvancedAnchorLinkFixer:
    """고급 앵커 링크 수정 도구"""
    
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.fixed_files = []
        self.fixed_issues = []
    
    def normalize_anchor_id(self, text: str) -> str:
        """VS Code 마크다운 미리보기와 동일한 앵커 ID 생성"""
        # 1. 앞뒤 공백 제거
        text = text.strip()
        
        # 2. 이모지와 특수문자 제거 (VS Code는 이모지를 제거함)
        text = re.sub(r'[^\w\s가-힣]', '', text)
        
        # 3. 공백을 하이픈으로 변환
        text = re.sub(r'\s+', '-', text)
        
        # 4. 연속된 하이픈을 하나로 변환
        text = re.sub(r'-+', '-', text)
        
        # 5. 앞뒤 하이픈 제거
        text = text.strip('-')
        
        # 6. 소문자로 변환
        return text.lower()
    
    def extract_sections(self, content: str) -> List[SectionInfo]:
        """문서에서 섹션 추출"""
        sections = []
        lines = content.split('\n')
        
        for i, line in enumerate(lines, 1):
            # ATX 스타일 헤딩 (# ## ### 등)
            match = re.match(r'^(#{1,6})\s+(.+)$', line.strip())
            if match:
                level = len(match.group(1))
                text = match.group(2).strip()
                anchor_id = self.normalize_anchor_id(text)
                
                # 섹션 오픈 상태 확인
                is_open = self._check_section_open_state(content, i)
                
                sections.append(SectionInfo(
                    title=text,
                    anchor_id=anchor_id,
                    level=level,
                    line_number=i,
                    is_open=is_open
                ))
        
        return sections
    
    def _check_section_open_state(self, content: str, line_number: int) -> bool:
        """섹션의 오픈 상태 확인"""
        lines = content.split('\n')
        
        # 해당 라인 이후의 내용 확인
        for i in range(line_number, min(line_number + 10, len(lines))):
            line = lines[i].strip()
            
            # 다음 헤딩이 나오면 닫힌 상태
            if re.match(r'^#{1,6}\s+', line):
                return False
            
            # 내용이 있으면 오픈 상태
            if line and not line.startswith('#'):
                return True
        
        return False
    
    def find_anchor_links_in_toc(self, content: str) -> List[Dict]:
        """목차에서 앵커 링크 찾기"""
        anchor_links = []
        lines = content.split('\n')
        
        # 목차 섹션 찾기
        in_toc = False
        for i, line in enumerate(lines, 1):
            if '<details>' in line and '목차' in line:
                in_toc = True
                continue
            
            if in_toc and '</details>' in line:
                break
            
            if in_toc:
                # 마크다운 링크 패턴 [text](#anchor)
                matches = re.finditer(r'\[([^\]]+)\]\(#([^)]+)\)', line)
                for match in matches:
                    text = match.group(1)
                    href = match.group(2)
                    
                    anchor_links.append({
                        'text': text,
                        'href': href,
                        'line': i,
                        'original_line': line
                    })
        
        return anchor_links
    
    def create_section_content(self, section_title: str, anchor_id: str) -> str:
        """섹션 콘텐츠 생성 (항상 OPEN 상태)"""
        # 이모지 추출
        emoji_match = re.match(r'^([🎯📚🔧💻📊🚀💰🧪📋✅👥📦🔄🛠️])\s*(.+)', section_title)
        if emoji_match:
            emoji = emoji_match.group(1)
            title_text = emoji_match.group(2)
        else:
            emoji = "📋"
            title_text = section_title
        
        section_content = f"""<details open>
<summary>{emoji} {title_text}</summary>

<!-- {title_text} 내용을 여기에 작성하세요 -->

</details>

"""
        return section_content
    
    def fix_document_anchors(self, file_path: Path) -> bool:
        """단일 문서의 앵커 링크 수정"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 섹션 추출
            sections = self.extract_sections(content)
            if not sections:
                return False
            
            # 목차에서 앵커 링크 찾기
            toc_links = self.find_anchor_links_in_toc(content)
            if not toc_links:
                return False
            
            # 섹션 ID 매핑
            section_map = {section.anchor_id: section for section in sections}
            
            # 수정할 내용 생성
            new_content = content
            modifications = []
            
            for link in toc_links:
                anchor_id = link['href']
                if anchor_id in section_map:
                    section = section_map[anchor_id]
                    
                    # 해당 섹션을 항상 OPEN 상태로 변경
                    section_content = self.create_section_content(section.title, anchor_id)
                    
                    # 기존 섹션 찾기 및 교체
                    lines = new_content.split('\n')
                    section_line = section.line_number - 1
                    
                    # 섹션 시작부터 다음 헤딩까지 찾기
                    end_line = section_line + 1
                    while end_line < len(lines):
                        if re.match(r'^#{1,6}\s+', lines[end_line].strip()):
                            break
                        end_line += 1
                    
                    # 섹션 교체
                    new_lines = lines[:section_line]
                    new_lines.append(f"## {section.title}")
                    new_lines.append("")
                    new_lines.append(section_content)
                    
                    # 기존 섹션 내용이 있으면 유지
                    if end_line > section_line + 1:
                        existing_content = lines[section_line + 1:end_line]
                        # 빈 줄 제거
                        existing_content = [line for line in existing_content if line.strip()]
                        if existing_content:
                            new_lines.extend(existing_content)
                    
                    new_lines.extend(lines[end_line:])
                    new_content = '\n'.join(new_lines)
                    
                    modifications.append({
                        'section': section.title,
                        'anchor_id': anchor_id,
                        'line': section.line_number
                    })
            
            if modifications:
                # 백업 생성
                backup_path = file_path.with_suffix('.md.backup')
                with open(backup_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                # 수정된 내용 저장
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                
                self.fixed_files.append(str(file_path))
                self.fixed_issues.extend(modifications)
                
                print(f"✅ {file_path.name}: {len(modifications)}개 섹션 수정 완료")
                return True
            
            return False
            
        except Exception as e:
            print(f"❌ {file_path.name} 수정 실패: {e}")
            return False
    
    def fix_all_remaining_issues(self):
        """모든 남은 문제 수정"""
        print("🔧 앵커 링크 자동 수정 시작...")
        
        # 문제가 있는 파일들
        problem_files = [
            "mcp_knowledge_base/cloud_basic/textbook/Day1/aws-gcp-account-setup.md",
            "mcp_knowledge_base/cloud_basic/textbook/Day1/practice/aws_basic_practice.md",
            "mcp_knowledge_base/cloud_master/textbook/Day1/docker-hub-setup-guide.md",
            "mcp_knowledge_base/cloud_master/textbook/Day2/troubleshooting-guide.md"
        ]
        
        fixed_count = 0
        for file_path in problem_files:
            if os.path.exists(file_path):
                if self.fix_document_anchors(Path(file_path)):
                    fixed_count += 1
        
        print(f"✅ {fixed_count}개 파일 수정 완료")
        return fixed_count
    
    def create_section_navigation(self, sections: List[SectionInfo]) -> str:
        """섹션 네비게이션 생성"""
        nav_items = []
        for section in sections:
            emoji_match = re.match(r'^([🎯📚🔧💻📊🚀💰🧪📋✅👥📦🔄🛠️])\s*(.+)', section.title)
            if emoji_match:
                emoji = emoji_match.group(1)
                title_text = emoji_match.group(2)
            else:
                emoji = "📋"
                title_text = section.title
            
            nav_items.append(f"- [{emoji} {title_text}](#{section.anchor_id})")
        
        return '\n'.join(nav_items)
    
    def generate_fix_report(self) -> Dict:
        """수정 보고서 생성"""
        return {
            "timestamp": datetime.now().isoformat(),
            "fixed_files": self.fixed_files,
            "fixed_issues": self.fixed_issues,
            "total_fixed_files": len(self.fixed_files),
            "total_fixed_issues": len(self.fixed_issues),
            "summary": {
                "section_creation_rule": "하단 링크를 섹션으로 작성하여 항상 OPEN 상태로 본문 1레벨에 위치",
                "section_open_state": "모든 섹션이 항상 펼쳐진 상태로 설정",
                "navigation_rule": "섹션 찾기 및 이동 기능 제공",
                "restore_rule": "다른 섹션은 원상태로 되돌리기"
            }
        }
    
    def save_fix_report(self, filename: str = "anchor_fix_report.json"):
        """수정 보고서 저장"""
        report = self.generate_fix_report()
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        print(f"📄 수정 보고서 저장: {filename}")

def main():
    """메인 실행 함수"""
    print("🔧 제목 앵커(섹션) 자동 수정 도구")
    print("=" * 50)
    print("📋 수정 규칙:")
    print("  - 하단 링크를 섹션으로 작성")
    print("  - 항상 OPEN 상태로 본문 1레벨에 위치")
    print("  - 섹션 오픈 상태 파악 및 전체 펼치기")
    print("  - 찾기 및 이동 기능 제공")
    print("  - 다른 섹션은 원상태로 되돌리기")
    print("=" * 50)
    
    # 수정 도구 초기화
    fixer = AdvancedAnchorLinkFixer()
    
    # 모든 문제 수정
    fixed_count = fixer.fix_all_remaining_issues()
    
    # 수정 보고서 생성
    fixer.save_fix_report()
    
    print(f"\n✅ 수정 완료: {fixed_count}개 파일")
    print("📄 수정된 파일들:")
    for file_path in fixer.fixed_files:
        print(f"  - {file_path}")
    
    print("\n💡 다음 단계:")
    print("  1. 수정된 파일들 확인")
    print("  2. 재검증 실행")
    print("  3. 필요시 추가 수정")

if __name__ == "__main__":
    main()