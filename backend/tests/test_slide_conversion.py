import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, mock_open
import os

# Assuming your main.py is in the backend directory
from backend.main import app, get_api_key, SLIDES_DIR

# Override the API key dependency for testing
app.dependency_overrides[get_api_key] = lambda: "my_mcp_eagle_tiger"

client = TestClient(app)

@pytest.fixture
def mock_slide_content():
    return "# Test Slide\n\nThis is a test slide content."

@pytest.fixture
def mock_pdf_buffer():
    # Simulate a PDF buffer
    from io import BytesIO
    buffer = BytesIO(b"%PDF-1.4\n%\xc2\xa5\xc2\xb1\xc3\xaf\xc3\xaf\n1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n2 0 obj<</Type/Pages/Count 0>>endobj\nxref\n0 3\n0000000000 65535 f\n0000000009 00000 n\n0000000074 00000 n\ntrailer<</Size 3/Root 1 0 R>>startxref\n123\n%%EOF")
    buffer.seek(0)
    return buffer

# Helper for mocking os.path.realpath
def create_mock_realpath_side_effect(expected_real_paths_map):
    """
    Helper to create a side_effect for os.path.realpath.
    :param expected_real_paths_map: A dictionary mapping input paths to their mocked real paths.
                                    Keys should be the paths as they would be passed to os.path.realpath.
    """
    def _side_effect(path):
        print(f"mock_realpath received: {path}") # Debug print
        if path in expected_real_paths_map:
            print(f"mock_realpath returning: {expected_real_paths_map[path]}") # Debug print
            return expected_real_paths_map[path]
        # Fallback for any other calls to os.path.realpath (shouldn't happen in these tests)
        print(f"mock_realpath falling back, returning: {path}") # Debug print
        return path # Or raise an error if unexpected calls are made
    return _side_effect

# Helper for mocking os.path.exists
def create_mock_exists_side_effect(expected_existing_paths):
    """
    Helper to create a side_effect for os.path.exists.
    :param expected_existing_paths: A list of paths that should exist.
    """
    def _side_effect(path):
        print(f"mock_exists received: {path}") # Debug print
        result = path in expected_existing_paths
        print(f"mock_exists returning: {result}") # Debug print
        return result
    return _side_effect

@patch('os.path.exists')
@patch('os.path.realpath')
@patch('builtins.open', new_callable=mock_open)
def test_get_slide_pdf_success(mock_open_file, mock_realpath, mock_exists, mock_slide_content):
    # Configure mocks for a successful scenario
    mock_exists.side_effect = create_mock_exists_side_effect([
        os.path.join(SLIDES_DIR, "test_slide.md")
    ])
    mock_realpath.side_effect = create_mock_realpath_side_effect({
        SLIDES_DIR: SLIDES_DIR,
        os.path.join(SLIDES_DIR, "test_slide.md"): os.path.join(SLIDES_DIR, "test_slide.md")
    })
    mock_open_file.return_value.read.return_value = mock_slide_content

    response = client.get("/api/v1/curriculum/slide?textbook_path=test_slide.md", headers={"X-API-Key": "my_mcp_eagle_tiger"})

    # Since HAS_MARKDOWN_PDF is False, it should return markdown content
    assert response.status_code == 200
    assert response.headers['content-type'] == 'text/markdown; charset=utf-8'
    assert response.headers['content-disposition'] == 'attachment; filename="test_slide.md"'
    assert response.content.decode() == mock_slide_content

    mock_exists.assert_called_with(os.path.join(SLIDES_DIR, "test_slide.md"))
    mock_open_file.assert_called_with(os.path.join(SLIDES_DIR, "test_slide.md"), 'r', encoding='utf-8')

@patch('os.path.exists')
@patch('os.path.realpath')
def test_get_slide_pdf_not_found(mock_realpath, mock_exists):
    mock_exists.side_effect = create_mock_exists_side_effect([]) # No files exist
    mock_realpath.side_effect = create_mock_realpath_side_effect({
        SLIDES_DIR: SLIDES_DIR,
        os.path.join(SLIDES_DIR, "non_existent_slide.md"): os.path.join(SLIDES_DIR, "non_existent_slide.md")
    })

    response = client.get("/api/v1/curriculum/slide?textbook_path=non_existent_slide.md", headers={"X-API-Key": "my_mcp_eagle_tiger"})

    assert response.status_code == 404
    assert "Slide mapping is not defined for this document." in response.json()["detail"]

