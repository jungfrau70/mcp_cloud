import pytest
import json
from unittest.mock import Mock, patch
from rag_service import RAGService, TerraformCodeGenerator, CostOptimizer, SecurityAuditor


# ---------------------- Fixtures ---------------------- #

@pytest.fixture
def mock_llm():
    """LLM Mock providing an invoke method used by LCEL chain."""
    return Mock()

@pytest.fixture
def terraform_generator(mock_llm):
    return TerraformCodeGenerator(mock_llm)

@pytest.fixture
def cost_optimizer(mock_llm):
    return CostOptimizer(mock_llm)

@pytest.fixture
def security_auditor(mock_llm):
    return SecurityAuditor(mock_llm)


# ---------------- TerraformCodeGenerator Tests ---------------- #

@pytest.mark.unit
def test_generate_code_success(terraform_generator, mock_llm):
    payload = {
        "main_tf": "resource \"aws_vpc\" \"main\" { cidr_block = \"10.0.0.0/16\" }",
        "variables_tf": "variable \"vpc_cidr_block\" { type = string }",
        "outputs_tf": "output \"vpc_id\" { value = aws_vpc.main.id }",
        "description": "A sample VPC",
        "estimated_cost": "$10 USD",
        "security_notes": "No critical issues.",
        "best_practices": "Use security groups."
    }
    mock_llm.invoke.return_value = json.dumps(payload)
    result = terraform_generator.generate_code("Create a VPC", "aws")
    assert result == payload

@pytest.mark.unit
def test_generate_code_llm_exception(terraform_generator, mock_llm):
    mock_llm.invoke.side_effect = Exception("LLM down")
    result = terraform_generator.generate_code("Create a VPC", "aws")
    assert result["error"].startswith("코드 생성 중 오류 발생")
    assert "main_tf" in result

@pytest.mark.unit
def test_generate_code_invalid_json_fallback(terraform_generator, mock_llm):
    mock_llm.invoke.return_value = "Not a JSON output"
    # Force parse_llm_json to return error -> fallback path
    result = terraform_generator.generate_code("Create a VPC", "aws")
    assert result["description"] == "Default VPC on failure"
    assert result["error"].startswith("코드 생성 중 오류 발생")

@pytest.mark.unit
def test_validate_code_success(terraform_generator, mock_llm):
    mock_llm.invoke.return_value = json.dumps({"is_valid": True, "syntax_errors": [], "recommendations": []})
    result = terraform_generator.validate_code('resource "aws_vpc" "main" { }')
    assert result["is_valid"] is True

@pytest.mark.unit
def test_validate_code_invalid_json(terraform_generator, mock_llm):
    mock_llm.invoke.return_value = "garbled"
    result = terraform_generator.validate_code("resource \"aws_vpc\" \"main\" { }")
    # Fallback returns is_valid False with error
    assert result["is_valid"] is False
    assert "error" in result


# ---------------- CostOptimizer Tests ---------------- #

@pytest.mark.unit
def test_analyze_cost_success(cost_optimizer, mock_llm):
    payload = {
        "estimated_monthly_cost": "$150 USD",
        "cost_breakdown": {"compute": "$100", "storage": "$30", "network": "$15", "other": "$5"},
        "optimization_opportunities": ["Right-size instances"],
        "reserved_instances": ["Consider 1-year RI for EC2"],
        "auto_scaling_recommendations": ["Implement ASG"],
        "budget_alerts": ["Set up budget alerts for 80% usage"],
    }
    mock_llm.invoke.return_value = json.dumps(payload)
    result = cost_optimizer.analyze_cost("EC2 and RDS infra", "aws")
    assert result == payload

@pytest.mark.unit
def test_analyze_cost_invalid_json(cost_optimizer, mock_llm):
    mock_llm.invoke.return_value = "blah"
    result = cost_optimizer.analyze_cost("infra", "aws")
    assert result["estimated_monthly_cost"] == "100 USD"  # fallback default
    assert "error" in result


# ---------------- SecurityAuditor Tests ---------------- #

@pytest.mark.unit
def test_audit_security_success(security_auditor, mock_llm):
    payload = {
        "security_score": 85,
        "critical_issues": [],
        "high_risk_issues": [],
        "medium_risk_issues": ["Public S3 bucket"],
        "low_risk_issues": [],
        "compliance_check": ["GDPR compliant"],
        "security_recommendations": ["Enable MFA"],
        "iam_recommendations": ["Least privilege"],
        "network_security": ["Use NACLs"],
    }
    mock_llm.invoke.return_value = json.dumps(payload)
    result = security_auditor.audit_security("Public EC2 instance", "aws")
    assert result == payload

@pytest.mark.unit
def test_audit_security_invalid_json(security_auditor, mock_llm):
    mock_llm.invoke.return_value = "junk"
    result = security_auditor.audit_security("desc", "aws")
    assert result["security_score"] == 50  # fallback
    assert "error" in result


# ---------------- RAGService Wrapper Tests ---------------- #

@pytest.fixture
def rag_service_with_mocks(mocker):
    mocker.patch("os.path.exists", return_value=True)
    mocker.patch("rag_service.FAISS.load_local", return_value=Mock())
    mocker.patch("rag_service.HuggingFaceEmbeddings", return_value=Mock())
    mocker.patch("rag_service.ChatGoogleGenerativeAI", return_value=Mock())
    service = RAGService()
    service.terraform_generator = Mock()
    service.cost_optimizer = Mock()
    service.security_auditor = Mock()
    return service

@pytest.mark.unit
def test_rag_generate_terraform_code_wrapper(rag_service_with_mocks):
    rag_service_with_mocks.terraform_generator.generate_code.return_value = {"main_tf": "resource ..."}
    res = rag_service_with_mocks.generate_terraform_code("req", "aws")
    assert "main_tf" in res

@pytest.mark.unit
def test_rag_analyze_cost_wrapper(rag_service_with_mocks):
    rag_service_with_mocks.cost_optimizer.analyze_cost.return_value = {"estimated_monthly_cost": "$42"}
    res = rag_service_with_mocks.analyze_cost("infra", "aws")
    assert res["estimated_monthly_cost"] == "$42"

@pytest.mark.unit
def test_rag_audit_security_wrapper(rag_service_with_mocks):
    rag_service_with_mocks.security_auditor.audit_security.return_value = {"security_score": 77}
    res = rag_service_with_mocks.audit_security("infra", "aws")
    assert res["security_score"] == 77


# ---------------- High-level Integration (Mocked RAGService) ------------- #

@pytest.mark.unit
@patch("rag_service.RAGService")
def test_ai_agent_integration_workflow(mock_rag_cls):
    inst = mock_rag_cls.return_value
    inst.generate_terraform_code.return_value = {"main_tf": "resource"}
    inst.analyze_cost.return_value = {"estimated_monthly_cost": "$50"}
    inst.audit_security.return_value = {"security_score": 80}
    assert "main_tf" in inst.generate_terraform_code("VPC", "aws")
    assert "estimated_monthly_cost" in inst.analyze_cost("VPC", "aws")
    assert "security_score" in inst.audit_security("VPC", "aws")


if __name__ == "__main__":  # pragma: no cover
    pytest.main([__file__, "-v"])