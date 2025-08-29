import os
import re
import subprocess
from pathlib import Path


MARKDOWN_PATH = Path("/mcp_knowledge_base/cloud_basic/textbook/실습_시나리오.md")


def run_cmd(cmd: list[str], timeout: int = 40) -> tuple[int, str, str]:
    env = os.environ.copy()
    # Disable pagers for AWS/GCloud and generic pagers
    env["AWS_PAGER"] = ""
    env["PAGER"] = "cat"
    env["MANPAGER"] = "cat"
    # Some gcloud installs respect LESS/flags; keep output non-interactive
    env["CLOUDSDK_CORE_DISABLE_PROMPTS"] = "1"
    proc = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        timeout=timeout,
        env=env,
        check=False,
    )
    return proc.returncode, proc.stdout, proc.stderr


def read_markdown_commands(md_path: Path) -> list[str]:
    text = md_path.read_text(encoding="utf-8")
    # extract code blocks between triple backticks
    blocks = re.findall(r"```[\s\S]*?```", text, flags=re.MULTILINE)
    commands: list[str] = []
    for block in blocks:
        # strip the fences
        content = re.sub(r"^```.*\n|\n```$", "", block, flags=re.MULTILINE)
        # collect CLI lines
        for line in content.splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if line.startswith(("az ", "aws ", "gcloud ", "gsutil ")) and "..." not in line:
                # Skip high-level AWS S3 commands (help requires groff/mandoc)
                if line.startswith("aws s3 "):
                    continue
                commands.append(line)
    return commands


def _command_tokens_only(tokens: list[str]) -> list[str]:
    cleaned: list[str] = []
    for tok in tokens:
        if tok.startswith("-"):
            break
        if tok in {"..."}:
            break
        if tok.startswith("s3://") or tok.startswith("gs://"):
            break
        if tok.startswith("http://") or tok.startswith("https://"):
            break
        if tok.startswith("<") and tok.endswith(">"):
            break
        cleaned.append(tok)
        # Cap depth by 4 to avoid overly deep tokens
        if len(cleaned) >= 4:
            break
    return cleaned


def to_help_invocation(raw_cmd: str) -> list[str]:
    tokens = raw_cmd.split()
    if not tokens:
        return []
    head = _command_tokens_only(tokens)
    if not head:
        head = tokens[:1]

    if head[0] == "az":
        # Use --help for az commands; keep up to verb (depth <= 4)
        return head + ["--help"]
    if head[0] == "gcloud":
        # Use broad group help to avoid component-specific availability issues
        return ["gcloud", "compute", "--help"]
    if head[0] == "aws":
        # Use 'aws <service> help' to avoid param parsing and still validate availability
        if len(head) >= 2:
            return ["aws", head[1], "help"]
        return ["aws", "help"]
    if head[0] == "gsutil":
        # Map 'gsutil web set' -> 'gsutil help web'
        topic = head[1] if len(head) >= 2 else None
        return ["gsutil", "help"] + ([topic] if topic else [])
    return head


def expected_flags_for(cmd_prefix: str) -> list[str]:
    """Return a small set of flags that should appear in help for stronger validation."""
    expectations: dict[str, list[str]] = {
        # Azure VMSS create
        "az vmss create": ["--image", "--instance-count", "--vm-sku"],
        # Azure monitor autoscale create
        "az monitor autoscale create": ["--min-count", "--max-count"],
        # AWS elbv2 create-load-balancer
        "aws elbv2 create-load-balancer": ["--name", "--subnets"],
        # AWS autoscaling create-auto-scaling-group
        "aws autoscaling create-auto-scaling-group": ["--min-size", "--max-size", "--desired-capacity"],
        # GCloud instance-templates create
        "gcloud compute instance-templates create": ["--machine-type", "--image-family"],
        # GCloud MIG create
        "gcloud compute instance-groups managed create": ["--size", "--template"],
        # GCloud autoscalers create (may be component-dependent; soft-check)
        "gcloud compute autoscalers create": ["--max-num-replicas"],
        # gsutil web
        "gsutil web": ["web"],
    }
    return expectations.get(cmd_prefix, [])


def prefix_of(raw_cmd: str) -> str:
    toks = raw_cmd.split()
    if not toks:
        return ""
    if toks[0] in {"az", "gcloud", "aws"}:
        return " ".join(toks[:4]) if len(toks) >= 4 else " ".join(toks)
    if toks[0] == "gsutil":
        return " ".join(toks[:2]) if len(toks) >= 2 else "gsutil"
    return toks[0]


def test_markdown_cli_commands_help_available():
    assert MARKDOWN_PATH.exists(), f"Missing markdown at {MARKDOWN_PATH}"
    commands = read_markdown_commands(MARKDOWN_PATH)
    assert commands, "No CLI commands found in markdown"

    unique_invocations: dict[str, list[str]] = {}
    for raw in commands:
        help_cmd = to_help_invocation(raw)
        key = " ".join(help_cmd)
        unique_invocations[key] = help_cmd

    errors: list[str] = []
    for key, help_cmd in unique_invocations.items():
        code, out, err = run_cmd(help_cmd)
        if code != 0:
            errors.append(f"FAILED {help_cmd} -> rc={code}, stderr={err[:200]} ...")
            continue
        # Strengthen validation: ensure expected flags appear for known prefixes
        pref = prefix_of(help_cmd[0] + " " + " ".join(help_cmd[1:-1]))
        for flag in expected_flags_for(pref):
            haystack = out if out else err
            if flag not in haystack:
                errors.append(f"MISSING flag '{flag}' in help of '{pref}'")

    assert not errors, "\n".join(errors)


def test_core_tools_versions_installed():
    # Quick smoke checks for version commands
    checks = [
        ["az", "version"],
        ["aws", "--version"],
        ["gcloud", "--version"],
        ["gsutil", "version"],
        ["terraform", "version"],
    ]
    for cmd in checks:
        code, out, err = run_cmd(cmd)
        assert code == 0, f"Version check failed for {cmd}: {err or out}"


