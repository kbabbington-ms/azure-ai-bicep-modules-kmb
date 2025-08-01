#!/bin/bash

# AI Workflows Module Deployment Script
# This script deploys the AI Workflows module with comprehensive validation and monitoring

set -e

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_NAME="ai-workflows"
TEMPLATE_FILE="$SCRIPT_DIR/main.bicep"
PARAMETERS_FILE="$SCRIPT_DIR/main.parameters.json"
DEPLOYMENT_NAME="$MODULE_NAME-$(date +%Y%m%d-%H%M%S)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Logging functions
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

log_header() {
    echo -e "${PURPLE}[DEPLOY]${NC} $1"
}

# Help function
show_help() {
    cat << EOF
AI Workflows Module Deployment Script

Usage: $0 [OPTIONS]

Options:
    -g, --resource-group RESOURCE_GROUP     Resource group name (required)
    -l, --location LOCATION                 Azure region for deployment (optional)
    -p, --parameters-file FILE              Parameters file path (default: main.parameters.json)
    -s, --subscription SUBSCRIPTION        Azure subscription ID or name (optional)
    -n, --deployment-name NAME              Custom deployment name (optional)
    -t, --tags TAGS                         Additional tags in format "key1=value1 key2=value2"
    -w, --what-if                           Run what-if analysis without deploying
    -v, --validate                          Validate template without deploying
    -m, --monitor                           Monitor deployment progress
    -f, --force                             Skip confirmations and deploy directly
    -h, --help                              Show this help message

Examples:
    # Basic deployment
    $0 -g my-rg -l eastus

    # Deployment with custom parameters
    $0 -g my-rg -p custom.parameters.json

    # What-if analysis
    $0 -g my-rg -w

    # Validate template
    $0 -g my-rg -v

    # Full deployment with monitoring
    $0 -g my-rg -l westus2 -m -f

Environment Variables:
    AZURE_RESOURCE_GROUP        Default resource group
    AZURE_LOCATION              Default location
    AZURE_SUBSCRIPTION_ID       Default subscription
    AZURE_PARAMETERS_FILE       Default parameters file

EOF
}

# Parse command line arguments
parse_arguments() {
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
            -p|--parameters-file)
                PARAMETERS_FILE="$2"
                shift 2
                ;;
            -s|--subscription)
                SUBSCRIPTION="$2"
                shift 2
                ;;
            -n|--deployment-name)
                DEPLOYMENT_NAME="$2"
                shift 2
                ;;
            -t|--tags)
                ADDITIONAL_TAGS="$2"
                shift 2
                ;;
            -w|--what-if)
                WHAT_IF=true
                shift
                ;;
            -v|--validate)
                VALIDATE_ONLY=true
                shift
                ;;
            -m|--monitor)
                MONITOR_DEPLOYMENT=true
                shift
                ;;
            -f|--force)
                FORCE_DEPLOY=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Validate prerequisites
validate_prerequisites() {
    log_header "Validating Prerequisites"
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI is not installed. Please install Azure CLI first."
        exit 1
    fi
    
    # Check Azure CLI login status
    if ! az account show &> /dev/null; then
        log_error "Not logged in to Azure. Please run 'az login' first."
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
    
    log_success "Prerequisites validated"
}

# Set environment variables with defaults
set_defaults() {
    RESOURCE_GROUP="${RESOURCE_GROUP:-$AZURE_RESOURCE_GROUP}"
    LOCATION="${LOCATION:-$AZURE_LOCATION}"
    SUBSCRIPTION="${SUBSCRIPTION:-$AZURE_SUBSCRIPTION_ID}"
    PARAMETERS_FILE="${PARAMETERS_FILE:-$AZURE_PARAMETERS_FILE}"
    
    # Validate required parameters
    if [[ -z "$RESOURCE_GROUP" ]]; then
        log_error "Resource group is required. Use -g option or set AZURE_RESOURCE_GROUP environment variable."
        exit 1
    fi
}

# Set Azure subscription
set_subscription() {
    if [[ -n "$SUBSCRIPTION" ]]; then
        log_info "Setting Azure subscription to: $SUBSCRIPTION"
        az account set --subscription "$SUBSCRIPTION"
        if [[ $? -ne 0 ]]; then
            log_error "Failed to set subscription: $SUBSCRIPTION"
            exit 1
        fi
    fi
    
    # Display current subscription
    CURRENT_SUBSCRIPTION=$(az account show --query "name" -o tsv)
    log_info "Current subscription: $CURRENT_SUBSCRIPTION"
}

# Create resource group if it doesn't exist
ensure_resource_group() {
    log_info "Checking resource group: $RESOURCE_GROUP"
    
    if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
        if [[ -z "$LOCATION" ]]; then
            log_error "Resource group doesn't exist and location is not specified. Use -l option to specify location."
            exit 1
        fi
        
        log_info "Creating resource group: $RESOURCE_GROUP in $LOCATION"
        az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
        
        if [[ $? -eq 0 ]]; then
            log_success "Resource group created successfully"
        else
            log_error "Failed to create resource group"
            exit 1
        fi
    else
        log_success "Resource group already exists"
    fi
}

