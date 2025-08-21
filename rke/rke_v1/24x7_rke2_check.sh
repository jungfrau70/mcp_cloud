#!/bin/bash



# RKE2 24x7 ?먭? ?ㅽ겕由쏀듃 (?ㅼ튂???대윭?ㅽ꽣 ?댁쁺吏?먯슜)

# (Azure VM + RHEL9 OS ?섍꼍 ?꾩슜)



# ?섍꼍 蹂???뚯씪 濡쒕뱶 諛?寃利?
if [ ! -f "./24x7_rke2_check.env" ]; then
    echo "?ㅻ쪟: 24x7_rke2_check.env ?뚯씪??李얠쓣 ???놁뒿?덈떎."
    echo "湲곕낯 ?섍꼍 蹂?섎? ?ъ슜?⑸땲??"
    # 湲곕낯 ?섍꼍 蹂???ㅼ젙
    export LOG_LEVEL="${LOG_LEVEL:-INFO}"
    export TIMEOUT="${TIMEOUT:-30}"
    export LOG_DIR="${LOG_DIR:-./logs}"
    export RKE2_CONFIG_PATH="${RKE2_CONFIG_PATH:-/etc/rancher/rke2}"
    export KUBECONFIG="${KUBECONFIG:-/etc/rancher/rke2/rke2.yaml}"
else
    source ./24x7_rke2_check.env
fi

# ?섍꼍 蹂??寃利?
validate_environment() {
    local required_vars=("KUBECONFIG")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        echo "?ㅻ쪟: ?꾩닔 ?섍꼍 蹂?섍? ?ㅼ젙?섏? ?딆븯?듬땲?? ${missing_vars[*]}"
        exit 1
    fi
    
    # kubectl ?묎렐 媛???щ? ?뺤씤
    if ! kubectl cluster-info &>/dev/null; then
        echo "?ㅻ쪟: kubectl濡??대윭?ㅽ꽣???묎렐?????놁뒿?덈떎."
        echo "KUBECONFIG 寃쎈줈瑜??뺤씤?섏꽭?? $KUBECONFIG"
        exit 1
    fi
}

# ?섍꼍 蹂??寃利??ㅽ뻾
validate_environment



# 湲곕낯 媛??ㅼ젙

LOG_DIR="./logs"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

LOG_FILE="${LOG_DIR}/24x7_rke2_${TIMESTAMP}.log"

HTML_LOG_FILE="${LOG_DIR}/24x7_rke2_${TIMESTAMP}.html"

TIMEOUT=30  # 紐낅졊???ㅽ뻾 ??꾩븘??(珥?



# 濡쒓렇 ?붾젆?좊━媛 ?놁쑝硫??앹꽦

mkdir -p ${LOG_DIR}



# ?됱긽 肄붾뱶 ?뺤쓽

RED='\033[0;31m'

GREEN='\033[0;32m'

YELLOW='\033[1;33m'

BLUE='\033[0;34m'

NC='\033[0m' # No Color

BOLD='\033[1m'



# 濡쒓렇 ?뚯씪 珥덇린??

