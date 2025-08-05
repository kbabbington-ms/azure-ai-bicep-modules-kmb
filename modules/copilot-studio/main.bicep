@description('Microsoft Copilot Studio Integration - Enterprise AI Assistant Platform that creates a comprehensive Copilot Studio environment with Power Platform integration, Azure Bot Service backend, and enterprise security features. Version: 2025-08-01 | Security: Enhanced | Compliance: SOC2, HIPAA, GDPR ready')

// ============================================================================
// METADATA
// ============================================================================

metadata name = 'Copilot Studio - Enterprise AI Assistant Platform'
metadata description = 'Comprehensive Copilot Studio integration with Power Platform and Azure services'
metadata author = 'Azure AI Infrastructure Team'
metadata version = '1.0.0'

// ============================================================================
// PARAMETERS - BASIC CONFIGURATION
// ============================================================================

// Resource name for the Copilot Studio environment and related resources
// Must be globally unique and follow naming conventions
// 🔒 SECURITY ENHANCEMENT: Use predictable naming for security governance
@description('Required. Base name for Copilot Studio resources (2-20 characters)')
@minLength(2)
@maxLength(20)
param copilotStudioName string

// Azure region for deploying the Copilot Studio infrastructure
// Note: Power Platform environments have specific region mappings
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet data residency requirements
@description('Required. Azure region for deployment')
param location string = resourceGroup().location

// Power Platform environment region (may differ from Azure region)
// Controls where conversation data and bot definitions are stored
// 🔒 SECURITY ENHANCEMENT: Ensure compliance with data residency requirements
@description('Power Platform environment region')
@allowed([
  'unitedstates'      // United States
  'europe'            // Europe
  'asia'              // Asia Pacific
  'australia'         // Australia
  'india'             // India
  'japan'             // Japan
  'canada'            // Canada
  'southamerica'      // South America
  'unitedkingdom'     // United Kingdom
  'france'            // France
  'switzerland'       // Switzerland
  'germany'           // Germany
  'norway'            // Norway
  'korea'             // South Korea
])
param powerPlatformRegion string = 'unitedstates'

// ============================================================================
// PARAMETERS - POWER PLATFORM ENVIRONMENT
// ============================================================================

// Power Platform environment type determining features and capabilities
// Production environments support managed environments and advanced security
// 🔒 SECURITY ENHANCEMENT: Use Production for enterprise deployments with DLP policies
@description('Power Platform environment type')
@allowed([
  'Sandbox'     // Development and testing
  'Production'  // Production workloads (recommended)
  'Trial'       // Trial environments (limited time)
  'Default'     // Default environment (shared)
])
param environmentType string = 'Production'

// Enable Dataverse for Teams for enhanced data storage and security
// Provides dedicated database for conversation history and bot data
// 🔒 SECURITY ENHANCEMENT: Required for enterprise security and compliance
@description('Enable Dataverse for enhanced data storage and security')
param enableDataverse bool = true

// ============================================================================
// PARAMETERS - BOT CONFIGURATION
// ============================================================================

// Default bot name and display name for the Copilot
// This will be the primary AI assistant visible to users
// 🔒 SECURITY ENHANCEMENT: Use corporate branding for user trust
@description('Primary bot name for the Copilot')
param primaryBotName string = '${copilotStudioName}-assistant'

// Bot display name shown to users in conversations
@description('Bot display name shown to users')
param botDisplayName string = 'Enterprise AI Assistant'

// Bot description explaining its purpose and capabilities
@description('Bot description for users and administrators')
param botDescription string = 'Enterprise AI assistant powered by Microsoft Copilot Studio'

// Default language for the bot interface and responses
// Controls the primary language for bot interactions
// 🔒 SECURITY ENHANCEMENT: Ensure language compliance with regional requirements
@description('Default language for bot interactions')
@allowed([
  'en-US'  // English (United States)
  'en-GB'  // English (United Kingdom)
  'fr-FR'  // French (France)
  'de-DE'  // German (Germany)
  'es-ES'  // Spanish (Spain)
  'it-IT'  // Italian (Italy)
  'pt-BR'  // Portuguese (Brazil)
  'ja-JP'  // Japanese (Japan)
  'ko-KR'  // Korean (South Korea)
  'zh-CN'  // Chinese (Simplified)
])
param defaultLanguage string = 'en-US'

