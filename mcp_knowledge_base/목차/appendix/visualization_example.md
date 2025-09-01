# 고급 시각화 예시 슬라이드

**커스텀 CSS와 다양한 시각화 요소를 활용한 프레젠테이션**

![시각화](https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=400&fit=crop)

---

## 학습 목표

**이번 강의를 통해 다음을 달성할 수 있습니다:**

- 커스텀 CSS를 활용한 고급 시각화 기법
- Mermaid 다이어그램과 인포그래픽의 효과적 활용
- 대화형 요소와 실습 시나리오 설계
- 반응형 디자인과 애니메이션 효과

---

## 시각화 요소 종합 활용

### 1. Mermaid 다이어그램

```mermaid
graph TB
    subgraph "클라우드 아키텍처"
        A[사용자] --> B[로드 밸런서]
        B --> C[웹 서버 1]
        B --> D[웹 서버 2]
        C --> E[데이터베이스]
        D --> E
    end
    
    subgraph "모니터링"
        F[CloudWatch] --> C
        F --> D
        F --> E
    end
    
    style A fill:#e1f5fe
    style B fill:#f3e5f5
    style C fill:#e8f5e8
    style D fill:#e8f5e8
    style E fill:#fff3e0
    style F fill:#fce4ec
```

---

## 2. 인포그래픽 스타일 요소

### 클라우드 서비스 비교

