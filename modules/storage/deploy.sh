#!/bin/bash

# =============================================================================
# Azure Storage Account Deployment Script
# =============================================================================
# This script deploys a secure Azure Storage Account using the Bicep module
# with different configuration scenarios.
# =============================================================================

set -e  # Exit on any error

# =============================================================================
# CONFIGURATION
# =============================================================================

# Basic settings
RESOURCE_GROUP_NAME="rg-storage-test"
LOCATION="East US 2"
SUBSCRIPTION_ID="your-subscription-id-here"
STORAGE_ACCOUNT_NAME="stgtest$(date +%Y%m%d%H%M%S | tail -c 10)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# FUNCTIONS
# =============================================================================

print_header() {
    echo -e "${BLUE}=============================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=============================================================${NC}"
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    print_header "Checking Prerequisites"
    
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
    
    # Check if Bicep is available
    if ! az bicep version &> /dev/null; then
        print_info "Installing Bicep CLI..."
        az bicep install
    fi
    
    print_info "Prerequisites check completed successfully"
}

create_resource_group() {
    print_header "Creating Resource Group"
    
    if az group show --name "$RESOURCE_GROUP_NAME" &> /dev/null; then
        print_warning "Resource group '$RESOURCE_GROUP_NAME' already exists"
    else
        print_info "Creating resource group '$RESOURCE_GROUP_NAME' in '$LOCATION'"
        az group create \
            --name "$RESOURCE_GROUP_NAME" \
            --location "$LOCATION" \
            --tags \
                Purpose="Storage Testing" \
                Environment="Development" \
                CreatedBy="$(az account show --query user.name -o tsv)" \
                CreatedDate="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    fi
}

validate_template() {
    print_header "Validating Bicep Template"
    
    print_info "Validating storage account template..."
    az deployment group validate \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --template-file "modules/storage/storage-account.bicep" \
        --parameters storageAccountName="$STORAGE_ACCOUNT_NAME" \
                    location="$LOCATION" \
                    skuName="Standard_LRS" \
                    kind="StorageV2"
    
    print_info "Template validation completed successfully"
}

deploy_basic_storage() {
    print_header "Deploying Basic Storage Account"
    
    local deployment_name="basic-storage-$(date +%Y%m%d%H%M%S)"
    
    print_info "Deploying basic storage account: $STORAGE_ACCOUNT_NAME"
    az deployment group create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$deployment_name" \
        --template-file "modules/storage/storage-account.bicep" \
        --parameters \
            storageAccountName="$STORAGE_ACCOUNT_NAME" \
            location="$LOCATION" \
            skuName="Standard_LRS" \
            kind="StorageV2" \
            accessTier="Hot" \
            tags='{"Environment":"Development","Purpose":"Testing","DeploymentType":"Basic"}'
    
    print_info "Basic storage account deployment completed"
}

deploy_secure_storage() {
    print_header "Deploying Secure Storage Account"
    
    local secure_storage_name="stgsec$(date +%Y%m%d%H%M%S | tail -c 10)"
    local deployment_name="secure-storage-$(date +%Y%m%d%H%M%S)"
    
    print_info "Deploying secure storage account: $secure_storage_name"
    az deployment group create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$deployment_name" \
        --template-file "modules/storage/storage-account.bicep" \
        --parameters \
            storageAccountName="$secure_storage_name" \
            location="$LOCATION" \
            skuName="Standard_ZRS" \
            kind="StorageV2" \
            accessTier="Hot" \
            supportsHttpsTrafficOnly=true \
            minimumTlsVersion="TLS1_2" \
            allowSharedKeyAccess=false \
            allowBlobPublicAccess=false \
            allowCrossTenantReplication=false \
            defaultToOAuthAuthentication=true \
            publicNetworkAccess="Disabled" \
            allowedCopyScope="AAD" \
            networkAclsDefaultAction="Deny" \
            networkAclsBypass="AzureServices" \
            encryptionKeySource="Microsoft.Storage" \
            requireInfrastructureEncryption=true \
            managedIdentityType="SystemAssigned" \
            sasExpirationPeriod="01.00:00:00" \
            sasExpirationAction="Block" \
            keyExpirationPeriodInDays=90 \
            tags='{"Environment":"Production","Purpose":"Secure Testing","DeploymentType":"Secure","DataClassification":"Confidential"}'
    
    print_info "Secure storage account deployment completed"
}

deploy_datalake_storage() {
    print_header "Deploying Data Lake Storage Account"
    
    local datalake_storage_name="stgdl$(date +%Y%m%d%H%M%S | tail -c 10)"
    local deployment_name="datalake-storage-$(date +%Y%m%d%H%M%S)"
    
    print_info "Deploying Data Lake storage account: $datalake_storage_name"
    az deployment group create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$deployment_name" \
        --template-file "modules/storage/storage-account.bicep" \
        --parameters \
            storageAccountName="$datalake_storage_name" \
            location="$LOCATION" \
            skuName="Standard_ZRS" \
            kind="StorageV2" \
            accessTier="Hot" \
            isHnsEnabled=true \
            supportsHttpsTrafficOnly=true \
            minimumTlsVersion="TLS1_2" \
            allowSharedKeyAccess=false \
            allowBlobPublicAccess=false \
            defaultToOAuthAuthentication=true \
            publicNetworkAccess="Disabled" \
            networkAclsDefaultAction="Deny" \
            networkAclsBypass="AzureServices" \
            managedIdentityType="SystemAssigned" \
            tags='{"Environment":"Development","Purpose":"Data Lake","DeploymentType":"Analytics","DataProcessing":"BigData"}'
    
    print_info "Data Lake storage account deployment completed"
}

