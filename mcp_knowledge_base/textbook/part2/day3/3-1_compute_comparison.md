# 3-1. 컴퓨팅 서비스 비교 (EC2 vs Compute Engine, Lambda vs Cloud Functions)

이 챕터에서는 AWS와 GCP의 핵심 컴퓨팅 서비스를 비교 분석하여, 다양한 시나리오에 가장 적합한 서비스를 선택하는 능력을 기릅니다.

---

### 서버리스 API 백엔드: Lambda vs Cloud Functions

**개요:** 서버를 직접 관리할 필요 없이 코드 실행 환경을 제공하는 서버리스 컴퓨팅은 현대적인 백엔드 아키텍처의 핵심입니다. AWS Lambda와 GCP Cloud Functions는 각각의 생태계에서 이 역할을 수행합니다.

| 구분 | AWS | GCP |
| --- | --- | --- |
| **핵심 서비스** | **AWS Lambda** | **Google Cloud Functions** |
| **API 연동** | Amazon API Gateway | Google Cloud API Gateway |
| **데이터베이스**| Amazon DynamoDB (NoSQL) | Google Firestore/Cloud SQL (NoSQL/SQL) |
| **아키텍처 특징** | - 이벤트 기반으로 코드를 실행 (예: API 호출, 파일 업로드)
- 사용한 만큼만 비용 지불 (밀리초 단위)
- 자동 확장 및 고가용성 내장 | - AWS Lambda와 매우 유사한 이벤트 기반 모델
- 1세대, 2세대로 구분되며 2세대는 Cloud Run 기반으로 더 긴 실행 시간과 유연성 제공 |
| **주요 사용 사례** | - 실시간 파일 처리
- 웹 애플리케이션 백엔드
- 데이터 스트림 분석 | - 간단한 API 엔드포인트
- IoT 기기 데이터 수집
- 다른 GCP 서비스와의 연동 자동화 |

**결론:** 두 서비스 모두 서버리스의 핵심 가치를 제공하지만, GCP의 2세대 Cloud Functions는 내부적으로 Cloud Run을 활용하여 컨테이너의 유연성을 더한 점이 특징입니다.

---

### 컨테이너 기반 마이크로서비스: ECS/EKS vs GKE/Cloud Run

**개요:** 마이크로서비스 아키텍처(MSA)가 보편화되면서 컨테이너 기술은 필수 요소가 되었습니다. AWS와 GCP는 다양한 컨테이너 오케스트레이션 서비스를 제공하여 개발자가 비즈니스 로직에 집중할 수 있도록 돕습니다.

| 구분 | AWS | GCP |
| --- | --- | --- |
| **관리형 Kubernetes** | **Amazon EKS (Elastic Kubernetes Service)** | **Google Kubernetes Engine (GKE)** |
| **독자적 오케스트레이션** | **Amazon ECS (Elastic Container Service)** | (해당 없음, GKE에 집중) |
| **서버리스 컨테이너** | AWS Fargate (ECS 또는 EKS의 실행 유형) | **Google Cloud Run** |
| **아키텍처 특징** | - **EKS:** 표준 Kubernetes를 완벽하게 지원하여, 오픈소스 생태계와의 호환성이 높고 복잡한 애플리케이션 관리에 적합합니다.
- **ECS:** AWS에 더 최적화된 자체 컨테이너 오케스트레이터로, 배우기 쉽고 AWS 서비스와 긴밀하게 통합됩니다.
- **Fargate:** EC2 인스턴스(노드)를 관리할 필요가 없는 서버리스 컨테이너 실행 환경을 제공합니다. | - **GKE:** Kubernetes를 최초로 개발한 구글의 노하우가 집약되어 있어, 가장 성숙하고 강력한 관리형 Kubernetes 서비스로 평가받습니다. (Autopilot 모드 제공)
- **Cloud Run:** 컨테이너 이미지를 배포하면 자동으로 확장/축소되는 완전 관리형 서버리스 플랫폼입니다. 간단한 웹 애플리케이션이나 API에 매우 적합합니다. |

**결론:** Kubernetes 표준을 중요시하고 복잡한 관리가 필요하다면 EKS와 GKE가, AWS 생태계에 깊이 통합된 단순함을 원한다면 ECS가, 서버리스의 간편함을 원한다면 Fargate와 Cloud Run이 좋은 선택입니다. 특히 GKE는 Kubernetes의 "표준"으로 여겨질 만큼 강력한 기능을 자랑합니다.
