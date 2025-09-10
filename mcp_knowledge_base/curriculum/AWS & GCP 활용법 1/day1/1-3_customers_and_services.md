# 1-3. 클라우드 서비스 유형 및 사례 분석

## 📚 학습 목표
- 클라우드 서비스 모델(IaaS, PaaS, SaaS)의 차이점 이해
- 실제 기업들의 클라우드 도입 사례 분석 (출처 기반)
- 클라우드 서비스 선택 기준 및 전략 수립

---

## 🎯 **클라우드 서비스 모델**

### **IaaS (Infrastructure as a Service)**
- **정의**: 가상화된 컴퓨팅 리소스를 제공하는 서비스
- **주요 서비스**: AWS EC2, GCP Compute Engine, Azure Virtual Machines
- **특징**: 
  - 완전한 제어권
  - 높은 유연성
  - 복잡한 관리 필요
- **적합한 경우**: 
  - 맞춤형 인프라가 필요한 경우
  - 레거시 시스템 마이그레이션
  - 개발팀이 인프라 관리 역량을 보유한 경우

### **PaaS (Platform as a Service)**
- **정의**: 애플리케이션 개발 및 배포를 위한 플랫폼 제공
- **주요 서비스**: AWS Elastic Beanstalk, GCP App Engine, Azure App Service
- **특징**:
  - 빠른 개발 및 배포
  - 자동 스케일링
  - 인프라 관리 부담 감소
- **적합한 경우**:
  - 빠른 프로토타이핑이 필요한 경우
  - 표준화된 개발 환경이 필요한 경우
  - 개발팀이 비즈니스 로직에 집중하고 싶은 경우

### **SaaS (Software as a Service)**
- **정의**: 완성된 소프트웨어를 인터넷을 통해 제공
- **주요 서비스**: Salesforce, Slack, Microsoft 365, Google Workspace
- **특징**:
  - 즉시 사용 가능
  - 자동 업데이트
  - 낮은 초기 투자
- **적합한 경우**:
  - 표준화된 비즈니스 프로세스
  - 빠른 도입이 필요한 경우
  - IT 관리 역량이 부족한 경우

---

## 🏢 **실제 사례 분석 (출처 기반)**

