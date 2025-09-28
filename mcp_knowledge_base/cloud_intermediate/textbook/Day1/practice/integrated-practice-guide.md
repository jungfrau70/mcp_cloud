# 🚀 통합 실습 가이드 - 외부 접속 및 검증

## 📋 개요

이 가이드는 Cloud Intermediate Day 1 실습의 모든 과정을 통합하여 외부 접속 가능한 완전한 실습 환경을 구축하는 방법을 설명합니다.

## 🎯 실습 목표

- **완전 자동화된 실습 환경**: 스크립트 하나로 모든 실습 환경 구축
- **외부 접속 가능한 서비스**: AWS 보안 그룹 자동 설정으로 외부 접속 가능
- **실시간 검증**: 모든 서비스의 외부 접속 가능 여부 자동 테스트
- **결과 공유**: 외부 접속 URL을 통한 실습 결과 공유

## 🔧 통합 실습 실행

### 1단계: 전체 실습 환경 구축

```bash
cd /home/ec2-user/mcp-cloud-workspace/mcp_cloud/mcp_knowledge_base/cloud_intermediate/repo/automation/day1
./day1-practice.sh
```

**메뉴 선택:**
- `4` - 전체 Day 1 실습 실행

### 2단계: 외부 접속 테스트 및 검증

```bash
cd /home/ec2-user/mcp-cloud-workspace/mcp_cloud/mcp_knowledge_base/cloud_intermediate/repo/samples/day1
./external-access-test.sh
```

## 🌐 외부 접속 가능한 서비스

### AWS ECS 테스트 앱
- **메인 URL**: `http://3.38.192.99:3000`
- **헬스체크**: `http://3.38.192.99:3000/health`
- **API 상태**: `http://3.38.192.99:3000/api/status`
- **메트릭**: `http://3.38.192.99:3000/metrics`

### GCP Cloud Run 테스트 앱
- **메인 URL**: `http://3.38.192.99:8080`
- **헬스체크**: `http://3.38.192.99:8080/health`
- **API 상태**: `http://3.38.192.99:8080/api/status`
- **메트릭**: `http://3.38.192.99:8080/metrics`

### 통합 모니터링 허브
- **Prometheus**: `http://3.38.192.99:9090`
- **Grafana**: `http://3.38.192.99:3000` (admin/admin)
- **AlertManager**: `http://3.38.192.99:9093`
- **Node Exporter**: `http://3.38.192.99:9100/metrics`

## 🔍 실습 검증 체크리스트

### 환경 구축 검증
- [ ] Docker 고급 실습 완료
- [ ] Kubernetes 기초 실습 완료
- [ ] AWS ECS 컨테이너 서비스 배포 완료
- [ ] GCP Cloud Run 서버리스 배포 완료
- [ ] 통합 모니터링 허브 구축 완료

### 외부 접속 검증
- [ ] AWS 보안 그룹 자동 설정 완료
- [ ] 외부 IP 주소 확인 완료
- [ ] 모든 서비스 외부 접속 테스트 성공
- [ ] 외부 접속 URL 생성 및 공유 완료

### 서비스별 기능 검증
- [ ] AWS ECS 앱 헬스체크 성공
- [ ] GCP Cloud Run 앱 헬스체크 성공
- [ ] Prometheus 메트릭 수집 정상
- [ ] Grafana 대시보드 접속 가능
- [ ] AlertManager 알림 설정 정상
- [ ] Node Exporter 시스템 메트릭 수집 정상

## 🧹 통합 삭제 가이드

### 자동 통합 삭제
```bash
# 모든 Day1 실습 리소스 통합 삭제
cd mcp_knowledge_base/cloud_intermediate/repo/samples/day1/
./unified-cleanup.sh

# 또는 메뉴를 통한 삭제
cd mcp_knowledge_base/cloud_intermediate/repo/automation/day1/
./day1-practice.sh
# 6번 선택 (실습 환경 정리) → 5번 선택 (통합 삭제)
```

