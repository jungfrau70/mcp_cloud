# backend/content_extractor.py
import requests
from bs4 import BeautifulSoup
from typing import Optional

class ContentExtractor:
    def __init__(self):
        pass

    def extract_content(self, url: str) -> Optional[str]:
        """
        Fetches content from a URL and extracts main text, removing boilerplate.
        """
        print(f"Fetching and extracting content from: {url}")
        try:
            response = requests.get(url, timeout=10)
            response.raise_for_status() # Raise HTTPError for bad responses (4xx or 5xx) 
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Remove script and style elements
            for script_or_style in soup(['script', 'style', 'header', 'footer', 'nav', 'aside']):
                script_or_style.extract()
            
            # Try to find the main content area (common patterns)
            main_content = soup.find('main') or soup.find('article') or soup.find('div', class_='content') or soup.find('div', id='main-content')
            
            if main_content:
                text = main_content.get_text(separator=' ', strip=True)
            else:
                # Fallback to body text if main content area not found
                text = soup.body.get_text(separator=' ', strip=True) if soup.body else soup.get_text(separator=' ', strip=True)
            
            # Basic cleaning: remove multiple newlines, excessive spaces
            text = '\n'.join([line.strip() for line in text.splitlines() if line.strip()])
            text = ' '.join(text.split())
            
            return text
        except requests.exceptions.RequestException as e:
            print(f"Error fetching URL {url}: {e}")
            return None
        except Exception as e:
            print(f"Error extracting content from {url}: {e}")
            return None

# Instantiate the service
content_extractor_instance = ContentExtractor()
