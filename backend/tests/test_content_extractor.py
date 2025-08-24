import pytest
from unittest.mock import Mock, patch
from content_extractor import ContentExtractor
import requests # Import requests to catch its exceptions
from bs4 import BeautifulSoup
import time

# Mock response for requests.get
class MockResponse:
    def __init__(self, text, status_code=200, content=None, encoding='utf-8'):
        self.text = text
        self.status_code = status_code
        self.content = content if content is not None else text.encode(encoding)
        self.encoding = encoding
        self.apparent_encoding = encoding

    def raise_for_status(self):
        if self.status_code >= 400:
            raise requests.exceptions.HTTPError(f"HTTP Error: {self.status_code}")

@pytest.fixture
def extractor_instance():
    """Provides a ContentExtractor instance for tests."""
    return ContentExtractor(return_dict=True)

# Function-level tests for private methods

def test_clean_text(extractor_instance):
    """Tests the _clean_text private method."""
    assert extractor_instance._clean_text("  hello   world  ") == "hello world"
    assert extractor_instance._clean_text("\n\nhello\nworld\n") == "hello world"
    assert extractor_instance._clean_text("test\r\nline") == "test line"


def test_extract_metadata():
    """Tests the _extract_metadata private method."""
    html = """
    <html>
        <head>
            <title>Test Title</title>
            <meta name=\"description\" content=\"Test Description.\">
            <meta name=\"keywords\" content=\"test, keyword">
            <meta property=\"article:published_time\" content=\"2025-08-24T00:00:00Z">
        </head>
        <body></body>
    </html>
    """
    soup = BeautifulSoup(html, 'html.parser')
    extractor = ContentExtractor()
    metadata = extractor._extract_metadata(soup, "http://example.com")
    assert metadata['title'] == "Test Title"
    assert metadata['description'] == "Test Description."
    assert metadata['keywords'] == "test, keyword"
    assert metadata['published_date'] == "2025-08-24T00:00:00Z"
    assert metadata['url'] == "http://example.com"


def test_find_main_content():
    """Tests the _find_main_content private method with various structures."""
    extractor = ContentExtractor()
    # Test with <main> tag
    soup_main = BeautifulSoup("<body><main>Main content</main><footer>Footer</footer></body>", 'html.parser')
    assert extractor._find_main_content(soup_main) == "Main content"

    # Test with <article> tag
    soup_article = BeautifulSoup("<body><article>Article content</article></body>", 'html.parser')
    assert extractor._find_main_content(soup_article) == "Article content"

    # Test with a class selector
    soup_class = BeautifulSoup('<body><div class="main-content">Class content</div></body>', 'html.parser')
    assert extractor._find_main_content(soup_class) == "Class content"

    # Test fallback to body
    soup_body = BeautifulSoup("<body>Just body content</body>", 'html.parser')
    assert extractor._find_main_content(soup_body) == "Just body content"

# Tests for public methods

@patch('requests.get')
def test_extract_content_with_dict_return(mock_get, extractor_instance):
    """Tests that extract_content returns a dictionary when configured."""
    html = "<html><head><title>A Title</title></head><body>Some content.</body></html>"
    mock_get.return_value = MockResponse(html)
    url = "http://example.com/dict-return"
    
    result = extractor_instance.extract_content(url)
    
    assert isinstance(result, dict)
    assert result['content'] == "Some content."
    assert result['metadata']['title'] == "A Title"
    assert result['word_count'] == 2
    assert 'extraction_time' in result

@patch('requests.get')
def test_caching_mechanism(mock_get, extractor_instance):
    """Tests that content is cached and subsequent calls do not trigger a new request."""
    mock_get.return_value = MockResponse("<html><body>Cached content</body></html>")
    url = "http://example.com/cached"

    # First call - should trigger fetch
    extractor_instance.extract_content(url)
    mock_get.assert_called_once_with(url, timeout=10)

    # Second call - should use cache
    extractor_instance.extract_content(url)
    mock_get.assert_called_once() # Should still be called only once

@patch('requests.get')
def test_extract_multiple_urls(mock_get, extractor_instance):
    """Tests concurrent extraction from multiple URLs."""
    urls = {
        "http://example.com/1": "Content 1",
        "http://example.com/2": "Content 2",
        "http://example.com/error": "Error page"
    }

    def side_effect(url, timeout):
        if url == "http://example.com/error":
            return MockResponse("Error", status_code=500)
        return MockResponse(f"<html><body>{urls[url]}</body></html>")

    mock_get.side_effect = side_effect
    
    results = extractor_instance.extract_multiple_urls(list(urls.keys()))

    assert len(results) == 3
    assert results["http://example.com/1"]['content'] == "Content 1"
    assert results["http://example.com/2"]['content'] == "Content 2"
    assert results["http://example.com/error"] is None

