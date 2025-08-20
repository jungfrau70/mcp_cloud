import pytest
from external_search_service import ExternalSearchService
from unittest.mock import MagicMock # Import MagicMock

# Mock data for google_web_search
MOCK_SEARCH_RESULTS = {
    "search_results": [
        {"title": "Mock Result 1", "link": "http://mock1.com", "snippet": "Snippet for mock result 1."},
        {"title": "Mock Result 2", "link": "http://mock2.com", "snippet": "Snippet for mock result 2."},
        {"title": "Mock Result 3", "link": "http://mock3.com", "snippet": "Snippet for mock result 3."},
        {"title": "Mock Result 4", "link": "http://mock4.com", "snippet": "Snippet for mock result 4."},
        {"title": "Mock Result 5", "link": "http://mock5.com", "snippet": "Snippet for mock result 5."},
    ]
}

@pytest.fixture
def mock_api_client():
    """Fixture to provide a mocked API client for ExternalSearchService."""
    mock_client = MagicMock()
    mock_client.google_web_search.return_value = MOCK_SEARCH_RESULTS
    return mock_client

@pytest.fixture
def external_search_service(mock_api_client):
    """Fixture to provide an ExternalSearchService instance with a mocked API client."""
    return ExternalSearchService(api_client=mock_api_client)

def test_external_search_service_initialization(external_search_service):
    """
    Tests that the ExternalSearchService can be initialized.
    """
    assert isinstance(external_search_service, ExternalSearchService)

def test_external_search_service_search_method(external_search_service, mock_api_client):
    """
    Tests the search method returns results with expected structure from mocked data.
    """
    query = "test query"
    results = external_search_service.search(query)

    assert isinstance(results, list)
    assert len(results) > 0
    
    for result in results:
        assert "title" in result
        assert "link" in result
        assert "snippet" in result
        assert isinstance(result["title"], str)
        assert isinstance(result["link"], str)
        assert isinstance(result["snippet"], str)
        assert any(result["title"] == mr["title"] for mr in MOCK_SEARCH_RESULTS["search_results"])
    
    mock_api_client.google_web_search.assert_called_once_with(query=query)

def test_external_search_service_search_num_results(external_search_service, mock_api_client):
    """
    Tests the num_results parameter of the search method with mocked data.
    """
    query = "another query"
    
    results_one = external_search_service.search(query, num_results=1)
    assert len(results_one) == 1
    assert results_one[0]["title"] == MOCK_SEARCH_RESULTS["search_results"][0]["title"]

    results_zero = external_search_service.search(query, num_results=0)
    assert len(results_zero) == 0

    results_five = external_search_service.search(query, num_results=5)
    assert len(results_five) == 5
    assert results_five[4]["title"] == MOCK_SEARCH_RESULTS["search_results"][4]["title"]

    results_more_than_mock = external_search_service.search(query, num_results=10)
    assert len(results_more_than_mock) == len(MOCK_SEARCH_RESULTS["search_results"])
    
    # Ensure google_web_search was called for each search operation
    assert mock_api_client.google_web_search.call_count == 4 # One for each call above