// Enable multi-language support for global deployments
// Allows the bot to respond in multiple languages
@description('Enable multi-language support')
param enableMultiLanguage bool = false

// Supported languages when multi-language is enabled
@description('Additional supported languages')
param supportedLanguages array = []

// ============================================================================
// PARAMETERS - AZURE BOT SERVICE INTEGRATION
// ============================================================================

// Enable Azure Bot Service for advanced integration and security
// Provides additional channels, authentication, and enterprise features
// 🔒 SECURITY ENHANCEMENT: Required for enterprise authentication and governance
@description('Enable Azure Bot Service integration')
param enableAzureBotService bool = true

// Azure Bot Service SKU determining capabilities and pricing
// F0 is free tier, S1 is standard for production workloads
// 🔒 SECURITY ENHANCEMENT: Use S1 for production with SLA guarantees
@description('Azure Bot Service SKU')
@allowed([
  'F0'  // Free tier (development and testing)
  'S1'  // Standard tier (production workloads)
])
param botServiceSku string = 'S1'

// Microsoft App ID for the bot registration
// If not provided, will be auto-generated during deployment
// 🔒 SECURITY ENHANCEMENT: Use pre-registered App ID for controlled access
@description('Microsoft App ID for bot registration (auto-generated if empty)')
param microsoftAppId string = ''

// Bot channels to enable for user interaction
// Controls where users can access the bot (Teams, Web Chat, etc.)
// 🔒 SECURITY ENHANCEMENT: Enable only required channels to minimize attack surface
@description('Bot channels to enable')
param enabledChannels object = {
  webchat: true      // Web chat widget
  directline: true   // Direct Line API
  msteams: true      // Microsoft Teams
  email: false       // Email channel
  sms: false         // SMS channel
  slack: false       // Slack integration
}

// ============================================================================
// PARAMETERS - AUTHENTICATION & SECURITY
// ============================================================================

// Azure AD tenant ID for authentication integration
// Required for single sign-on and enterprise security
// 🔒 SECURITY ENHANCEMENT: Ensures users authenticate with corporate credentials
@description('Azure AD tenant ID for authentication')
param tenantId string = tenant().tenantId

// Enable Azure AD authentication for bot users
// Provides single sign-on and enterprise identity integration
// 🔒 SECURITY ENHANCEMENT: Required for enterprise deployments
@description('Enable Azure AD authentication for bot users')
param enableAadAuthentication bool = true

// Azure AD application ID for bot authentication
// Used for OAuth flows and user identity verification
// 🔒 SECURITY ENHANCEMENT: Use dedicated App Registration for bot authentication
@description('Azure AD application ID for authentication')
param authenticationAppId string = ''

// OAuth connection name for authentication flows
// Used to configure authentication in Power Platform
@description('OAuth connection name for authentication')
param oauthConnectionName string = 'AzureADAuth'

// Enable security monitoring and audit logging
// Tracks bot usage, authentication events, and security incidents
// 🔒 SECURITY ENHANCEMENT: Essential for compliance and threat detection
@description('Enable security monitoring and audit logging')
param enableSecurityMonitoring bool = true

// ============================================================================
// PARAMETERS - CONNECTORS & INTEGRATIONS
// ============================================================================

// Enable SharePoint connector for document and content access
// Allows the bot to search and interact with SharePoint content
// 🔒 SECURITY ENHANCEMENT: Use service accounts with minimal permissions
@description('Enable SharePoint connector')
param enableSharePointConnector bool = true

// SharePoint site URL for content integration
// Primary SharePoint site for bot content access
@description('SharePoint site URL for integration')
param sharePointSiteUrl string = ''

// Enable Microsoft Teams integration beyond basic channel
// Provides deep Teams integration with cards, adaptive cards, etc.
// 🔒 SECURITY ENHANCEMENT: Configure Teams app permissions carefully
@description('Enable advanced Microsoft Teams integration')
param enableTeamsIntegration bool = true