# Validate Bicep template
validate_template() {
    log_header "Validating Bicep Template"
    
    log_info "Running Bicep linting..."
    az bicep build --file "$TEMPLATE_FILE"
    
    if [[ $? -eq 0 ]]; then
        log_success "Bicep template compilation successful"
    else
        log_error "Bicep template compilation failed"
        exit 1
    fi
    
    log_info "Running deployment validation..."
    az deployment group validate \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$TEMPLATE_FILE" \
        --parameters "@$PARAMETERS_FILE"
    
    if [[ $? -eq 0 ]]; then
        log_success "Template validation successful"
    else
        log_error "Template validation failed"
        exit 1
    fi
}

# Run what-if analysis
run_what_if() {
    log_header "Running What-If Analysis"
    
    az deployment group what-if \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$TEMPLATE_FILE" \
        --parameters "@$PARAMETERS_FILE" \
        --result-format ResourceIdOnly
    
    if [[ $? -eq 0 ]]; then
        log_success "What-if analysis completed"
    else
        log_error "What-if analysis failed"
        exit 1
    fi
}

# Deploy template
deploy_template() {
    log_header "Deploying AI Workflows Module"
    
    # Prepare deployment command
    local deploy_cmd="az deployment group create"
    deploy_cmd+=" --resource-group '$RESOURCE_GROUP'"
    deploy_cmd+=" --name '$DEPLOYMENT_NAME'"
    deploy_cmd+=" --template-file '$TEMPLATE_FILE'"
    deploy_cmd+=" --parameters '@$PARAMETERS_FILE'"
    
    # Add additional tags if provided
    if [[ -n "$ADDITIONAL_TAGS" ]]; then
        deploy_cmd+=" --parameters tags='{$ADDITIONAL_TAGS}'"
    fi
    
    log_info "Deployment command: $deploy_cmd"
    log_info "Starting deployment: $DEPLOYMENT_NAME"
    log_info "Resource Group: $RESOURCE_GROUP"
    log_info "Template: $TEMPLATE_FILE"
    log_info "Parameters: $PARAMETERS_FILE"
    
    # Execute deployment
    eval $deploy_cmd
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "Deployment completed successfully"
        return 0
    else
        log_error "Deployment failed with exit code: $exit_code"
        return $exit_code
    fi
}

# Monitor deployment
monitor_deployment() {
    log_header "Monitoring Deployment Progress"
    
    while true; do
        local status=$(az deployment group show \
            --resource-group "$RESOURCE_GROUP" \
            --name "$DEPLOYMENT_NAME" \
            --query "properties.provisioningState" -o tsv 2>/dev/null)
        
        if [[ -z "$status" ]]; then
            log_error "Unable to retrieve deployment status"
            break
        fi
        
        log_info "Deployment status: $status"
        
        case "$status" in
            "Succeeded")
                log_success "Deployment completed successfully"
                break
                ;;
            "Failed")
                log_error "Deployment failed"
                show_deployment_errors
                break
                ;;
            "Canceled")
                log_warning "Deployment was canceled"
                break
                ;;
            *)
                log_info "Deployment in progress... (Status: $status)"
                sleep 30
                ;;
        esac
    done
}

# Show deployment errors
show_deployment_errors() {
    log_header "Deployment Error Details"
    
    az deployment group show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEPLOYMENT_NAME" \
        --query "properties.error" -o json
}

# Show deployment outputs
show_deployment_outputs() {
    log_header "Deployment Outputs"
    
    local outputs=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEPLOYMENT_NAME" \
        --query "properties.outputs" -o json 2>/dev/null)
    
    if [[ "$outputs" != "null" && -n "$outputs" ]]; then
        echo "$outputs" | jq '.'
    else
        log_info "No outputs available for this deployment"
    fi
}

# Main execution function
main() {
    log_header "AI Workflows Module Deployment"
    echo "Starting deployment at $(date)"
    echo
    
    # Parse arguments and validate
    parse_arguments "$@"
    set_defaults
    validate_prerequisites
    set_subscription
    ensure_resource_group
    
    # Run what-if if requested
    if [[ "$WHAT_IF" == true ]]; then
        run_what_if
        exit 0
    fi
    
    # Validate template
    validate_template
    
    # Exit if validation only
    if [[ "$VALIDATE_ONLY" == true ]]; then
        log_success "Template validation completed"
        exit 0
    fi
    
    # Confirm deployment if not forced
    if [[ "$FORCE_DEPLOY" != true ]]; then
        echo
        log_warning "About to deploy AI Workflows module:"
        log_info "Resource Group: $RESOURCE_GROUP"
        log_info "Deployment Name: $DEPLOYMENT_NAME"
        log_info "Template: $TEMPLATE_FILE"
        log_info "Parameters: $PARAMETERS_FILE"
        echo
        read -p "Do you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Deployment canceled by user"
            exit 0
        fi
    fi
    
    # Deploy template
    if deploy_template; then
        # Monitor deployment if requested
        if [[ "$MONITOR_DEPLOYMENT" == true ]]; then
            monitor_deployment
        fi
        
        # Show outputs
        show_deployment_outputs
        
        log_success "AI Workflows module deployment completed successfully"
        echo "Deployment Name: $DEPLOYMENT_NAME"
        echo "Resource Group: $RESOURCE_GROUP"
        echo "Completed at: $(date)"
    else
        log_error "Deployment failed"
        show_deployment_errors
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
