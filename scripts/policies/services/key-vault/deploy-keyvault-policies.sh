#!/bin/bash

# =============================================================================
# Azure Key Vault Policy Deployment Script
# =============================================================================
# Purpose: Deploy comprehensive Key Vault security policies for SFI-W1 compliance
# Version: 1.0.0
# Date: August 2, 2025
# =============================================================================

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
POLICY_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
SUBSCRIPTION_ID=""
LOG_ANALYTICS_WORKSPACE_ID=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -s, --subscription SUBSCRIPTION_ID    Azure subscription ID"
    echo "  -w, --workspace WORKSPACE_ID          Log Analytics workspace resource ID"
    echo "  -h, --help                           Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -s \"12345678-1234-1234-1234-123456789012\" \\"
    echo "     -w \"/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-audit\""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--subscription)
            SUBSCRIPTION_ID="$2"
            shift 2
            ;;
        -w|--workspace)
            LOG_ANALYTICS_WORKSPACE_ID="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validation
if [[ -z "$SUBSCRIPTION_ID" ]]; then
    log_error "Subscription ID is required. Use -s or --subscription."
    show_usage
    exit 1
fi

if [[ -z "$LOG_ANALYTICS_WORKSPACE_ID" ]]; then
    log_error "Log Analytics workspace ID is required. Use -w or --workspace."
    show_usage
    exit 1
fi

# Verify Azure CLI login
log_info "Verifying Azure CLI authentication..."
if ! az account show &> /dev/null; then
    log_error "Not logged in to Azure CLI. Please run 'az login' first."
    exit 1
fi

# Set subscription context
log_info "Setting subscription context to: $SUBSCRIPTION_ID"
az account set --subscription "$SUBSCRIPTION_ID"

# Array of Key Vault policy definitions to deploy
KEYVAULT_POLICIES=(
    "SFI-W1-Def-Foundry-RequireKeyVaultPrivateEndpoint"
    "SFI-W1-Def-KeyVault-DisablePublicNetworkAccess"
    "SFI-W1-Def-KeyVault-RequireRBAC"
    "SFI-W1-Def-KeyVault-RequirePurgeProtection"
    "SFI-W1-Def-KeyVault-RequireSoftDelete"
    "SFI-W1-Def-KeyVault-RequireCustomerManagedKeys"
    "SFI-W1-Def-KeyVault-RequireManagedIdentity"
    "SFI-W1-Def-Foundry-KeyVaultAISecrets"
    "SFI-W1-Def-KeyVault-RequireDiagnosticSettings"
)

log_info "Starting deployment of ${#KEYVAULT_POLICIES[@]} Key Vault policy definitions..."

# Deploy individual policy definitions
FAILED_POLICIES=()
for policy in "${KEYVAULT_POLICIES[@]}"; do
    log_info "Deploying policy: $policy"
    
    # Construct file path
    POLICY_FILE=""
    if [[ "$policy" == *"Foundry"* ]]; then
        POLICY_FILE="$POLICY_DIR/definitions/key-vault/$policy.bicep"
    else
        POLICY_FILE="$POLICY_DIR/definitions/key-vault/$policy.bicep"
    fi
    
    if [[ ! -f "$POLICY_FILE" ]]; then
        log_error "Policy file not found: $POLICY_FILE"
        FAILED_POLICIES+=("$policy")
        continue
    fi
    
    if az deployment sub create \
        --name "deploy-$policy-$(date +%Y%m%d-%H%M%S)" \
        --template-file "$POLICY_FILE" \
        --location "eastus" \
        --only-show-errors; then
        log_success "Successfully deployed: $policy"
    else
        log_error "Failed to deploy: $policy"
        FAILED_POLICIES+=("$policy")
    fi
done

# Deploy Key Vault initiative
log_info "Deploying Key Vault policy initiative..."
INITIATIVE_FILE="$POLICY_DIR/initiatives/key-vault/SFI-W1-Ini-KeyVault.bicep"

if [[ -f "$INITIATIVE_FILE" ]]; then
    if az deployment sub create \
        --name "deploy-keyvault-initiative-$(date +%Y%m%d-%H%M%S)" \
        --template-file "$INITIATIVE_FILE" \
        --parameters logAnalyticsWorkspaceId="$LOG_ANALYTICS_WORKSPACE_ID" \
        --location "eastus" \
        --only-show-errors; then
        log_success "Successfully deployed Key Vault initiative"
    else
        log_error "Failed to deploy Key Vault initiative"
        FAILED_POLICIES+=("SFI-W1-Ini-KeyVault")
    fi
else
    log_error "Initiative file not found: $INITIATIVE_FILE"
    FAILED_POLICIES+=("SFI-W1-Ini-KeyVault")
fi

# Summary
echo ""
log_info "=== DEPLOYMENT SUMMARY ==="
if [[ ${#FAILED_POLICIES[@]} -eq 0 ]]; then
    log_success "All Key Vault policies deployed successfully!"
    log_info "Deployed ${#KEYVAULT_POLICIES[@]} policy definitions and 1 initiative"
else
    log_warning "Some policies failed to deploy:"
    for failed_policy in "${FAILED_POLICIES[@]}"; do
        echo "  - $failed_policy"
    done
    exit 1
fi

echo ""
log_info "Next steps:"
echo "1. Assign the Key Vault initiative to appropriate scopes"
echo "2. Configure exemptions if needed for legacy workloads"
echo "3. Monitor compliance in Azure Policy portal"
echo ""
log_info "Policy initiative deployed: SFI-W1-Ini-KeyVault"
log_info "Log Analytics workspace: $LOG_ANALYTICS_WORKSPACE_ID"
