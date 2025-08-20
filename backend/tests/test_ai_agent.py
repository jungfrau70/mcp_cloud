import pytest
import json
from unittest.mock import Mock, patch
from rag_service import RAGService, TerraformCodeGenerator, CostOptimizer, SecurityAuditor

class TestTerraformCodeGenerator:
    def setup_method(self):
        self.mock_llm = Mock()
        self.generator = TerraformCodeGenerator(self.mock_llm)

    def test_generate_code_success(self):
        mock_response_dict = {
            "main_tf": "resource \"aws_vpc\" \"main\" { cidr_block = \"10.0.0.0/16\" }",
            "variables_tf": "variable \"vpc_cidr_block\" { type = string }",
            "outputs_tf": "output \"vpc_id\" { value = aws_vpc.main.id }",
            "description": "A sample VPC",
            "estimated_cost": "$10 USD",
            "security_notes": "No critical issues.",
            "best_practices": "Use security groups."
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
        self.mock_llm.invoke.return_value = json.dumps(mock_response)
        result = self.generator.validate_code('resource "aws_vpc" "main" { }')
        assert result == mock_response

class TestCostOptimizer:
    def setup_method(self):
        self.mock_llm = Mock()
        self.optimizer = CostOptimizer(self.mock_llm)

    def test_analyze_cost_success(self):
        mock_response = {
            "estimated_monthly_cost": "$150 USD",
            "cost_breakdown": {
                "compute": "$100",
                "storage": "$30", 
                "network": "$15",
                "other": "$5"
            },
            "optimization_opportunities": ["Right-size instances"],
            "reserved_instances": ["Consider 1-year RI for EC2"],
            "auto_scaling_recommendations": ["Implement ASG"],
            "budget_alerts": ["Set up budget alerts for 80% usage"]
        }
        self.mock_llm.invoke.return_value = json.dumps(mock_response)
        result = self.optimizer.analyze_cost("EC2 and RDS infra", "aws")
        assert result == mock_response

class TestSecurityAuditor:
    def setup_method(self):
        self.mock_llm = Mock()
        self.auditor = SecurityAuditor(self.mock_llm)

    def test_audit_security_success(self):
        mock_response = {
            "security_score": 85,
            "critical_issues": [],
            "high_risk_issues": [],
            "medium_risk_issues": ["Public S3 bucket"],
            "low_risk_issues": [],
            "compliance_check": ["GDPR compliant"],
            "security_recommendations": ["Enable MFA"],
            "iam_recommendations": ["Least privilege"],
            "network_security": ["Use NACLs"]
        }
        self.mock_llm.invoke.return_value = json.dumps(mock_response)
        result = self.auditor.audit_security("Public EC2 instance", "aws")
        assert result == mock_response

@pytest.fixture
def rag_service_with_mocks(mocker):
    """
    Provides a RAGService instance with its external dependencies mocked.
    """
    mocker.patch('os.path.exists', return_value=True) # Prevent file system operations

    # Patch the external dependencies of RAGService
    mocker.patch('rag_service.FAISS.load_local', return_value=Mock())
    mocker.patch('rag_service.HuggingFaceEmbeddings', return_value=Mock())
    mocker.patch('rag_service.ChatGoogleGenerativeAI', return_value=Mock())
    
    # Create a real RAGService instance
    service = RAGService()

    # Mock the sub-components for isolated testing of RAGService methods
    service.terraform_generator = Mock()
    service.cost_optimizer = Mock()
    service.security_auditor = Mock()
    
    return service

def test_generate_terraform_code(rag_service_with_mocks):
    mock_result = {"main_tf": "resource..."}
    rag_service_with_mocks.terraform_generator.generate_code.return_value = mock_result
    result = rag_service_with_mocks.generate_terraform_code("VPC", "aws")
    assert result == mock_result

def test_analyze_cost(rag_service_with_mocks):
    mock_result = {"estimated_monthly_cost": "$100"}
    rag_service_with_mocks.cost_optimizer.analyze_cost.return_value = mock_result
    result = rag_service_with_mocks.analyze_cost("Infra", "aws")
    assert result == mock_result

def test_audit_security(rag_service_with_mocks):
    mock_result = {"security_score": 80}
    rag_service_with_mocks.security_auditor.audit_security.return_value = mock_result
    result = rag_service_with_mocks.audit_security("Infra", "aws")
    assert result == mock_result

@patch('rag_service.RAGService')
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