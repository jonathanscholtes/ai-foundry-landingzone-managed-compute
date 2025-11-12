
@description('Name of the AI project')
param aiProjectName string

@description('Azure region of the deployment')
param location string

@description('Name of the user-assigned managed identity')
param managedIdentityName string

@description('Target deletion timestamp in RFC1123 format')
param targetAutoDeletionTime string

param onlineEndpointName string

// Existing Managed Identity Reference
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
}



resource aiProject 'Microsoft.MachineLearningServices/workspaces@2023-08-01-preview' existing = {
  name: aiProjectName
}



// Online Endpoint Definition
resource qwenOnlineEndpoint 'Microsoft.MachineLearningServices/workspaces/onlineEndpoints@2025-01-01-preview' = {
  parent: aiProject 
  name: onlineEndpointName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}  
    }
  }
  properties: {
    properties:{
      SharedComputeCapacityEnabled: 'true'
      TargetAutoDeletionTime: targetAutoDeletionTime
  }
    authMode: 'Key'
  }
}

// Model Deployment Definition
resource qwenModelDeployment 'Microsoft.MachineLearningServices/workspaces/onlineEndpoints/deployments@2025-01-01-preview' = {
  parent: qwenOnlineEndpoint  
  name: 'qwen3'
  location: location
  properties: {
    
    model:'azureml://registries/HuggingFace/models/qwen-qwen3-0.6b/versions/3'  
    instanceType: 'Standard_NC24ads_A100_v4'
    endpointComputeType: 'Managed'
    scaleSettings: {
      scaleType: 'Default'
    }
  }
  sku: {
    name: 'Default'
    tier: 'Standard'
    capacity: 1
}
}
