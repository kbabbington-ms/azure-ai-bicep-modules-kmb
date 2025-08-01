#!/bin/bash

# Azure AI Document Intelligence Module - Deployment Script
# This script deploys the Document Intelligence service with comprehensive security and processing capabilities
# Version: 1.0.0 | Date: 2025-08-01

set -e  # Exit on any error

# Script configuration
SCRIPT_NAME="Azure AI Document Intelligence Deployment"
SCRIPT_VERSION="1.0.0"
DEPLOYMENT_NAME="document-intelligence-$(date +%Y%m%d-%H%M%S)"

# Color codes for output
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

# Function to display script header
show_header() {
    echo "======================================"
    echo "$SCRIPT_NAME"
    echo "Version: $SCRIPT_VERSION"
    echo "Date: $(date)"
    echo "======================================"
    echo
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI is not installed. Please install Azure CLI first."
        exit 1
    fi
    
    # Check if user is logged in
    if ! az account show &> /dev/null; then
        log_error "Not logged in to Azure CLI. Please run 'az login' first."
        exit 1
    fi
    
    # Check if Bicep is available
    if ! az bicep version &> /dev/null; then
        log_warning "Bicep CLI not found. Installing Bicep..."
        az bicep install
    fi
    
    log_success "Prerequisites check completed"
}