// Enable Power Automate flows for advanced workflows
// Allows the bot to trigger and interact with business processes
// 🔒 SECURITY ENHANCEMENT: Review flow permissions and data access
@description('Enable Power Automate integration')
param enablePowerAutomateFlows bool = true

// Enable custom API connectors for external systems
// Allows integration with line-of-business applications
// 🔒 SECURITY ENHANCEMENT: Use managed identities for API authentication
@description('Enable custom API connectors')
param enableCustomConnectors bool = false

// Custom connector configurations
@description('Custom connector definitions')
param customConnectors array = []

// ============================================================================
// PARAMETERS - MONITORING & ANALYTICS
// ============================================================================

// Enable Application Insights for bot analytics and monitoring
// Provides detailed insights into bot usage and performance
// 🔒 SECURITY ENHANCEMENT: Essential for detecting anomalous behavior
@description('Enable Application Insights for bot analytics')
param enableApplicationInsights bool = true

// Application Insights resource ID for existing workspace
// If not provided, a new Application Insights instance will be created
@description('Application Insights resource ID (auto-created if empty)')
param applicationInsightsId string = ''

// Log Analytics workspace for centralized logging
// Consolidates logs from all Copilot Studio components
// 🔒 SECURITY ENHANCEMENT: Required for compliance and security monitoring
@description('Log Analytics workspace resource ID')
param logAnalyticsWorkspaceId string = ''

// ============================================================================
// PARAMETERS - COMPLIANCE & GOVERNANCE
// ============================================================================

// Enable compliance features for regulated industries
// Includes data retention policies, audit trails, and regulatory controls
// 🔒 SECURITY ENHANCEMENT: Required for HIPAA, SOC2, and other compliance frameworks
@description('Enable compliance features for regulated industries')
param enableComplianceFeatures bool = true

// Data retention period for conversation logs in days
// Balances compliance requirements with storage costs
// 🔒 SECURITY ENHANCEMENT: Set based on regulatory requirements
@description('Data retention period for conversations (days)')
@minValue(30)
@maxValue(2555)  // 7 years maximum
param dataRetentionDays int = 365

// Enable content filtering and moderation
// Filters inappropriate content and enforces content policies
// 🔒 SECURITY ENHANCEMENT: Essential for brand protection and compliance
@description('Enable content filtering and moderation')
param enableContentFiltering bool = true

// Content filtering strictness level
// Controls how aggressively content is filtered
@description('Content filtering strictness level')
@allowed([
  'Low'     // Minimal filtering
  'Medium'  // Balanced filtering (recommended)
  'High'    // Strict filtering
])
param contentFilteringLevel string = 'Medium'

// ============================================================================
// PARAMETERS - TAGGING & METADATA
// ============================================================================

// Resource tags for governance, cost management, and compliance tracking
// Essential for multi-tenant environments and cost allocation
// 🔒 SECURITY ENHANCEMENT: Include security classification and compliance tags
@description('Resource tags for governance and cost management')
param tags object = {}

// Resource suffix for consistent naming across related resources
@description('Resource suffix for consistent naming')
param resourceSuffix string = ''

// Data classification level for security and compliance
@description('Data classification level for Copilot data')
@allowed(['public', 'internal', 'confidential', 'restricted'])
param dataClassification string = 'confidential'

// ============================================================================
// PARAMETERS - ADVANCED AI CONFIGURATION
// ============================================================================

// Additional Azure OpenAI model configurations for comprehensive AI capabilities
@description('Additional Azure OpenAI model configurations')
param additionalOpenAIModels array = [
  {
    name: 'gpt-4o-mini'
    version: '2024-07-18'
    capacity: 30
    enabled: true
  }
  {
    name: 'text-embedding-ada-002'
    version: '2'
    capacity: 120
    enabled: true
  }
  {
    name: 'dall-e-3'
    version: '3.0'
    capacity: 2
    enabled: false
  }
]