```
AWS vs GCP 서비스 비교 (2024년 기준)
┌─────────────────────────────────────┐
│  컴퓨팅 서비스                      │
│  ┌─────────────────────────────┐   │
│  │ AWS EC2: 200+ 인스턴스 타입│   │
│  │ GCP Compute: 100+ 머신 타입│   │
│  │ 성능: AWS 15% 우위          │   │
│  └─────────────────────────────┘   │
│                                     │
│  스토리지 서비스                    │
│  ┌─────────────────────────────┐   │
│  │ AWS S3: 99.999999999%      │   │
│  │ GCP Storage: 99.999999999% │   │
│  │ 가격: GCP 10% 저렴          │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

---

## 3. 고급 테이블 및 비교표

### 클라우드 서비스 상세 비교

| 서비스 카테고리 | AWS 서비스 | GCP 서비스 | 주요 차이점 | 가격 비교 |
|-----------------|------------|------------|-------------|-----------|
| **컴퓨팅** | EC2, Lambda, ECS | Compute Engine, Cloud Functions, GKE | 인스턴스 타입, 가격 정책 | AWS 15% 비쌈 |
| **스토리지** | S3, EBS, EFS | Cloud Storage, Persistent Disk, Filestore | 일관성 모델, 접근 제어 | GCP 10% 저렴 |
| **데이터베이스** | RDS, DynamoDB, ElastiCache | Cloud SQL, Firestore, Memorystore | 관리 수준, 확장성 | 비슷함 |
| **네트워킹** | VPC, ALB, CloudFront | VPC, Load Balancing, Cloud CDN | 글로벌 vs 리전별 | AWS 20% 비쌈 |
| **AI/ML** | SageMaker, Rekognition | AI Platform, Vision API | 서비스 범위, 사용 편의성 | GCP 우위 |

---

## 4. 커스텀 CSS 클래스 활용

### 카드 레이아웃

<div class="grid grid-3">

<div class="card hover-lift">
  <div class="card-header">
    <h4 class="card-title">AWS 서비스</h4>
  </div>
  <div class="card-body">
    <p>가장 큰 시장 점유율과 서비스 범위를 제공하는 클라우드 플랫폼</p>
    <span class="badge badge-primary">Market Leader</span>
  </div>
</div>

<div class="card hover-lift">
  <div class="card-header">
    <h4 class="card-title">GCP 서비스</h4>
  </div>
  <div class="card-body">
    <p>AI/ML과 데이터 분석에 특화된 혁신적인 클라우드 서비스</p>
    <span class="badge badge-secondary">AI First</span>
  </div>
</div>

<div class="card hover-lift">
  <div class="card-header">
    <h4 class="card-title">Azure 서비스</h4>
  </div>
  <div class="card-body">
    <p>엔터프라이즈 환경에 최적화된 Microsoft 클라우드 플랫폼</p>
    <span class="badge badge-info">Enterprise</span>
  </div>
</div>

</div>

---

## 5. 알림 및 경고 시스템

### 중요 정보 표시

<div class="alert alert-info">
  <strong>정보:</strong> AWS와 GCP는 각각 다른 강점을 가지고 있습니다. 프로젝트 요구사항에 맞는 선택이 중요합니다.
</div>

<div class="alert alert-success">
  <strong>성공:</strong> 클라우드 마이그레이션을 통해 운영 비용을 30% 절감했습니다.
</div>

<div class="alert alert-warning">
  <strong>주의:</strong> 무료 티어 사용 시 예상치 못한 비용이 발생할 수 있습니다.
</div>

<div class="alert alert-error">
  <strong>오류:</strong> 잘못된 보안 그룹 설정으로 인해 서비스 접근이 차단되었습니다.
</div>

---

## 6. 진행률 및 상태 표시

### 학습 진행률

**Day 1: 클라우드 기초** <span class="badge badge-success">완료</span>
<div class="progress-bar">
  <div class="progress-fill" style="width: 100%"></div>
</div>

**Day 2: CLI 환경** <span class="badge badge-success">완료</span>
<div class="progress-bar">
  <div class="progress-fill" style="width: 100%"></div>
</div>

**Day 3: 서비스 비교** <span class="badge badge-warning">진행 중</span>
<div class="progress-bar">
  <div class="progress-fill" style="width: 75%"></div>
</div>

**Day 4: Terraform** <span class="badge badge-info">예정</span>
<div class="progress-bar">
  <div class="progress-fill" style="width: 0%"></div>
</div>

---

## 7. 타임라인 및 프로세스

### 클라우드 학습 로드맵

<div class="timeline">

<div class="timeline-item">
  <h4>기초 단계 (Day 1-2)</h4>
  <p>클라우드 개념 이해 및 CLI 환경 구축</p>
  <span class="badge badge-primary">완료</span>
</div>

<div class="timeline-item">
  <h4>중급 단계 (Day 3-5)</h4>
  <p>서비스 비교 분석 및 Terraform 실습</p>
  <span class="badge badge-warning">진행 중</span>
</div>

<div class="timeline-item">
  <h4>고급 단계 (Day 6-7)</h4>
  <p>컨테이너 및 보안 고급 실습</p>
  <span class="badge badge-info">예정</span>
</div>

</div>

---

## 8. 대화형 요소

### 퀴즈 및 체크포인트

**Q1. 다음 중 AWS의 핵심 컴퓨팅 서비스는?**

- [ ] Cloud Functions
- [ ] EC2 (Elastic Compute Cloud)
- [ ] Compute Engine
- [ ] Virtual Machines

**Q2. GCP의 주요 강점은?**

- [ ] 가장 큰 시장 점유율
- [ ] AI/ML 서비스 우수성
- [ ] 엔터프라이즈 지원
- [ ] 가장 저렴한 가격

**Q3. 클라우드 선택 시 고려해야 할 요소는?**

- [ ] 비용
- [ ] 성능
- [ ] 보안
- [ ] 모두 해당

---

## 9. 실습 시나리오

### **🎯 실습 시나리오: 멀티 클라우드 아키텍처 설계**

당신은 스타트업의 클라우드 아키텍트입니다. 다음 요구사항을 만족하는 멀티 클라우드 아키텍처를 설계해야 합니다:

**요구사항:**
- 고가용성 (99.9% 이상)
- 비용 최적화
- 지역별 성능 최적화
- 보안 및 규정 준수

**제약사항:**
1. **예산**: 월 $5,000 이하
2. **팀 역량**: AWS 경험자 2명, GCP 경험자 1명
3. **규정**: GDPR, SOC 2 준수 필요
4. **성장**: 1년 내 사용자 50배 증가 예상

**질문:**
- 어떤 클라우드 조합을 선택하시겠습니까?
- 각 클라우드의 역할은 무엇입니까?
- 비용 최적화 전략은 무엇입니까?

---

## 10. 고급 애니메이션 효과

### 애니메이션 클래스 활용

<div class="animate-fade-in">

<div class="hero-section">
  <h2 class="hero-title">클라우드 엔지니어링 부트캠프</h2>
  <p class="hero-subtitle">7일 만에 클라우드 전문가가 되세요!</p>
  <a href="#" class="btn">시작하기</a>
</div>

</div>

<div class="animate-slide-in">

<div class="card hover-scale">
  <div class="card-header">
    <h4 class="card-title">학습 성과</h4>
  </div>
  <div class="card-body">
    <p>7일 과정 완료 후 클라우드 인프라 설계 및 구축 능력 확보</p>
    <div class="flex flex-center">
      <span class="badge badge-success">AWS</span>
      <span class="badge badge-secondary">GCP</span>
      <span class="badge badge-info">Terraform</span>
    </div>
  </div>
</div>

</div>

---

## 11. 반응형 그리드 레이아웃

### 서비스 비교 그리드

<div class="grid grid-2">

<div class="card">
  <h4>컴퓨팅 서비스</h4>
  <ul class="checklist">
    <li class="completed">EC2 인스턴스 생성</li>
    <li class="completed">Auto Scaling 설정</li>
    <li>Load Balancer 구성</li>
    <li>Health Check 설정</li>
  </ul>
</div>

<div class="card">
  <h4>스토리지 서비스</h4>
  <ul class="checklist">
    <li class="completed">S3 버킷 생성</li>
    <li class="completed">EBS 볼륨 연결</li>
    <li>EFS 파일시스템</li>
    <li>백업 정책 설정</li>
  </ul>
</div>

</div>

---

## 12. 통계 및 수치 시각화

### 클라우드 시장 현황

```
글로벌 클라우드 시장 점유율 (2024년)
┌─────────────────────────────────────┐
│  AWS: 32%                          │
│  ┌─────────────────────────────┐   │
│  │ ████████████████████████████│   │
│  │ ████████████████████████████│   │
│  │ ████████████████████████████│   │
│  └─────────────────────────────┘   │
│                                     │
│  Azure: 22%                        │
│  ┌─────────────────────────────┐   │
│  │ ████████████████████████    │   │
│  │ ████████████████████████    │   │
│  └─────────────────────────────┘   │
│                                     │
│  GCP: 11%                          │
│  ┌─────────────────────────────┐   │
│  │ ████████████                │   │
│  └─────────────────────────────┘   │
│                                     │
│  기타: 35%                         │
│  ┌─────────────────────────────┐   │
│  │ ████████████████████████████│   │
│  │ ████████████████████████████│   │
│  │ ████████████████████████████│   │
│  │ ████████████████████████████│   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