# Function to validate parameters
validate_parameters() {
    log_info "Validating deployment parameters..."
    
    if [ -z "$RESOURCE_GROUP" ]; then
        log_error "RESOURCE_GROUP environment variable is required"
        exit 1
    fi
    
    if [ -z "$LOCATION" ]; then
        log_warning "LOCATION not specified, using default: eastus"
        LOCATION="eastus"
    fi
    
    if [ -z "$DOC_INTEL_NAME" ]; then
        log_error "DOC_INTEL_NAME environment variable is required"
        exit 1
    fi
    
    # Validate Document Intelligence name
    if [[ ${#DOC_INTEL_NAME} -lt 2 || ${#DOC_INTEL_NAME} -gt 24 ]]; then
        log_error "Document Intelligence name must be between 2 and 24 characters"
        exit 1
    fi
    
    log_success "Parameter validation completed"
}

# Function to check resource group
check_resource_group() {
    log_info "Checking resource group: $RESOURCE_GROUP"
    
    if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
        log_warning "Resource group '$RESOURCE_GROUP' does not exist"
        read -p "Do you want to create it? (y/N): " create_rg
        
        if [[ $create_rg =~ ^[Yy]$ ]]; then
            log_info "Creating resource group: $RESOURCE_GROUP"
            az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
            log_success "Resource group created successfully"
        else
            log_error "Resource group is required for deployment"
            exit 1
        fi
    else
        log_success "Resource group exists"
    fi
}

# Function to validate Bicep template
validate_template() {
    log_info "Validating Bicep template..."
    
    if [ ! -f "main.bicep" ]; then
        log_error "main.bicep file not found in current directory"
        exit 1
    fi
    
    # Build Bicep template to check for errors
    if ! az bicep build --file main.bicep --outfile temp-template.json; then
        log_error "Bicep template validation failed"
        exit 1
    fi
    
    # Clean up temporary file
    rm -f temp-template.json
    
    log_success "Bicep template validation completed"
}

# Function to perform what-if analysis
perform_whatif() {
    if [[ "${SKIP_WHATIF:-false}" == "true" ]]; then
        log_info "Skipping what-if analysis (SKIP_WHATIF=true)"
        return
    fi
    
    log_info "Performing what-if analysis..."
    
    local whatif_params=""
    if [ -f "main.parameters.json" ]; then
        whatif_params="--parameters @main.parameters.json"
    fi
    
    # Override specific parameters
    whatif_params="$whatif_params --parameters documentIntelligenceName=$DOC_INTEL_NAME location=$LOCATION"
    
    # Add optional parameters if set
    if [ -n "$DOC_INTEL_SKU" ]; then
        whatif_params="$whatif_params --parameters documentIntelligenceSku=$DOC_INTEL_SKU"
    fi
    
    if [ -n "$ENABLE_PRIVATE_ENDPOINT" ]; then
        whatif_params="$whatif_params --parameters enablePrivateEndpoint=$ENABLE_PRIVATE_ENDPOINT"
    fi
    
    if [ -n "$SUBNET_ID" ]; then
        whatif_params="$whatif_params --parameters subnetId=$SUBNET_ID"
    fi
    
    # Perform what-if analysis
    az deployment group what-if \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEPLOYMENT_NAME" \
        --template-file main.bicep \
        $whatif_params
    
    echo
    read -p "Do you want to proceed with the deployment? (y/N): " proceed
    
    if [[ ! $proceed =~ ^[Yy]$ ]]; then
        log_info "Deployment cancelled by user"
        exit 0
    fi
}

# Function to deploy the template
deploy_template() {
    log_info "Starting Document Intelligence deployment..."
    
    local deploy_params=""
    if [ -f "main.parameters.json" ]; then
        deploy_params="--parameters @main.parameters.json"
    fi
    
    # Override specific parameters
    deploy_params="$deploy_params --parameters documentIntelligenceName=$DOC_INTEL_NAME location=$LOCATION"
    
    # Add optional parameters if set
    if [ -n "$DOC_INTEL_SKU" ]; then
        deploy_params="$deploy_params --parameters documentIntelligenceSku=$DOC_INTEL_SKU"
    fi
    
    if [ -n "$ENABLE_PRIVATE_ENDPOINT" ]; then
        deploy_params="$deploy_params --parameters enablePrivateEndpoint=$ENABLE_PRIVATE_ENDPOINT"
    fi
    
    if [ -n "$SUBNET_ID" ]; then
        deploy_params="$deploy_params --parameters subnetId=$SUBNET_ID"
    fi
    
    if [ -n "$ENABLE_CUSTOMER_MANAGED_KEY" ]; then
        deploy_params="$deploy_params --parameters enableCustomerManagedKey=$ENABLE_CUSTOMER_MANAGED_KEY"
    fi
    
    if [ -n "$KEY_VAULT_ID" ]; then
        deploy_params="$deploy_params --parameters keyVaultId=$KEY_VAULT_ID"
    fi
    
    if [ -n "$KEY_NAME" ]; then
        deploy_params="$deploy_params --parameters keyName=$KEY_NAME"
    fi
    
    if [ -n "$LOG_ANALYTICS_WORKSPACE_ID" ]; then
        deploy_params="$deploy_params --parameters logAnalyticsWorkspaceId=$LOG_ANALYTICS_WORKSPACE_ID"
    fi
    
    # Add resource tags if specified
    if [ -n "$RESOURCE_TAGS" ]; then
        deploy_params="$deploy_params --parameters tags=$RESOURCE_TAGS"
    fi
    
    # Deploy the template
    local start_time=$(date +%s)
    
    az deployment group create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEPLOYMENT_NAME" \
        --template-file main.bicep \
        $deploy_params \
        --output table
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "Deployment completed in ${duration} seconds"
}

# Function to get deployment outputs
get_deployment_outputs() {
    log_info "Retrieving deployment outputs..."
    
    local outputs=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEPLOYMENT_NAME" \
        --query "properties.outputs" \
        --output json)
    
    if [ "$outputs" != "null" ] && [ "$outputs" != "{}" ]; then
        echo "Deployment Outputs:"
        echo "=================="
        echo "$outputs" | jq '.'
        
        # Extract key information
        local endpoint=$(echo "$outputs" | jq -r '.documentIntelligenceConfig.value.endpoint // empty')
        local service_name=$(echo "$outputs" | jq -r '.documentIntelligenceConfig.value.name // empty')
        
        if [ -n "$endpoint" ]; then
            echo
            log_success "Document Intelligence service deployed successfully!"
            echo "Service Name: $service_name"
            echo "Endpoint: $endpoint"
            echo
            echo "Next Steps:"
            echo "1. Configure custom models for your document types"
            echo "2. Set up batch processing workflows"
            echo "3. Integrate with your applications"
            echo "4. Configure monitoring and alerting"
            echo "5. Test document processing capabilities"
        fi
    else
        log_warning "No deployment outputs available"
    fi
}

# Function to perform post-deployment verification
verify_deployment() {
    log_info "Performing post-deployment verification..."
    
    # Get the Document Intelligence service name
    local service_name="${DOC_INTEL_NAME}"
    
    # Check if the service exists and is accessible
    if az cognitiveservices account show \
        --name "$service_name" \
        --resource-group "$RESOURCE_GROUP" &> /dev/null; then
        log_success "Document Intelligence service is accessible"
        
        # Get service details
        local service_info=$(az cognitiveservices account show \
            --name "$service_name" \
            --resource-group "$RESOURCE_GROUP" \
            --output json)
        
        local sku=$(echo "$service_info" | jq -r '.sku.name')
        local location=$(echo "$service_info" | jq -r '.location')
        local provisioning_state=$(echo "$service_info" | jq -r '.properties.provisioningState')
        
        echo "Service Details:"
        echo "- SKU: $sku"
        echo "- Location: $location"
        echo "- Provisioning State: $provisioning_state"
        
        if [ "$provisioning_state" = "Succeeded" ]; then
            log_success "Service is successfully provisioned"
        else
            log_warning "Service provisioning state: $provisioning_state"
        fi
    else
        log_error "Document Intelligence service verification failed"
        return 1
    fi
}

# Function to clean up on error
cleanup_on_error() {
    log_warning "Cleaning up due to error..."
    # Add any cleanup logic here if needed
}

# Function to display usage
show_usage() {
    echo "Usage: $0"
    echo
    echo "Environment Variables:"
    echo "  RESOURCE_GROUP                   - Required: Target resource group"
    echo "  DOC_INTEL_NAME                  - Required: Document Intelligence service name"
    echo "  LOCATION                        - Optional: Azure region (default: eastus)"
    echo "  DOC_INTEL_SKU                   - Optional: Service SKU (F0/S0)"
    echo "  ENABLE_PRIVATE_ENDPOINT         - Optional: Enable private endpoint (true/false)"
    echo "  SUBNET_ID                       - Optional: Subnet ID for private endpoint"
    echo "  ENABLE_CUSTOMER_MANAGED_KEY     - Optional: Enable CMK (true/false)"
    echo "  KEY_VAULT_ID                    - Optional: Key Vault resource ID"
    echo "  KEY_NAME                        - Optional: Key name for encryption"
    echo "  LOG_ANALYTICS_WORKSPACE_ID      - Optional: Log Analytics workspace ID"
    echo "  RESOURCE_TAGS                   - Optional: Resource tags (JSON format)"
    echo "  SKIP_WHATIF                     - Optional: Skip what-if analysis (true/false)"
    echo
    echo "Examples:"
    echo "  # Basic deployment"
    echo "  export RESOURCE_GROUP=\"my-rg\""
    echo "  export DOC_INTEL_NAME=\"mydocintel\""
    echo "  ./deploy.sh"
    echo
    echo "  # Production deployment with private endpoint"
    echo "  export RESOURCE_GROUP=\"my-prod-rg\""
    echo "  export DOC_INTEL_NAME=\"mydocintel-prod\""
    echo "  export DOC_INTEL_SKU=\"S0\""
    echo "  export ENABLE_PRIVATE_ENDPOINT=\"true\""
    echo "  export SUBNET_ID=\"/subscriptions/.../subnets/mysubnet\""
    echo "  ./deploy.sh"
}

# Main execution
main() {
    # Set error trap
    trap cleanup_on_error ERR
    
    # Check for help flag
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    show_header
    
    check_prerequisites
    validate_parameters
    check_resource_group
    validate_template
    perform_whatif
    deploy_template
    get_deployment_outputs
    verify_deployment
    
    echo
    log_success "Document Intelligence deployment completed successfully!"
    echo "Deployment Name: $DEPLOYMENT_NAME"
    echo "Resource Group: $RESOURCE_GROUP"
    echo "Service Name: $DOC_INTEL_NAME"
    echo
    echo "For more information, see the README.md file"
}

# Run main function with all arguments
main "$@"
