#!/bin/bash
# Azure OpenAI Service Deployment Script
# This script deploys the Azure OpenAI module with comprehensive validation and monitoring

set -euo pipefail

# Default values
RESOURCE_GROUP=""
LOCATION="eastus"
TEMPLATE_FILE="main.bicep"
PARAMETERS_FILE="main.parameters.json"
DEPLOYMENT_NAME="openai-deployment-$(date +%Y%m%d-%H%M%S)"
VALIDATE_ONLY=false
DRY_RUN=false
VERBOSE=false
MONITOR=false
TIMEOUT=1800  # 30 minutes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Help function
show_help() {
    cat << EOF
Azure OpenAI Service Deployment Script

USAGE:
    $0 -g <resource-group> [OPTIONS]

REQUIRED:
    -g, --resource-group    Azure resource group name

OPTIONS:
    -l, --location         Azure region (default: eastus)
    -t, --template         Bicep template file (default: main.bicep)
    -p, --parameters       Parameters file (default: main.parameters.json)
    -n, --name            Deployment name (default: auto-generated)
    --validate            Validate template only, don't deploy
    --dry-run             Show what would be deployed without deploying
    --monitor             Monitor deployment progress
    --timeout             Deployment timeout in seconds (default: 1800)
    -v, --verbose         Enable verbose output
    -h, --help            Show this help message

EXAMPLES:
    # Basic deployment
    $0 -g myai-rg

    # Custom location and validation
    $0 -g myai-rg -l westus2 --validate

    # Deployment with monitoring
    $0 -g myai-rg --monitor

    # Dry run to preview changes
    $0 -g myai-rg --dry-run

EOF
}

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
        -t|--template)
            TEMPLATE_FILE="$2"
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
        --validate)
            VALIDATE_ONLY=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --monitor)
            MONITOR=true
            shift
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
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

# Validate required parameters
if [[ -z "$RESOURCE_GROUP" ]]; then
    log_error "Resource group is required. Use -g or --resource-group"
    show_help
    exit 1
fi

# Check if required files exist
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    log_error "Template file not found: $TEMPLATE_FILE"
    exit 1
fi

if [[ ! -f "$PARAMETERS_FILE" ]]; then
    log_error "Parameters file not found: $PARAMETERS_FILE"
    exit 1
fi

# Check if Azure CLI is installed and user is logged in
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if logged in
    if ! az account show &> /dev/null; then
        log_error "Not logged in to Azure. Run 'az login' first."
        exit 1
    fi
    
    # Check if Bicep is available
    if ! az bicep version &> /dev/null; then
        log_warning "Bicep CLI not found. Installing..."
        az bicep install
    fi
    
    log_success "Prerequisites check completed"
}

