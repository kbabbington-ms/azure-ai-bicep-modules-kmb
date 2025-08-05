#!/bin/bash

# ================================================================
# SFI-W1 Policy Initiative Deployment Script
# ================================================================
# Purpose: Deploy all Azure Policy definitions and initiative for Azure AI Foundry
# Author: AI Infrastructure Team
# Version: 2.0
# Last Updated: August 1, 2025
# ================================================================

set -e  # Exit on any error

# ================================================================
# CONFIGURATION VARIABLES
# ================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/policy-deployment-$(date +%Y%m%d-%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Policy definition files in dependency order
POLICY_DEFINITIONS=(
    "SFI-W1-Def-Foundry-RequireCreatedByTag.bicep"
    "SFI-W1-Def-Foundry-RestrictPublicNetworkAccess.bicep"
    "SFI-W1-Def-Foundry-RequireDiagnosticLogging.bicep"
    "SFI-W1-Def-Foundry-EnforceManagedIdentityUsage.bicep"
    "SFI-W1-Def-Foundry-RequireEncryptionAtRest.bicep"
    "SFI-W1-Def-Foundry-RequireKeyVaultPrivateEndpoint.bicep"
    "SFI-W1-Def-Foundry-AllowedAISku.bicep"
    "SFI-W1-Def-Foundry-ModelVersionControl.bicep"
    "SFI-W1-Def-Foundry-DataResidency.bicep"
    "SFI-W1-Def-Foundry-PrivateEndpointAI.bicep"
    "SFI-W1-Def-Foundry-DiagnosticLoggingAI.bicep"
    "SFI-W1-Def-Foundry-KeyVaultAISecrets.bicep"
    "SFI-W1-Def-Foundry-TaggingAI.bicep"
    "SFI-W1-Def-Foundry-ManagedIdentityAI.bicep"
    "SFI-W1-Def-Foundry-EncryptionTransitAI.bicep"
    "SFI-W1-Def-Foundry-LogRetentionAI.bicep"
    "SFI-W1-Def-Foundry-ContentSafety.bicep"
    "SFI-W1-Def-Foundry-VideoIndexer.bicep"
    "SFI-W1-Def-Foundry-LogicAppsAIWorkflows.bicep"
    "SFI-W1-Def-Foundry-AdvancedMonitoring.bicep"
)

INITIATIVE_FILE="SFI-W1-Ini-Foundry.bicep"

# ================================================================
# UTILITY FUNCTIONS
# ================================================================

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${CYAN}ℹ️  $1${NC}" | tee -a "$LOG_FILE"
}

separator() {
    echo -e "${BLUE}================================================================${NC}"
}

progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    local remaining=$((width - completed))
    
    printf "\r${CYAN}Progress: ["
    printf "%*s" $completed | tr ' ' '█'
    printf "%*s" $remaining | tr ' ' '░'
    printf "] %d%% (%d/%d)${NC}" $percentage $current $total
}

# ================================================================
# VALIDATION FUNCTIONS
# ================================================================

check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        error "Azure CLI is not installed. Please install it from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi
    
    # Check if user is logged in
    if ! az account show &> /dev/null; then
        error "Not logged into Azure. Please run 'az login' first."
        exit 1
    fi
    
    # Check if Bicep is available
    if ! az bicep version &> /dev/null; then
        warning "Bicep CLI not found. Installing..."
        az bicep install
    fi
    
    # Verify subscription access
    CURRENT_SUB=$(az account show --query "id" -o tsv)
    CURRENT_SUB_NAME=$(az account show --query "name" -o tsv)
    
    if [[ -z "$CURRENT_SUB" ]]; then
        error "Unable to determine current subscription"
        exit 1
    fi
    
    success "Prerequisites check completed"
    info "Current subscription: $CURRENT_SUB_NAME ($CURRENT_SUB)"
}

validate_files() {
    log "Validating Bicep files..."
    
    local missing_files=()
    
    # Check policy definition files
    for file in "${POLICY_DEFINITIONS[@]}"; do
        if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    # Check initiative file
    if [[ ! -f "$SCRIPT_DIR/$INITIATIVE_FILE" ]]; then
        missing_files+=("$INITIATIVE_FILE")
    fi
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        error "Missing required files:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        exit 1
    fi
    
    success "All required files found"
}

