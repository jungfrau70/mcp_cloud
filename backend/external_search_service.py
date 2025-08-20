# backend/external_search_service.py
import os
import time
import logging
from typing import List, Dict, Optional
from urllib.parse import urlparse

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ExternalSearchService:
    def __init__(self, api_client=None, max_retries=3, retry_delay=1):
        self.api_client = api_client
        self.max_retries = max_retries
        self.retry_delay = retry_delay
        
        if self.api_client is None:
            try:
                import default_api as _default_api
                self.api_client = _default_api
            except ImportError:
                logger.warning("default_api not found. External search will not function.")
                self.api_client = None

    def _is_valid_url(self, url: str) -> bool:
        """URL 유효성 검사"""
        try:
            result = urlparse(url)
            return all([result.scheme, result.netloc])
        except Exception:
            return False

    def _filter_search_results(self, results: List[Dict], min_title_length: int = 10) -> List[Dict]:
        """검색 결과 필터링 (스팸, 광고 등 제거)"""
        filtered_results = []
        
        for result in results:
            title = result.get('title', '')
            link = result.get('link', '')
            
            # 기본 필터링 조건
            if (len(title) < min_title_length or 
                not self._is_valid_url(link) or
                any(spam_word in title.lower() for spam_word in ['광고', 'spam', 'click', 'buy now'])):
                continue
                
            filtered_results.append(result)
            
        return filtered_results

    def search(self, query: str, num_results: int = 5, search_type: str = "web") -> List[Dict]:
        """
        웹 검색을 수행하고 검색 결과 목록을 반환합니다.
        
        Args:
            query: 검색 쿼리
            num_results: 반환할 결과 수
            search_type: 검색 타입 ("web", "news", "docs")
        """
        logger.info(f"Performing {search_type} search for: {query}")
        
        if self.api_client is None:
            logger.error("API client not available for search.")
            return []

        # 재시도 로직
        for attempt in range(self.max_retries):
            try:
                # 검색 타입에 따른 API 호출
                if search_type == "news":
                    search_response = self.api_client.google_news_search(query=query)
                elif search_type == "docs":
                    search_response = self.api_client.google_docs_search(query=query)
                else:
                    search_response = self.api_client.google_web_search(query=query)
                
                if not search_response or "search_results" not in search_response:
                    logger.warning(f"Empty or invalid search response on attempt {attempt + 1}")
                    if attempt < self.max_retries - 1:
                        time.sleep(self.retry_delay * (attempt + 1))
                        continue
                    return []

                # 결과 처리 및 필터링
                results = []
                for i, item in enumerate(search_response["search_results"]):
                    if i >= num_results * 2:  # 필터링을 위해 더 많은 결과 수집
                        break
                    results.append({
                        "title": item.get("title", "No Title"),
                        "link": item.get("link", "#"),
                        "snippet": item.get("snippet", "No snippet available."),
                        "source": item.get("source", "Unknown"),
                        "date": item.get("date", "")
                    })
                
                # 결과 필터링
                filtered_results = self._filter_search_results(results)
                
                # 요청된 수만큼 반환
                return filtered_results[:num_results]
                
            except Exception as e:
                logger.error(f"Search attempt {attempt + 1} failed: {e}")
                if attempt < self.max_retries - 1:
                    time.sleep(self.retry_delay * (attempt + 1))
                else:
                    logger.error(f"All search attempts failed for query: {query}")
                    return []

    def search_multiple_sources(self, query: str, sources: List[str] = None) -> Dict[str, List[Dict]]:
        """
        여러 소스에서 검색을 수행합니다.
        
        Args:
            query: 검색 쿼리
            sources: 검색할 소스 목록 ["web", "news", "docs"]
        """
        if sources is None:
            sources = ["web", "news"]
            
        results = {}
        for source in sources:
            try:
                results[source] = self.search(query, num_results=3, search_type=source)
            except Exception as e:
                logger.error(f"Failed to search {source}: {e}")
                results[source] = []
                
        return results

# Instantiate the service
external_search_service_instance = ExternalSearchService()
