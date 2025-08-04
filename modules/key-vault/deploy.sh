#!/bin/bash

# ================================================================
# Key Vault Module Deployment Script
# ================================================================
# Purpose: Deploy Azure Key Vault using Bicep template with comprehensive validation
# Author: AI Infrastructure Team
# Version: 1.0
# Last Updated: August 1, 2025
# ================================================================

set -e  # Exit on any error

# ================================================================
# CONFIGURATION VARIABLES
# ================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/key-vault.bicep"
DEFAULT_PARAMETERS_FILE="$SCRIPT_DIR/key-vault.parameters.json"
LOG_FILE="$SCRIPT_DIR/deployment-$(date +%Y%m%d-%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

separator() {
    echo -e "${BLUE}================================================================${NC}"
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
    
    # Check if template file exists
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        error "Template file not found: $TEMPLATE_FILE"
        exit 1
    fi
    
    success "Prerequisites check completed"
}

validate_template() {
    log "Validating Bicep template..."
    
    # Lint the Bicep template
    if az bicep build --file "$TEMPLATE_FILE" --outfile /tmp/keyvault-template.json; then
        success "Bicep template lint validation passed"
    else
        error "Bicep template lint validation failed"
        exit 1
    fi
    
    # ARM template validation
    if az deployment group validate \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$TEMPLATE_FILE" \
        --parameters @"$PARAMETERS_FILE" > /dev/null; then
        success "ARM template validation passed"
    else
        error "ARM template validation failed"
        exit 1
    fi
}

# ================================================================
# DEPLOYMENT FUNCTIONS
# ================================================================

get_deployment_info() {
    echo ""
    separator
    log "🔍 Deployment Information"
    separator
    
    # Get current subscription
    CURRENT_SUB=$(az account show --query "name" -o tsv)
    CURRENT_SUB_ID=$(az account show --query "id" -o tsv)
    
    echo "📋 Current Subscription: $CURRENT_SUB ($CURRENT_SUB_ID)"
    echo "📁 Resource Group: $RESOURCE_GROUP"
    echo "📄 Template: $TEMPLATE_FILE"
    echo "⚙️  Parameters: $PARAMETERS_FILE"
    echo "📝 Log File: $LOG_FILE"
    echo ""
}

confirm_deployment() {
    if [[ "$SKIP_CONFIRMATION" != "true" ]]; then
        echo "🤔 Do you want to proceed with the deployment? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log "Deployment cancelled by user"
            exit 0
        fi
    fi
}

run_whatif_analysis() {
    if [[ "$SKIP_WHATIF" != "true" ]]; then
        log "Running What-If analysis..."
        separator
        
        az deployment group what-if \
            --resource-group "$RESOURCE_GROUP" \
            --template-file "$TEMPLATE_FILE" \
            --parameters @"$PARAMETERS_FILE" \
            --color true
        
        separator
        success "What-If analysis completed"
        echo ""
        
        if [[ "$SKIP_CONFIRMATION" != "true" ]]; then
            echo "🤔 Continue with deployment? (y/N)"
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                log "Deployment cancelled after What-If analysis"
                exit 0
            fi
        fi
    fi
}

deploy_template() {
    log "Starting deployment..."
    
    DEPLOYMENT_NAME="keyvault-$(date +%Y%m%d-%H%M%S)"
    
    if az deployment group create \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$TEMPLATE_FILE" \
        --parameters @"$PARAMETERS_FILE" \
        --name "$DEPLOYMENT_NAME" \
        --output table; then
        
        success "Deployment completed successfully!"
        
        # Get deployment outputs
        log "Retrieving deployment outputs..."
        az deployment group show \
            --resource-group "$RESOURCE_GROUP" \
            --name "$DEPLOYMENT_NAME" \
            --query "properties.outputs" \
            --output table
            
    else
        error "Deployment failed!"
        
        # Get deployment details for troubleshooting
        log "Getting deployment details for troubleshooting..."
        az deployment group show \
            --resource-group "$RESOURCE_GROUP" \
            --name "$DEPLOYMENT_NAME" \
            --query "properties.error" \
            --output table
        
        exit 1
    fi
}

# ================================================================
# POST-DEPLOYMENT VALIDATION
# ================================================================

