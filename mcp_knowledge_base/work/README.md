유첨된 내용(과정명, 과정상세)을 참조하여 1일차 교안 및 실습 코드 설계하는데 A4 용지로 20장 이상 작성해 줘

DOCKERHUB_TOKEN 시크릿 설정 관련 사용자 안내 추가 필요

현재 문서가 코드가 위에서 언급된 내용으로 맥락을 같이 하는지 점검

요청1) mcp_knowledge_base\cloud_master\textbook\Day1 디렉토리에 위치한 교재와 코드가 맥락에 맞게 구성되었는지 실습 코드 포함하여 점검해 줘.  진행 전 질문있으면 하고. 

  - 질문에 대한 답: Day1 디렉토리 진행, AWS/GCP 배포 관련 파일들도 포함, 전체적인 맥락 점검 후 actions-demo 에 집중

요청2) 스크립트 수정 요청: 스크립트가 중단되어도 다시 시작할 때 기존 리소스를 재사용하도록 수정. (각 스크립트에 리소스 존재 확인 및 재사용 로직을 추가)

google cloud 에 프로젝트, 네트워크 및 VM 생성 및 설정 스크립트로, 스크립트가 중단되어도 다시 시작할 때 기존 리소스를 재사용하도록 수정. (각 스크립트에 리소스 존재 확인 및 재사용 로직을 추가)


gcloud projects create mcp-cloud-2025-12345 --name="MCP Cloud Project"



ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSM06ULO0goKY74s9TZ6lteH76r0IrAEvv58ke2ayAXw/zrH8t51JI1RucbbZy4yoQAQCWoeEje9ClmOJ3OtvcchqrKlh5J5Wy4XghsgeZn0Ap+efDHyhzzdu0FS087pF90xJztQDHssHJ1JdUhw61R2wr5h4j4lfHJam1jVFDQAqU+LewfKggzBwNB3jNkULrP2aVUGA+CCNTQqHRp02ltySWgZ3r4CEixZLqSwPaY1I/RgsWdv0VYb0LVZ2iDwcq1LAtgho2kfKTyPRdsGyr8fRa33CmPIszovPBXmTmGT5iRJokASOFu3ZRZnioQOPm7lmRiXjaytip350LJc/3 DESKTOP-0TCBR9U\JIH@DESKTOP-0TCBR9U