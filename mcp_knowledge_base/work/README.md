
---
# 커리큘럼 작성
## 요청1) 과정 제공 후 커리큘럼 작성 요청 (to: Gemini)
   결과: 과정명.md, 과정상세.md

---
# 교안 및 실습코드 작성

## 요청1) 유첨된 내용(과정명.md, 과정상세.md)을 참조하여 1일차 교안 및 실습 코드 설계하는데 A4 용지로 20장 이상 작성해 줘 (to: ChatGPT 심층 리서치)
   산출물: 과정별_일차별_교안.docx

---
# textbook 및 실습코드 작성

## 요청1) 전체 구조는 mcp_knowledge_base\cloud_master 를 참조하여, cloud_basic 과 cloud_container 과정 재구성.

## 요청2) mcp_knowledge_base 디렉토리 하위에 구성된, cloud_basic, cloud_master, cloud_container 과정 확인 후, 각 과정이 맥락에 맞게 구성되었는지 실습 코드 포함하여 점검 및 개선 방안 제시  (단, 현재 과정 유지 조건, 질문 필수)

  질문에 대한 답변)
    1. 커리큘럼
    2. 과정간 및 과정내 맥락 (basic->master->container)
    3. 모두
    4. 과정 간 연계성과 실무 적용성
    5. 커리큘럼외 모두 수정 가능

## 요청3) 각 과정이 마크다운 문서로 작성된 textbook 을 중심으로 진행될때, 섹션과 링크 기능을 활용하여 맥락을 쉽게 파악하고 사용자 친화적으로 UI 가 구성될 수 있도록 고도화 해 줘. 

* 맥락: 과정간: mcp_knowledge_base\curriculum.md -> 과정별: 과정명, 과정상세 -> 과정내: textbook간, 코드간
* 참고) 섹션사용 textbook : mcp_knowledge_base\cloud_master\textbook\Day1\cloud-deployment-guide.md


## 요청4) 각 과정의 모든 markdown 문서들이 섹션과 링크 기능을 활용하여 맥락을 쉽게 파악하고 사용자 친화적으로 UI 가 구성될 수 있도록 고도화 되어 있는지 점검해 줘


---
# 실습 코드 작성

요청1) 스크립트 수정 요청: 스크립트가 중단되어도 다시 시작할 때 기존 리소스를 재사용하도록 수정. (각 스크립트에 리소스 존재 확인 및 재사용 로직을 추가)

google cloud 에 프로젝트, 네트워크 및 VM 생성 및 설정 스크립트로, 스크립트가 중단되어도 다시 시작할 때 기존 리소스를 재사용하도록 수정. (각 스크립트에 리소스 존재 확인 및 재사용 로직을 추가)