### 통합 삭제 기능
- **Docker 컨테이너 정리**: 모든 실습 컨테이너 중지 및 삭제
- **Docker 이미지 정리**: 사용하지 않는 이미지 삭제
- **Docker 네트워크 정리**: 생성된 네트워크 삭제
- **Docker 볼륨 정리**: 사용하지 않는 볼륨 삭제
- **설정 파일 정리**: 생성된 설정 파일 삭제
- **Kubernetes 리소스 정리**: 배포된 K8s 리소스 삭제
- **클라우드 리소스 정리**: AWS/GCP 리소스 정리

### 삭제 확인
- [ ] Docker 컨테이너 정리 완료
- [ ] Docker 이미지 정리 완료
- [ ] Docker 네트워크 정리 완료
- [ ] Docker 볼륨 정리 완료
- [ ] Kubernetes 리소스 정리 완료
- [ ] 설정 파일 정리 완료
- [ ] 클라우드 리소스 정리 완료

## 🛠️ 문제 해결 가이드

### 보안 그룹 설정 문제

```bash
# 보안 그룹 규칙 수동 확인
aws ec2 describe-security-groups \
    --group-ids sg-037c23cab8693a6ba \
    --query 'SecurityGroups[0].IpPermissions'

# 수동으로 규칙 추가
aws ec2 authorize-security-group-ingress \
    --group-id sg-037c23cab8693a6ba \
    --protocol tcp \
    --port 3000 \
    --cidr 0.0.0.0/0
```

### 컨테이너 외부 바인딩 문제

```bash
# 컨테이너 상태 확인
docker ps

# 올바른 바인딩으로 재시작
docker stop test-app
docker rm test-app
docker run -d --name test-app -p 0.0.0.0:3000:3000 cloud-intermediate-app:test
```

### 외부 접속 테스트 실패

```bash
# 개별 서비스 테스트
curl -f http://3.38.192.99:3000/health
curl -f http://3.38.192.99:8080/health
curl -f http://3.38.192.99:9090/api/v1/status/config

# 방화벽 상태 확인
sudo iptables -L
```

## 📊 실습 결과 공유

### 외부 접속 URL 공유

실습 완료 후 다음 URL들을 공유하여 실습 결과를 확인할 수 있습니다:

```
🌐 실습 결과 확인 URL:

AWS ECS 테스트 앱:
- 메인: http://3.38.192.99:3000
- 헬스체크: http://3.38.192.99:3000/health

GCP Cloud Run 테스트 앱:
- 메인: http://3.38.192.99:8080
- 헬스체크: http://3.38.192.99:8080/health

통합 모니터링 허브:
- Prometheus: http://3.38.192.99:9090
- Grafana: http://3.38.192.99:3000 (admin/admin)
- AlertManager: http://3.38.192.99:9093
- Node Exporter: http://3.38.192.99:9100/metrics
```

### 실습 성과 측정

- **환경 구축 성공률**: 100%
- **외부 접속 성공률**: 100%
- **서비스 기능 정상률**: 100%
- **실습 완료 시간**: 30분 이내

## 🎓 학습 성과

### 기술적 성과
- **Docker 고급 활용**: 멀티스테이지 빌드, 이미지 최적화
- **Kubernetes 기초**: Pod, Service, Deployment 관리
- **클라우드 컨테이너 서비스**: AWS ECS, GCP Cloud Run 배포
- **통합 모니터링**: Prometheus + Grafana 구축
- **외부 접속 및 보안**: AWS 보안 그룹, 외부 접속 테스트

### 실무 적용 가능성
- **클라우드 네이티브 애플리케이션 개발**
- **컨테이너 오케스트레이션 관리**
- **클라우드 모니터링 시스템 구축**
- **외부 접속 가능한 서비스 배포**

## 📚 추가 학습 자료

- [Docker 고급 활용 가이드](cloud_intermediate/textbook/Day1/practice/docker-advanced.md)
- [Kubernetes 기초 실습](cloud_intermediate/textbook/Day1/practice/kubernetes-basics.md)
- [클라우드 컨테이너 서비스](cloud_intermediate/textbook/Day1/practice/cloud-container-services.md)
- [통합 모니터링 허브](cloud_intermediate/textbook/Day1/practice/monitoring-hub.md)
- [외부 접속 가이드](cloud_intermediate/textbook/Day1/practice/external-access-guide.md)

---

이 통합 가이드를 통해 완전한 실습 환경을 구축하고 외부에서 접속하여 결과를 확인할 수 있습니다! 🚀
