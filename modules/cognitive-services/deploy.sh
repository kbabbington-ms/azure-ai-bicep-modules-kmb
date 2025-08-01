#!/bin/bash

# =============================================================================
# Azure Cognitive Services Bicep Module Deployment Script
# =============================================================================
# This script deploys the Azure Cognitive Services Bicep module with 
# comprehensive validation and error handling.
# =============================================================================

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="${SCRIPT_DIR}/cognitive-services.bicep"
PARAMETERS_FILE="${SCRIPT_DIR}/cognitive-services.parameters.json"
DEPLOYMENT_NAME="cognitive-services-$(date +%Y%m%d-%H%M%S)"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# =============================================================================
# FUNCTIONS
# =============================================================================

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
    cat << EOF
Usage: $0 [OPTIONS]

Deploy Azure Cognitive Services using Bicep template.

OPTIONS:
    -g, --resource-group RESOURCE_GROUP    Target resource group name (required)
    -l, --location LOCATION               Azure region for deployment (default: eastus)
    -p, --parameters PARAMETERS_FILE      Parameters file path (default: cognitive-services.parameters.json)
    -n, --name DEPLOYMENT_NAME           Deployment name (default: auto-generated)
    -s, --subscription SUBSCRIPTION_ID    Azure subscription ID (optional)
    -v, --validate-only                   Only validate template, don't deploy
    -d, --dry-run                         Show what would be deployed without deploying
    --skip-validation                     Skip template validation
    --enable-preview                      Enable preview features
    -h, --help                           Show this help message

EXAMPLES:
    # Basic deployment
    $0 -g myai-rg

    # Deploy with custom parameters
    $0 -g myai-rg -p custom-parameters.json

    # Validate only
    $0 -g myai-rg --validate-only

    # Deploy to specific subscription
    $0 -g myai-rg -s "12345678-1234-1234-1234-123456789012"

    # Dry run to see planned changes
    $0 -g myai-rg --dry-run

EOF
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI is not installed. Please install it from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi
    
    # Check if jq is installed (for JSON processing)
    if ! command -v jq &> /dev/null; then
        log_warning "jq is not installed. JSON output might not be formatted properly."
    fi
    
    # Check if user is logged into Azure
    if ! az account show &> /dev/null; then
        log_error "Not logged into Azure. Please run 'az login' first."
        exit 1
    fi
    
    # Check if template file exists
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        log_error "Template file not found: $TEMPLATE_FILE"
        exit 1
    fi
    
    # Check if parameters file exists
    if [[ ! -f "$PARAMETERS_FILE" ]]; then
        log_error "Parameters file not found: $PARAMETERS_FILE"
        exit 1
    fi
    
    log_success "Prerequisites check completed"
}

validate_template() {
    log_info "Validating Bicep template..."
    
    local validation_result
    validation_result=$(az deployment group validate \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$TEMPLATE_FILE" \
        --parameters @"$PARAMETERS_FILE" \
        --output json 2>&1)
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "Template validation passed"
        
        # Show validation results if jq is available
        if command -v jq &> /dev/null; then
            echo "$validation_result" | jq -r '.properties.validatedResources[]? | "  ✓ \(.type): \(.name)"'
        fi
        
        return 0
    else
        log_error "Template validation failed"
        echo "$validation_result" | head -50
        return 1
    fi
}

show_deployment_plan() {
    log_info "Generating deployment plan..."
    
    # Use what-if to show planned changes
    local whatif_result
    whatif_result=$(az deployment group what-if \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$TEMPLATE_FILE" \
        --parameters @"$PARAMETERS_FILE" \
        --output table 2>&1)
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "Deployment plan generated"
        echo "$whatif_result"
        return 0
    else
        log_warning "Could not generate deployment plan (what-if might not be supported)"
        echo "$whatif_result"
        return 1
    fi
}

deploy_template() {
    log_info "Starting deployment: $DEPLOYMENT_NAME"
    log_info "Resource Group: $RESOURCE_GROUP"
    log_info "Location: $LOCATION"
    log_info "Template: $TEMPLATE_FILE"
    log_info "Parameters: $PARAMETERS_FILE"
    
    # Perform deployment
    local deployment_result
    deployment_result=$(az deployment group create \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$TEMPLATE_FILE" \
        --parameters @"$PARAMETERS_FILE" \
        --name "$DEPLOYMENT_NAME" \
        --output json)
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "Deployment completed successfully"
        
        # Extract and display key outputs
        if command -v jq &> /dev/null; then
            log_info "Deployment outputs:"
            echo "$deployment_result" | jq -r '.properties.outputs | to_entries[] | "  \(.key): \(.value.value)"'
            
            # Extract Cognitive Service details
            local service_name
            local service_endpoint
            local service_id
            
            service_name=$(echo "$deployment_result" | jq -r '.properties.outputs.cognitiveServiceName.value // "N/A"')
            service_endpoint=$(echo "$deployment_result" | jq -r '.properties.outputs.endpoint.value // "N/A"')
            service_id=$(echo "$deployment_result" | jq -r '.properties.outputs.cognitiveServiceId.value // "N/A"')
            
            echo
            log_success "Cognitive Services Account Details:"
            echo "  Name: $service_name"
            echo "  Endpoint: $service_endpoint"
            echo "  Resource ID: $service_id"
        fi
        
        return 0
    else
        log_error "Deployment failed"
        echo "$deployment_result"
        return 1
    fi
}

check_deployment_status() {
    log_info "Checking deployment status..."
    
    local status_result
    status_result=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEPLOYMENT_NAME" \
        --output json)
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        if command -v jq &> /dev/null; then
            local provisioning_state
            provisioning_state=$(echo "$status_result" | jq -r '.properties.provisioningState')
            
            case "$provisioning_state" in
                "Succeeded")
                    log_success "Deployment status: $provisioning_state"
                    ;;
                "Failed")
                    log_error "Deployment status: $provisioning_state"
                    echo "$status_result" | jq -r '.properties.error.message // "No error message available"'
                    ;;
                "Running"|"Accepted")
                    log_info "Deployment status: $provisioning_state"
                    ;;
                *)
                    log_warning "Deployment status: $provisioning_state"
                    ;;
            esac
        fi
        
        return 0
    else
        log_error "Could not retrieve deployment status"
        return 1
    fi
}

