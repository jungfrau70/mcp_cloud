#!/bin/bash

# =============================================================================
# WSL Management Tool
# A script to manage the WSL environment for the Cloud Master course.
# =============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Log Functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}[HEADER]${NC} $1"; }
log_wsl() { echo -e "${CYAN}[WSL]${NC} $1"; }

# Settings
DISTRO_NAME="Ubuntu-22.04"
USER_NAME="clouduser"
WORKSPACE_DIR="$HOME/mcp-cloud-workspace"
PROJECT_DIR="$WORKSPACE_DIR/mcp_cloud"

# =============================================================================
# WSL Management Functions
# =============================================================================

# Helper function to execute WSL commands
run_wsl_command() {
    if command -v wsl &> /dev/null; then
        wsl.exe "$@"
    elif command -v wsl.exe &> /dev/null; then
        wsl.exe "$@"
    else
        log_error "WSL is not installed."
        return 1
    fi
}

# List WSL distributions
list_wsl_distros() {
    log_info "Listing WSL distributions..."
    echo ""
    run_wsl_command --list --verbose
}

# Get WSL distribution names (MODIFIED for encoding issues)
get_wsl_distros() {
    # The output from wsl.exe can be UTF-16LE, which needs to be converted for awk.
    # We convert to UTF-8, remove carriage returns, and then parse based on whether it's the default distro.
    run_wsl_command --list --verbose | iconv -f UTF-16LE -t UTF-8 | sed 's/\r$//' | awk 'NR>1 {if ($1 == "*") {print $2} else {print $1}}'
}


# WSL distribution selection menu
select_wsl_distro() {
    local action="$1"
    
    echo ""
    log_info "Select a WSL distribution to $action:"
    
    # Read distribution list into an array
    mapfile -t distros < <(get_wsl_distros)
    
    if [ ${#distros[@]} -eq 0 ]; then
        log_error "No installed WSL distributions found."
        return 1
    fi
    
    echo ""
    # Display menu options for each item in the array
    for i in "${!distros[@]}"; do
        printf "  %d. %s\n" "$((i+1))" "${distros[$i]}"
    done
    echo ""
    
    local choice
    echo -n "Select (1-${#distros[@]}): "
    read -r choice
    
    # Validate that the input is a number within the valid range
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#distros[@]} ]; then
        # Output the selected distribution name to stdout
        echo "${distros[$((choice-1))]}"
        return 0
    else
        log_error "Invalid selection."
        return 1
    fi
}

# Check WSL distribution status (MODIFIED for encoding issues)
check_wsl_status() {
    local distro_name="$1"
    
    log_info "Checking status of WSL distribution: $distro_name"
    
    # Convert WSL output from UTF-16LE to UTF-8 to ensure correct parsing
    local wsl_list_output
    wsl_list_output=$(run_wsl_command --list --verbose | iconv -f UTF-16LE -t UTF-8 | sed 's/\r$//')

    if echo "$wsl_list_output" | grep -qw "$distro_name"; then
        local status
        # For the default distro (marked with '*'), the status is in field 3. For others, it's in field 2.
        status=$(echo "$wsl_list_output" | grep -w "$distro_name" | awk '{if ($1 == "*") {print $3} else {print $2}}')
        case "$status" in
            "Running")
                log_success "✅ $distro_name: Running"
                ;;
            "Stopped")
                log_warning "⚠️ $distro_name: Stopped"
                ;;
            *)
                log_warning "⚠️ $distro_name: Unknown status ($status)"
                ;;
        esac
    else
        log_error "❌ $distro_name: Not installed"
        return 1
    fi
}

# Stop a WSL distribution
stop_wsl_distro() {
    local distro_name="$1"
    
    log_warning "Stopping WSL distribution: $distro_name"
    echo -n "Are you sure you want to stop it? (y/N): "
    read -r response || {
        log_error "Failed to read input."
        return 1
    }
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "Stop operation cancelled."
        return 0
    fi
    
    log_info "Stopping WSL distribution: $distro_name"
    
    if run_wsl_command --terminate "$distro_name"; then
        log_success "Successfully stopped WSL distribution: $distro_name"
    else
        log_error "Failed to stop WSL distribution: $distro_name"
        return 1
    fi
}

