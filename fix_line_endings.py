
import os

files_to_fix = [
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\automation\\day1\\cloud_basics.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\install\\install_docker_compose_azure.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\install\\install_docker_compose_gcp.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\install\\install_git_aws.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\install\\install_git_azure.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\install\\install_git_gcp.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\textbook\\Day1\\scripts\\aws-gcp-setup.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\textbook\\Day1\\scripts\\aws-setup-helper.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\textbook\\Day1\\scripts\\gcp-setup-helper.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\textbook\\Day2\\scripts\\aws-setup-helper.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\textbook\\Day2\\scripts\\gcp-setup-helper.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation_tests\\get_helm.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation_tests\\install_tools.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation\\day1\\ecs_fargate.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation\\day1\\gke_cluster.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation\\day1\\kubernetes_advanced.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\install\\get_helm.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\install\\install_docker_compose_azure.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\install\\install_docker_compose_gcp.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\install\\install_git_aws.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\install\\install_git_azure.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\install\\install_git_gcp.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\textbook\\Day1\\container-demo-setup.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\textbook\\Day1\\scripts\\aws-setup-helper.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\textbook\\Day1\\scripts\\container-comprehensive-deploy.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\textbook\\Day1\\scripts\\deploy-advanced.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\textbook\\Day1\\scripts\\gcp-setup-helper.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\textbook\\Day2\\scripts\\aws-setup-helper.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\textbook\\Day2\\scripts\\gcp-setup-helper.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation\\day1\\docker_basics.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation\\day1\\git_github_basics.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation\\day1\\github_actions.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\install\\install_docker_compose_azure.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\install\\install_docker_compose_gcp.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\install\\install_git_aws.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\install\\install_git_azure.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\install\\install_git_gcp.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day1\\scripts\\aws-ec2-create.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day1\\scripts\\aws-resource-cleanup.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day1\\scripts\\aws-setup-helper.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day1\\scripts\\gcp-compute-create.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day1\\scripts\\gcp-project-cleanup.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day1\\scripts\\gcp-setup-helper.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day1\\startup-script.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\scripts\\aws-ec2-create.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\scripts\\aws-resource-cleanup.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\scripts\\aws-setup-helper.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\scripts\\gcp-compute-create.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\scripts\\gcp-project-cleanup.sh",
    "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\scripts\\gcp-setup-helper.sh"
]

def fix_line_endings():
    for file_path in files_to_fix:
        try:
            with open(file_path, 'rb') as f:
                content = f.read()
            
            # Replace CRLF with LF
            new_content = content.replace(b'\r\n', b'\n')
            
            if new_content != content:
                print(f"Fixing line endings in: {file_path}")
                with open(file_path, 'wb') as f:
                    f.write(new_content)
            else:
                print(f"Line endings already correct in: {file_path}")

        except Exception as e:
            print(f"Error processing {file_path}: {e}")

if __name__ == "__main__":
    fix_line_endings()
