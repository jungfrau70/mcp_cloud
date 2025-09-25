# Cloud Container - 2일차 강의안

> 📋 **강의 일시**: 2024년 10월 2일 ["수"] 9:00~17:00  
> 📋 **강의 방식**: 온라인 실습 중심  
> 📋 **선수 학습**: Cloud Container 1일차 완료

---

## 🎯 2일차 학습 목표

### 핵심 목표
- **고가용성 아키텍처**: Multi-AZ, Multi-Region 클러스터 구축
- **고급 모니터링**: Alerting, Logging, APM 통합 시스템
- **보안 강화**: RBAC, Network Policies, Secrets 관리
- **성능 최적화**: Resource Management, QoS, VPA 설정
- **재해 복구**: Velero 백업, 다중 지역 복구 시스템

### 실습 후 달성할 수 있는 능력
- ✅ Multi-AZ 클러스터 구축 및 관리
- ✅ 통합 모니터링 시스템 운영
- ✅ Kubernetes 보안 정책 적용
- ✅ 성능 최적화 및 자동 스케일링
- ✅ 재해 복구 시스템 구축

### 예상 소요 시간
- **고가용성 아키텍처**: 90분
- **고급 모니터링**: 90분
- **보안 강화**: 90분
- **성능 최적화**: 90분
- **재해 복구**: 90분
- **전체 과정**: 7시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `repo/scripts/samples/`
- **자동화 스크립트**: `repo/scripts/automation/`
- **보안 설정**: `repo/scripts/security/`
- **성능 튜닝**: `repo/scripts/performance/`
- **백업 복구**: `repo/scripts/backup/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **kubectl**: Kubernetes 클러스터 관리
- **gcloud**: GCP 리소스 관리
- **velero**: Kubernetes 백업 도구
- **helm**: Kubernetes 패키지 관리

#### 환경 설정
```bash
# 필수 도구 설치 확인
kubectl version --client
gcloud version
velero version
helm version

# 클러스터 인증
gcloud container clusters get-credentials cloud-container-ha-cluster --zone=asia-northeast3-a
```

</details>

---

## 🕘 1교시: 고가용성 아키텍처 [9:00~10:30]

### 📚 학습 목표
- Multi-AZ 클러스터 구축
- Pod Anti-Affinity 설정
- Multi-Zone Load Balancer 구성

### 🛠️ 주요 실습

#### 🏗️ **1단계: Multi-AZ 클러스터 구축**
```bash
# 자동화 스크립트 실행
./repo/scripts/day2-practice-improved.sh

# 또는 수동 실행
gcloud container clusters create cloud-container-ha-cluster \
    --zone=asia-northeast3-a \
    --num-nodes=2 \
    --machine-type=e2-medium \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=10 \
    --node-locations=asia-northeast3-a,asia-northeast3-b,asia-northeast3-c
```

#### 🏗️ **2단계: Pod Anti-Affinity 설정**
```bash
# Pod Anti-Affinity 매니페스트 적용
kubectl apply -f k8s/anti-affinity-deployment.yaml
kubectl apply -f k8s/anti-affinity-service.yaml

# Pod 분산 확인
kubectl get pods -l app=sample-app-ha -o wide
```

#### 🏗️ **3단계: Multi-Zone Load Balancer 설정**
```bash
# Multi-Zone Ingress 적용
kubectl apply -f k8s/multi-zone-ingress.yaml

# Load Balancer IP 확인
kubectl get service ingress-nginx-controller -n ingress-nginx
```

**✅ 예상 결과:**
- Multi-AZ 클러스터: 3개 Zone에 노드 분산
- Pod 분산: 6개 Pod가 3개 Zone에 고르게 분산
- Load Balancer: 3개 Zone에 트래픽 분산

**🌐 브라우저로 서비스 접근:**
```bash
echo "Sample App HA: http://$EXTERNAL_IP"
echo "Health Check: http://$EXTERNAL_IP/health"
```

---

## 🕘 2교시: 고급 모니터링 [10:45~12:00]

### 📚 학습 목표
- 고급 Alerting 시스템 구축
- 중앙화된 Logging 시스템 구축
- APM [Application Performance Monitoring] 설정

### 🛠️ 주요 실습

#### 🏗️ **4단계: 고급 Alerting 시스템 구축**
```bash
# 자동화 스크립트 실행
.repo/scripts/automation/02-advanced-alerting.sh setup