# Delete a WSL distribution
delete_wsl_distro() {
    local distro_name="$1"
    
    log_error "⚠️ WARNING: Deleting WSL distribution: $distro_name"
    log_warning "This operation cannot be undone!"
    echo -n "Are you sure you want to delete it? (y/N): "
    read -r response || {
        log_error "Failed to read input."
        return 1
    }
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "Delete operation cancelled."
        return 0
    fi
    
    # One more confirmation
    echo -n "Please type 'DELETE' to confirm deletion. All data will be lost: "
    read -r confirm || {
        log_error "Failed to read input."
        return 1
    }
    
    if [[ "$confirm" != "DELETE" ]]; then
        log_info "Delete operation cancelled."
        return 0
    fi
    
    log_info "Deleting WSL distribution: $distro_name"
    
    if run_wsl_command --unregister "$distro_name"; then
        log_success "Successfully deleted WSL distribution: $distro_name"
    else
        log_error "Failed to delete WSL distribution: $distro_name"
        return 1
    fi
}

# Create a new WSL distribution
create_wsl_distro() {
    local distro_name="$1"
    
    log_info "Creating WSL distribution: $distro_name"
    
    # Download and install Ubuntu 22.04 LTS
    log_info "Downloading Ubuntu 22.04 LTS..."
    
    if run_wsl_command --install -d "$distro_name"; then
        log_success "Successfully created WSL distribution: $distro_name"
        
        # Wait for initial setup
        log_info "Press Enter after completing the initial setup..."
        read -r
        
        # Setup user
        setup_wsl_user "$distro_name"
        
    else
        log_error "Failed to create WSL distribution: $distro_name"
        return 1
    fi
}

# Setup WSL user
setup_wsl_user() {
    local distro_name="$1"
    
    log_info "Setting up WSL user: $distro_name"
    
    # Create user and grant sudo privileges
    run_wsl_command -d "$distro_name" -u root -- bash -c "
        # Create user
        useradd -m -s /bin/bash $USER_NAME
        
        # Add to sudo group
        usermod -aG sudo $USER_NAME
        
        # Set password
        echo '$USER_NAME:cloud123!' | chpasswd
        
        # Set home directory permissions
        chown -R $USER_NAME:$USER_NAME /home/$USER_NAME
    "
    
    log_success "WSL user setup complete: $USER_NAME"
}

# Restart a WSL distribution
restart_wsl_distro() {
    local distro_name="$1"
    
    log_info "Restarting WSL distribution: $distro_name"
    
    # Stop
    run_wsl_command --terminate "$distro_name" 2>/dev/null || true
    
    # Wait a bit
    sleep 2
    
    # Start
    run_wsl_command -d "$distro_name" -- echo "WSL distribution started."
    
    log_success "WSL distribution restarted: $distro_name"
}

# Backup a WSL distribution
backup_wsl_distro() {
    local distro_name="$1"
    local backup_path="$2"
    
    log_info "Backing up WSL distribution: $distro_name → $backup_path"
    
    # Create backup directory
    mkdir -p "$(dirname "$backup_path")"
    
    # Export WSL distribution
    if run_wsl_command --export "$distro_name" "$backup_path"; then
        log_success "WSL distribution backup complete: $backup_path"
    else
        log_error "Failed to back up WSL distribution: $distro_name"
        return 1
    fi
}

# Restore a WSL distribution
restore_wsl_distro() {
    local distro_name="$1"
    local backup_path="$2"
    local install_location="$3"

    log_info "Restoring WSL distribution: $backup_path → $distro_name"
    
    if [[ ! -f "$backup_path" ]]; then
        log_error "Backup file not found: $backup_path"
        return 1
    fi
    
    # If distribution already exists, unregister it
    if run_wsl_command --list --quiet | grep -q "$distro_name"; then
        log_warning "Deleting existing distribution: $distro_name"
        run_wsl_command --unregister "$distro_name"
    fi
    
    log_info "Restoring to: $install_location"
    mkdir -p "$install_location"

    # Restore from backup
    if run_wsl_command --import "$distro_name" "$install_location" "$backup_path"; then
        log_success "WSL distribution restored: $distro_name"
    else
        log_error "Failed to restore WSL distribution: $distro_name"
        return 1
    fi
}

# Clean up all WSL distributions
cleanup_all_wsl() {
    log_error "⚠️ WARNING: Cleaning up all WSL distributions"
    log_warning "This operation cannot be undone!"
    echo -n "Are you sure you want to delete all WSL distributions? (y/N): "
    read -r response || {
        log_error "Failed to read input."
        return 1
    }
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "Cleanup cancelled."
        return 0
    fi
    
    # One more confirmation
    echo -n "Please type 'DELETE ALL' to confirm: "
    read -r confirm || {
        log_error "Failed to read input."
        return 1
    }
    
    if [[ "$confirm" != "DELETE ALL" ]]; then
        log_info "Cleanup cancelled."
        return 0
    fi
    
    log_info "Cleaning up all WSL distributions..."
    
    # Get all distribution names
    mapfile -t distros < <(get_wsl_distros)
    
    for distro in "${distros[@]}"; do
        log_info "Deleting WSL distribution: $distro"
        run_wsl_command --unregister "$distro" 2>/dev/null || true
    done
    
    log_success "Cleanup of all WSL distributions complete."
}

