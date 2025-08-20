# backend/ai_document_generator.py
import google.generativeai as genai
import os
from typing import Optional, Dict, List

class AIDocumentGenerator:
    def __init__(self):
        self.api_key = os.getenv("GEMINI_API_KEY")
        if not self.api_key:
            print("Warning: GEMINI_API_KEY not set. AI document generation will be limited or fail.")
        else:
            genai.configure(api_key=self.api_key)
        self.model = genai.GenerativeModel('gemini-1.5-flash') # Or another suitable model

    async def generate_document(self, query: str, extracted_content: str, search_results: List[Dict]) -> Optional[Dict]:
        """
        Generates a structured knowledge base document using an LLM.
        Returns a dictionary with 'title', 'slug', and 'content' (markdown).
        """
        print(f"Generating document for query: {query} with content length: {len(extracted_content)}")

        # Construct a prompt for the LLM
        sources_markdown = ""
        if search_results:
            sources_markdown = "\n\n## 참고 자료\n"
            for i, result in enumerate(search_results):
                sources_markdown += f"- [{result['title']}]({result['link']})\n"

        prompt = f"""
        You are an expert technical writer and cloud engineer. Your task is to create a concise and informative knowledge base document in Markdown format based on the provided query and extracted content.

        Follow these instructions:
        1.  **Title**: Create a clear, concise, and searchable title (Korean, max 50 characters).
        2.  **Slug**: Generate a URL-friendly slug (lowercase, hyphens, no special characters, max 50 characters) from the title.
        3.  **Content Structure**: Organize the content with headings, subheadings, bullet points, and code blocks where appropriate. Focus on key concepts, steps, and best practices.
        4.  **Language**: Write the document in Korean.
        5.  **Conciseness**: Be direct and avoid unnecessary jargon. Aim for a document that can be quickly understood.
        6.  **Focus**: Prioritize information directly relevant to the query from the extracted content.
        7.  **Source Attribution**: Include a "참고 자료" (References) section at the end of the document, listing the provided search results with their titles and links in Markdown link format.
        8.  **Output Format**: Respond ONLY with a JSON object containing 'title', 'slug', and 'content' (Markdown string).

        --- Query ---
        {query}

        --- Extracted Content ---
        {extracted_content}
        {sources_markdown}
        """

        try:
            # For actual LLM call, use generate_content_async
            response = await self.model.generate_content_async(
                prompt,
                generation_config=genai.types.GenerationConfig(
                    response_mime_type="application/json"
                )
            )
            
            generated_data = response.text
            # Parse the JSON string returned by the LLM
            import json
            doc_data = json.loads(generated_data)
            
            # Basic validation of the expected keys
            if all(k in doc_data for k in ['title', 'slug', 'content']):
                return doc_data
            else:
                print(f"LLM response missing required keys: {doc_data}")
                return None

        except Exception as e:
            print(f"Error generating document with LLM: {e}")
            return None

# Instantiate the service
ai_document_generator_instance = AIDocumentGenerator()