# Alertmanager 설정 적용
kubectl apply -f monitoring/prometheus/alertmanager.yml
kubectl apply -f monitoring/prometheus/alert-rules.yml
```

#### 🏗️ **5단계: 중앙화된 Logging 시스템 구축**
```bash
# ELK Stack 설정
cd monitoring/logging
docker-compose up -d

# Fluentd DaemonSet 설치
kubectl apply -f https://raw.githubusercontent.com/fluent/fluentd-kubernetes-daemonset/master/fluentd-daemonset-elasticsearch.yaml
```

#### 🏗️ **6단계: APM 설정**
```bash
# Jaeger 설정
cd monitoring/apm
docker-compose up -d

# APM Pod 적용
kubectl apply -f k8s/apm-deployment.yaml
```

**✅ 예상 결과:**
- Alertmanager: 8개 주요 알림 규칙 설정
- ELK Stack: 중앙화된 로그 수집 및 분석
- Jaeger: 분산 추적 시스템

**🌐 브라우저로 모니터링 확인:**
```bash
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 [admin/admin]"
echo "Alertmanager: http://localhost:9093"
echo "Kibana: http://localhost:5601"
echo "Jaeger: http://localhost:16686"
```

---

## 🍽️ 점심 시간 [12:00~13:00]

---

## 🕘 3교시: 보안 강화 [13:00~14:30]

### 📚 학습 목표
- RBAC [Role-Based Access Control] 설정
- Network Policies 설정
- Secrets 관리
- Pod Security Standards 설정

### 🛠️ 주요 실습

#### 🏗️ **7단계: RBAC 설정**
```bash
# 자동화 스크립트 실행
.repo/scripts/automation/03-rbac-setup.sh setup

# RBAC 매니페스트 적용
kubectl apply -f k8s/rbac/

# 권한 테스트
kubectl auth can-i get pods --as=system:serviceaccount:default:sample-app-sa
```

#### 🏗️ **8단계: Network Policies 설정**
```bash
# Network Policy 적용
kubectl apply -f k8s/network-policies/

# 네트워크 연결 테스트
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default.svc.cluster.local
```

#### 🏗️ **9단계: Secrets 관리**
```bash
# Secret 생성
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secretpassword123

# Secret Pod 적용
kubectl apply -f k8s/secrets/secret-pod.yaml
```

#### 🏗️ **10단계: Pod Security Standards 설정**
```bash
# Pod Security Policy 적용
kubectl apply -f k8s/security/pod-security-policy.yaml

# 보안 테스트 Pod 적용
kubectl apply -f k8s/security/security-test-pod.yaml
```

**✅ 예상 결과:**
- Service Accounts: 3개 생성 [sample-app-sa, monitoring-sa, admin-sa]
- Network Policies: 4개 생성 ["기본 거부 + 선택적 허용"]
- Secrets: 4개 생성 [db-secret, tls-secret, registry-secret, app-secret]
- Pod Security: restricted-psp 생성

**🌐 브라우저로 보안 설정 확인:**
```bash
echo "RBAC 설정: kubectl get roles,rolebindings,clusterroles,clusterrolebindings"
echo "Network Policies: kubectl get networkpolicies --all-namespaces"
echo "Secrets: kubectl get secrets"
```

---

## 🕘 4교시: 성능 최적화 [14:45~16:15]

### 📚 학습 목표
- Resource Management 및 QoS 설정
- Node Affinity 설정
- Pod Disruption Budget 설정
- 성능 튜닝 및 최적화
- VPA [Vertical Pod Autoscaler] 설정

### 🛠️ 주요 실습

#### 🏗️ **11단계: Resource Management 및 QoS 설정**
```bash
# 자동화 스크립트 실행
.repo/scripts/automation/04-resource-management.sh setup

# QoS Pod들 적용
kubectl apply -f k8s/performance/

# QoS 클래스 확인
kubectl get pods -o custom-columns=NAME:.metadata.name,QOS-CLASS:.status.qosClass
```

#### 🏗️ **12단계: Node Affinity 설정**
```bash
# 노드 라벨 추가
kubectl label nodes $[kubectl get nodes -o jsonpath='{.items[0].metadata.name}'] node-type=high-performance

