"""
Test cases for path duplication issues in curriculum API.
"""
import pytest
from app.api.routes.curriculum import _clean_duplicate_path


class TestPathDuplication:
    """Test cases for path duplication cleaning."""
    
    def test_clean_duplicate_path_basic(self):
        """Test basic path cleaning without duplicates."""
        path = "cloud_master/textbook/Day1/README.md"
        result = _clean_duplicate_path(path)
        assert result == "cloud_master/textbook/Day1/README.md"
    
    def test_clean_duplicate_path_simple_duplication(self):
        """Test simple duplication removal."""
        path = "cloud_master/textbook/Day1/cloud_master/textbook/Day1/README.md"
        result = _clean_duplicate_path(path)
        assert result == "cloud_master/textbook/Day1/README.md"
    
    def test_clean_duplicate_path_multiple_duplications(self):
        """Test multiple duplication removal."""
        path = "cloud_master/textbook/Day1/cloud_master/textbook/Day1/cloud_master/textbook/Day1/README.md"
        result = _clean_duplicate_path(path)
        assert result == "cloud_master/textbook/Day1/README.md"
    
    def test_clean_duplicate_path_different_courses(self):
        """Test that different courses are not removed."""
        path = "cloud_basic/textbook/Day1/cloud_master/textbook/Day2/README.md"
        result = _clean_duplicate_path(path)
        assert result == "cloud_basic/textbook/Day1/cloud_master/textbook/Day2/README.md"
    
    def test_clean_duplicate_path_container_course(self):
        """Test container course path cleaning."""
        path = "cloud_container/textbook/Day2/cloud_container/textbook/Day2/README.md"
        result = _clean_duplicate_path(path)
        assert result == "cloud_container/textbook/Day2/README.md"
    
    def test_clean_duplicate_path_complex_duplication(self):
        """Test complex duplication patterns."""
        path = "cloud_master/textbook/Day3/cloud_master/textbook/Day3/cloud_master/textbook/Day3/cloud_master/textbook/Day3/README.md"
        result = _clean_duplicate_path(path)
        assert result == "cloud_master/textbook/Day3/README.md"
    
    def test_clean_duplicate_path_textbook_only_duplication(self):
        """Test textbook-only duplication removal."""
        path = "cloud_master/textbook/Day1/textbook/Day1/README.md"
        result = _clean_duplicate_path(path)
        assert result == "cloud_master/textbook/Day1/README.md"
    
    def test_clean_duplicate_path_empty_string(self):
        """Test empty string handling."""
        result = _clean_duplicate_path("")
        assert result == ""
    
    def test_clean_duplicate_path_none(self):
        """Test None handling."""
        result = _clean_duplicate_path(None)
        assert result is None
    
    def test_clean_duplicate_path_no_root_marker(self):
        """Test path without root markers."""
        path = "some/other/path/README.md"
        result = _clean_duplicate_path(path)
        assert result == "some/other/path/README.md"
    
    def test_clean_duplicate_path_with_slashes(self):
        """Test path with leading/trailing slashes."""
        path = "/cloud_master/textbook/Day1/cloud_master/textbook/Day1/README.md/"
        result = _clean_duplicate_path(path)
        assert result == "cloud_master/textbook/Day1/README.md"
    
    def test_clean_duplicate_path_windows_separators(self):
        """Test path with Windows separators."""
        path = "cloud_master\\textbook\\Day1\\cloud_master\\textbook\\Day1\\README.md"
        result = _clean_duplicate_path(path)
        assert result == "cloud_master/textbook/Day1/README.md"
    
    def test_clean_duplicate_path_extreme_duplication(self):
        """Test extreme duplication case."""
        path = "cloud_master/textbook/Day1/" * 50 + "README.md"
        result = _clean_duplicate_path(path)
        assert result == "cloud_master/textbook/Day1/README.md"
    
    def test_clean_duplicate_path_mixed_patterns(self):
        """Test mixed duplication patterns."""
        path = "cloud_basic/textbook/Day1/cloud_basic/textbook/Day1/cloud_master/textbook/Day2/cloud_master/textbook/Day2/README.md"
        result = _clean_duplicate_path(path)
        assert result == "cloud_basic/textbook/Day1/cloud_master/textbook/Day2/README.md"


if __name__ == "__main__":
    pytest.main([__file__])
