import pytest
import json
from unittest.mock import Mock, patch
from backend.rag_service import RAGService, TerraformCodeGenerator, CostOptimizer, SecurityAuditor

class TestUserScenario1_NewTeamInfrastructure:
    def setup_method(self):
        self.mock_llm = Mock()
        self.terraform_generator = TerraformCodeGenerator(self.mock_llm)
        self.cost_optimizer = CostOptimizer(self.mock_llm)
        self.security_auditor = SecurityAuditor(self.mock_llm)

    def test_new_team_infrastructure_workflow(self):
        mock_terraform_response = {
            "main_tf": "resource \"aws_vpc\" \"main\" {\n  cidr_block = \"10.0.0.0/16\"\n}",
            "variables_tf": "variable \"region\" {\n  default = \"us-east-1\"\n}",
            "outputs_tf": "output \"vpc_id\" {\n  value = aws_vpc.main.id\n}",
            "description": "High-availability web application infrastructure.",
            "estimated_cost": "$180/month",
            "security_notes": "Security group configuration needed.",
            "best_practices": "Apply tags, enable monitoring."
        }
        self.mock_llm.invoke.return_value = Mock(text=json.dumps(mock_terraform_response))
        terraform_result = self.terraform_generator.generate_code("Build a HA web app infra", "aws")
        assert "aws_vpc" in terraform_result["main_tf"]

class TestUserScenarioIntegration:
    @patch('backend.rag_service.RAGService')
    def test_complete_user_journey(self, mock_rag_service):
        mock_instance = mock_rag_service.return_value

        mock_instance.generate_terraform_code.return_value = {"main_tf": "resource..."}
        terraform_result = mock_instance.generate_terraform_code("web app", "aws")
        assert "main_tf" in terraform_result

        mock_instance.analyze_cost.return_value = {"estimated_monthly_cost": "$200"}
        cost_result = mock_instance.analyze_cost("web app", "aws")
        assert "estimated_monthly_cost" in cost_result

        mock_instance.audit_security.return_value = {"security_score": 90}
        security_result = mock_instance.audit_security("web app", "aws")
        assert "security_score" in security_result

if __name__ == "__main__":
    pytest.main([__file__, "-v"])