# Node Affinity Pod 적용
kubectl apply -f k8s/performance/node-affinity-pod.yaml
```

#### 🏗️ **13단계: Pod Disruption Budget 설정**
```bash
# Pod Disruption Budget 적용
kubectl apply -f k8s/performance/pod-disruption-budget.yaml

# PDB 상태 확인
kubectl get poddisruptionbudgets --all-namespaces
```

#### 🏗️ **14단계: 성능 튜닝 및 최적화**
```bash
# 성능 모니터링 Pod 적용
kubectl apply -f k8s/performance/performance-monitor.yaml

# 성능 테스트 실행
./performance-test.sh
```

#### 🏗️ **15단계: VPA 설정**
```bash
# VPA 설치
kubectl apply -f https://github.com/kubernetes/autoscaler/releases/download/vertical-pod-autoscaler-0.13.0/vpa-release.yaml

# VPA 설정 적용
kubectl apply -f k8s/performance/vpa-config.yaml
```

**✅ 예상 결과:**
- Guaranteed QoS: CPU/메모리 requests = limits
- Burstable QoS: CPU/메모리 requests < limits
- BestEffort QoS: CPU/메모리 requests/limits 없음
- Node Affinity: 고성능 노드 우선 스케줄링
- VPA: 자동 리소스 조정

**🌐 브라우저로 성능 모니터링 확인:**
```bash
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 [admin/admin]"
echo "성능 메트릭: kubectl top pods --sort-by=cpu"
```

---

## 🕘 5교시: 재해 복구 [16:30~17:00]

### 📚 학습 목표
- 데이터 백업 시스템 구축 [Velero]
- Persistent Volume 백업 설정
- 다중 지역 재해 복구 설정
- 자동화된 재해 복구 파이프라인
- 재해 복구 검증 및 테스트

### 🛠️ 주요 실습

#### 🏗️ **16단계: 데이터 백업 시스템 구축**
```bash
# 자동화 스크립트 실행
.repo/scripts/automation/05-backup-system.sh setup

# Velero 설치
velero install \
    --provider gcp \
    --plugins velero/velero-plugin-for-gcp:v1.5.1 \
    --bucket velero-backups \
    --secret-file ./credentials-velero
```

#### 🏗️ **17단계: Persistent Volume 백업 설정**
```bash
# Persistent Volume 적용
kubectl apply -f k8s/backup/persistent-volume.yaml

# 데이터베이스 Pod 적용
kubectl apply -f k8s/backup/database-pod.yaml

# Velero 백업 생성
velero backup create sample-app-backup \
    --include-namespaces default \
    --include-resources persistentvolumes,persistentvolumeclaims,deployments,services
```

#### 🏗️ **18단계: 다중 지역 재해 복구 설정**
```bash
# 보조 지역 클러스터 생성
gcloud container clusters create cloud-container-dr-cluster \
    --zone=asia-northeast1-a \
    --num-nodes=2 \
    --machine-type=e2-medium

# 백업 복제 실행
./backup-replication.sh
```

#### 🏗️ **19단계: 자동화된 재해 복구 파이프라인**
```bash
# 재해 복구 자동화 스크립트 실행
./disaster-recovery.sh

# 정기 백업 CronJob 적용
kubectl apply -f k8s/backup/backup-cronjob.yaml
```

#### 🏗️ **20단계: 재해 복구 검증 및 테스트**
```bash
# 백업 검증 테스트
velero backup get --output table

# 복원 테스트
velero restore create test-restore-$[date +%Y%m%d-%H%M%S] \
    --from-backup sample-app-backup

