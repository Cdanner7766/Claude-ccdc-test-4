#!/bin/bash
#
# WCC CCDC Range - Automated Deployment Script
# This script automates the deployment of the Whatcom Community College CCDC practice range
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════╗"
echo "║   WCC CCDC Practice Range Deployment Script          ║"
echo "║   Whatcom Community College                           ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to print status messages
print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[*]${NC} $1"
}

# Check if ludus command exists
if ! command -v ludus &> /dev/null; then
    print_error "Ludus CLI not found. Please install it first."
    echo "Visit: https://docs.ludus.cloud/docs/quick-start/using-cli-locally"
    exit 1
fi

print_status "Ludus CLI found"

# Check if we're in the correct directory
if [ ! -f "range.yaml" ]; then
    print_error "range.yaml not found in current directory"
    print_error "Please run this script from the wcc-ccdc-range directory"
    exit 1
fi

print_status "Found range.yaml configuration"

# Pre-flight checks
echo ""
print_warning "Pre-flight checks..."

# Check Ludus connection
if ! ludus user list &> /dev/null; then
    print_error "Cannot connect to Ludus server"
    print_error "Please check your Ludus configuration and VPN connection"
    exit 1
fi

print_status "Connected to Ludus server"

# Verify templates exist
print_status "Checking for required templates..."
REQUIRED_TEMPLATES=(
    "debian-11-x64-server-template"
    "debian-12-x64-server-template"
    "win11-22h2-x64-enterprise-template"
    "win2022-server-x64-template"
)

MISSING_TEMPLATES=()

for template in "${REQUIRED_TEMPLATES[@]}"; do
    if ! ludus templates list | grep -q "$template"; then
        MISSING_TEMPLATES+=("$template")
    fi
done

if [ ${#MISSING_TEMPLATES[@]} -ne 0 ]; then
    print_error "Missing required templates:"
    for template in "${MISSING_TEMPLATES[@]}"; do
        echo "  - $template"
    done
    echo ""
    echo "Please build these templates first:"
    echo "  https://docs.ludus.cloud/docs/quick-start/build-templates"
    exit 1
fi

print_status "All required templates found"

# Add Ansible roles
echo ""
print_status "Adding Ansible roles..."

ROLES=(
    "wcc_scoring_engine"
    "wcc_sysmon_install"
    "wcc_ad_vulnerable_setup"
    "wcc_fileserver_setup"
    "wcc_iis_ecommerce_setup"
    "wcc_exchange_setup"
    "wcc_sqlserver_setup"
    "wcc_bind_dhcp_setup"
    "wcc_linux_logging"
    "wcc_lamp_setup"
    "wcc_vsftpd_setup"
    "wcc_kali_setup"
)

for role in "${ROLES[@]}"; do
    if [ -d "roles/$role" ]; then
        print_status "Adding role: $role"
        ludus ansible role add -d "./roles/$role/" || print_warning "Role may already exist: $role"
    else
        print_warning "Role directory not found: $role (skipping)"
    fi
done

# Verify roles were added
echo ""
print_status "Verifying roles..."
if ! ludus ansible roles list | grep -q "wcc_"; then
    print_error "Failed to add WCC roles"
    exit 1
fi

print_status "All roles added successfully"

# Set range configuration
echo ""
print_status "Setting range configuration..."
ludus range config set -f ./range.yaml

print_status "Range configuration set"

# Ask for confirmation before deployment
echo ""
print_warning "Ready to deploy WCC CCDC Practice Range"
echo ""
echo "This will:"
echo "  - Deploy 11+ virtual machines"
echo "  - Require 45-90 minutes to complete"
echo "  - Use approximately 64GB RAM and 16 CPU cores"
echo ""
read -p "Continue with deployment? (yes/no): " -r
echo ""

if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    print_warning "Deployment cancelled"
    exit 0
fi

# Deploy the range
echo ""
print_status "Starting range deployment..."
print_warning "This will take 45-90 minutes. Logs will be shown below."
echo ""

ludus range deploy

# Monitor deployment
echo ""
print_status "Deployment started. Monitoring logs..."
echo ""

# Wait a moment for deployment to start
sleep 5

# Show logs
ludus range logs -f &
LOG_PID=$!

# Wait for deployment to complete
while ludus range status | grep -q "deploying"; do
    sleep 30
done

# Kill the log tail
kill $LOG_PID 2>/dev/null || true

# Check if deployment succeeded
if ludus range status | grep -q "error"; then
    print_error "Deployment completed with errors"
    echo ""
    echo "Check errors with: ludus range errors"
    exit 1
fi

print_status "Deployment completed successfully!"

# Post-deployment instructions
echo ""
print_status "Post-deployment steps:"
echo ""
echo "1. Power cycle VMs in the correct order:"
echo "   ludus range power off"
echo "   sleep 30"
echo "   ludus range power on --vm-name \"*-router\""
echo "   sleep 60"
echo "   ludus range power on --vm-name \"*-dc01\""
echo "   sleep 120"
echo "   ludus range power on"
echo ""
echo "2. Access the scoring engine:"
echo "   - Get your range ID: ludus range list"
echo "   - Open browser to: http://10.{range_id}.99.10"
echo "   - Login: admin / changeme"
echo "   - CHANGE THE PASSWORD!"
echo ""
echo "3. Verify all services on the scoreboard"
echo ""
echo "4. Start your first practice session!"
echo ""

print_status "For detailed information, see README.md"
print_status "For quick reference, see QUICKSTART.md"

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Deployment Complete - Happy Defending!              ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