lint_bicep_files() {
    log "Linting Bicep files..."
    
    local lint_errors=0
    
    # Lint policy definitions
    for file in "${POLICY_DEFINITIONS[@]}"; do
        if ! az bicep build --file "$SCRIPT_DIR/$file" --outfile /tmp/policy-temp.json &> /dev/null; then
            error "Lint error in $file"
            lint_errors=$((lint_errors + 1))
        fi
    done
    
    # Lint initiative
    if ! az bicep build --file "$SCRIPT_DIR/$INITIATIVE_FILE" --outfile /tmp/initiative-temp.json &> /dev/null; then
        error "Lint error in $INITIATIVE_FILE"
        lint_errors=$((lint_errors + 1))
    fi
    
    if [[ $lint_errors -gt 0 ]]; then
        error "$lint_errors Bicep lint errors found. Please fix before proceeding."
        exit 1
    fi
    
    success "All Bicep files passed lint validation"
}

# ================================================================
# DEPLOYMENT FUNCTIONS
# ================================================================

show_deployment_summary() {
    echo ""
    separator
    log "🚀 SFI-W1 Policy Initiative Deployment Summary"
    separator
    
    echo "📋 Subscription: $CURRENT_SUB_NAME ($CURRENT_SUB)"
    echo "📁 Location: $LOCATION"
    echo "📄 Policy Definitions: ${#POLICY_DEFINITIONS[@]}"
    echo "📋 Initiative: $INITIATIVE_FILE"
    echo "📝 Log File: $LOG_FILE"
    echo ""
    
    if [[ "$SKIP_CONFIRMATION" != "true" ]]; then
        echo "🤔 Do you want to proceed with the deployment? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log "Deployment cancelled by user"
            exit 0
        fi
    fi
}