# 데이터 무결성 확인
kubectl exec -it deployment/postgres-db -- psql -U admin -d sample_app -c "SELECT * FROM users;"
```

**✅ 예상 결과:**
- Velero: Kubernetes 백업 도구 설치
- 백업 시스템: 자동 백업 파이프라인 구축
- 보조 지역 클러스터: asia-northeast1에 생성
- 백업 복제: 기본 지역 → 보조 지역 자동 복제
- RTO/RPO: 복구 시간 15분, 복구 지점 1시간

**🌐 브라우저로 재해 복구 상태 확인:**
```bash
echo "Velero 백업: velero backup get"
echo "Velero 복원: velero restore get"
echo "클러스터 상태: kubectl cluster-info"
```

---

## 🎯 **실습 진행 패턴 요약**

### 📋 **각 단계별 진행 패턴**
1. **🏗️ 아키텍처 그림**: 현재 상태와 목표 상태를 Mermaid 다이어그램으로 시각화
2. **🔍 명령 실행**: 자동화 스크립트 또는 수동 명령어 실행
3. **✅ 예상 결과**: 명령 실행 후 예상되는 결과 명시
4. **🌐 콘솔에서 확인**: GCP 콘솔에서 리소스 상태 확인
5. **🌐 브라우저로 서비스 접근**: 실제 서비스에 접근하여 동작 확인

### 🚀 **실습 진행 순서**
1. **1교시**: 고가용성 아키텍처 [Multi-AZ, Pod Anti-Affinity, Load Balancer]
2. **2교시**: 고급 모니터링 [Alerting, Logging, APM]
3. **3교시**: 보안 강화 [RBAC, Network Policies, Secrets]
4. **4교시**: 성능 최적화 [Resource Management, QoS, VPA]
5. **5교시**: 재해 복구 [Backup, Disaster Recovery]

### 🎯 **핵심 학습 포인트**
- **아키텍처 이해**: 각 단계별 시스템 구조 변화 시각화
- **실습 중심**: 90% 실습, 10% 이론
- **단계별 검증**: 각 단계마다 결과 확인 및 검증
- **통합 시나리오**: 고가용성 → 모니터링 → 보안 → 성능 → 복구 연계
- **자동화**: 스크립트를 통한 효율적 실습

---

## 🏗️ 최종 시스템 아키텍처

### 5교시: 재해 복구 완료 후
```mermaid
flowchart TB
    subgraph "GitHub"
        GH1[Repository<br/>sample-app]
        GH2[GitHub Actions<br/>CI/CD Pipeline]
    end
    
    subgraph "GCP Cloud - Primary Region [asia-northeast3]"
        PR1[GKE Cluster<br/>cloud-container-ha-cluster<br/>Multi-AZ]
        PR2[Sample App Pods<br/>6 replicas<br/>HPA + VPA]
        PR3[Load Balancer<br/>Multi-Zone]
        PR4[Persistent Volumes<br/>PostgreSQL]
        PR5["Velero Backup<br/>정기 백업"]
    end
    
    subgraph "GCP Cloud - Secondary Region [asia-northeast1]"
        SR1["GKE Cluster<br/>cloud-container-dr-cluster<br/>재해 복구"]
        SR2["Sample App Pods<br/>복원된 Pods"]
        SR3[Load Balancer<br/>DR Load Balancer]
        SR4["Persistent Volumes<br/>복원된 데이터"]
        SR5["Velero Restore<br/>자동 복원"]
    end
    
    subgraph "External VM - Monitoring"
        M1["Prometheus<br/>:9090<br/>메트릭 수집"]
        M2["Grafana<br/>:3000<br/>시각화"]
        M3["Alertmanager<br/>:9093<br/>알림 관리"]
        M4["ELK Stack<br/>로그 수집"]
        M5["Jaeger<br/>:16686<br/>분산 추적"]
    end
    
    subgraph "Backup & Recovery"
        BR1[Cloud Storage<br/>velero-backups]
        BR2[Cloud Storage<br/>velero-backups-secondary]
        BR3["Disaster Recovery<br/>자동 복구"]
        BR4["Monitoring<br/>백업 상태"]
    end
    
    GH1 -->> GH2
    GH2 -->> PR1
    
    PR1 -->> PR2
    PR2 -->> PR3
    PR2 -->> PR4
    PR4 -->> PR5
    PR5 -->> BR1
    BR1 -->> BR2
    BR2 -->> SR5
    SR5 -->> SR4
    SR4 -->> SR2
    SR2 -->> SR3
    
    M1 -->> PR2
    M2 -->> M1
    M3 -->> M1
    M4 -->> PR2
    M5 -->> PR2
    
    BR3 -->> PR1
    BR3 -->> SR1
    BR4 -->> BR1
    BR4 -->> BR2
