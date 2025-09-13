"""
Integration tests for curriculum API with path duplication fixes.
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


class TestCurriculumAPIIntegration:
    """Integration tests for curriculum API path handling."""
    
    def test_curriculum_api_with_duplicate_path(self):
        """Test curriculum API with duplicated path parameters."""
        # Test with duplicated path that should be cleaned
        duplicated_path = "cloud_master/textbook/Day1/cloud_master/textbook/Day1/README.md"
        
        response = client.get(
            f"/api/v1/curriculum?curriculum_path={duplicated_path}",
            headers={"X-API-Key": "test-key"}
        )
        
        # Should not return 404 due to path duplication
        assert response.status_code != 404
        # Should either return 200 (if file exists) or 400 (if invalid path)
        assert response.status_code in [200, 400]
    
    def test_curriculum_api_with_extreme_duplication(self):
        """Test curriculum API with extreme path duplication."""
        # Create extremely duplicated path
        base_path = "cloud_master/textbook/Day1/"
        duplicated_path = base_path * 10 + "README.md"
        
        response = client.get(
            f"/api/v1/curriculum?curriculum_path={duplicated_path}",
            headers={"X-API-Key": "test-key"}
        )
        
        # Should not return 404 due to path duplication
        assert response.status_code != 404
        # Should either return 200 (if file exists) or 400 (if invalid path)
        assert response.status_code in [200, 400]
    
    def test_curriculum_api_with_legacy_textbook_path(self):
        """Test curriculum API with legacy textbook_path parameter."""
        duplicated_path = "cloud_basic/textbook/Day1/cloud_basic/textbook/Day1/README.md"
        
        response = client.get(
            f"/api/v1/curriculum?textbook_path={duplicated_path}",
            headers={"X-API-Key": "test-key"}
        )
        
        # Should not return 404 due to path duplication
        assert response.status_code != 404
        # Should either return 200 (if file exists) or 400 (if invalid path)
        assert response.status_code in [200, 400]
    
    def test_curriculum_api_with_url_encoded_duplication(self):
        """Test curriculum API with URL encoded duplicated path."""
        import urllib.parse
        
        duplicated_path = "cloud_container/textbook/Day2/cloud_container/textbook/Day2/README.md"
        encoded_path = urllib.parse.quote(duplicated_path)
        
        response = client.get(
            f"/api/v1/curriculum?curriculum_path={encoded_path}",
            headers={"X-API-Key": "test-key"}
        )
        
        # Should not return 404 due to path duplication
        assert response.status_code != 404
        # Should either return 200 (if file exists) or 400 (if invalid path)
        assert response.status_code in [200, 400]
    
    def test_curriculum_api_with_double_encoded_duplication(self):
        """Test curriculum API with double URL encoded duplicated path."""
        import urllib.parse
        
        duplicated_path = "cloud_master/textbook/Day3/cloud_master/textbook/Day3/README.md"
        # Double encode
        encoded_path = urllib.parse.quote(urllib.parse.quote(duplicated_path))
        
        response = client.get(
            f"/api/v1/curriculum?curriculum_path={encoded_path}",
            headers={"X-API-Key": "test-key"}
        )
        
        # Should not return 404 due to path duplication
        assert response.status_code != 404
        # Should either return 200 (if file exists) or 400 (if invalid path)
        assert response.status_code in [200, 400]
    
    def test_curriculum_api_missing_path(self):
        """Test curriculum API with missing path parameter."""
        response = client.get(
            "/api/v1/curriculum",
            headers={"X-API-Key": "test-key"}
        )
        
        assert response.status_code == 400
        assert "Missing curriculum_path" in response.json()["detail"]
    
    def test_curriculum_api_invalid_path(self):
        """Test curriculum API with invalid path (path traversal)."""
        invalid_path = "../../../etc/passwd"
        
        response = client.get(
            f"/api/v1/curriculum?curriculum_path={invalid_path}",
            headers={"X-API-Key": "test-key"}
        )
        
        assert response.status_code == 400
        assert "Invalid path" in response.json()["detail"]


if __name__ == "__main__":
    pytest.main([__file__])