cleanup_on_failure() {
    if [[ "${CLEANUP_ON_FAILURE:-false}" == "true" ]]; then
        log_warning "Cleaning up failed deployment..."
        az deployment group delete \
            --resource-group "$RESOURCE_GROUP" \
            --name "$DEPLOYMENT_NAME" \
            --no-wait \
            --yes &> /dev/null || true
        log_info "Cleanup initiated"
    fi
}

# =============================================================================
# MAIN SCRIPT
# =============================================================================

main() {
    # Default values
    RESOURCE_GROUP=""
    LOCATION="eastus"
    VALIDATE_ONLY=false
    DRY_RUN=false
    SKIP_VALIDATION=false
    ENABLE_PREVIEW=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -g|--resource-group)
                RESOURCE_GROUP="$2"
                shift 2
                ;;
            -l|--location)
                LOCATION="$2"
                shift 2
                ;;
            -p|--parameters)
                PARAMETERS_FILE="$2"
                shift 2
                ;;
            -n|--name)
                DEPLOYMENT_NAME="$2"
                shift 2
                ;;
            -s|--subscription)
                az account set --subscription "$2"
                shift 2
                ;;
            -v|--validate-only)
                VALIDATE_ONLY=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            --skip-validation)
                SKIP_VALIDATION=true
                shift
                ;;
            --enable-preview)
                ENABLE_PREVIEW=true
                shift
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
    
    # Validate required parameters
    if [[ -z "$RESOURCE_GROUP" ]]; then
        log_error "Resource group is required. Use -g or --resource-group option."
        show_usage
        exit 1
    fi
    
    # Enable preview features if requested
    if [[ "$ENABLE_PREVIEW" == "true" ]]; then
        log_info "Enabling preview features..."
        az config set extension.use_dynamic_install=yes_without_prompt
    fi
    
    # Set error handling
    trap cleanup_on_failure ERR
    
    # Main execution flow
    log_info "Starting Azure Cognitive Services deployment process"
    
    # Check prerequisites
    check_prerequisites
    
    # Create resource group if it doesn't exist
    if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
        log_info "Creating resource group: $RESOURCE_GROUP"
        az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
        log_success "Resource group created"
    else
        log_info "Using existing resource group: $RESOURCE_GROUP"
    fi
    
    # Validation
    if [[ "$SKIP_VALIDATION" != "true" ]]; then
        validate_template || exit 1
    fi
    
    # Handle different execution modes
    if [[ "$VALIDATE_ONLY" == "true" ]]; then
        log_success "Validation completed. Exiting without deployment."
        exit 0
    elif [[ "$DRY_RUN" == "true" ]]; then
        show_deployment_plan
        log_info "Dry run completed. No resources were deployed."
        exit 0
    else
        # Proceed with deployment
        deploy_template || exit 1
        check_deployment_status
        
        log_success "Cognitive Services deployment process completed"
        log_info "Deployment name: $DEPLOYMENT_NAME"
        log_info "Resource group: $RESOURCE_GROUP"
    fi
}

# Execute main function with all arguments
main "$@"
