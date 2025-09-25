## 🎯 학습 목표

### 핵심 학습 목표
- ** 기초** 클라우드 서비스 이해 및 활용
- ** 실무** 실제 프로젝트 적용 능력 향상

### 실습 후 달성할 수 있는 능력
- ✅ 클라우드 서비스 기본 개념 이해
- ✅ 실제 환경에서 서비스 배포 및 관리
- ✅ 문제 해결 및 최적화 능력

### 예상 소요 시간
- **기초 학습**: 90-120분
- **실습 진행**: 60-90분
- **전체 과정**: 3-4시간

---
# 커리큘럼 작성
## 요청1) 과정 제공 후 커리큘럼 작성 요청 [to: Gemini]
   결과: 과정명.md, 과정상세.md

---
# 교안 및 실습코드 작성

## 요청1) 유첨된 내용["과정명.md, 과정상세.md"]을 참조하여 1일차 교안 및 실습 코드 설계하는데 A4 용지로 20장 이상 작성해 줘 ["to: ChatGPT 심층 리서치"]
   산출물: 과정별_일차별_교안.docx

---
# textbook 및 실습코드 작성

## 요청1) 전체 구조는 mcp_knowledge_base/cloud_master 를 참조하여, cloud_basic 과 cloud_container 과정 재구성.

## 요청2) mcp_knowledge_base 디렉토리 하위에 구성된, cloud_basic, cloud_master, cloud_container 과정 확인 후, 각 과정이 맥락에 맞게 구성되었는지 실습 코드 포함하여 점검 및 개선 방안 제시  ["단, 현재 과정 유지 조건, 질문 필수"]

  질문에 대한 답변)
    1. 커리큘럼
    2. 과정간 및 과정내 맥락 [basic->>master->>container]
    3. 모두
    4. 과정 간 연계성과 실무 적용성
    5. 커리큘럼외 모두 수정 가능

## 요청3) 각 과정이 마크다운 문서로 작성된 textbook 을 중심으로 진행될때, 섹션과 링크 기능을 활용하여 맥락을 쉽게 파악하고 사용자 친화적으로 UI 가 구성될 수 있도록 고도화 해 줘. 

* 맥락: 과정간: mcp_knowledge_base/curriculum.md ->> 과정별: 과정명, 과정상세 ->> 과정내: textbook간, 코드간
* 참고) 섹션사용 textbook : mcp_knowledge_base/cloud_master/textbook/Day1/cloud-deployment-guide.md

## 요청4) 각 과정의 모든 markdown 문서들이 섹션과 링크 기능을 활용하여 맥락을 쉽게 파악하고 사용자 친화적으로 UI 가 구성될 수 있도록 고도화 되어 있는지 점검해 줘

---
# 실습 코드 작성

요청1) 스크립트 수정 요청: 스크립트가 중단되어도 다시 시작할 때 기존 리소스를 재사용하도록 수정. ["각 스크립트에 리소스 존재 확인 및 재사용 로직을 추가"]

google cloud 에 프로젝트, 네트워크 및 VM 생성 및 설정 스크립트로, 스크립트가 중단되어도 다시 시작할 때 기존 리소스를 재사용하도록 수정. ["각 스크립트에 리소스 존재 확인 및 재사용 로직을 추가"]

# 2025-09-12

1) 아래 파일을 보고, 관련 내용간 링크를 추가해 줘. README.md 는 container 과정 처럼 작성하면 좋겠어

mcp_knowledge_base/cloud_master/README.md
mcp_knowledge_base/cloud_master/과정명.md
mcp_knowledge_base/cloud_master/과정상세.md

요청2) 이제, 전체 관점에서 아래 파일을 보고, 관련 내용간 링크를 추가해 줘. mcp_knowledge_base/README.md 는 필요 시 작성하면 좋겠어

mcp_knowledge_base/curriculum.md
mcp_knowledge_base/index.md
mcp_knowledge_base/README.md
mcp_knowledge_base/cloud_basic/README.md
mcp_knowledge_base/cloud_basic/과정명.md
mcp_knowledge_base/cloud_basic/과정상세.md
mcp_knowledge_base/cloud_master/README.md
mcp_knowledge_base/cloud_master/과정명.md
mcp_knowledge_base/cloud_master/과정상세.md
mcp_knowledge_base/cloud_container/README.md
mcp_knowledge_base/cloud_container/과정명.md
mcp_knowledge_base/cloud_container/과정상세.m

요청3) 아래 파일들은 Master 과정 디렉토리 내 파일인데, 내용이 이에 부합하게 작성되었는지 확인해 줘

mcp_knowledge_base/cloud_master/README.md
mcp_knowledge_base/cloud_master/과정명.md
mcp_knowledge_base/cloud_master/과정상세.md

요청4) 위 세개의 파일들이 Master 과정 교구들 ["mcp_knowledge_base/cloud_master 디렉토리 내 파일들"]과  맥락적으로 연계 되었는지, 특히 mcp_knowledge_base/cloud_master/textbook 내 교재들은 전수 조사해 줘.

요청5) 교재간 전/후 이동 링크 확인 및 부재 시 추가

요청6) 아래 날짜간 README 파일과 실습파일 간 전/후 이동 링크 추가

