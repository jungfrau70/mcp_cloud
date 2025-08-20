import pytest
from unittest.mock import Mock, patch
from content_extractor import ContentExtractor
import requests # Import requests to catch its exceptions

# Mock response for requests.get
class MockResponse:
    def __init__(self, text, status_code=200):
        self.text = text
        self.status_code = status_code

    def raise_for_status(self):
        if self.status_code >= 400:
            raise requests.exceptions.HTTPError(f"HTTP Error: {self.status_code}")

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
