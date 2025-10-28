@description('Azure region of the deployment')
param location string

@description('Name of the AI hub')
param aiHubName string

@description('Friendly display name for the AI hub')
param aiHubFriendlyName string

@description('Description of the AI hub')
param aiHubDescription string

@description('Resource ID of the Key Vault for storing connection strings')
param keyVaultResourceId string

param containerRegistryID string

@description('Resource ID of the Azure AI Services instance')
param aiServicesResourceId string

@description('Target endpoint of the Azure AI Services instance')
param aiServicesEndpoint string

@description('Target endpoint of the Azure Blob Storage service')
param blobStorageEndpoint string

@description('Resource ID of the Azure Storage Account')
param storageAccountResourceId string

@description('Resource ID of the Application Insights instance')
param appInsightsResourceId string

@description('Name of the user-assigned managed identity')
param managedIdentityName string


@description('Name of the Azure Blob Storage container')
param blobContainerName string

@description('Name of the Azure Storage Account')
param storageAccountName string



resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
}

var aiServicesConnectionName = '${aiHubName}-connection-AI-Services'
var aiSearchConnectionName = '${aiHubName}-connection-AzureAISearch'

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-10-01-preview' = {
  name: aiHubName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: aiHubFriendlyName
    description: aiHubDescription
    keyVault: keyVaultResourceId
    containerRegistry: containerRegistryID
    applicationInsights: appInsightsResourceId
    storageAccount: storageAccountResourceId
    systemDatastoresAuthMode: 'identity'
    provisionNetworkNow: true
    publicNetworkAccess: 'Disabled'
    managedNetwork: {
      isolationMode: 'AllowInternetOutbound'
    
    }
     sharedPrivateLinkResources: [
      
    ]
  }
  kind: 'hub'
}

resource aiServicesConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-01-01-preview' = {
  parent: aiHub
  name: aiServicesConnectionName
  properties: {
    category: 'AzureOpenAI'
    target: aiServicesEndpoint
    authType: 'AAD'
    isSharedToAll: true
  
    metadata: {
      ApiType: 'Azure'
      ResourceId: aiServicesResourceId
    }
  }
}


resource aiStorageConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-01-01-preview' = {
  parent: aiHub
  name: '${aiHubName}-connection-AzureBlob'                         
  properties: {
    category: 'AzureBlob'
    target: blobStorageEndpoint
    authType: 'ApiKey'
    isSharedToAll: true
    credentials: {
      key: '${listKeys(storageAccountResourceId, '2023-01-01').keys[0].value}'
    }
    metadata: {
      ApiType: 'Azure'
      ContainerName:blobContainerName
      AccountName:storageAccountName
    }
  }
}

output aiHubResourceId string = aiHub.id
output aiHubName string = aiHubName
output aiSearchConnectionName string = aiSearchConnectionName
output aiServicesConnectionName string = aiServicesConnectionName
output aiHubPrincipalId string = aiHub.identity.principalId
