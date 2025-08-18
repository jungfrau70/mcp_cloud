import pytest
import json
from unittest.mock import Mock, patch
from backend.rag_service import RAGService, TerraformCodeGenerator, CostOptimizer, SecurityAuditor

class TestTerraformCodeGenerator:
    def setup_method(self):
        self.mock_llm = Mock()
        self.generator = TerraformCodeGenerator(self.mock_llm)

    def test_generate_code_success(self):
        mock_response_dict = {
            "main_tf": "resource \"aws_vpc\" \"main\" {\n  cidr_block = \"10.0.0.0/16\"\n}"
        }
        # generate_code uses StrOutputParser, so the mock must return a string to be parsed.
        self.mock_llm.invoke.return_value = json.dumps(mock_response_dict)
        result = self.generator.generate_code("Create a VPC", "aws")
        assert result == mock_response_dict

    def test_generate_code_error(self):
        self.mock_llm.invoke.side_effect = Exception("LLM connection failed")
        result = self.generator.generate_code("Create a VPC", "aws")
        assert "error" in result
        assert result["description"] == "Default VPC on failure"

    def test_validate_code_success(self):
        mock_response = {"is_valid": True, "recommendations": []}
        # validate_code uses JsonOutputParser, so the mock can return a dict directly.
        self.mock_llm.invoke.return_value = mock_response
        result = self.generator.validate_code('resource "aws_vpc" "main" { }')
        assert result == mock_response

class TestCostOptimizer:
    def setup_method(self):
        self.mock_llm = Mock()
        self.optimizer = CostOptimizer(self.mock_llm)

    def test_analyze_cost_success(self):
        mock_response = {"estimated_monthly_cost": "$150/month"}
        self.mock_llm.invoke.return_value = mock_response
        result = self.optimizer.analyze_cost("EC2 and RDS infra", "aws")
        assert result == mock_response

class TestSecurityAuditor:
    def setup_method(self):
        self.mock_llm = Mock()
        self.auditor = SecurityAuditor(self.mock_llm)

    def test_audit_security_success(self):
        mock_response = {"security_score": 75}
        self.mock_llm.invoke.return_value = mock_response
        result = self.auditor.audit_security("Public EC2 instance", "aws")
        assert result == mock_response

# Decorators are applied from bottom to top.
# The first argument to setup_method corresponds to the innermost decorator.
@patch('backend.rag_service.ChatGoogleGenerativeAI')
@patch('backend.rag_service.HuggingFaceEmbeddings')
@patch('backend.rag_service.FAISS')
class TestRAGService:
    def setup_method(self, mock_genai, mock_embeddings, mock_faiss):
        # Prevent file system operations during tests
        with patch('os.path.exists', return_value=True):
            mock_faiss.load_local.return_value = Mock()
            mock_embeddings.return_value = Mock()
            mock_genai.return_value = Mock()
            
            self.rag_service = RAGService()
            # Mock the sub-components for isolated testing of RAGService methods
            self.rag_service.terraform_generator = Mock()
            self.rag_service.cost_optimizer = Mock()
            self.rag_service.security_auditor = Mock()

    def test_generate_terraform_code(self):
        mock_result = {"main_tf": "resource..."}
        self.rag_service.terraform_generator.generate_code.return_value = mock_result
        result = self.rag_service.generate_terraform_code("VPC", "aws")
        assert result == mock_result

    def test_analyze_cost(self):
        mock_result = {"estimated_monthly_cost": "$100"}
        self.rag_service.cost_optimizer.analyze_cost.return_value = mock_result
        result = self.rag_service.analyze_cost("Infra", "aws")
        assert result == mock_result

    def test_audit_security(self):
        mock_result = {"security_score": 80}
        self.rag_service.security_auditor.audit_security.return_value = mock_result
        result = self.rag_service.audit_security("Infra", "aws")
        assert result == mock_result

@patch('backend.rag_service.RAGService')
class TestAIAgentIntegration:
    def test_ai_agent_workflow(self, mock_rag_service):
        mock_instance = mock_rag_service.return_value
        mock_instance.generate_terraform_code.return_value = {"main_tf": "resource..."}
        mock_instance.analyze_cost.return_value = {"estimated_monthly_cost": "$50"}
        mock_instance.audit_security.return_value = {"security_score": 80}

        assert "main_tf" in mock_instance.generate_terraform_code("VPC", "aws")
        assert "estimated_monthly_cost" in mock_instance.analyze_cost("VPC", "aws")
        assert "security_score" in mock_instance.audit_security("VPC", "aws")

if __name__ == "__main__":
    pytest.main([__file__, "-v"])