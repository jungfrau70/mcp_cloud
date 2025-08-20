# backend/external_search_service.py
import os
from typing import List, Dict, Optional

class ExternalSearchService:
    def __init__(self, api_client=None):
        self.api_client = api_client # Allow dependency injection for testing
        if self.api_client is None:
            # For runtime in Gemini environment, default_api is globally available
            # This assumes default_api is always present in the execution environment
            # when not explicitly provided (e.g., during testing).
            # In a real-world scenario, you might want a more robust way to handle this,
            # perhaps by raising an error if default_api is truly missing.
            try:
                import default_api as _default_api
                self.api_client = _default_api
            except ImportError:
                print("Warning: default_api not found. External search will not function.")
                self.api_client = None # Or raise an error

    def search(self, query: str, num_results: int = 5) -> List[Dict]:
        """
        Performs a web search and returns a list of search results.
        Each result is a dictionary with 'title', 'link', and 'snippet'.
        """
        print(f"Performing real web search for: {query}")
        
        if self.api_client is None:
            print("Error: API client not available for search.")
            return []

        search_response = self.api_client.google_web_search(query=query)
        
        results = []
        if search_response and "search_results" in search_response:
            for i, item in enumerate(search_response["search_results"]):
                if i >= num_results:
                    break
                results.append({
                    "title": item.get("title", "No Title"),
                    "link": item.get("link", "#"),
                    "snippet": item.get("snippet", "No snippet available.")
                })
        return results

# Instantiate the service
external_search_service_instance = ExternalSearchService()
