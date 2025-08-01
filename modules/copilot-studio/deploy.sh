#!/bin/bash

# Azure Copilot Studio Module Deployment Script
# This script deploys the Copilot Studio module with enterprise-grade configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Default values
RESOURCE_GROUP=""
LOCATION="eastus"
DEPLOYMENT_NAME="copilot-studio-$(date +%Y%m%d-%H%M%S)"
TEMPLATE_FILE="main.bicep"
PARAMETERS_FILE="main.parameters.json"
SUBSCRIPTION_ID=""
VALIDATE_ONLY=false
COPILOT_STUDIO_NAME=""
POWER_PLATFORM_REGION="unitedstates"

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Deploy Azure Copilot Studio Module"
    echo ""
    echo "Required Options:"
    echo "  -g, --resource-group RESOURCE_GROUP    Name of the resource group"
    echo "  -n, --name COPILOT_STUDIO_NAME        Name for the Copilot Studio environment"
    echo ""
    echo "Optional Options:"
    echo "  -s, --subscription SUBSCRIPTION_ID     Azure subscription ID"
    echo "  -l, --location LOCATION                Azure region (default: eastus)"
    echo "  -r, --power-platform-region REGION     Power Platform region (default: unitedstates)"
    echo "  -d, --deployment-name DEPLOYMENT_NAME  Deployment name (default: auto-generated)"
    echo "  -p, --parameters-file PARAMETERS_FILE  Parameters file (default: main.parameters.json)"
    echo "  --validate-only                        Only validate the template without deploying"
    echo "  -h, --help                             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -g myResourceGroup -n mycopilot"
    echo "  $0 -g myResourceGroup -n mycopilot -l westus2 -r unitedstates"
    echo "  $0 -g myResourceGroup -n mycopilot --validate-only"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -n|--name)
            COPILOT_STUDIO_NAME="$2"
            shift 2
            ;;
        -s|--subscription)
            SUBSCRIPTION_ID="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -r|--power-platform-region)
            POWER_PLATFORM_REGION="$2"
            shift 2
            ;;
        -d|--deployment-name)
            DEPLOYMENT_NAME="$2"
            shift 2
            ;;
        -p|--parameters-file)
            PARAMETERS_FILE="$2"
            shift 2
            ;;
        --validate-only)
            VALIDATE_ONLY=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$RESOURCE_GROUP" ]]; then
    print_error "Resource group is required. Use -g or --resource-group"
    show_usage
    exit 1
fi

if [[ -z "$COPILOT_STUDIO_NAME" ]]; then
    print_error "Copilot Studio name is required. Use -n or --name"
    show_usage
    exit 1
fi

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Set subscription if provided
if [[ -n "$SUBSCRIPTION_ID" ]]; then
    print_status "Setting subscription to $SUBSCRIPTION_ID"
    az account set --subscription "$SUBSCRIPTION_ID"
fi

# Get current subscription info
CURRENT_SUBSCRIPTION=$(az account show --query name -o tsv)
CURRENT_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
print_status "Using subscription: $CURRENT_SUBSCRIPTION ($CURRENT_SUBSCRIPTION_ID)"

# Check if resource group exists
if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    print_warning "Resource group '$RESOURCE_GROUP' does not exist."
    read -p "Create resource group '$RESOURCE_GROUP' in location '$LOCATION'? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Creating resource group '$RESOURCE_GROUP'"
        az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
        print_success "Resource group created successfully"
    else
        print_error "Deployment cancelled"
        exit 1
    fi
fi

# Check if template files exist
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    print_error "Template file '$TEMPLATE_FILE' not found"
    exit 1
fi

if [[ ! -f "$PARAMETERS_FILE" ]]; then
    print_error "Parameters file '$PARAMETERS_FILE' not found"
    exit 1
fi

# Validate Power Platform region
VALID_REGIONS=("unitedstates" "europe" "asia" "australia" "india" "japan" "canada" "southamerica" "unitedkingdom" "france" "germany" "switzerland" "norway" "korea" "southafrica")
if [[ ! " ${VALID_REGIONS[@]} " =~ " ${POWER_PLATFORM_REGION} " ]]; then
    print_error "Invalid Power Platform region: $POWER_PLATFORM_REGION"
    print_error "Valid regions: ${VALID_REGIONS[*]}"
    exit 1
fi

print_status "Starting deployment with the following configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Location: $LOCATION"
echo "  Copilot Studio Name: $COPILOT_STUDIO_NAME"
echo "  Power Platform Region: $POWER_PLATFORM_REGION"
echo "  Deployment Name: $DEPLOYMENT_NAME"
echo "  Template File: $TEMPLATE_FILE"
echo "  Parameters File: $PARAMETERS_FILE"
echo "  Validate Only: $VALIDATE_ONLY"

# Confirm deployment
if [[ "$VALIDATE_ONLY" == "false" ]]; then
    echo
    read -p "Proceed with deployment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Deployment cancelled"
        exit 1
    fi
fi

# Validate template
print_status "Validating Bicep template..."
if az deployment group validate \
    --resource-group "$RESOURCE_GROUP" \
    --template-file "$TEMPLATE_FILE" \
    --parameters @"$PARAMETERS_FILE" \
    --parameters copilotStudioName="$COPILOT_STUDIO_NAME" \
    --parameters location="$LOCATION" \
    --parameters powerPlatformRegion="$POWER_PLATFORM_REGION" \
    --output none; then
    print_success "Template validation passed"
else
    print_error "Template validation failed"
    exit 1
fi

# Exit if validate-only mode
if [[ "$VALIDATE_ONLY" == "true" ]]; then
    print_success "Validation completed successfully"
    exit 0
fi

# Deploy template
print_status "Deploying Copilot Studio module..."
DEPLOYMENT_OUTPUT=$(az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --template-file "$TEMPLATE_FILE" \
    --parameters @"$PARAMETERS_FILE" \
    --parameters copilotStudioName="$COPILOT_STUDIO_NAME" \
    --parameters location="$LOCATION" \
    --parameters powerPlatformRegion="$POWER_PLATFORM_REGION" \
    --output json)

if [[ $? -eq 0 ]]; then
    print_success "Deployment completed successfully!"
    
    # Extract outputs
    print_status "Deployment outputs:"
    echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs // {}'
    
    # Show important information
    print_status "Important Information:"
    echo "  Deployment Name: $DEPLOYMENT_NAME"
    echo "  Resource Group: $RESOURCE_GROUP"
    echo "  Copilot Studio Name: $COPILOT_STUDIO_NAME"
    
    print_status "Next Steps:"
    echo "1. Navigate to Power Platform Admin Center"
    echo "2. Configure your Copilot Studio environment"
    echo "3. Set up authentication and security policies"
    echo "4. Configure bot channels as needed"
    echo "5. Monitor deployment in Azure portal"
    
else
    print_error "Deployment failed"
    exit 1
fi

print_success "Copilot Studio module deployment completed!"
