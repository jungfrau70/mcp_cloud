# backend/external_search_service.py
import os
import time
import logging
from typing import List, Dict, Optional
from urllib.parse import urlparse, quote_plus
import requests
from bs4 import BeautifulSoup
import xml.etree.ElementTree as ET

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

    # ---------------------------- Fallback searchers ---------------------------- #
    def _fallback_web_search(self, query: str, num_results: int) -> List[Dict]:
        """API 클라이언트가 없을 때 사용할 경량 웹 검색 폴백.
        우선 DuckDuckGo, 실패 시 Bing HTML 결과를 파싱합니다.
        외부 의존성 없이 requests + BeautifulSoup만 사용합니다.
        """
        results: List[Dict] = []
        q = quote_plus(query)
        # Try DuckDuckGo
        try:
            resp = requests.get(f"https://duckduckgo.com/html/?q={q}", timeout=8)
            if resp.ok:
                soup = BeautifulSoup(resp.text, 'html.parser')
                for a in soup.select('a.result__a'):
                    title = a.get_text(strip=True)
                    href = a.get('href', '')
                    if title and href:
                        results.append({
                            "title": title,
                            "link": href,
                            "snippet": "",
                            "source": "duckduckgo",
                            "date": ""
                        })
                        if len(results) >= num_results * 3:
                            break
        except Exception as e:
            logger.debug(f"DuckDuckGo fallback failed: {e}")

        # Fallback: Bing
        if not results:
            try:
                resp = requests.get(f"https://www.bing.com/search?q={q}", timeout=8)
                if resp.ok:
                    soup = BeautifulSoup(resp.text, 'html.parser')
                    for h2 in soup.select('li.b_algo h2'):
                        a = h2.find('a')
                        if not a:
                            continue
                        title = a.get_text(strip=True)
                        href = a.get('href', '')
                        if title and href:
                            # Try to capture a nearby snippet
                            snippet_el = h2.find_parent().select_one('p') if h2.find_parent() else None
                            snippet = snippet_el.get_text(strip=True) if snippet_el else ""
                            results.append({
                                "title": title,
                                "link": href,
                                "snippet": snippet,
                                "source": "bing",
                                "date": ""
                            })
                            if len(results) >= num_results * 3:
                                break
            except Exception as e:
                logger.debug(f"Bing fallback failed: {e}")

        return results

    def _fallback_news_search(self, query: str, num_results: int) -> List[Dict]:
        """Google News RSS 기반 뉴스 검색 폴백."""
        results: List[Dict] = []
        q = quote_plus(query)
        try:
            url = f"https://news.google.com/rss/search?q={q}&hl=ko&gl=KR&ceid=KR:ko"
            resp = requests.get(url, timeout=8)
            if not resp.ok:
                return results
            root = ET.fromstring(resp.content)
            # items
            for item in root.findall('.//item'):
                title = (item.findtext('title') or '').strip()
                link = (item.findtext('link') or '').strip()
                pub_date = (item.findtext('pubDate') or '').strip()
                if title and link:
                    results.append({
                        "title": title,
                        "link": link,
                        "snippet": "",
                        "source": "google_news",
                        "date": pub_date
                    })
                if len(results) >= num_results * 3:
                    break
        except Exception as e:
            logger.debug(f"News RSS fallback failed: {e}")
        return results

    def _fallback_docs_search(self, query: str, num_results: int) -> List[Dict]:
        """공식 문서 위주 사이트로 쿼리를 보강하여 일반 웹 검색 폴백."""
        docs_query = (
            f"({query}) site:docs.aws.amazon.com OR site:cloud.google.com OR "
            f"site:developer.hashicorp.com OR site:registry.terraform.io"
        )
        return self._fallback_web_search(docs_query, num_results)

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
            # 폴백 검색 수행 (API 키 없이 동작)
            try:
                if search_type == "news":
                    raw_results = self._fallback_news_search(query, num_results)
                elif search_type == "docs":
                    raw_results = self._fallback_docs_search(query, num_results)
                else:
                    raw_results = self._fallback_web_search(query, num_results)
                # 폴백 결과 필터링 및 슬라이싱
                filtered = self._filter_search_results(raw_results)
                return filtered[:num_results]
            except Exception as e:
                logger.error(f"Fallback search failed: {e}")
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
