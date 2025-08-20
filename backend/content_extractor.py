# backend/content_extractor.py
import requests
from bs4 import BeautifulSoup
from typing import Optional, Dict, List
import re
import logging
import hashlib
import time
from urllib.parse import urlparse
import json

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ContentExtractor:
    def __init__(self, cache_duration: int = 3600):
        self.cache_duration = cache_duration
        self.content_cache = {}  # 간단한 메모리 캐시 (운영에서는 Redis 사용 권장)
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        })

    def _get_cache_key(self, url: str) -> str:
        """URL을 기반으로 캐시 키 생성"""
        return hashlib.md5(url.encode()).hexdigest()

    def _is_cached(self, url: str) -> bool:
        """캐시된 콘텐츠가 있는지 확인"""
        cache_key = self._get_cache_key(url)
        if cache_key in self.content_cache:
            cached_time, _ = self.content_cache[cache_key]
            return time.time() - cached_time < self.cache_duration
        return False

    def _get_cached_content(self, url: str) -> Optional[Dict]:
        """캐시된 콘텐츠 반환"""
        cache_key = self._get_cache_key(url)
        if self._is_cached(url):
            _, content = self.content_cache[cache_key]
            return content
        return None

    def _cache_content(self, url: str, content: Dict):
        """콘텐츠를 캐시에 저장"""
        cache_key = self._get_cache_key(url)
        self.content_cache[cache_key] = (time.time(), content)

    def _clean_text(self, text: str) -> str:
        """텍스트 정제"""
        # 여러 공백을 하나로
        text = re.sub(r'\s+', ' ', text)
        # 불필요한 문자 제거
        text = re.sub(r'[^\w\s\-.,!?;:()[\]{}"\']', '', text)
        # 줄바꿈 정리
        text = re.sub(r'\n\s*\n', '\n\n', text)
        return text.strip()

    def _extract_metadata(self, soup: BeautifulSoup, url: str) -> Dict:
        """웹페이지 메타데이터 추출"""
        metadata = {
            'title': '',
            'description': '',
            'keywords': '',
            'author': '',
            'published_date': '',
            'url': url
        }

        # 제목 추출
        title_tag = soup.find('title')
        if title_tag:
            metadata['title'] = title_tag.get_text().strip()

        # 메타 태그에서 정보 추출
        meta_tags = soup.find_all('meta')
        for meta in meta_tags:
            name = meta.get('name', '').lower()
            property_attr = meta.get('property', '').lower()
            content = meta.get('content', '')

            if name == 'description' or property_attr == 'og:description':
                metadata['description'] = content
            elif name == 'keywords':
                metadata['keywords'] = content
            elif name == 'author' or property_attr == 'article:author':
                metadata['author'] = content
            elif property_attr == 'article:published_time':
                metadata['published_date'] = content

        return metadata

    def _find_main_content(self, soup: BeautifulSoup) -> Optional[str]:
        """메인 콘텐츠 영역 찾기"""
        # 일반적인 메인 콘텐츠 선택자들
        selectors = [
            'main',
            'article',
            '[role="main"]',
            '.main-content',
            '.content',
            '#main-content',
            '#content',
            '.post-content',
            '.entry-content',
            '.article-content'
        ]

        for selector in selectors:
            element = soup.select_one(selector)
            if element:
                text = element.get_text(separator=' ', strip=True)
                if len(text) > 200:  # 최소 콘텐츠 길이 확인
                    return text

        # 선택자로 찾지 못한 경우 body 전체 사용
        body = soup.find('body')
        if body:
            return body.get_text(separator=' ', strip=True)

        return None

    def extract_content(self, url: str, extract_metadata: bool = True) -> Optional[Dict]:
        """
        URL에서 콘텐츠를 추출하고 정제합니다.
        
        Args:
            url: 추출할 URL
            extract_metadata: 메타데이터 추출 여부
            
        Returns:
            Dict with 'content', 'metadata', 'word_count', 'extraction_time'
        """
        logger.info(f"Extracting content from: {url}")

        # 캐시 확인
        cached_content = self._get_cached_content(url)
        if cached_content:
            logger.info(f"Returning cached content for: {url}")
            return cached_content

        try:
            # URL 유효성 검사
            parsed_url = urlparse(url)
            if not parsed_url.scheme or not parsed_url.netloc:
                logger.error(f"Invalid URL: {url}")
                return None

            # 웹페이지 가져오기
            response = self.session.get(url, timeout=15)
            response.raise_for_status()

            # 인코딩 확인
            if response.encoding == 'ISO-8859-1':
                response.encoding = response.apparent_encoding

            # BeautifulSoup으로 파싱
            soup = BeautifulSoup(response.text, 'html.parser')

            # 불필요한 요소 제거
            for element in soup(['script', 'style', 'nav', 'header', 'footer', 'aside', 'iframe']):
                element.decompose()

            # 메인 콘텐츠 찾기
            main_content = self._find_main_content(soup)
            if not main_content:
                logger.warning(f"No main content found for: {url}")
                return None

            # 텍스트 정제
            cleaned_content = self._clean_text(main_content)

            # 결과 구성
            result = {
                'content': cleaned_content,
                'word_count': len(cleaned_content.split()),
                'extraction_time': time.time(),
                'url': url
            }

            # 메타데이터 추출
            if extract_metadata:
                result['metadata'] = self._extract_metadata(soup, url)

            # 캐시에 저장
            self._cache_content(url, result)

            logger.info(f"Successfully extracted {result['word_count']} words from: {url}")
            return result

        except requests.exceptions.RequestException as e:
            logger.error(f"Request error for {url}: {e}")
            return None
        except Exception as e:
            logger.error(f"Error extracting content from {url}: {e}")
            return None

    def extract_multiple_urls(self, urls: List[str], max_concurrent: int = 5) -> Dict[str, Optional[Dict]]:
        """
        여러 URL에서 동시에 콘텐츠를 추출합니다.
        
        Args:
            urls: 추출할 URL 목록
            max_concurrent: 최대 동시 요청 수
            
        Returns:
            URL을 키로 하는 결과 딕셔너리
        """
        import concurrent.futures
        
        results = {}
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=max_concurrent) as executor:
            future_to_url = {executor.submit(self.extract_content, url): url for url in urls}
            
            for future in concurrent.futures.as_completed(future_to_url):
                url = future_to_url[future]
                try:
                    result = future.result()
                    results[url] = result
                except Exception as e:
                    logger.error(f"Error extracting from {url}: {e}")
                    results[url] = None

        return results

    def get_extraction_stats(self) -> Dict:
        """추출 통계 반환"""
        total_cached = len(self.content_cache)
        total_words = sum(
            content.get('word_count', 0) 
            for _, content in self.content_cache.values()
        )
        
        return {
            'cached_urls': total_cached,
            'total_words': total_words,
            'cache_size_mb': len(json.dumps(self.content_cache)) / (1024 * 1024)
        }

# Instantiate the service
content_extractor_instance = ContentExtractor()
