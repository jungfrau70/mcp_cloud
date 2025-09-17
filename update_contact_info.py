#!/usr/bin/env python3
"""
연락처 정보 일괄 변경 도구
"""

import os
import re
from pathlib import Path
from typing import List, Dict

class ContactInfoUpdater:
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.new_contact_info = """### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https://github.com/jungfrau70/aws_gcp.git)"""
        
        self.updated_files = []
        
    def run_update(self):
        """연락처 정보 일괄 변경 실행"""
        print("📧 연락처 정보 일괄 변경 시작")
        
        # 1. 모든 마크다운 파일 찾기
        md_files = list(self.knowledge_base_path.rglob('*.md'))
        
        print(f"  📄 발견된 마크다운 파일: {len(md_files)}개")
        
        # 2. 각 파일에서 연락처 정보 업데이트
        for md_file in md_files:
            self.update_contact_in_file(md_file)
        
        # 3. 보고서 생성
        self.generate_update_report()
        
        print(f"\n🎉 연락처 정보 변경 완료! ({len(self.updated_files)}개 파일 수정)")
    
    def update_contact_in_file(self, file_path: Path):
        """파일에서 연락처 정보 업데이트"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 기존 연락처 정보 패턴들 찾기
            contact_patterns = [
                r'### 📧 연락처.*?(?=\n###|\n##|\Z)',
                r'## 📧 연락처.*?(?=\n##|\Z)',
                r'### 연락처.*?(?=\n###|\n##|\Z)',
                r'## 연락처.*?(?=\n##|\Z)',
                r'📧.*?연락처.*?(?=\n###|\n##|\Z)',
                r'이메일.*?github.*?(?=\n###|\n##|\Z)',
                r'문의.*?이메일.*?(?=\n###|\n##|\Z)'
            ]
            
            original_content = content
            updated = False
            
            # 기존 연락처 정보가 있는지 확인하고 교체
            for pattern in contact_patterns:
                if re.search(pattern, content, re.DOTALL | re.IGNORECASE):
                    content = re.sub(pattern, self.new_contact_info, content, flags=re.DOTALL | re.IGNORECASE)
                    updated = True
                    break
            
            # 연락처 정보가 없으면 파일 끝에 추가
            if not updated and not re.search(r'연락처|contact|이메일.*@|github', content, re.IGNORECASE):
                if not content.endswith('\n'):
                    content += '\n'
                content += f"\n{self.new_contact_info}\n"
                updated = True
            
            # 파일이 변경되었으면 저장
            if updated and content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                self.updated_files.append({
                    'file': str(file_path),
                    'action': '연락처 정보 업데이트'
                })
                
                print(f"  ✅ 업데이트: {file_path.relative_to(self.knowledge_base_path)}")
        
        except Exception as e:
            print(f"  ❌ 오류: {file_path} - {str(e)}")
    
    def generate_update_report(self):
        """업데이트 보고서 생성"""
        report = f"""# 연락처 정보 일괄 변경 보고서

## 📧 변경된 연락처 정보

```
### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https://github.com/jungfrau70/aws_gcp.git)
```

## 📊 변경 통계

- **총 수정된 파일 수**: {len(self.updated_files)}개
- **변경 유형**: 연락처 정보 일괄 업데이트

## 📋 상세 변경 내역

"""
        
        for update in self.updated_files:
            report += f"- **{update['file']}**: {update['action']}\n"
        
        report += f"""
## 🎯 변경 내용

### 이전 연락처 정보
- 기존의 다양한 연락처 정보 형식들이 통일되지 않음
- 일부 파일에는 연락처 정보가 누락됨

### 변경 후 연락처 정보
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: https://github.com/jungfrau70/aws_gcp.git
- 모든 파일에 일관된 형식으로 통일

## ✅ 완료 사항

1. **기존 연락처 정보 교체**: 모든 파일의 기존 연락처 정보를 새로운 정보로 교체
2. **누락된 연락처 정보 추가**: 연락처 정보가 없던 파일에 새로운 연락처 정보 추가
3. **일관된 형식 적용**: 모든 파일에 동일한 형식의 연락처 정보 적용

## 🎉 결론

**총 {len(self.updated_files)}개의 파일에서 연락처 정보가 성공적으로 업데이트**되었습니다.

이제 모든 교육 자료에서 일관된 연락처 정보를 확인할 수 있으며, 
학습자들이 문의사항이 있을 때 쉽게 연락할 수 있습니다.

**변경된 연락처 정보:**
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: https://github.com/jungfrau70/aws_gcp.git
"""
        
        with open("contact_info_update_report.md", "w", encoding="utf-8") as f:
            f.write(report)
        
        print(f"\n📋 업데이트 보고서 생성: contact_info_update_report.md")

def main():
    """메인 함수"""
    updater = ContactInfoUpdater()
    updater.run_update()

if __name__ == "__main__":
    main()