validate_deployment() {
    log "Validating deployment..."
    
    # Get the Key Vault name from parameters
    VAULT_NAME=$(jq -r '.parameters.keyVaultName.value' "$PARAMETERS_FILE")
    
    if [[ "$VAULT_NAME" == "null" || -z "$VAULT_NAME" ]]; then
        warning "Could not retrieve Key Vault name from parameters file"
        return
    fi
    
    # Check if Key Vault exists and is accessible
    if az keyvault show --name "$VAULT_NAME" --resource-group "$RESOURCE_GROUP" > /dev/null 2>&1; then
        success "Key Vault '$VAULT_NAME' is accessible"
        
        # Check Key Vault properties
        VAULT_SKU=$(az keyvault show --name "$VAULT_NAME" --resource-group "$RESOURCE_GROUP" --query "properties.sku.name" -o tsv)
        SOFT_DELETE=$(az keyvault show --name "$VAULT_NAME" --resource-group "$RESOURCE_GROUP" --query "properties.enableSoftDelete" -o tsv)
        PURGE_PROTECTION=$(az keyvault show --name "$VAULT_NAME" --resource-group "$RESOURCE_GROUP" --query "properties.enablePurgeProtection" -o tsv)
        
        echo "  📊 SKU: $VAULT_SKU"
        echo "  🗑️  Soft Delete: $SOFT_DELETE"
        echo "  🛡️  Purge Protection: $PURGE_PROTECTION"
        
    else
        error "Key Vault '$VAULT_NAME' is not accessible"
    fi
    
    # Check diagnostic settings if enabled
    log "Checking diagnostic settings..."
    DIAG_COUNT=$(az monitor diagnostic-settings list --resource "/subscriptions/$CURRENT_SUB_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$VAULT_NAME" --query "length(value)" -o tsv)
    
    if [[ "$DIAG_COUNT" -gt 0 ]]; then
        success "Diagnostic settings configured ($DIAG_COUNT settings)"
    else
        warning "No diagnostic settings found"
    fi
}

# ================================================================
# ERROR HANDLING & ROLLBACK
# ================================================================

cleanup_on_error() {
    error "Deployment failed. Cleaning up resources..."
    
    # Add cleanup logic here if needed
    # For Key Vault, we typically don't auto-delete due to purge protection
    
    warning "Please review the deployment logs and clean up manually if necessary"
}

# ================================================================
# MAIN SCRIPT
# ================================================================

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -g, --resource-group     Resource group name (required)"
    echo "  -p, --parameters         Parameters file path (default: key-vault.parameters.json)"
    echo "  -y, --yes               Skip confirmation prompts"
    echo "  --skip-whatif           Skip What-If analysis"
    echo "  --skip-validation       Skip post-deployment validation"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -g my-resource-group"
    echo "  $0 -g my-rg -p custom-parameters.json -y"
    echo "  $0 --resource-group my-rg --skip-whatif"
}

main() {
    # Initialize variables
    RESOURCE_GROUP=""
    PARAMETERS_FILE="$DEFAULT_PARAMETERS_FILE"
    SKIP_CONFIRMATION="false"
    SKIP_WHATIF="false"
    SKIP_VALIDATION="false"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -g|--resource-group)
                RESOURCE_GROUP="$2"
                shift 2
                ;;
            -p|--parameters)
                PARAMETERS_FILE="$2"
                shift 2
                ;;
            -y|--yes)
                SKIP_CONFIRMATION="true"
                shift
                ;;
            --skip-whatif)
                SKIP_WHATIF="true"
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
    if [[ -z "$RESOURCE_GROUP" ]]; then
        error "Resource group is required. Use -g or --resource-group."
        show_usage
        exit 1
    fi
    
    if [[ ! -f "$PARAMETERS_FILE" ]]; then
        error "Parameters file not found: $PARAMETERS_FILE"
        exit 1
    fi
    
    # Main execution flow
    echo ""
    separator
    log "🚀 Azure Key Vault Deployment Script"
    separator
    
    # Set up error handling
    trap cleanup_on_error ERR
    
    # Execute deployment steps
    check_prerequisites
    get_deployment_info
    confirm_deployment
    validate_template
    run_whatif_analysis
    deploy_template
    
    if [[ "$SKIP_VALIDATION" != "true" ]]; then
        validate_deployment
    fi
    
    echo ""
    separator
    success "✅ Deployment process completed successfully!"
    log "📝 Deployment logs saved to: $LOG_FILE"
    separator
    echo ""
}

# Execute main function with all arguments
main "$@"
