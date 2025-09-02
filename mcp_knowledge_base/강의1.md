


1. 구독 
   rootadmin@jupyteronlinegmail.onmicrosoft.com
   bright2n@2025
2. Entra ID . 사용자 생성 -> 권한 부여() 
3. ENTRA ID . 그룹 생성
4. 리소스그룹 생성
5. rootadmin 이 Entra ID 에서 계정 관리할 수 있도록 Global Administrator 권한 부여
6. (오후) UI 사용방법
7. GUI 로 VM 생성 (Windows VM)
8. 명령어로 VM 생성하기 (Ubuntu)
9. Azure Lock - Delete Lock
10. Azure Policy - Allowed Location
11. VM
12. VNet (=Switch)


*** ChatGPT ***

1) 이미지 내용을 알고 싶은데, 네가 최적의 프롬프트 추천해 줘

최적 프롬프트 예시

"이 스크린샷은 Azure Portal의 Add role assignment 과정 중 'Conditions' 단계 화면입니다. 여기서 어떤 역할(Owner)을 선택했을 때, 사용자가 할 수 있는 권한 옵션(세 가지)과 그 의미를 요약·설명해 주세요. 또한 보안 관점에서 어떤 선택이 권장되는지 알려주세요."








2일차:

1. 1일차 wrap-up
2. storage account 생성
3. container
3.1 static website 생성 (static html)
   blob 에 파일을 올려 공유하고, URL 을 만들어 static 사이트에 사용
3.2 DNS 등록하여 정적 사이트로 서비스 개시하기
   Cloudflare 등록 -> Azure DNS Zone -> and more
4. file-share 
   윈도우즈 서버에 붙여, 디렉토리로 사용
5. backup 
   life cycle management

6. virtual network

시나리오1. 로드밸런싱
  1) 2개의 네트워크를 구성하고
  2) 네트워크간 피어링을 맺은 후,
  3) 각 네트워크에 서브넷 1개씩 추가하고,
  4) VM을 하나씩 만들고,
  5) 웹서버를 구성하고,
  6) 앞단에 로드밸런서를 구성하고,
  7) 웹서버 앞단에 두고,
  8) 외부에서 웹서버(웹페이지)를 접근하게 하고,
  9) VM에서 외부와 통신할 수 있게 NAT 를 구성하여,
  10) 시큐리티 패치 등을 할 수 있다.
   
시나리오2. Traffic Manager
  1. 7


재작성 페이지:

  6 10 16 21 26 30 31 36 43 44 62 68 70 76
  80 81 82 86 87 91 97 111 115 118  126 142