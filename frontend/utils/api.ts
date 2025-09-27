// API 유틸리티 함수들
interface DeleteResponse {
  success: boolean;
  message: string;
  path: string;
  error?: string;
}

/**
 * 파일 삭제 API 호출
 */
export const deleteFile = async (path: string): Promise<DeleteResponse> => {
  try {
    const response = await fetch(`/api/v1/knowledge/item?path=${encodeURIComponent(path)}`, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': getApiKey()
      }
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data: DeleteResponse = await response.json();
    return data;
    
  } catch (error) {
    console.error('파일 삭제 API 호출 실패:', error);
    return {
      success: false,
      message: '서버와의 통신 중 오류가 발생했습니다.',
      path: path,
      error: 'NETWORK_ERROR'
    };
  }
};

/**
 * API 키 가져오기
 */
const getApiKey = (): string => {
  // 환경 변수나 설정에서 API 키 가져오기
  if (typeof window !== 'undefined') {
    return (window as any).NUXT_PUBLIC_API_KEY || 'my_mcp_eagle_tiger';
  }
  return 'my_mcp_eagle_tiger';
};

/**
 * 메시지 표시 함수 (전역 이벤트)
 */
export const showMessage = (message: string, type: 'success' | 'error' | 'info' = 'info') => {
  // 전역 이벤트 발생
  window.dispatchEvent(new CustomEvent('show-message', {
    detail: { message, type }
  }));
};

/**
 * 파일 목록 새로고침 이벤트
 */
export const refreshFileList = () => {
  window.dispatchEvent(new CustomEvent('refresh-file-list'));
};
