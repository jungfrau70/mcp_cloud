#!/usr/bin/env python3
"""
누락된 README.md 파일 자동 생성 도구
디렉토리 링크가 가리키는 디렉토리에 README.md 파일 생성
"""

import os
import re
from pathlib import Path
from typing import List, Dict

class MissingReadmeCreator:
    def __init__(self, knowledge_base_root: str = "mcp_knowledge_base"):
        self.knowledge_base_root = Path(knowledge_base_root)
        self.created_count = 0
        
    def find_directory_links(self) -> List[Dict]:
        """디렉토리 링크 찾기"""
        directory_links = []
        
        for md_file in self.knowledge_base_root.rglob("*.md"):
            try:
                with open(md_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # 디렉토리 링크 패턴 찾기 (슬래시로 끝나는 링크)
                pattern = r'\[([^\]]+)\]\(([^)]+/)\)'
                matches = re.finditer(pattern, content)
                
                for match in matches:
                    link_text = match.group(1)
                    link_url = match.group(2)
                    
                    # 외부 링크가 아닌 경우만 처리
                    if not link_url.startswith(('http://', 'https://', 'ftp://', 'mailto:')):
                        directory_links.append({
                            "source_file": str(md_file),
                            "link_text": link_text,
                            "link_url": link_url,
                            "target_path": self._resolve_path(md_file, link_url)
                        })
            
            except Exception as e:
                print(f"❌ 파일 읽기 오류: {md_file} - {str(e)}")
        
        return directory_links
    
    def _resolve_path(self, source_file: Path, link_url: str) -> Path:
        """링크 URL을 실제 경로로 변환"""
        if link_url.startswith('/'):
            # 절대 경로
            return self.knowledge_base_root / link_url[1:]
        else:
            # 상대 경로
            return source_file.parent / link_url
    
    def create_readme_for_directory(self, directory_path: Path, link_text: str) -> bool:
        """디렉토리에 README.md 파일 생성"""
        try:
            if not directory_path.exists() or not directory_path.is_dir():
                print(f"⚠️  디렉토리가 존재하지 않음: {directory_path}")
                return False
            
            readme_path = directory_path / "README.md"
            
            if readme_path.exists():
                print(f"⏭️  README.md 이미 존재: {readme_path}")
                return False
            
            # 디렉토리 내용 분석
            files = []
            directories = []
            
            for item in sorted(directory_path.iterdir()):
                if item.is_file():
                    files.append(item.name)
                elif item.is_dir():
                    directories.append(item.name)
            
            # README.md 내용 생성
            content = self._generate_readme_content(
                directory_path, 
                link_text, 
                files, 
                directories
            )
            
            # 파일 생성
            with open(readme_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"✅ README.md 생성 완료: {readme_path}")
            self.created_count += 1
            return True
            
        except Exception as e:
            print(f"❌ README.md 생성 오류: {directory_path} - {str(e)}")
            return False
    
    def _generate_readme_content(self, directory_path: Path, link_text: str, files: List[str], directories: List[str]) -> str:
        """README.md 내용 생성"""
        # 상위 디렉토리 경로 계산
        relative_path = directory_path.relative_to(self.knowledge_base_root)
        parent_path = str(relative_path.parent) if relative_path.parent != Path('.') else ""
        
        # 파일 목록 생성
        file_list = ""
        if files:
            file_list += "### 📄 파일 목록\n"
            for file in files:
                if file.endswith('.md'):
                    file_list += f"- [{file}]({file})\n"
                else:
                    file_list += f"- {file}\n"
            file_list += "\n"
        
        # 디렉토리 목록 생성
        dir_list = ""
        if directories:
            dir_list += "### 📁 하위 디렉토리\n"
            for dir_name in directories:
                dir_list += f"- [{dir_name}/]({dir_name}/)\n"
            dir_list += "\n"
        
        # 네비게이션 링크 생성
        nav_links = ""
        if parent_path:
            nav_links += f"- [← 상위 디렉토리](../README.md)\n"
        nav_links += "- [🏠 홈으로 돌아가기](/index.md)\n"
        
        content = f"""# {link_text}

## 📁 디렉토리 개요
이 디렉토리는 **{link_text}** 관련 파일들을 포함합니다.

{file_list}{dir_list}## 🔗 관련 링크
{nav_links}

---
*이 파일은 자동으로 생성되었습니다.*
"""
        return content
    
    def process_all_directory_links(self) -> None:
        """모든 디렉토리 링크 처리"""
        print("🔍 디렉토리 링크 분석 중...")
        
        directory_links = self.find_directory_links()
        
        print(f"📊 발견된 디렉토리 링크: {len(directory_links)}개")
        
        for link in directory_links:
            print(f"\n📄 {link['source_file']}")
            print(f"   링크: [{link['link_text']}]({link['link_url']})")
            print(f"   대상: {link['target_path']}")
            
            self.create_readme_for_directory(
                link['target_path'], 
                link['link_text']
            )
        
        print(f"\n📊 처리 결과:")
        print(f"   - 처리된 디렉토리 링크: {len(directory_links)}개")
        print(f"   - 생성된 README.md: {self.created_count}개")

def main():
    """메인 함수"""
    print("🚀 누락된 README.md 파일 생성 도구")
    print("=" * 50)
    
    creator = MissingReadmeCreator()
    creator.process_all_directory_links()
    
    print("\n✅ 처리 완료!")

if __name__ == "__main__":
    main()