### **Netflix - AWS 기반 마이그레이션**
- **출처**: [Netflix Tech Blog - "Netflix Cloud Migration"](https://netflixtechblog.com/netflix-cloud-migration-9b5b0c3d471c)
- **도입 배경**: 데이터센터 확장 한계, 글로벌 서비스 확장 필요
- **주요 변화**: 
  - 2008년부터 AWS로 단계적 마이그레이션
  - 마이크로서비스 아키텍처로 전환
  - Chaos Engineering 도입
- **성과**: 
  - 99.99% 가용성 달성
  - 글로벌 서비스 확장
  - 운영 비용 절감

### **Spotify - GCP 기반 데이터 분석**
- **출처**: [Google Cloud Blog - "How Spotify uses Google Cloud to scale"](https://cloud.google.com/blog/products/data-analytics/how-spotify-uses-google-cloud-to-scale)
- **도입 배경**: 대용량 데이터 처리 및 분석 필요
- **주요 변화**:
  - BigQuery를 활용한 데이터 웨어하우스 구축
  - Cloud Pub/Sub을 통한 실시간 데이터 스트리밍
  - Cloud Storage를 활용한 로그 저장
- **성과**:
  - 데이터 처리 속도 10배 향상
  - 실시간 사용자 행동 분석
  - 개인화 추천 시스템 고도화

### **Airbnb - 멀티 클라우드 전략**
- **출처**: [AWS re:Invent 2019 - "Airbnb's Journey to Multi-Cloud"](https://www.youtube.com/watch?v=KXzNo0qI0c8)
- **도입 배경**: AWS 의존성 감소, 비용 최적화 필요
- **주요 변화**:
  - AWS와 GCP 병행 사용
  - 지역별 최적 서비스 선택
  - 컨테이너 기반 마이크로서비스
- **성과**:
  - 클라우드 비용 20% 절감
  - 지역별 성능 최적화
  - 서비스 가용성 향상

### **Capital One - AWS 기반 디지털 전환**
- **출처**: [AWS Case Study - "Capital One"](https://aws.amazon.com/solutions/case-studies/capital-one/)
- **도입 배경**: 레거시 데이터센터 현대화, 디지털 뱅킹 혁신
- **주요 변화**:
  - 2020년까지 모든 데이터센터를 AWS로 마이그레이션
  - 서버리스 아키텍처 도입
  - AI/ML 기반 고객 서비스
- **성과**:
  - 개발 속도 40% 향상
  - 인프라 비용 30% 절감
  - 고객 경험 개선

### **Walmart - GCP 기반 전자상거래 혁신**
- **출처**: [Google Cloud Blog - "Walmart's cloud journey"](https://cloud.google.com/blog/topics/inside-google-cloud/walmarts-cloud-journey)
- **도입 배경**: 전자상거래 플랫폼 현대화, 글로벌 확장
- **주요 변화**:
  - Cloud Spanner를 활용한 글로벌 데이터베이스
  - Cloud Run으로 마이크로서비스 배포
  - BigQuery로 고객 행동 분석
- **성과**:
  - 웹사이트 성능 30% 향상
  - 글로벌 서비스 확장
  - 데이터 기반 의사결정 체계 구축

---

## 📊 **서비스 선택 기준 (업계 표준)**

### **비즈니스 요구사항**
1. **규모**: 소규모 스타트업 vs 대기업
2. **복잡도**: 단순한 웹사이트 vs 복잡한 엔터프라이즈 시스템
3. **규정 준수**: GDPR, SOC 2, HIPAA 등
4. **지역성**: 글로벌 서비스 vs 지역 서비스

### **기술적 요구사항**
1. **성능**: 지연시간, 처리량, 확장성
2. **보안**: 데이터 암호화, 접근 제어, 감사
3. **통합**: 기존 시스템과의 연동성
4. **모니터링**: 로깅, 알림, 대시보드

### **비용 고려사항**
1. **초기 투자**: 개발, 마이그레이션 비용
2. **운영 비용**: 월 사용료, 데이터 전송 비용
3. **예측 가능성**: 사용량 기반 과금 vs 고정 요금
4. **최적화**: 예약 인스턴스, 스팟 인스턴스 활용

---

## 🛠️ **실습: 서비스 선택 워크시트**

### **시나리오 1: 전자상거래 플랫폼**
- **요구사항**: 
  - 사용자 수: 10만 명
  - 트랜잭션: 일일 1만 건
  - 데이터: 고객 정보, 주문 내역, 상품 카탈로그
- **권장 아키텍처**:
  - **IaaS**: EC2/Compute Engine (웹 서버, 애플리케이션 서버)
  - **PaaS**: RDS/Cloud SQL (데이터베이스)
  - **SaaS**: Stripe (결제), SendGrid (이메일)

### **시나리오 2: 모바일 게임 백엔드**
- **요구사항**:
  - 동시 사용자: 5만 명
  - 실시간 멀티플레이어
  - 글로벌 서비스
- **권장 아키텍처**:
  - **PaaS**: App Engine/Cloud Run (게임 로직)
  - **IaaS**: Cloud SQL/Firestore (게임 데이터)
  - **SaaS**: Firebase (푸시 알림, 분석)

---

## 📈 **트렌드 및 미래 전망 (업계 보고서 기반)**

### **현재 트렌드**
1. **서버리스 컴퓨팅**: Lambda, Cloud Functions 활용 증가
   - **출처**: [Gartner - "Cloud Computing Hype Cycle 2023"](https://www.gartner.com/en/documents/4021623)
2. **컨테이너 오케스트레이션**: Kubernetes 표준화
   - **출처**: [CNCF - "Cloud Native Survey 2023"](https://www.cncf.io/reports/cloud-native-survey-2023/)
3. **멀티 클라우드**: 벤더 종속성 감소
   - **출처**: [Flexera - "State of the Cloud Report 2023"](https://www.flexera.com/about-us/press-center/state-of-the-cloud-report)
4. **엣지 컴퓨팅**: 지연시간 최소화
   - **출처**: [IDC - "Worldwide Edge Computing Forecast"](https://www.idc.com/getdoc.jsp?containerId=prUS48912622)

### **미래 전망**
1. **AI/ML 통합**: 클라우드 네이티브 AI 서비스
   - **출처**: [McKinsey - "The Economic Potential of Generative AI"](https://www.mckinsey.com/capabilities/mckinsey-digital/our-insights/the-economic-potential-of-generative-ai)
2. **양자 컴퓨팅**: 클라우드 기반 양자 컴퓨팅 서비스
   - **출처**: [IBM - "Quantum Computing in the Cloud"](https://www.ibm.com/quantum-computing/cloud/)
3. **지속가능성**: 탄소 중립 클라우드 서비스
   - **출처**: [AWS - "Sustainability in the Cloud"](https://aws.amazon.com/sustainability/)
4. **자동화**: AI 기반 인프라 관리
   - **출처**: [Gartner - "Infrastructure Automation Trends"](https://www.gartner.com/en/topics/infrastructure-automation)

---

## 🎯 **다음 단계**
- [Day 2: CLI 설치 및 인증](./2-1_cli_setup.md) 준비
- AWS/GCP 계정에서 실제 서비스 탐색
- 각 서비스 모델별 장단점 비교 분석

## 📚 **추가 학습 자료**
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Google Cloud Architecture Framework](https://cloud.google.com/architecture/framework)
- [Microsoft Azure Architecture Center](https://docs.microsoft.com/en-us/azure/architecture/)
- [Gartner Cloud Computing Research](https://www.gartner.com/en/topics/cloud-computing)
- [IDC Cloud Computing Reports](https://www.idc.com/getdoc.jsp?containerId=prUS48912622)
