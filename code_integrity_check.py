import subprocess
import os

def to_wsl_path(win_path):
    path = win_path.replace('\\', '/')
    drive, path_no_drive = os.path.splitdrive(path)
    drive_letter = drive.replace(':', '')
    return f"/mnt/{drive_letter.lower()}{path_no_drive}"

def check_integrity():
    py_files = [
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\integrated_automation\\improved_validation.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\integrated_automation\\improved_integrated_automation.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\automation_tests\\improved_basic_automation.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation_tests\\improved_container_automation.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation_tests\\improved_master_automation.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\integrated_automation\\validate_integration.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation_tests\\cloud_container_course_automation.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\integrated_automation\\validate_course_connections.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation_tests\\cloud_master_course_automation.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\automation_tests\\cloud_basic_course_automation.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\integrated_automation\\run_integrated_automation.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\automation_tests\\basic_course_day2_scripts.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\automation_tests\\run_basic_course_tests.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\automation_tests\\test_basic_course_automation.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation_tests\\container_course_day2_scripts.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation_tests\\run_container_course_tests.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation_tests\\test_container_course_automation.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation_tests\\master_course_day2_scripts.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation_tests\\master_course_day3_scripts.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation_tests\\run_master_course_tests.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation_tests\\test_master_course_automation.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\integrated_automation\\integrated_course_automation.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\integrated_automation\\shared_resource_manager.py",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\integrated_automation\\test_integrated_automation.py"
    ]

    sh_files = [
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\automation\\day1\\cloud_basics.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\automation\\day1\\iam_basics.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\automation\\day1\\storage_services.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\automation\\day1\\vm_services.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\automation\\day2\\comprehensive_practice.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\automation\\day2\\database_services.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\automation\\day2\\networking_basics.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\automation\\day2\\security_basics.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_basic\\install\\install_docker_compose_aws.sh",
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
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation\\day1\\advanced_cicd.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation\\day1\\ecs_fargate.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation\\day1\\gke_cluster.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation\\day1\\kubernetes_advanced.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation\\day2\\comprehensive_project.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation\\day2\\high_availability.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\automation\\day2\\monitoring.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\install\\get_helm.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_container\\install\\install_docker_compose_aws.sh",
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
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation\\day1\\vm_deployment.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation\\day2\\advanced_cicd.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation\\day2\\container_orchestration.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation\\day2\\docker_advanced.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation\\day3\\cost_optimization.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation\\day3\\load_balancing.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\automation\\day3\\monitoring.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\install\\install_docker_compose_aws.sh",
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
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day1\\user-data.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\scripts\\aws-ec2-create.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\scripts\\aws-resource-cleanup.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\scripts\\aws-setup-helper.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\scripts\\gcp-compute-create.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\scripts\\gcp-project-cleanup.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\scripts\\gcp-setup-helper.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\integrated_automation\\bridge_scripts\\basic_to_master_bridge.sh",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\integrated_automation\\bridge_scripts\\master_to_container_bridge.sh"
    ]

    js_files = [
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day1\\my-app\\app_v1.js",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day1\\my-app\\app.js",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\actions-demo\\.eslintrc.js",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\actions-demo\\app.js",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\actions-demo\\jest.config.js",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\actions-demo\\tests\\app.test.js",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\my-app\\app_v1.js",
        "C:\\Users\\JIH\\githubs\\mcp_cloud\\mcp_knowledge_base\\cloud_master\\textbook\\Day3\\my-app\\app.js"
    ]

    print("---" + "Checking Python files" + "---")
    errors = []
    for f in py_files:
        if not os.path.exists(f):
            print(f"[ERROR] File not found: {f}")
            errors.append(f)
            continue
        try:
            subprocess.run(['python', '-m', 'py_compile', f], check=True, capture_output=True, text=True, encoding='utf-8')
            print(f"[OK] {f}")
        except subprocess.CalledProcessError as e:
            print(f"[ERROR] {f}\n{e.stderr}")
            errors.append(f)
    
    print("\n" + "---" + "Checking Shell scripts" + "---")
    for f in sh_files:
        if not os.path.exists(f):
            print(f"[ERROR] File not found: {f}")
            errors.append(f)
            continue
        try:
            wsl_path = to_wsl_path(f)
            subprocess.run(['wsl', 'bash', '-n', wsl_path], check=True, capture_output=True, text=True, encoding='utf-8')
            print(f"[OK] {f}")
        except subprocess.CalledProcessError as e:
            print(f"[ERROR] {f}\n{e.stderr}")
            errors.append(f)
        except FileNotFoundError:
            print("[WARNING] wsl not found. Skipping shell script checks.")
            break

    print("\n" + "---" + "Checking JavaScript files" + "---")
    for f in js_files:
        if not os.path.exists(f):
            print(f"[ERROR] File not found: {f}")
            errors.append(f)
            continue
        try:
            subprocess.run(['node', '-c', f], check=True, capture_output=True, text=True, encoding='utf-8')
            print(f"[OK] {f}")
        except subprocess.CalledProcessError as e:
            print(f"[ERROR] {f}\n{e.stderr}")
            errors.append(f)
        except FileNotFoundError:
            print("[WARNING] Node.js not found. Skipping JavaScript checks.")
            break

    print("\n" + "---" + "Summary" + "---")
    if not errors:
        print("All files checked successfully.")
    else:
        print(f"{len(errors)} file(s) with errors:")
        for f in errors:
            print(f"  - {f}")

if __name__ == "__main__":
    check_integrity()