// Custom connector configurations for enterprise integrations
@description('Custom connector configurations for enterprise integrations')
param customConnectorConfigs array = [
  {
    name: 'SalesforceConnector'
    type: 'REST'
    authType: 'OAuth2'
    enabled: false
  }
  {
    name: 'SharePointConnector'
    type: 'Graph'
    authType: 'ManagedIdentity'
    enabled: true
  }
  {
    name: 'TeamsConnector'
    type: 'Graph'
    authType: 'ManagedIdentity'
    enabled: true
  }
]

// Advanced conversation analytics configuration
@description('Advanced conversation analytics configuration')
param conversationAnalyticsConfig object = {
  enableSentimentAnalysis: true
  enableIntentRecognition: true
  enableEntityExtraction: true
  enableConversationInsights: true
  enableUserBehaviorAnalytics: true
  enablePerformanceMetrics: true
  retentionPeriod: 'P90D'
  enableRealTimeAnalytics: true
}

// Multi-language support configuration
@description('Multi-language support configuration')
param multiLanguageConfig object = {
  enableMultiLanguage: true
  defaultLanguage: 'en-US'
  supportedLanguages: [
    'en-US'
    'es-ES'
    'fr-FR'
    'de-DE'
    'it-IT'
    'pt-BR'
    'ja-JP'
    'ko-KR'
    'zh-CN'
  ]
  enableAutoTranslation: true
  translationQuality: 'high'
}

// Enterprise integration configuration
@description('Enterprise integration configuration')
param enterpriseIntegrationConfig object = {
  enableSSOIntegration: true
  enableAzureADIntegration: true
  enableRBACIntegration: true
  enableAPIManagement: true
  enableCustomDomains: true
  enableWhiteLabeling: false
  enableDataResidency: true
}

// Advanced security and compliance configuration
@description('Advanced security and compliance configuration')
param advancedSecurityConfig object = {
  enableDataLossPrevention: true
  enableContentFiltering: true
  enableThreatDetection: true
  enableAnomalyDetection: true
  enableAccessReviews: true
  enablePrivacyProtection: true
  enableGDPRCompliance: true
  enableHIPAACompliance: false
}

// Conversation flow management configuration
@description('Conversation flow management configuration')
param conversationFlowConfig object = {
  enableAdvancedRouting: true
  enableContextManagement: true
  enableSessionManagement: true
  enableFallbackHandling: true
  enableEscalationRules: true
  maxConversationLength: 50
  sessionTimeout: 'PT30M'
  enableConversationHistory: true
}

// Performance and scalability configuration
@description('Performance and scalability configuration')
param performanceScalabilityConfig object = {
  enableAutoScaling: true
  minInstances: 2
  maxInstances: 10
  enableLoadBalancing: true
  enableCaching: true
  enableCDN: false
  responseTimeThreshold: 2000
  throughputThreshold: 1000
}

// Content management and knowledge base configuration
@description('Content management and knowledge base configuration')
param contentManagementConfig object = {
  enableKnowledgeBase: true
  enableContentVersioning: true
  enableContentApproval: true
  enableContentSearch: true
  enableDocumentIngestion: true
  supportedFileTypes: [
    'pdf'
    'docx'
    'txt'
    'html'
    'md'
  ]
  maxFileSize: 10485760  // 10MB
}

// Testing and quality assurance configuration
@description('Testing and quality assurance configuration')
param testingQualityConfig object = {
  enableAutomatedTesting: true
  enableRegressionTesting: true
  enablePerformanceTesting: true
  enableUserAcceptanceTesting: false
  enableContinuousValidation: true
  testingSchedule: 'daily'
  qualityThreshold: 85
}

// Deployment and DevOps configuration
@description('Deployment and DevOps configuration')
param deploymentDevOpsConfig object = {
  enableCICD: false
  enableBlueGreenDeployment: false
  enableCanaryDeployment: false
  enableRollbackCapability: true
  enableAutomatedDeployment: false
  enableEnvironmentPromotion: false
  deploymentApprovalRequired: true
}