deploy_policy_definitions() {
    log "Deploying policy definitions..."
    separator
    
    local failed_deployments=()
    local successful_deployments=0
    local total_definitions=${#POLICY_DEFINITIONS[@]}
    
    for i in "${!POLICY_DEFINITIONS[@]}"; do
        local file="${POLICY_DEFINITIONS[$i]}"
        local current=$((i + 1))
        
        echo ""
        progress_bar $current $total_definitions
        echo ""
        info "Deploying: $file"
        
        local deployment_name="policy-def-$(date +%Y%m%d-%H%M%S)-$current"
        
        if az deployment sub create \
            --location "$LOCATION" \
            --template-file "$SCRIPT_DIR/$file" \
            --name "$deployment_name" \
            --output none; then
            
            success "✅ $file deployed successfully"
            successful_deployments=$((successful_deployments + 1))
        else
            error "❌ Failed to deploy $file"
            failed_deployments+=("$file")
        fi
    done
    
    echo ""
    progress_bar $total_definitions $total_definitions
    echo ""
    
    if [[ ${#failed_deployments[@]} -gt 0 ]]; then
        error "Failed to deploy ${#failed_deployments[@]} policy definitions:"
        for file in "${failed_deployments[@]}"; do
            echo "  - $file"
        done
        exit 1
    fi
    
    success "All $successful_deployments policy definitions deployed successfully!"
}

deploy_policy_initiative() {
    log "Deploying policy initiative..."
    
    local deployment_name="policy-initiative-$(date +%Y%m%d-%H%M%S)"
    
    if az deployment sub create \
        --location "$LOCATION" \
        --template-file "$SCRIPT_DIR/$INITIATIVE_FILE" \
        --name "$deployment_name" \
        --output table; then
        
        success "Policy initiative deployed successfully!"
    else
        error "Failed to deploy policy initiative"
        exit 1
    fi
}

# ================================================================
# POST-DEPLOYMENT ACTIONS
# ================================================================

validate_deployment() {
    log "Validating deployment..."
    
    # Check policy definitions
    local expected_policies=${#POLICY_DEFINITIONS[@]}
    local deployed_policies=$(az policy definition list --query "[?contains(name, 'SFI-W1-Def-Foundry')] | length(@)" -o tsv)
    
    if [[ "$deployed_policies" -ge "$expected_policies" ]]; then
        success "All policy definitions are deployed ($deployed_policies found)"
    else
        warning "Expected $expected_policies policies, found $deployed_policies"
    fi
    
    # Check initiative
    if az policy set-definition show --name "SFI-W1-Ini-Foundry" &> /dev/null; then
        success "Policy initiative is deployed and accessible"
    else
        error "Policy initiative not found or not accessible"
        exit 1
    fi
}

show_next_steps() {
    echo ""
    separator
    log "🎯 Next Steps"
    separator
    
    echo "1. 📋 Assign the policy initiative to subscription or resource group:"
    echo "   az policy assignment create \\"
    echo "     --name 'SFI-W1-AI-Foundry-Assignment' \\"
    echo "     --policy-set-definition 'SFI-W1-Ini-Foundry' \\"
    echo "     --scope '/subscriptions/$CURRENT_SUB'"
    echo ""
    
    echo "2. 📊 Monitor compliance:"
    echo "   az policy state list --filter \"PolicySetDefinitionName eq 'SFI-W1-Ini-Foundry'\""
    echo ""
    
    echo "3. 📈 Generate compliance report:"
    echo "   az policy state summarize --policy-set-definition 'SFI-W1-Ini-Foundry'"
    echo ""
    
    echo "4. 🔍 View deployed policies:"
    echo "   az policy definition list --query \"[?contains(name, 'SFI-W1-Def-Foundry')]\""
    echo ""
    
    info "Policy deployment completed successfully!"
    info "Review the logs at: $LOG_FILE"
}

# ================================================================
# ERROR HANDLING
# ================================================================

cleanup_on_error() {
    error "Deployment failed. Check the logs for details."
    warning "You may need to manually clean up partially deployed policies."
    info "Log file: $LOG_FILE"
}

# ================================================================
# MAIN SCRIPT
# ================================================================

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -s, --subscription-id    Subscription ID (optional, uses current subscription)"
    echo "  -l, --location          Azure region for deployment (required)"
    echo "  -y, --yes               Skip confirmation prompts"
    echo "  --skip-validation       Skip post-deployment validation"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --location eastus"
    echo "  $0 -l westus2 -y"
    echo "  $0 --subscription-id 12345678-1234-1234-1234-123456789012 --location eastus"
}

main() {
    # Initialize variables
    LOCATION=""
    SUBSCRIPTION_ID=""
    SKIP_CONFIRMATION="false"
    SKIP_VALIDATION="false"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--subscription-id)
                SUBSCRIPTION_ID="$2"
                shift 2
                ;;
            -l|--location)
                LOCATION="$2"
                shift 2
                ;;
            -y|--yes)
                SKIP_CONFIRMATION="true"
                shift
                ;;
            --skip-validation)
                SKIP_VALIDATION="true"
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate required parameters
    if [[ -z "$LOCATION" ]]; then
        error "Location is required. Use -l or --location."
        show_usage
        exit 1
    fi
    
    # Set subscription if provided
    if [[ -n "$SUBSCRIPTION_ID" ]]; then
        log "Setting subscription to: $SUBSCRIPTION_ID"
        az account set --subscription "$SUBSCRIPTION_ID"
    fi
    
    # Main execution flow
    echo ""
    separator
    log "🛡️ SFI-W1 Policy Initiative Deployment Script"
    separator
    
    # Set up error handling
    trap cleanup_on_error ERR
    
    # Execute deployment steps
    check_prerequisites
    validate_files
    lint_bicep_files
    show_deployment_summary
    deploy_policy_definitions
    deploy_policy_initiative
    
    if [[ "$SKIP_VALIDATION" != "true" ]]; then
        validate_deployment
    fi
    
    show_next_steps
    
    echo ""
    separator
    success "🎉 Policy deployment completed successfully!"
    separator
    echo ""
}

# Execute main function with all arguments
main "$@"