---

## 13. 코드 블록 시각화

### 단계별 실행 결과

```bash
# 1단계: AWS CLI 설정
$ aws configure
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: ap-northeast-2
Default output format [None]: json

# 2단계: EC2 인스턴스 생성
$ aws ec2 run-instances \
  --image-id ami-0c7c4e3c6b47be499 \
  --instance-type t2.micro \
  --key-name my-key \
  --security-group-ids sg-12345678

{
  "InstanceId": "i-1234567890abcdef0",
  "State": "pending"
}

# 3단계: 상태 확인
$ aws ec2 describe-instances --instance-ids i-1234567890abcdef0
{
  "State": "running",
  "PublicIpAddress": "52.78.123.45"
}
```

---

## 14. 플렉스 레이아웃 활용

### 도구 및 리소스 배치

<div class="flex flex-between flex-wrap">

<div class="card">
  <h4>개발 도구</h4>
  <div class="flex flex-col">
    <span class="badge badge-primary">VS Code</span>
    <span class="badge badge-secondary">Terraform</span>
    <span class="badge badge-info">Docker</span>
  </div>
</div>

<div class="card">
  <h4>클라우드 서비스</h4>
  <div class="flex flex-col">
    <span class="badge badge-primary">AWS</span>
    <span class="badge badge-secondary">GCP</span>
    <span class="badge badge-info">Azure</span>
  </div>
</div>

<div class="card">
  <h4>모니터링</h4>
  <div class="flex flex-col">
    <span class="badge badge-primary">CloudWatch</span>
    <span class="badge badge-secondary">Stackdriver</span>
    <span class="badge badge-info">Prometheus</span>
  </div>
</div>

</div>

---

## 15. 최종 요약 및 다음 단계

### 학습 진행 상황

<div class="grid grid-2">

<div class="card">
  <h4>완료된 항목</h4>
  <ul class="checklist">
    <li class="completed">클라우드 개념 이해</li>
    <li class="completed">AWS/GCP 계정 설정</li>
    <li class="completed">CLI 환경 구축</li>
    <li class="completed">기본 서비스 탐색</li>
  </ul>
</div>

<div class="card">
  <h4>다음 단계</h4>
  <ul class="checklist">
    <li>Terraform 기초 학습</li>
    <li>인프라 자동화 실습</li>
    <li>DevOps 파이프라인 구축</li>
    <li>보안 및 모니터링</li>
  </ul>
</div>

</div>

---

## 참고 자료 및 추가 학습

### **공식 문서**
- [AWS 공식 문서](https://aws.amazon.com/ko/documentation/)
- [GCP 공식 문서](https://cloud.google.com/docs)
- [Terraform 공식 문서](https://www.terraform.io/docs)

### **추가 학습 자료**
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Google Cloud Architecture Framework](https://cloud.google.com/architecture/framework)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)

### **실습 환경**
- [AWS Free Tier](https://aws.amazon.com/free/)
- [Google Cloud Free Tier](https://cloud.google.com/free)
- [Terraform Cloud](https://cloud.hashicorp.com/products/terraform)

---

## 버전 정보 및 업데이트

> **📅 최종 업데이트**: 2024년 1월 15일
> **☁️ AWS 서비스 버전**: 2024년 1월 기준
> **☁️ GCP 서비스 버전**: 2024년 1월 기준
> **📚 강의 버전**: v1.0.0

**호환성 확인:**
- AWS CLI v2.15.0 이상
- gcloud CLI 450.0.0 이상
- Terraform 1.6.0 이상

---

## 질문 및 토론

**이번 강의에 대한 질문이나 토론하고 싶은 주제가 있으시면 언제든 말씀해 주세요!**

- 시각화 요소의 효과적 활용 방법
- 커스텀 CSS 테마 커스터마이징
- 반응형 디자인 구현 전략
- 애니메이션 효과 최적화

---

## 감사합니다!

**고급 시각화 기법을 활용한 프레젠테이션 강의를 완료했습니다!**

다음 강의에서 실제 프로젝트에 시각화 요소를 적용하는 실습을 진행하겠습니다.

![시각화 완성](https://images.unsplash.com/photo-1555949963-ff9fe0c870eb?w=800&h=300&fit=crop)