def test_get_extraction_stats(extractor_instance):
    """Tests the statistics calculation."""
    # Manually populate cache for test predictability
    cache_content = {
        'content': 'word1 word2',
        'word_count': 2
    }
    extractor_instance._cache_content("http://example.com/stats", cache_content)

    stats = extractor_instance.get_extraction_stats()
    assert stats['cached_urls'] == 1
    assert stats['total_words'] == 2


# Keep existing tests as well

@pytest.fixture
def content_extractor():
    return ContentExtractor()

@patch('requests.get')
def test_extract_content_basic_html(mock_get, content_extractor):
    """
    Tests content extraction from basic HTML.
    """
    mock_get.return_value = MockResponse("<html><body><h1>Title</h1><p>Some text here.</p></body></html>")
    url = "http://example.com/basic"
    content = content_extractor.extract_content(url)
    assert content == "Title Some text here."
    mock_get.assert_called_once_with(url, timeout=10)

@patch('requests.get')
def test_extract_content_with_scripts_and_styles(mock_get, content_extractor):
    """
    Tests content extraction with script and style tags removed.
    """
    html_content = """
    <html>
    <head><style>body {color: red;}</style></head>
    <body>
        <script>console.log('hello');</script>
        <p>Main content.</p>
        <style>.hidden {display: none;}</style>
        <div>More text.</div>
    </body>
    </html>
    """
    mock_get.return_value = MockResponse(html_content)
    url = "http://example.com/scripts-styles"
    content = content_extractor.extract_content(url)
    assert content == "Main content. More text."

@patch('requests.get')
def test_extract_content_with_main_tag(mock_get, content_extractor):
    """
    Tests content extraction prioritizing <main> tag.
    """
    html_content = """
    <html>
    <body>
        <header>Header content</header>
        <main>
            <h1>Article Title</h1>
            <p>This is the main article content.</p>
        </main>
        <footer>Footer content</footer>
    </body>
    </html>
    """
    mock_get.return_value = MockResponse(html_content)
    url = "http://example.com/main-tag"
    content = content_extractor.extract_content(url)
    assert content == "Article Title This is the main article content."

@patch('requests.get')
def test_extract_content_http_error(mock_get, content_extractor):
    """
    Tests handling of HTTP errors during content fetching.
    """
    mock_get.return_value = MockResponse("Not Found", status_code=404)
    url = "http://example.com/404"
    content = content_extractor.extract_content(url)
    assert content is None

@patch('requests.get')
def test_extract_content_request_exception(mock_get, content_extractor):
    """
    Tests handling of network-related request exceptions.
    """
    mock_get.side_effect = requests.exceptions.ConnectionError("Network error")
    url = "http://example.com/network-error"
    content = content_extractor.extract_content(url)
    assert content is None

@patch('requests.get')
def test_extract_content_empty_body(mock_get, content_extractor):
    """
    Tests handling of HTML with an empty body.
    """
    mock_get.return_value = MockResponse("<html><head></head><body></body></html>")
    url = "http://example.com/empty-body"
    content = content_extractor.extract_content(url)
    assert content == ""

@patch('requests.get')
def test_extract_content_no_html_tags(mock_get, content_extractor):
    """
    Tests handling of plain text content without HTML tags.
    """
    mock_get.return_value = MockResponse("Just plain text content.")
    url = "http://example.com/plain-text"
    content = content_extractor.extract_content(url)
    assert content == "Just plain text content."

@patch('requests.get')
def test_extract_content_complex_structure(mock_get, content_extractor):
    """
    Tests content extraction from a more complex HTML structure.
    """
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Complex Page</title>
        <script>var data = {};</script>
    </head>
    <body>
        <nav><ul><li>Link 1</li></ul></nav>
        <article>
            <h2>Article Heading</h2>
            <p>Paragraph one of the article.</p>
            <div class="image-container">
                <img src="image.jpg" alt="An image">
            </div>
            <p>Paragraph two with some <span>inline</span> text.</p>
        </article>
        <aside>Sidebar content</aside>
        <footer>Contact info</footer>
    </body>
    </html>
    """
    mock_get.return_value = MockResponse(html_content)
    url = "http://example.com/complex"
    content = content_extractor.extract_content(url)
    expected_content = "Article Heading Paragraph one of the article. Paragraph two with some inline text."
    assert content == expected_content