README 파일
   mcp_knowledge_base/cloud_master/textbook/Day3/README.md
   mcp_knowledge_base/cloud_master/textbook/Day2/README.md
   mcp_knowledge_base/cloud_master/textbook/Day1/README.md

실습파일
   mcp_knowledge_base/cloud_master/textbook/Day1/practice/docker-basics.md
   mcp_knowledge_base/cloud_master/textbook/Day1/practice/git-github-basics.md
   mcp_knowledge_base/cloud_master/textbook/Day1/practice/github-actions-basics.md
   mcp_knowledge_base/cloud_master/textbook/Day1/practice/vm-deployment.md

요청7) 페이지 이동 시, 이동 후 해당 페이지 상단이 보여지게

요청8) ContainerView 우상단에 위치한 PDF ["다운로드"] 버튼 왼쪽에 호출한 페이지로 복귀하는 링크 "이전" 화면으로 이동하는 링크를 추가할 수 있어?

요청9) 내부파일 링크가 클릭 시, 프론트엔드에서 URL 에 경로가 재귀적으로 추가되어 실패하는 이슈가 발생하고 있어.

요청10) 구현된 내용 단위 테스트 수행

-. 추가된 "이전" 버튼이 모두 로그인 화면으로 이동하고 있음. 사용자 인증 코드와 관련 된듯.
-. 경로 중복은 여전히 발생하고 있음.
https:///api.goldencircle.us/api/v1/curriculum?curriculum_path=cloud_master%2Ftextbook%2FDay1%2Ftextbook%2FDay1%2Ftextbook%2FDay2%2FREADME 

-. 페이지 이동 후, 새로운 페이지에서 스크롤을 페이지 상단이 보이게 해 달라는 거였는데, 변화가 없음.

이슈1) 경로 중복 문제 관련하여, 모든 문서가 안되든지 되든지 해야 하는데 어떻게 되는게 있고 안되는게 있을 수 있지? 원인 분석 해 줘. ["단, 코드 수정은 하지 말것"]

이슈2) 본문내 링크를 클릭하는 경우에도 되는경우가 있고 안되는 경우가 있어.

   1. 정상 작동하는 링크: "절대 경로" 스타일
   2. 오류를 일으키는 링크: "상대 경로" 스타일
  본문 내 링크의 동작이 일관성 없는 이유는 링크가 마크다운 소스 코드에 어떤 
  형식["절대/상대"]으로 작성되었는지에 따라 애플리케이션이 다르게 반응하기
  때문입니다.

   * 슬래시[/]로 시작하는 절대 경로 스타일 링크는 정상적으로 동작합니다.
  따라서 이 현상은 무작위로 발생하는 것이 아니라, 링크의 작성 방식에 따라
  결정론적으로 발생하는 문제입니다.
이슈3) 오류를 일으키는 링크: "상대 경로" 스타일에 대한 해결책은?

2025-09-15

1. 프로파일 모달 팝업 설정 기본 상태는 False, 사용자 클릭 시에만 True
2. 왼쪽 메뉴 FileTree 에 최근 오픈파일 리스트 3개 보여주게
3. 사용자 과정별 진도 관리: 학습진도 [%] 표기 체계 및 현재 위치 보여주기
4. 내부 파일 URI 한글 인코딩. URI내 한글을 읽을 수 있게 처리
5. 지식베이스 FileTree 커리큘럼 설정 버튼으로 설정된 디렉토리만 커리큘럼 FileTree 에서 보여지게 
6. 

7. docs 디렉토리내 모든 문서를 점검하여, 현재 시스템 목적과 현재에 부합하게 내용 현행화 ["수정"]

mcp_knowledge_base 디렉토리 하위에 구성된, cloud_basic, cloud_master, cloud_container 과정과 integrated_automation 자동화 코드 확인 후, 각 과정이 맥락에 맞게 구성되었는지 실습 코드 포함하여 점검 및 개선 방안 제시  ["단, 현재 과정 유지 조건, 질문 필수"]

파일에 읽고 쓰는 api 와 해당 파일 위치를 찾아 줘

frontend 프로젝트에서 프로젝트 루트 디렉토리에 있는 .slides_selection.json 파일을 읽고 쓰는 API를 호출하는 코드는 어디에 있는지 찾아 줘. 

강의 계획 관련하여 backend 와 frontend 가 적절하게 동작되도록 되어 있는지 점검해 줘. 

.slides_selection.json 파일에 있는 디렉토리 아래 있는 파일을 보여 지게 되어 있는거라는 거지?

---



---



---



---

<div align="center">

 현재 위치
**작업 문서**

## 🔗 관련 과정
Cloud Basic 1일차 | ["Cloud Master 1일차"][cloud_master/textbook/Day1/README.md] | ["Cloud Container 1일차"][cloud_container/textbook/Day1/README.md]

</div>

---

<div align="center">

["🏠 홈"][index.md] | ["📚 전체 커리큘럼"][curriculum.md] | ["🔗 학습 경로"][learning-path.md]

</div>

요청) 과정별로 실습내용이 많이 달라졌을 거야. 해서, 자동화 코드도 이에 부합하게 갱신되게 해 줘. 
요청) 자동화 코드 수행 중간에 실패하더라도, 생성한 리소스를 다시 사용할 수 있도록 체크하는 로직 추가해 주고, 사용자 가이드도 갱신해 줘. 