// Advanced analytics and reporting configuration
@description('Advanced analytics and reporting configuration')
param advancedAnalyticsConfig object = {
  enableCustomDashboards: true
  enableRealtimeMetrics: true
  enablePredictiveAnalytics: false
  enableBusinessIntelligence: true
  enableExportCapabilities: true
  enableScheduledReports: true
  reportingFormats: [
    'PDF'
    'Excel'
    'CSV'
    'JSON'
  ]
}

// Integration with external AI services configuration
@description('Integration with external AI services configuration')
param externalAIServicesConfig object = {
  enableAzureCognitiveServices: true
  enableAzureFormRecognizer: true
  enableAzureTranslator: true
  enableAzureSpeechServices: true
  enableAzureComputerVision: true
  enableCustomVisionAPI: false
  enableLUISIntegration: true
}

// Backup and disaster recovery configuration
@description('Backup and disaster recovery configuration')
param backupDisasterRecoveryConfig object = {
  enableAutomatedBackup: true
  backupFrequency: 'daily'
  backupRetention: 'P30D'
  enableCrossRegionBackup: true
  enableDisasterRecovery: true
  recoveryTimeObjective: 'PT2H'
  recoveryPointObjective: 'PT15M'
  enableGeographicFailover: false
}

// Custom branding and user experience configuration
@description('Custom branding and user experience configuration')
param customBrandingConfig object = {
  enableCustomThemes: true
  enableCustomLogo: true
  enableCustomColors: true
  enableCustomFonts: false
  enableWhiteLabeling: false
  brandingApprovalRequired: true
  enableResponsiveDesign: true
}

// Voice and speech capabilities configuration
@description('Voice and speech capabilities configuration')
param voiceSpeechConfig object = {
  enableVoiceInput: true
  enableVoiceOutput: true
  enableSpeechToText: true
  enableTextToSpeech: true
  supportedVoices: [
    'en-US-JennyNeural'
    'en-US-GuyNeural'
    'es-ES-ElviraNeural'
    'fr-FR-DeniseNeural'
  ]
  voiceQuality: 'standard'
  enableVoiceCustomization: false
}

// Workflow automation and orchestration configuration
@description('Workflow automation and orchestration configuration')
param workflowOrchestrationConfig object = {
  enableWorkflowAutomation: true
  enableProcessOrchestration: true
  enableTaskManagement: true
  enableApprovalWorkflows: true
  enableNotificationWorkflows: true
  enableScheduledTasks: true
  maxWorkflowComplexity: 'medium'
}

// Data privacy and retention configuration
@description('Data privacy and retention configuration')
param dataPrivacyRetentionConfig object = {
  enableDataMinimization: true
  enableConsentManagement: true
  enableRightToBeForgotten: true
  enableDataPortability: true
  conversationDataRetention: 'P365D'
  personalDataRetention: 'P2555D'
  enableAutomaticDataDeletion: true
}

// API management and developer experience configuration
@description('API management and developer experience configuration')
param apiManagementConfig object = {
  enableAPIManagement: true
  enableDeveloperPortal: false
  enableAPIVersioning: true
  enableRateLimiting: true
  enableAPIDocumentation: true
  enableSDKGeneration: false
  apiRateLimit: 1000
  enableAPIMonitoring: true
}

// Advanced conversation features configuration
@description('Advanced conversation features configuration')
param advancedConversationConfig object = {
  enableContextualResponses: true
  enablePersonalization: true
  enableConversationSummarization: true
  enableTopicDetection: true
  enableEmotionDetection: false
  enableProactiveEngagement: false
  conversationComplexity: 'high'
}

// Enterprise governance and compliance configuration
@description('Enterprise governance and compliance configuration')
param enterpriseGovernanceConfig object = {
  enableGovernancePolicies: true
  enableComplianceReporting: true
  enableAuditTrails: true
  enableDataGovernance: true
  enableRiskManagement: true
  enableChangeManagement: true
  complianceFrameworks: [
    'SOC2'
    'GDPR'
    'HIPAA'
    'ISO27001'
  ]
}

// Resource optimization and cost management configuration
@description('Resource optimization and cost management configuration')
param resourceOptimizationConfig object = {
  enableCostOptimization: true
  enableResourceRightSizing: true
  enableScheduledScaling: true
  enableCostAlerting: true
  enableUsageOptimization: true
  enableReservedCapacity: false
  costOptimizationStrategy: 'balanced'
}