# Validate template
validate_template() {
    log_info "Validating Bicep template..."
    
    # Validate template syntax
    if ! az bicep build --file "$TEMPLATE_FILE" --stdout > /dev/null; then
        log_error "Template validation failed"
        exit 1
    fi
    
    # Validate deployment
    local validation_result
    validation_result=$(az deployment group validate \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$TEMPLATE_FILE" \
        --parameters "@$PARAMETERS_FILE" \
        --query "error" \
        --output tsv 2>/dev/null || echo "validation_failed")
    
    if [[ "$validation_result" != "null" && "$validation_result" != "" ]]; then
        log_error "Template validation failed:"
        az deployment group validate \
            --resource-group "$RESOURCE_GROUP" \
            --template-file "$TEMPLATE_FILE" \
            --parameters "@$PARAMETERS_FILE" \
            --output table
        exit 1
    fi
    
    log_success "Template validation passed"
}

# Show what would be deployed (dry run)
show_dry_run() {
    log_info "Showing deployment preview (dry-run)..."
    
    az deployment group what-if \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$TEMPLATE_FILE" \
        --parameters "@$PARAMETERS_FILE" \
        --result-format FullResourcePayloads
    
    echo ""
    log_info "Dry-run completed. No resources were deployed."
}

# Deploy the template
deploy_template() {
    log_info "Starting Azure OpenAI deployment..."
    log_info "Resource Group: $RESOURCE_GROUP"
    log_info "Location: $LOCATION"
    log_info "Deployment Name: $DEPLOYMENT_NAME"
    
    local deploy_cmd=(
        az deployment group create
        --resource-group "$RESOURCE_GROUP"
        --template-file "$TEMPLATE_FILE"
        --parameters "@$PARAMETERS_FILE"
        --name "$DEPLOYMENT_NAME"
    )
    
    if [[ "$VERBOSE" == "true" ]]; then
        deploy_cmd+=(--verbose)
    fi
    
    if [[ "$MONITOR" == "true" ]]; then
        deploy_cmd+=(--no-wait)
    fi
    
    # Start deployment
    local deployment_result
    if deployment_result=$("${deploy_cmd[@]}" 2>&1); then
        if [[ "$MONITOR" == "true" ]]; then
            log_info "Deployment started. Monitoring progress..."
            monitor_deployment
        else
            log_success "Deployment completed successfully"
            show_deployment_outputs
        fi
    else
        log_error "Deployment failed:"
        echo "$deployment_result"
        exit 1
    fi
}

# Monitor deployment progress
monitor_deployment() {
    local start_time=$(date +%s)
    local spinner_chars="/-\\|"
    local spinner_index=0
    
    log_info "Monitoring deployment progress (timeout: ${TIMEOUT}s)..."
    
    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        # Check timeout
        if [[ $elapsed -gt $TIMEOUT ]]; then
            log_error "Deployment timed out after ${TIMEOUT} seconds"
            exit 1
        fi
        
        # Get deployment status
        local status
        status=$(az deployment group show \
            --resource-group "$RESOURCE_GROUP" \
            --name "$DEPLOYMENT_NAME" \
            --query "properties.provisioningState" \
            --output tsv 2>/dev/null || echo "Unknown")
        
        # Show spinner
        printf "\r${BLUE}[INFO]${NC} Deployment status: %s %s (elapsed: %ds)" \
            "$status" "${spinner_chars:$spinner_index:1}" "$elapsed"
        spinner_index=$(((spinner_index + 1) % 4))
        
        case "$status" in
            "Succeeded")
                printf "\n"
                log_success "Deployment completed successfully"
                show_deployment_outputs
                break
                ;;
            "Failed"|"Canceled")
                printf "\n"
                log_error "Deployment failed with status: $status"
                show_deployment_errors
                exit 1
                ;;
            "Running"|"Accepted"|"Creating")
                sleep 5
                ;;
            *)
                printf "\n"
                log_warning "Unknown deployment status: $status"
                sleep 10
                ;;
        esac
    done
}

# Show deployment outputs
show_deployment_outputs() {
    log_info "Deployment outputs:"
    
    az deployment group show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEPLOYMENT_NAME" \
        --query "properties.outputs" \
        --output table
    
    echo ""
    log_info "Getting OpenAI service details..."
    
    # Get OpenAI account details
    local openai_name
    openai_name=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEPLOYMENT_NAME" \
        --query "properties.outputs.openAIName.value" \
        --output tsv 2>/dev/null || echo "")
    
    if [[ -n "$openai_name" ]]; then
        echo ""
        log_info "Azure OpenAI Service Details:"
        az cognitiveservices account show \
            --resource-group "$RESOURCE_GROUP" \
            --name "$openai_name" \
            --output table
        
        echo ""
        log_info "Model Deployments:"
        az cognitiveservices account deployment list \
            --resource-group "$RESOURCE_GROUP" \
            --account-name "$openai_name" \
            --output table
    fi
}

# Show deployment errors
show_deployment_errors() {
    log_error "Deployment errors:"
    
    az deployment group show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEPLOYMENT_NAME" \
        --query "properties.error" \
        --output json
    
    # Show operation details
    log_info "Deployment operations:"
    az deployment operation group list \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEPLOYMENT_NAME" \
        --query "[?properties.provisioningState=='Failed']" \
        --output table
}

# Cleanup on exit
cleanup() {
    if [[ $? -ne 0 ]]; then
        log_error "Script execution failed"
    fi
}

trap cleanup EXIT

# Main execution
main() {
    log_info "Azure OpenAI Service Deployment Script"
    log_info "======================================="
    
    check_prerequisites
    
    # Create resource group if it doesn't exist
    if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
        log_info "Creating resource group: $RESOURCE_GROUP"
        az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
        log_success "Resource group created"
    fi
    
    validate_template
    
    if [[ "$VALIDATE_ONLY" == "true" ]]; then
        log_success "Validation completed. Exiting without deployment."
        exit 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        show_dry_run
        exit 0
    fi
    
    deploy_template
    
    log_success "Azure OpenAI deployment script completed successfully!"
}

# Run main function
main