# =============================================================================
# Main Menu
# =============================================================================

main_menu() {
    while true; do
        clear
        echo ""
        log_header "=== WSL Management Tool ==="
        echo "1. List WSL Distributions"
        echo "2. Check WSL Distribution Status"
        echo "3. Stop WSL Distribution"
        echo "4. Delete WSL Distribution"
        echo "5. Create New WSL Distribution"
        echo "6. Restart WSL Distribution"
        echo "7. Backup WSL Distribution"
        echo "8. Restore WSL Distribution"
        echo "9. Cleanup All WSL Distributions"
        echo "10. Run WSL Auto-Setup"
        echo "11. Exit"
        echo ""
        echo -n "Select (1-11): "
        if ! read -r choice; then
            log_error "Failed to read input."
            continue
        fi

        # Common logic for actions requiring a selection
        handle_selection() {
            local action_name="$1"
            local action_func="$2"
            local distro_name
            distro_name=$(select_wsl_distro "$action_name")
            if [[ $? -eq 0 && -n "$distro_name" ]]; then
                "$action_func" "$distro_name"
                echo ""
                log_info "Press Enter to return to the menu..."
                read -r
            fi
        }
        
        case $choice in
            1)
                list_wsl_distros
                echo ""
                log_info "Press Enter to return to the menu..."
                read -r
                ;;
            2) handle_selection "status check" "check_wsl_status" ;;
            3) handle_selection "stop" "stop_wsl_distro" ;;
            4) handle_selection "delete" "delete_wsl_distro" ;;
            5)
                echo -n "Enter the name for the new distribution (default: $DISTRO_NAME): "
                read -r new_distro_name
                new_distro_name=${new_distro_name:-$DISTRO_NAME}
                
                if get_wsl_distros | grep -q "^$new_distro_name$"; then
                    log_warning "Distribution '$new_distro_name' already exists."
                else
                    create_wsl_distro "$new_distro_name"
                fi
                echo ""
                log_info "Press Enter to return to the menu..."
                read -r
                ;;
            6) handle_selection "restart" "restart_wsl_distro" ;;
            7)
                distro_name=$(select_wsl_distro "backup")
                if [[ $? -eq 0 && -n "$distro_name" ]]; then
                    default_backup_path="$HOME/wsl-backup-$distro_name.tar"
                    echo -n "Enter the backup file path (default: $default_backup_path): "
                    read -r backup_path
                    backup_path=${backup_path:-$default_backup_path}
                    backup_wsl_distro "$distro_name" "$backup_path"
                    echo ""
                    log_info "Press Enter to return to the menu..."
                    read -r
                fi
                ;;
            8)
                echo -n "Enter the name for the new restored distribution: "
                read -r distro_name
                echo -n "Enter the path to the backup file: "
                read -r backup_path
                echo -n "Enter the installation location (e.g., C:\wsl_distros\$distro_name): "
                read -r install_location

                if [[ -n "$distro_name" && -n "$backup_path" && -n "$install_location" ]]; then
                    restore_wsl_distro "$distro_name" "$backup_path" "$install_location"
                else
                    log_error "All fields are required."
                fi
                echo ""
                log_info "Press Enter to return to the menu..."
                read -r
                ;;
            9)
                cleanup_all_wsl
                echo ""
                log_info "Press Enter to return to the menu..."
                read -r
                ;;
            10)
                log_info "Running WSL auto-setup script."
                if [[ -f "./wsl-auto-setup.sh" ]]; then
                    ./wsl-auto-setup.sh
                else
                    log_error "wsl-auto-setup.sh not found."
                fi
                echo ""
                log_info "Press Enter to return to the menu..."
                read -r
                ;;
            11)
                log_info "Exiting WSL Management Tool."
                break
                ;;
            *)
                log_error "Invalid selection. Please choose between 1-11."
                ;;
        esac
    done
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    log_header "=== Starting WSL Management Tool ==="
    
    # Check if WSL is installed
    if ! command -v wsl &> /dev/null && ! command -v wsl.exe &> /dev/null; then
        log_error "WSL is not installed."
        log_info "Please install WSL in Windows and run this script again."
        log_info "How-to: https://docs.microsoft.com/en-us/windows/wsl/install"
        exit 1
    fi
    
    # Run main menu
    main_menu
}

# Execute script
main "$@"