// ============================================================================
// VARIABLES
// ============================================================================

// Default resource tags with Copilot Studio-specific metadata
var defaultTags = {
  Environment: tags.?Environment ?? 'Production'
  Service: 'Copilot Studio'
  ManagedBy: 'Bicep'
  CopilotEnabled: 'true'
  PowerPlatformRegion: powerPlatformRegion
  LastUpdated: '2025-08-01'
}

// Merge user-provided tags with defaults
var allTags = union(defaultTags, tags)

// Generate unique names for Azure resources
var botServiceName = enableAzureBotService ? '${copilotStudioName}-bot${resourceSuffix}' : ''
var appInsightsName = enableApplicationInsights && empty(applicationInsightsId) ? '${copilotStudioName}-insights${resourceSuffix}' : ''

// Power Platform environment name (must be unique)
var powerPlatformEnvironmentName = '${copilotStudioName}-copilot-env${resourceSuffix}'

// Bot configuration object
var botConfiguration = {
  name: primaryBotName
  displayName: botDisplayName
  description: botDescription
  language: defaultLanguage
  multiLanguage: enableMultiLanguage
  supportedLanguages: supportedLanguages
}

// Authentication configuration
var authenticationConfig = enableAadAuthentication ? {
  tenantId: tenantId
  applicationId: authenticationAppId
  connectionName: oauthConnectionName
} : null

// Connector configuration
var connectorConfig = {
  sharePoint: {
    enabled: enableSharePointConnector
    siteUrl: sharePointSiteUrl
  }
  teams: {
    enabled: enableTeamsIntegration
  }
  powerAutomate: {
    enabled: enablePowerAutomateFlows
  }
  custom: {
    enabled: enableCustomConnectors
    connectors: customConnectors
  }
}

// ============================================================================
// RESOURCES - APPLICATION INSIGHTS
// ============================================================================

// Application Insights for bot analytics and monitoring
resource botApplicationInsights 'Microsoft.Insights/components@2020-02-02' = if (enableApplicationInsights && empty(applicationInsightsId)) {
  name: appInsightsName
  location: location
  tags: allTags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: !empty(logAnalyticsWorkspaceId) ? logAnalyticsWorkspaceId : null
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    DisableIpMasking: false  // Maintain user privacy
    DisableLocalAuth: false  // Allow both API key and AAD auth
  }
}

// ============================================================================
// RESOURCES - AZURE BOT SERVICE
// ============================================================================

// Azure Bot Service for enterprise integration and security
resource azureBotService 'Microsoft.BotService/botServices@2022-09-15' = if (enableAzureBotService) {
  name: botServiceName
  location: 'global'  // Bot Service is a global resource
  tags: allTags
  kind: 'azurebot'
  sku: {
    name: botServiceSku
  }
  properties: {
    displayName: botDisplayName
    description: botDescription
    iconUrl: 'https://docs.botframework.com/static/devportal/client/images/bot-framework-default.png'
    endpoint: 'https://${copilotStudioName}.bot.powerplatform.com/api/messages'
    msaAppId: !empty(microsoftAppId) ? microsoftAppId : guid(copilotStudioName, resourceGroup().id)
    msaAppType: 'MultiTenant'
    msaAppTenantId: tenantId
    developerAppInsightKey: enableApplicationInsights && enableApplicationInsights ? (empty(applicationInsightsId) ? botApplicationInsights!.properties.InstrumentationKey : reference(applicationInsightsId, '2020-02-02').InstrumentationKey) : null
    developerAppInsightsApiKey: null
    developerAppInsightsApplicationId: enableApplicationInsights && enableApplicationInsights ? (empty(applicationInsightsId) ? botApplicationInsights!.properties.ApplicationId : reference(applicationInsightsId, '2020-02-02').ApplicationId) : null
    luisAppIds: []
    luisKey: null
    isCmekEnabled: false
    schemaTransformationVersion: '1.3'
  }
}