init_log_files() {

    cat > ${LOG_FILE} << EOF

============================================

     RKE2 24x7 紐⑤땲?곕쭅 蹂닿퀬??

     ?ㅽ뻾 ?쒓컖: $(date)

============================================



EOF



    cat > ${HTML_LOG_FILE} << EOF

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <style>

        body { font-family: Arial, sans-serif; margin: 20px; }

        .header { background-color: #f8f9fa; padding: 20px; border-radius: 5px; }

        .section { margin: 20px 0; padding: 15px; border: 1px solid #dee2e6; border-radius: 5px; }

        .success { color: #28a745; }

        .warning { color: #ffc107; }

        .error { color: #dc3545; }

        .info { color: #17a2b8; }

        .timestamp { color: #6c757d; }

        .summary { background-color: #e9ecef; padding: 15px; margin-top: 20px; border-radius: 5px; }

        table { width: 100%; border-collapse: collapse; margin: 10px 0; }

        th, td { padding: 8px; text-align: left; border: 1px solid #dee2e6; }

        th { background-color: #f8f9fa; }

        .status-ok { color: #28a745; }

        .status-warning { color: #ffc107; }

        .status-error { color: #dc3545; }

        .details { margin-left: 20px; }

    </style>

</head>

<body>

    <div class="header">

        <h1>RKE2 24x7 紐⑤땲?곕쭅 蹂닿퀬??/h1>

        <p class="timestamp">?먭? ?쒓컖: $(date)</p>

    </div>

EOF

}



# 誘쇨컧 ?뺣낫 留덉뒪???⑥닔 (RKE2 ?뱁솕 媛뺥솕)

mask_sensitive_info() {
    local content="$1"
    local patterns=(
        # UUID ?⑦꽩
        's/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/********-****-****-****-************/gi'
        
        # Base64 ?몄퐫?⑸맂 ?좏겙/?몄쬆??
        's/[A-Za-z0-9+/]{88,90}=[A-Za-z0-9+/]*={0,2}/************************************/g'
        's/[A-Za-z0-9+/]{40,}=[A-Za-z0-9+/]*={0,2}/****************************/g'
        
        # Azure 愿??誘쇨컧 ?뺣낫
        's/"clientId": "[^"]*"/"clientId": "****"/g'
        's/"clientSecret": "[^"]*"/"clientSecret": "****"/g'
        's/"subscriptionId": "[^"]*"/"subscriptionId": "****"/g'
        's/"tenantId": "[^"]*"/"tenantId": "****"/g'
        's/"resourceGroup": "[^"]*"/"resourceGroup": "****"/g'
        
        # SSH ??
        's/ssh-rsa [A-Za-z0-9+/]+[=]*/ssh-rsa ****/g'
        's/ssh-ed25519 [A-Za-z0-9+/]+[=]*/ssh-ed25519 ****/g'
        
        # ?쇰컲?곸씤 誘쇨컧 ?뺣낫
        's/password[=:][ ]*[^ ]*\b/password: ****/gi'
        's/secret[=:][ ]*[^ ]*\b/secret: ****/gi'
        's/token[=:][ ]*[^ ]*\b/token: ****/gi'
        's/key[=:][ ]*[^ ]*\b/key: ****/gi'
        's/credential[=:][ ]*[^ ]*\b/credential: ****/gi'
        
        # RKE2 ?뱁솕 誘쇨컧 ?뺣낫
        's/"clusterSecret": "[^"]*"/"clusterSecret": "****"/g'
        's/"serviceAccountToken": "[^"]*"/"serviceAccountToken": "****"/g'
        's/"caCert": "[^"]*"/"caCert": "****"/g'
        's/"clientCert": "[^"]*"/"clientCert": "****"/g'
        's/"clientKey": "[^"]*"/"clientKey": "****"/g'
        
        # etcd 愿??誘쇨컧 ?뺣낫
        's/"etcdKey": "[^"]*"/"etcdKey": "****"/g'
        's/"etcdCert": "[^"]*"/"etcdCert": "****"/g'
        
        # containerd 愿??誘쇨컧 ?뺣낫
        's/"registryPassword": "[^"]*"/"registryPassword": "****"/g'
        's/"registryUsername": "[^"]*"/"registryUsername": "****"/g'
        
        # ?ㅽ듃?뚰겕 愿??誘쇨컧 ?뺣낫
        's/"wireguardKey": "[^"]*"/"wireguardKey": "****"/g'
        's/"vpnKey": "[^"]*"/"vpnKey": "****"/g'
    )
    
    local masked_content="$content"
    for pattern in "${patterns[@]}"; do
        masked_content=$(echo "$masked_content" | sed -E "$pattern")
    done
    
    echo "$masked_content"
}



# 濡쒓렇 硫붿떆吏 異쒕젰 ?⑥닔

log_message() {

    local message="$1"

    local level="${2:-INFO}"

    message=$(echo -e "$message")

    local masked_message=$(mask_sensitive_info "$message")

    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local html_message=$(echo "$masked_message" | sed ':a;N;$!ba;s/\n/<br>/g')



    case $level in

        "ERROR")

            printf "${RED}[?ㅻ쪟]${NC} %b\n" "$masked_message" >&2

            printf "[%s] [?ㅻ쪟] %b\n" "$timestamp" "$masked_message" >> ${LOG_FILE}

            echo "<div class='section error'><strong>?ㅻ쪟:</strong> $html_message</div>" >> ${HTML_LOG_FILE}

            ;;

        "WARNING")

            printf "${YELLOW}[寃쎄퀬]${NC} %b\n" "$masked_message"

            printf "[%s] [寃쎄퀬] %b\n" "$timestamp" "$masked_message" >> ${LOG_FILE}

            echo "<div class='section warning'><strong>寃쎄퀬:</strong> $html_message</div>" >> ${HTML_LOG_FILE}

            ;;

        "SUCCESS")

            printf "${GREEN}[?깃났]${NC} %b\n" "$masked_message"

            printf "[%s] [?깃났] %b\n" "$timestamp" "$masked_message" >> ${LOG_FILE}

            echo "<div class='section success'><strong>?깃났:</strong> $html_message</div>" >> ${HTML_LOG_FILE}

            ;;

        "SECTION")

            printf "\n${BLUE}${BOLD}=== %b ===${NC}\n" "$masked_message"

            printf "\n===========================================\n" >> ${LOG_FILE}

            printf "[%s] === %b ===\n" "$timestamp" "$masked_message" >> ${LOG_FILE}

            printf "===========================================\n" >> ${LOG_FILE}

            echo "<div class='section'><h2>$html_message</h2>" >> ${HTML_LOG_FILE}

            ;;

        "SECTION_END")

            echo "</div>" >> ${HTML_LOG_FILE}

            ;;

        *)

            printf "%b\n" "$masked_message"

            printf "[%s] %b\n" "$timestamp" "$masked_message" >> ${LOG_FILE}

            echo "<div class='details'>$html_message</div>" >> ${HTML_LOG_FILE}

            ;;

    esac

}



# ?ㅻ쪟 泥섎━ ?⑥닔

handle_error() {

    local error_message="$1"

    log_message "?ㅻ쪟 諛쒖깮: ${error_message}" "ERROR"

    return 1

}



# ?덉쟾??紐낅졊???ㅽ뻾 ?⑥닔 (RKE2 ?뱁솕 媛쒖꽑)

safe_execute() {
    local command="$1"
    local timeout="${2:-${TIMEOUT:-30}}"
    local retry_count="${3:-0}"
    local max_retries="${4:-2}"
    
    # 紐낅졊??寃利?(湲곕낯?곸씤 ?몄젥??諛⑹?)
    if [[ "$command" =~ [\&\|\`\;] ]]; then
        log_message "?좎옱???꾪뿕??紐낅졊??媛먯?: $command" "ERROR"
        return 1
    fi
    
    local output
    local exit_code
    
    for ((i=0; i<=max_retries; i++)); do
        if output=$(timeout "$timeout" bash -c "$command" 2>&1); then
            exit_code=0
            break
        else
            exit_code=$?
            if [[ $i -lt $max_retries ]]; then
                log_message "紐낅졊???ъ떆??以?.. ($((i+1))/$((max_retries+1))): $command" "WARNING"
                sleep 2
            fi
        fi
    done
    
    case $exit_code in
        0)
            log_message "$(mask_sensitive_info "$output")"
            return 0
            ;;
        124)
            log_message "紐낅졊???ㅽ뻾 ?쒓컙 珥덇낵 (${timeout}珥?: $command" "ERROR"
            return 1
            ;;
        126)
            log_message "紐낅졊?대? ?ㅽ뻾?????놁뒿?덈떎: $command" "ERROR"
            return 1
            ;;
        127)
            log_message "紐낅졊?대? 李얠쓣 ???놁뒿?덈떎: $command" "ERROR"
            return 1
            ;;
        *)
            log_message "紐낅졊???ㅽ뻾 ?ㅽ뙣 (exit: $exit_code): $command" "ERROR"
            log_message "$(mask_sensitive_info "$output")" "ERROR"
            return 1
            ;;
    esac
}

# 湲곗〈 log_command ?⑥닔瑜?safe_execute濡??泥?
log_command() {
    safe_execute "$1"
}



# ?꾩닔 ?꾧뎄 ?ㅼ튂 ?щ? ?뺤씤 (RKE2 ?뱁솕)

check_prerequisites() {
    log_message "\n=== ?꾩닔 ?꾧뎄 ?ㅼ튂 ?щ? ?뺤씤 ===" "SECTION"
    
    local required_tools=("kubectl" "jq")
    local optional_tools=("rke2" "helm" "k9s")
    local missing_required=()
    local missing_optional=()
    
    # ?꾩닔 ?꾧뎄 ?뺤씤
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_required+=("$tool")
        fi
    done
    
    # ?좏깮???꾧뎄 ?뺤씤
    for tool in "${optional_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_optional+=("$tool")
        fi
    done
    
    # 寃곌낵 蹂닿퀬
    if [[ ${#missing_required[@]} -gt 0 ]]; then
        log_message "?ㅻ쪟: ?꾩닔 ?꾧뎄媛 ?ㅼ튂?섏뼱 ?덉? ?딆뒿?덈떎: ${missing_required[*]}" "ERROR"
        exit 1
    fi
    
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        log_message "寃쎄퀬: ?좏깮???꾧뎄媛 ?ㅼ튂?섏뼱 ?덉? ?딆뒿?덈떎: ${missing_optional[*]}" "WARNING"
    fi
    
    # RKE2 ?뱁솕 ?뺤씤
    if command -v rke2 &> /dev/null; then
        log_message "RKE2 踰꾩쟾: $(rke2 -v)" "SUCCESS"
    else
        log_message "RKE2媛 ?ㅼ튂?섏뼱 ?덉? ?딆뒿?덈떎 (?좏깮??" "WARNING"
    fi
    
    # kubectl 踰꾩쟾 ?뺤씤
    log_message "kubectl 踰꾩쟾: $(kubectl version --short 2>/dev/null || echo '踰꾩쟾 ?뺣낫 ?놁쓬')" "SUCCESS"
    
    log_message "紐⑤뱺 ?꾩닔 ?꾧뎄媛 ?ㅼ튂?섏뼱 ?덉뒿?덈떎" "SUCCESS"
    log_message "" "SECTION_END"
}



# RKE2/?대윭?ㅽ꽣 ?뺣낫 ?뺤씤

check_cluster_info() {

    log_message "\n=== RKE2 諛??대윭?ㅽ꽣 ?뺣낫 ?뺤씤 ===" "SECTION"

    log_command "rke2 -v"

    log_command "kubectl version --short"

    log_command "kubectl cluster-info"

    log_message "" "SECTION_END"

}



# etcd/Control-plane ?곹깭 ?뺤씤

check_control_plane() {

    log_message "\n=== etcd 諛?Control-plane ?곹깭 ===" "SECTION"

    log_command "kubectl get pods -n kube-system -l component=etcd -o wide"

    # etcd health (???몃뱶?먯꽌留??섑뻾)

    ETCD_POD=$(kubectl get pod -n kube-system -l component=etcd -o jsonpath='{.items[0].metadata.name}')

    if [ -n "$ETCD_POD" ]; then

        log_command "kubectl -n kube-system exec -it $ETCD_POD -- etcdctl endpoint health --cluster"

    fi

    log_command "kubectl get pods -n kube-system -l 'component in (etcd, kube-apiserver, kube-controller-manager, kube-scheduler)' -o wide"

    log_message "" "SECTION_END"

}



# ?꾩껜 ?몃뱶/?쇰꺼/taint ???곹깭

check_node_overview() {

    log_message "\n=== ?꾩껜 ?몃뱶/?덉씠釉?taint ?꾪솴 ===" "SECTION"

    log_command "kubectl get nodes -o wide"

    log_command "kubectl get nodes --show-labels"

    log_command "kubectl get nodes -o json | jq '.items[].spec.taints'"

    log_message "" "SECTION_END"

}



# ??븷蹂??몃뱶(Master/Worker/OSS) ?먭?

check_role_nodes() {

    log_message "\n=== Master/Worker/OSS Node ?곹깭 ?먭? ===" "SECTION"

    declare -A node_roles=( ["master"]="node-role.kubernetes.io/master=" ["worker"]="node-role.kubernetes.io/worker=" ["oss"]="node-role.kubernetes.io/oss=" )



    for role in "${!node_roles[@]}"; do

        log_message "\n[${role^^} Node]" "SUCCESS"

        NODES=$(kubectl get nodes -l ${node_roles[$role]} -o jsonpath='{.items[*].metadata.name}')

        if [ -z "$NODES" ]; then

            log_message "?대떦 ??븷($role) ?몃뱶媛 議댁옱?섏? ?딆뒿?덈떎" "WARNING"

            continue

        fi

        for NODE in $NODES; do

            log_message "\n--- $role: $NODE ---"

            log_command "kubectl describe node $NODE"

            log_command "kubectl get pods -A -o wide --field-selector spec.nodeName=$NODE"

        done

    done

    log_message "" "SECTION_END"

}



# ?꾩껜 ?ㅼ엫?ㅽ럹?댁뒪/?뚮뱶/由ъ냼???곹깭

check_namespace_pod() {

    log_message "\n=== ?ㅼ엫?ㅽ럹?댁뒪/?뚮뱶/由ъ냼???곹깭 ===" "SECTION"

    log_command "kubectl get ns"

    log_command "kubectl get pods -A -o wide"

    log_command "kubectl top node"

    log_command "kubectl top pod -A"

    log_message "" "SECTION_END"

}



# ?ㅽ넗由ъ? 諛??명봽??由ъ냼??

check_storage_infra() {

    log_message "\n=== ?ㅽ넗由ъ? 諛??명봽???댁쁺???쒕퉬???? ===" "SECTION"

    log_command "kubectl get sc"

    log_command "kubectl get pv -A"

    log_command "kubectl get pvc -A"

    log_command "kubectl get deploy -A"

    log_command "kubectl get svc -A"

    log_command "kubectl get ingress -A"

    log_command "kubectl get hpa -A"

    log_command "kubectl get pdb -A"

    log_command "kubectl get rs -A"

    log_command "kubectl get networkpolicy -A"

    log_message "" "SECTION_END"

}



# OSS ?댁쁺???곹깭 (?ㅼ엫?ㅽ럹?댁뒪 議곗젙 ?꾩슂)

check_oss_tools() {

    log_message "\n=== ?댁쁺??Grafana, Prometheus, Loki, Harbor) ?곹깭 ===" "SECTION"

    log_command "kubectl get pods -n monitoring"

    log_command "kubectl get pods -n logging"

    log_command "kubectl get pods -n harbor"

    log_command "kubectl get svc -n harbor"

    log_command "kubectl get ingress -n harbor"

    log_command "kubectl get pods -n kube-system | grep csi-azure"

    log_message "" "SECTION_END"

}



# ?쒖뒪???먭?(由щ늼??由ъ냼??蹂댁븞 ??

check_system() {

    log_message "\n=== ?쒖뒪??由ъ냼??諛?蹂댁븞 ?곹깭 ===" "SECTION"

    log_command "free -h"

    log_command "df -h"

    log_command "uptime"

    log_command "ss -tulpn | grep -E '6443|2379|2380|10250'"

    log_command "ps aux | grep -E 'rke2|etcd|containerd'"

    log_command "getenforce"

    log_command "firewall-cmd --state"

    log_command "sysctl -a | grep -E 'vm.max_map_count|fs.inotify.max_user_watches'"

    log_message "" "SECTION_END"

}



# RKE2 ?뱁솕 ?먭? ?⑥닔??

check_rke2_specific() {
    log_message "\n=== RKE2 ?뱁솕 援ъ꽦 諛??곹깭 ===" "SECTION"
    
    # RKE2 ?ㅼ젙 ?뚯씪 ?뺤씤
    log_message "[RKE2 ?ㅼ젙 ?뚯씪]"
    safe_execute "ls -la ${RKE2_CONFIG_PATH:-/etc/rancher/rke2}/"
    safe_execute "cat ${RKE2_CONFIG_PATH:-/etc/rancher/rke2}/config.yaml 2>/dev/null || echo '?ㅼ젙 ?뚯씪 ?놁쓬'"
    
    # RKE2 ?쒕퉬???곹깭
    log_message "[RKE2 ?쒕퉬???곹깭]"
    safe_execute "systemctl status rke2-server --no-pager -l"
    safe_execute "systemctl status rke2-agent --no-pager -l"
    
    # RKE2 ?꾨줈?몄뒪 ?뺤씤
    log_message "[RKE2 ?꾨줈?몄뒪]"
    safe_execute "ps aux | grep -E 'rke2|containerd' | grep -v grep"
    
    # RKE2 ?곗씠???붾젆?좊━
    log_message "[RKE2 ?곗씠???붾젆?좊━]"
    safe_execute "du -sh /var/lib/rancher/rke2/ 2>/dev/null || echo '?곗씠???붾젆?좊━ ?놁쓬'"
    safe_execute "ls -la /var/lib/rancher/rke2/ 2>/dev/null || echo '?곗씠???붾젆?좊━ ?놁쓬'"
    
    log_message "" "SECTION_END"
}

check_rke2_etcd() {
    log_message "\n=== RKE2 etcd ?곹깭 (?댁옣) ===" "SECTION"
    
    # etcd ?뚮뱶 ?뺤씤
    local etcd_pods=$(kubectl get pods -n kube-system -l component=etcd -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    
    if [[ -n "$etcd_pods" ]]; then
        for pod in $etcd_pods; do
            log_message "[etcd ?뚮뱶: $pod]"
            safe_execute "kubectl describe pod $pod -n kube-system"
            safe_execute "kubectl logs $pod -n kube-system --tail=50"
        done
        
        # etcd ?곹깭 ?뺤씤
        local first_etcd_pod=$(echo "$etcd_pods" | awk '{print $1}')
        if [[ -n "$first_etcd_pod" ]]; then
            log_message "[etcd ?대윭?ㅽ꽣 ?곹깭]"
            safe_execute "kubectl -n kube-system exec $first_etcd_pod -- etcdctl endpoint health --cluster"
            safe_execute "kubectl -n kube-system exec $first_etcd_pod -- etcdctl member list"
        fi
    else
        log_message "etcd ?뚮뱶瑜?李얠쓣 ???놁뒿?덈떎" "WARNING"
    fi
    
    log_message "" "SECTION_END"
}

check_rke2_containerd() {
    log_message "\n=== RKE2 containerd ?곹깭 ===" "SECTION"
    
    # containerd ?쒕퉬???곹깭
    safe_execute "systemctl status containerd --no-pager -l"
    
    # containerd ?꾨줈?몄뒪
    safe_execute "ps aux | grep containerd | grep -v grep"
    
    # containerd ?뚯폆 ?뺤씤
    safe_execute "ls -la /run/containerd/containerd.sock 2>/dev/null || echo 'containerd ?뚯폆 ?놁쓬'"
    
    # 而⑦뀒?대꼫 紐⑸줉
    safe_execute "crictl ps -a 2>/dev/null || echo 'crictl ?ъ슜 遺덇?'"
    
    # ?대?吏 紐⑸줉
    safe_execute "crictl images 2>/dev/null || echo 'crictl ?ъ슜 遺덇?'"
    
    log_message "" "SECTION_END"
}

check_rke2_security() {
    log_message "\n=== RKE2 蹂댁븞 ?ㅼ젙 ===" "SECTION"
    
    # SELinux ?곹깭
    safe_execute "getenforce"
    safe_execute "sestatus"
    
    # AppArmor ?곹깭
    safe_execute "aa-status 2>/dev/null || echo 'AppArmor ?ъ슜 ?덊븿'"
    
    # 諛⑺솕踰??곹깭
    safe_execute "firewall-cmd --state"
    safe_execute "firewall-cmd --list-all"
    
    # RKE2 蹂댁븞 ?꾨줈?뚯씪
    safe_execute "grep -r 'profile' ${RKE2_CONFIG_PATH:-/etc/rancher/rke2}/config.yaml 2>/dev/null || echo '蹂댁븞 ?꾨줈?뚯씪 ?ㅼ젙 ?놁쓬'"
    
    # mTLS ?ㅼ젙 ?뺤씤
    safe_execute "kubectl get configmap -n kube-system rke2-canal-config -o yaml 2>/dev/null || echo 'Canal ?ㅼ젙 ?놁쓬'"
    
    log_message "" "SECTION_END"
}

# ?μ븷 吏뺥썑(RKE2 ?쒕쾭 濡쒓렇 ??

check_rke2_logs() {
    log_message "\n=== RKE2 ?μ븷 吏뺥썑(濡쒓렇) ===" "SECTION"
    
    # RKE2 ?쒕쾭 濡쒓렇
    log_message "[RKE2 ?쒕쾭 濡쒓렇]"
    safe_execute "journalctl -u rke2-server -n 100 --no-pager"
    
    # RKE2 ?먯씠?꾪듃 濡쒓렇
    log_message "[RKE2 ?먯씠?꾪듃 濡쒓렇]"
    safe_execute "journalctl -u rke2-agent -n 100 --no-pager"
    
    # containerd 濡쒓렇
    log_message "[containerd 濡쒓렇]"
    safe_execute "journalctl -u containerd -n 50 --no-pager"
    
    # ?쒖뒪??濡쒓렇?먯꽌 RKE2 愿???ㅻ쪟
    log_message "[?쒖뒪??濡쒓렇 RKE2 ?ㅻ쪟]"
    safe_execute "journalctl -n 200 | grep -i 'rke2\|containerd' | grep -i 'error\|fail'"
    
    log_message "" "SECTION_END"
}



# 硫붿씤 ?ㅽ뻾 (RKE2 ?뱁솕 媛쒖꽑)

main() {
    init_log_files
    
    # ?쒖옉 ?쒓컙 湲곕줉
    local start_time=$(date +%s)
    
    log_message "RKE2 24x7 紐⑤땲?곕쭅 ?쒖옉 - $(date)" "SUCCESS"
    
    check_prerequisites
    check_cluster_info
    check_control_plane
    check_node_overview
    check_role_nodes
    check_namespace_pod
    check_storage_infra
    check_oss_tools
    check_system
    
    # RKE2 ?뱁솕 ?먭? 異붽?
    check_rke2_specific
    check_rke2_etcd
    check_rke2_containerd
    check_rke2_security
    check_rke2_logs
    
    # 醫낅즺 ?쒓컙 諛??뚯슂 ?쒓컙 怨꾩궛
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_message "\n=== ?곹깭 ?먭? ?꾨즺 ===" "SUCCESS"
    log_message "?뚯슂 ?쒓컙: ${duration}珥? "INFO"
    log_message "?곸꽭 寃곌낵???ㅼ쓬 ?뚯씪?먯꽌 ?뺤씤?????덉뒿?덈떎: ${LOG_FILE}" "INFO"
    log_message "HTML 蹂닿퀬?? ${HTML_LOG_FILE}" "INFO"
}



main