@patch('os.path.exists')
@patch('os.path.realpath')
def test_get_slide_pdf_invalid_path(mock_realpath, mock_exists):
    # The requested_path will be SLIDES_DIR/test_slide.md after normpath
    # We want os.path.realpath(requested_path) to return a malicious path
    mock_exists.side_effect = create_mock_exists_side_effect([
        "/malicious/path/outside/slides_dir" # This path should exist for the test to proceed to the security check
    ])
    mock_realpath.side_effect = create_mock_realpath_side_effect({
        SLIDES_DIR: SLIDES_DIR,
        os.path.join(SLIDES_DIR, "../test_slide.md"): "/malicious/path/outside/slides_dir" # This is the path passed to realpath
    })

    response = client.get("/api/v1/curriculum/slide?textbook_path=../test_slide.md", headers={"X-API-Key": "my_mcp_eagle_tiger"})

    assert response.status_code == 404
    assert "Not Found" in response.json()["detail"]

@patch('os.path.exists')
@patch('os.path.realpath')
@patch('builtins.open', new_callable=mock_open)
def test_get_slide_pdf_internal_error(mock_open_file, mock_realpath, mock_exists, mock_slide_content):
    mock_exists.side_effect = create_mock_exists_side_effect([
        os.path.join(SLIDES_DIR, "test_slide.md")
    ])
    mock_realpath.side_effect = create_mock_realpath_side_effect({
        SLIDES_DIR: SLIDES_DIR,
        os.path.join(SLIDES_DIR, "test_slide.md"): os.path.join(SLIDES_DIR, "test_slide.md")
    })
    mock_open_file.return_value.read.return_value = mock_slide_content

    response = client.get("/api/v1/curriculum/slide?textbook_path=test_slide.md", headers={"X-API-Key": "my_mcp_eagle_tiger"})

    # Since HAS_MARKDOWN_PDF is False, it should return markdown content successfully
    assert response.status_code == 200
    assert response.headers['content-type'] == 'text/markdown; charset=utf-8'
    assert response.headers['content-disposition'] == 'attachment; filename="test_slide.md"'
    assert response.content.decode() == mock_slide_content

@patch('os.path.exists')
@patch('os.path.realpath')
@patch('builtins.open', new_callable=mock_open)
def test_get_slide_pdf_no_md_extension(mock_open_file, mock_realpath, mock_exists, mock_slide_content):
    mock_exists.side_effect = create_mock_exists_side_effect([
        os.path.join(SLIDES_DIR, "test_slide.md")
    ])
    mock_realpath.side_effect = create_mock_realpath_side_effect({
        SLIDES_DIR: SLIDES_DIR,
        os.path.join(SLIDES_DIR, "test_slide.md"): os.path.join(SLIDES_DIR, "test_slide.md")
    })
    mock_open_file.return_value.read.return_value = mock_slide_content

    response = client.get("/api/v1/curriculum/slide?textbook_path=test_slide", headers={"X-API-Key": "my_mcp_eagle_tiger"})

    # Since HAS_MARKDOWN_PDF is False, it should return markdown content
    assert response.status_code == 200
    assert response.headers['content-type'] == 'text/markdown; charset=utf-8'
    assert response.headers['content-disposition'] == 'attachment; filename="test_slide.md"'
    assert response.content.decode() == mock_slide_content

    mock_exists.assert_called_with(os.path.join(SLIDES_DIR, "test_slide.md"))
    mock_open_file.assert_called_with(os.path.join(SLIDES_DIR, "test_slide.md"), 'r', encoding='utf-8')

@patch('os.path.exists')
@patch('os.path.realpath')
@patch('builtins.open', new_callable=mock_open)
def test_get_slide_pdf_with_path_segments(mock_open_file, mock_realpath, mock_exists, mock_slide_content):
    # Configure mocks for a successful scenario with path segments
    # Mock os.path.exists to return True only for the expected full path
    mock_exists.side_effect = create_mock_exists_side_effect([
        os.path.join(SLIDES_DIR, "subdir", "another_slide.md")
    ])
    # Mock os.path.realpath to return the expected real path
    mock_realpath.side_effect = create_mock_realpath_side_effect({
        SLIDES_DIR: SLIDES_DIR,
        os.path.join(SLIDES_DIR, "subdir", "another_slide.md"): os.path.join(SLIDES_DIR, "subdir", "another_slide.md")
    })

    mock_open_file.return_value.read.return_value = mock_slide_content

    # Simulate a slide in a subdirectory
    slide_name_with_path = "subdir/another_slide.md"
    expected_full_path = os.path.join(SLIDES_DIR, "subdir", "another_slide.md")

    response = client.get(f"/api/v1/curriculum/slide?textbook_path={slide_name_with_path}", headers={"X-API-Key": "my_mcp_eagle_tiger"})

    # Since HAS_MARKDOWN_PDF is False, it should return markdown content
    assert response.status_code == 200
    assert response.headers['content-type'] == 'text/markdown; charset=utf-8'
    assert response.headers['content-disposition'] == 'attachment; filename="another_slide.md"'
    assert response.content.decode() == mock_slide_content

    mock_exists.assert_called_with(expected_full_path)
    mock_open_file.assert_called_with(expected_full_path, 'r', encoding='utf-8')