verify_deployment() {
    print_header "Verifying Deployment"
    
    print_info "Listing storage accounts in resource group..."
    az storage account list \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --query "[].{Name:name,Location:location,Kind:kind,Sku:sku.name,CreationTime:creationTime}" \
        --output table
    
    print_info "Checking storage account security settings..."
    for storage_account in $(az storage account list --resource-group "$RESOURCE_GROUP_NAME" --query "[].name" -o tsv); do
        echo -e "\n${BLUE}Storage Account: $storage_account${NC}"
        
        # Get security settings
        local security_info=$(az storage account show \
            --name "$storage_account" \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --query "{HttpsOnly:supportsHttpsTrafficOnly,MinTls:minimumTlsVersion,PublicAccess:allowBlobPublicAccess,SharedKey:allowSharedKeyAccess,NetworkAccess:publicNetworkAccess}" \
            --output json)
        
        echo "$security_info" | jq .
    done
}

cleanup_resources() {
    print_header "Cleanup Resources"
    
    read -p "Do you want to delete the test resource group '$RESOURCE_GROUP_NAME'? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Deleting resource group '$RESOURCE_GROUP_NAME'..."
        az group delete --name "$RESOURCE_GROUP_NAME" --yes --no-wait
        print_info "Resource group deletion initiated (running in background)"
    else
        print_info "Resource group '$RESOURCE_GROUP_NAME' preserved"
        print_warning "Remember to clean up resources manually to avoid charges"
    fi
}

show_help() {
    cat << EOF
Azure Storage Account Deployment Script

Usage: $0 [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -g, --resource-group    Resource group name (default: $RESOURCE_GROUP_NAME)
    -l, --location          Azure location (default: $LOCATION)
    -s, --subscription      Azure subscription ID
    --basic                 Deploy basic storage account only
    --secure                Deploy secure storage account only
    --datalake              Deploy data lake storage account only
    --no-cleanup            Skip cleanup prompt

EXAMPLES:
    $0                      # Deploy all scenarios with interactive cleanup
    $0 --basic              # Deploy only basic storage account
    $0 --secure --no-cleanup # Deploy secure storage without cleanup prompt
    $0 -g "my-rg" -l "West US 2" # Use custom resource group and location

SECURITY FEATURES DEMONSTRATED:
    - HTTPS-only traffic enforcement
    - Minimum TLS version configuration
    - Shared key access controls
    - Public blob access restrictions
    - Network access controls
    - Customer-managed encryption options
    - Managed identity integration
    - SAS policy enforcement
    - Cross-tenant replication controls

EOF
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    local deploy_basic=true
    local deploy_secure=true
    local deploy_datalake=true
    local skip_cleanup=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -g|--resource-group)
                RESOURCE_GROUP_NAME="$2"
                shift 2
                ;;
            -l|--location)
                LOCATION="$2"
                shift 2
                ;;
            -s|--subscription)
                SUBSCRIPTION_ID="$2"
                shift 2
                ;;
            --basic)
                deploy_basic=true
                deploy_secure=false
                deploy_datalake=false
                shift
                ;;
            --secure)
                deploy_basic=false
                deploy_secure=true
                deploy_datalake=false
                shift
                ;;
            --datalake)
                deploy_basic=false
                deploy_secure=false
                deploy_datalake=true
                shift
                ;;
            --no-cleanup)
                skip_cleanup=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    print_header "Azure Storage Account Deployment"
    print_info "Resource Group: $RESOURCE_GROUP_NAME"
    print_info "Location: $LOCATION"
    print_info "Timestamp: $(date)"
    
    # Set subscription if provided
    if [[ -n "$SUBSCRIPTION_ID" && "$SUBSCRIPTION_ID" != "your-subscription-id-here" ]]; then
        print_info "Setting Azure subscription: $SUBSCRIPTION_ID"
        az account set --subscription "$SUBSCRIPTION_ID"
    fi
    
    # Execute deployment steps
    check_prerequisites
    create_resource_group
    validate_template
    
    if [[ "$deploy_basic" == true ]]; then
        deploy_basic_storage
    fi
    
    if [[ "$deploy_secure" == true ]]; then
        deploy_secure_storage
    fi
    
    if [[ "$deploy_datalake" == true ]]; then
        deploy_datalake_storage
    fi
    
    verify_deployment
    
    if [[ "$skip_cleanup" == false ]]; then
        cleanup_resources
    fi
    
    print_header "Deployment Completed Successfully"
    print_info "All storage accounts have been deployed and verified"
    
    if [[ "$skip_cleanup" == true ]]; then
        print_warning "Resources are still running in resource group: $RESOURCE_GROUP_NAME"
        print_warning "Remember to clean up manually to avoid charges"
    fi
}

# Run main function with all arguments
main "$@"
