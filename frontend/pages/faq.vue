<template>
  <div class="h-full overflow-y-auto bg-gray-50">
    <div class="py-8">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- 헤더 -->
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-4">자주 묻는 질문 (FAQ)</h1>
        <p class="text-lg text-gray-600">GoldenCircle 플랫폼 사용 중 궁금한 점들을 해결해보세요.</p>
      </div>

      <!-- FAQ 섹션들 -->
      <div class="space-y-8">
        <!-- 계정 관련 FAQ -->
        <div class="bg-white rounded-lg shadow-md p-6">
          <h2 class="text-xl font-semibold text-gray-900 mb-4 flex items-center">
            <span class="text-2xl mr-2">👤</span>
            계정 관련
          </h2>
          <div class="space-y-4">
            <div class="border-l-4 border-blue-500 pl-4">
              <h3 class="font-semibold text-gray-800 mb-2">Q. 회원가입 후 이메일 인증이 안 됩니다.</h3>
              <div class="text-gray-600 space-y-2">
                <p><strong>A. 다음 사항을 확인해주세요:</strong></p>
                <ul class="list-disc list-inside space-y-1 ml-4">
                  <li><strong>스팸 폴더 확인:</strong> 이메일 인증 메일이 스팸 폴더로 분류될 수 있습니다.</li>
                  <li><strong>이메일 주소 확인:</strong> 회원가입 시 입력한 이메일 주소가 정확한지 확인해주세요.</li>
                  <li><strong>메일 서비스 확인:</strong> Gmail, Naver, Daum 등 사용 중인 메일 서비스의 전체 폴더를 확인해주세요.</li>
                  <li><strong>재발송:</strong> 로그인 페이지에서 "인증 메일 재발송" 버튼을 클릭해보세요.</li>
                </ul>
                <div class="bg-yellow-50 border border-yellow-200 rounded-md p-3 mt-3">
                  <p class="text-sm text-yellow-800">
                    <strong>💡 팁:</strong> 이메일 인증이 완료되어야 로그인할 수 있습니다. 
                    스팸 폴더를 꼭 확인해주세요!
                  </p>
                </div>
              </div>
            </div>

            <div class="border-l-4 border-green-500 pl-4">
              <h3 class="font-semibold text-gray-800 mb-2">Q. 비밀번호를 잊어버렸습니다.</h3>
              <div class="text-gray-600">
                <p><strong>A. 비밀번호 재설정 기능을 이용해주세요:</strong></p>
                <ol class="list-decimal list-inside space-y-1 ml-4 mt-2">
                  <li>로그인 페이지에서 "비밀번호 찾기" 클릭</li>
                  <li>가입한 이메일 주소 입력</li>
                  <li>이메일로 전송된 재설정 링크 클릭</li>
                  <li>새 비밀번호 설정</li>
                </ol>
              </div>
            </div>
          </div>
        </div>

        <!-- AI 채팅 관련 FAQ -->
        <div class="bg-white rounded-lg shadow-md p-6">
          <h2 class="text-xl font-semibold text-gray-900 mb-4 flex items-center">
            <span class="text-2xl mr-2">🤖</span>
            AI 채팅 기능
          </h2>
          <div class="space-y-4">
            <div class="border-l-4 border-purple-500 pl-4">
              <h3 class="font-semibold text-gray-800 mb-2">Q. AI 채팅 기능을 사용하려면 어떻게 해야 하나요?</h3>
              <div class="text-gray-600 space-y-2">
                <p><strong>A. Gemini API 키 설정이 필요합니다:</strong></p>
                <ol class="list-decimal list-inside space-y-1 ml-4">
                  <li><strong>Google AI Studio 방문:</strong> <a href="https://makersuite.google.com/app/apikey" target="_blank" class="text-blue-600 hover:text-blue-800 underline">https://makersuite.google.com/app/apikey</a></li>
                  <li><strong>Google 계정으로 로그인</strong></li>
                  <li><strong>API 키 생성:</strong> "Create API Key" 버튼 클릭</li>
                  <li><strong>API 키 복사:</strong> 생성된 API 키를 복사 (AIzaSy...로 시작)</li>
                  <li><strong>프로필에 저장:</strong> GoldenCircle 프로필 페이지에서 "Gemini API 키 설정" 섹션에 입력</li>
                  <li><strong>저장:</strong> "저장" 버튼 클릭</li>
                </ol>
                <div class="bg-blue-50 border border-blue-200 rounded-md p-3 mt-3">
                  <p class="text-sm text-blue-800">
                    <strong>💡 중요:</strong> API 키는 유효성 검사를 통과한 것만 저장됩니다. 
                    잘못된 형식의 키는 저장되지 않습니다.
                  </p>
                </div>
              </div>
            </div>

            <div class="border-l-4 border-orange-500 pl-4">
              <h3 class="font-semibold text-gray-800 mb-2">Q. API 키를 입력했는데도 채팅이 안 됩니다.</h3>
              <div class="text-gray-600 space-y-2">
                <p><strong>A. 다음 사항을 확인해주세요:</strong></p>
                <ul class="list-disc list-inside space-y-1 ml-4">
                  <li><strong>API 키 형식:</strong> "AIzaSy"로 시작하는지 확인</li>
                  <li><strong>API 키 길이:</strong> 최소 20자 이상인지 확인</li>
                  <li><strong>저장 완료:</strong> 프로필에서 "저장" 버튼을 클릭했는지 확인</li>
                  <li><strong>페이지 새로고침:</strong> 저장 후 페이지를 새로고침해보세요</li>
                  <li><strong>Google 계정 상태:</strong> Google AI Studio에서 API 키가 활성화되어 있는지 확인</li>
                </ul>
                <div class="bg-red-50 border border-red-200 rounded-md p-3 mt-3">
                  <p class="text-sm text-red-800">
                    <strong>⚠️ 주의:</strong> API 키는 개인정보이므로 다른 사람과 공유하지 마세요.
                  </p>
                </div>
              </div>
            </div>

            <div class="border-l-4 border-indigo-500 pl-4">
              <h3 class="font-semibold text-gray-800 mb-2">Q. API 키는 무료인가요?</h3>
              <div class="text-gray-600">
                <p><strong>A. 네, Google Gemini API는 무료로 제공됩니다:</strong></p>
                <ul class="list-disc list-inside space-y-1 ml-4 mt-2">
                  <li><strong>무료 할당량:</strong> 월 1,500회 요청까지 무료</li>
                  <li><strong>개인 사용:</strong> 개인 학습 및 실습용으로는 충분합니다</li>
                  <li><strong>추가 요금:</strong> 무료 할당량 초과 시에만 요금 발생</li>
                  <li><strong>사용량 확인:</strong> Google AI Studio에서 사용량을 확인할 수 있습니다</li>
                </ul>
              </div>
            </div>
          </div>
        </div>

        <!-- 플랫폼 사용 관련 FAQ -->
        <div class="bg-white rounded-lg shadow-md p-6">
          <h2 class="text-xl font-semibold text-gray-900 mb-4 flex items-center">
            <span class="text-2xl mr-2">📚</span>
            플랫폼 사용법
          </h2>
          <div class="space-y-4">
            <div class="border-l-4 border-teal-500 pl-4">
              <h3 class="font-semibold text-gray-800 mb-2">Q. 커리큘럼과 지식베이스의 차이점은 무엇인가요?</h3>
              <div class="text-gray-600 space-y-2">
                <p><strong>A. 다음과 같이 구분됩니다:</strong></p>
                <div class="grid md:grid-cols-2 gap-4 mt-2">
                  <div class="bg-blue-50 p-3 rounded-md">
                    <h4 class="font-semibold text-blue-800 mb-2">📖 커리큘럼</h4>
                    <ul class="text-sm text-blue-700 space-y-1">
                      <li>• 모든 사용자가 접근 가능</li>
                      <li>• 체계적인 학습 과정</li>
                      <li>• 실습 가이드 포함</li>
                      <li>• 읽기 전용</li>
                    </ul>
                  </div>
                  <div class="bg-green-50 p-3 rounded-md">
                    <h4 class="font-semibold text-green-800 mb-2">📝 지식베이스</h4>
                    <ul class="text-sm text-green-700 space-y-1">
                      <li>• 관리자만 접근 가능</li>
                      <li>• 교육 자료 관리</li>
                      <li>• 편집 및 수정 가능</li>
                      <li>• 실시간 협업</li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>

            <div class="border-l-4 border-cyan-500 pl-4">
              <h3 class="font-semibold text-gray-800 mb-2">Q. 학습 진도를 확인할 수 있나요?</h3>
              <div class="text-gray-600">
                <p><strong>A. 네, 학습 진도를 추적할 수 있습니다:</strong></p>
                <ul class="list-disc list-inside space-y-1 ml-4 mt-2">
                  <li><strong>진도 표시:</strong> 각 학습 자료에서 완료 상태 확인</li>
                  <li><strong>진도 저장:</strong> 자동으로 브라우저에 저장</li>
                  <li><strong>이어서 학습:</strong> 다음 방문 시 이전 진도에서 계속</li>
                  <li><strong>진도 초기화:</strong> 필요시 프로필에서 초기화 가능</li>
                </ul>
              </div>
            </div>
          </div>
        </div>

        <!-- 기술 지원 FAQ -->
        <div class="bg-white rounded-lg shadow-md p-6">
          <h2 class="text-xl font-semibold text-gray-900 mb-4 flex items-center">
            <span class="text-2xl mr-2">🔧</span>
            기술 지원
          </h2>
          <div class="space-y-4">
            <div class="border-l-4 border-red-500 pl-4">
              <h3 class="font-semibold text-gray-800 mb-2">Q. 페이지가 제대로 로드되지 않습니다.</h3>
              <div class="text-gray-600 space-y-2">
                <p><strong>A. 다음 방법을 시도해보세요:</strong></p>
                <ol class="list-decimal list-inside space-y-1 ml-4">
                  <li><strong>브라우저 새로고침:</strong> F5 키 또는 Ctrl+R (Cmd+R)</li>
                  <li><strong>캐시 삭제:</strong> Ctrl+Shift+R (Cmd+Shift+R)로 강제 새로고침</li>
                  <li><strong>브라우저 확인:</strong> Chrome, Firefox, Safari, Edge 최신 버전 사용</li>
                  <li><strong>인터넷 연결:</strong> 안정적인 인터넷 연결 확인</li>
                  <li><strong>다른 브라우저:</strong> 다른 브라우저로 시도</li>
                </ol>
              </div>
            </div>

            <div class="border-l-4 border-gray-500 pl-4">
              <h3 class="font-semibold text-gray-800 mb-2">Q. 추가 도움이 필요합니다.</h3>
              <div class="text-gray-600">
                <p><strong>A. 다음 방법으로 문의해주세요:</strong></p>
                <ul class="list-disc list-inside space-y-1 ml-4 mt-2">
                  <li><strong>이메일:</strong> support@goldencircle.us</li>
                  <li><strong>문의 내용:</strong> 문제 상황, 사용 환경, 오류 메시지 포함</li>
                  <li><strong>응답 시간:</strong> 영업일 기준 1-2일 내 답변</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 하단 안내 -->
      <div class="mt-12 text-center">
        <div class="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-2">더 궁금한 점이 있으신가요?</h3>
          <p class="text-gray-600 mb-4">FAQ에서 답을 찾지 못하셨다면 언제든 문의해주세요.</p>
          <div class="flex justify-center space-x-4">
            <a href="mailto:support@goldencircle.us" class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors">
              이메일 문의
            </a>
            <NuxtLink to="/curriculum" class="px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 transition-colors">
              학습 시작하기
            </NuxtLink>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
</template>

<script setup>
// SEO 메타데이터
useHead({
  title: 'FAQ - 자주 묻는 질문 | GoldenCircle',
  meta: [
    { name: 'description', content: 'GoldenCircle 플랫폼 사용 중 궁금한 점들을 해결해보세요. 계정, AI 채팅, 플랫폼 사용법 등 다양한 FAQ를 제공합니다.' },
    { name: 'keywords', content: 'FAQ, 자주묻는질문, GoldenCircle, 이메일인증, API키, AI채팅, 학습진도' }
  ]
})
</script>

<style scoped>
/* 추가 스타일링이 필요한 경우 여기에 작성 */
</style>