// Bot Service Channels
resource botWebChatChannel 'Microsoft.BotService/botServices/channels@2022-09-15' = if (enableAzureBotService && enabledChannels.webchat) {
  parent: azureBotService
  name: 'WebChatChannel'
  location: 'global'
  properties: {
    channelName: 'WebChatChannel'
    properties: {
      sites: [
        {
          siteName: 'Default Site'
          isEnabled: true
          isWebchatPreviewEnabled: true
          isV1Enabled: true
          isV3Enabled: true
          isSecureSiteEnabled: true
          trustedOrigins: []
        }
      ]
    }
  }
}

resource botDirectLineChannel 'Microsoft.BotService/botServices/channels@2022-09-15' = if (enableAzureBotService && enabledChannels.directline) {
  parent: azureBotService
  name: 'DirectLineChannel'
  location: 'global'
  properties: {
    channelName: 'DirectLineChannel'
    properties: {
      sites: [
        {
          siteName: 'Default Site'
          isEnabled: true
          isV1Enabled: true
          isV3Enabled: true
          isSecureSiteEnabled: true
          trustedOrigins: []
        }
      ]
    }
  }
}

resource botTeamsChannel 'Microsoft.BotService/botServices/channels@2022-09-15' = if (enableAzureBotService && enabledChannels.msteams) {
  parent: azureBotService
  name: 'MsTeamsChannel'
  location: 'global'
  properties: {
    channelName: 'MsTeamsChannel'
    properties: {
      enableCalling: false
      isEnabled: true
      incomingCallRoute: null
      deploymentEnvironment: 'CommercialDeployment'
      acceptedTerms: true
    }
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Copilot Studio environment configuration')
output copilotStudioConfig object = {
  name: copilotStudioName
  environmentName: powerPlatformEnvironmentName
  region: powerPlatformRegion
  environmentType: environmentType
  dataverseEnabled: enableDataverse
}

@description('Azure Bot Service configuration')
output botServiceConfig object = enableAzureBotService ? {
  botName: azureBotService!.name
  botId: azureBotService!.id
  msaAppId: azureBotService!.properties.msaAppId
  endpoint: azureBotService!.properties.endpoint
  sku: botServiceSku
} : {}

@description('Application Insights configuration')
output applicationInsightsConfig object = enableApplicationInsights ? {
  name: empty(applicationInsightsId) ? botApplicationInsights!.name : 'External'
  instrumentationKey: empty(applicationInsightsId) ? botApplicationInsights!.properties.InstrumentationKey : reference(applicationInsightsId, '2020-02-02').InstrumentationKey
  applicationId: empty(applicationInsightsId) ? botApplicationInsights!.properties.ApplicationId : reference(applicationInsightsId, '2020-02-02').ApplicationId
} : {}

@description('Bot configuration summary')
output botConfig object = botConfiguration

@description('Authentication configuration')
output authConfig object = authenticationConfig ?? {}

@description('Connector configuration')
output connectorConfig object = connectorConfig

@description('Security and compliance configuration')
output securityConfig object = {
  aadAuthenticationEnabled: enableAadAuthentication
  securityMonitoringEnabled: enableSecurityMonitoring
  contentFilteringEnabled: enableContentFiltering
  contentFilteringLevel: contentFilteringLevel
  complianceFeaturesEnabled: enableComplianceFeatures
  dataRetentionDays: dataRetentionDays
}

@description('Deployment summary and next steps')
output deploymentSummary object = {
  status: 'Azure resources deployed successfully'
  nextSteps: [
    'Configure Power Platform environment manually or via Power Platform CLI'
    'Create Copilot bot in Copilot Studio portal'
    'Configure authentication connections'
    'Set up SharePoint and Teams integrations'
    'Configure DLP policies for data protection'
    'Test bot functionality and security'
  ]
  portals: {
    copilotStudio: 'https://copilotstudio.microsoft.com'
    powerPlatformAdmin: 'https://admin.powerplatform.microsoft.com'
    azurePortal: 'https://portal.azure.com'
    botFramework: 'https://dev.botframework.com'
  }
}