```

**최종 적용된 기능:**
- ✅ **GitHub Actions CI/CD**: 코드 푸시 → 자동 빌드 → K8s 배포
- ✅ **Multi-AZ 클러스터**: 고가용성 아키텍처
- ✅ **외부 모니터링**: VM 기반 Prometheus/Grafana로 K8s 모니터링
- ✅ **로드밸런싱**: Ingress를 통한 트래픽 분산
- ✅ **자동 스케일링**: HPA + VPA + Cluster Autoscaler
- ✅ **보안 강화**: RBAC + Network Policies + Secrets
- ✅ **성능 최적화**: Resource Management + QoS + Node Affinity
- ✅ **재해 복구**: Velero 백업 + 다중 지역 복구

### 📊 예상 결과
- **성공률**: 95% ["자동화 스크립트 활용"]
- **소요 시간**: 7시간 ["자동화로 단축"]
- **주요 개선**: 통합 시나리오, 실시간 모니터링, 자동 스케일링, 보안 강화, 재해 복구

---

## 🎯 2일차 수업 성과

### ✅ 달성한 학습 목표
- [x] 고가용성 아키텍처 [Multi-AZ, Multi-Region]
- [x] 고급 모니터링 [Alerting, Logging, APM]
- [x] 보안 강화 [RBAC, Network Policies, Secrets]
- [x] 성능 최적화 [Resource Management, Tuning]
- [x] 재해 복구 [Backup, Disaster Recovery]

### 🔍 주요 학습 포인트
1. **고가용성**: Multi-AZ를 통한 장애 복구
2. **고급 모니터링**: Alerting + Logging + APM 통합
3. **보안**: RBAC + Network Policies + Secrets 관리
4. **성능 최적화**: Resource Management + QoS + VPA
5. **재해 복구**: Velero 백업 + 다중 지역 복구

### 🚀 실습 결과물
- **고가용성 클러스터**: Multi-AZ GKE 클러스터
- **통합 모니터링**: Prometheus + Grafana + ELK + Jaeger
- **보안 시스템**: RBAC + Network Policies + Secrets
- **성능 최적화**: HPA + VPA + Node Affinity
- **재해 복구**: Velero 백업 + 다중 지역 복구

---

## 📚 상세 실습 가이드

### 🔗 **분할 작성 버전 참조**
상세한 실습 내용과 단계별 가이드는 다음 문서들을 참조하세요:

#### **1교시: 고가용성 아키텍처**
- **상세 가이드**: `textbook/Day2/guides/01-high-availability.md`
- **자동화 스크립트**: `repo/scripts/day2-practice-improved.sh`
- **샘플 코드**: `repo/samples/day2/01-multi-az/`

#### **2교시: 고급 모니터링**
- **상세 가이드**: `textbook/Day2/guides/02-advanced-monitoring.md`
- **자동화 스크립트**: `repo/scripts/day2-practice-improved.sh`
- **샘플 코드**: `repo/samples/day2/02-monitoring/`

#### **3교시: 보안 강화**
- **상세 가이드**: `textbook/Day2/guides/03-security-enhancement.md`
- **자동화 스크립트**: `repo/scripts/day2-practice-improved.sh`
- **샘플 코드**: `repo/samples/day2/03-security/`

#### **4교시: 성능 최적화**
- **상세 가이드**: `textbook/Day2/guides/04-performance-optimization.md`
- **자동화 스크립트**: `repo/scripts/day2-practice-improved.sh`
- **샘플 코드**: `repo/samples/day2/04-performance/`

#### **5교시: 재해 복구**
- **상세 가이드**: `textbook/Day2/guides/05-disaster-recovery.md`
- **자동화 스크립트**: `repo/scripts/day2-practice-improved.sh`
- **샘플 코드**: `repo/samples/day2/05-backup/`

### 🛠️ **자동화 도구**
- **통합 환경 체크**: `repo/scripts/cloud-container-helper.sh`
- **성능 테스트**: `repo/scripts/day2-practice-improved.sh`
- **재해 복구 테스트**: `repo/scripts/day2-practice-improved.sh`

### 📋 **문제 해결 가이드**
- **일반적인 문제**: `textbook/Day2/troubleshooting/troubleshooting.md`
- **성능 문제**: `textbook/Day2/troubleshooting/performance-troubleshooting.md`
- **보안 문제**: `textbook/Day2/troubleshooting/security-troubleshooting.md`

---

**강의안 작성일**: 2024년 10월 2일  
**예상 소요 시간**: 7시간 ["9:00~17:00, 자동화로 단축"]  
**실습 중심**: 90% 실습, 10% 이론  
**자동화 활용**: 95% 자동화 스크립트 사용 권장  
**통합 시나리오**: 고가용성 → 모니터링 → 보안 → 성능 → 복구 완전 연계
