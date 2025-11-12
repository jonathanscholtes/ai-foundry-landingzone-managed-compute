
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
resource gptOnlineEndpoint 'Microsoft.MachineLearningServices/workspaces/onlineEndpoints@2025-01-01-preview' = {
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
    authMode: 'Key'
  }
}

// Model Deployment Definition
resource gptModelDeployment 'Microsoft.MachineLearningServices/workspaces/onlineEndpoints/deployments@2025-01-01-preview' = {
  parent: gptOnlineEndpoint
  name: 'gpt-4o-mini'
  location: location
  properties: {
    model: 'azureml://registries/azure-openai/models/gpt-4o-mini/versions/2024-07-18'
    environmentId: 'azureml://registries/azureml/environments/minimal-py312-cuda12.4-inference/versions/6'
    codeConfiguration: {
      scoringScript: 'score.py'
    }
    instanceType: 'Standard_DS3_v2'
    endpointComputeType: 'Managed'
    scaleSettings: {
      scaleType: 'Default'
    }
  }
  sku: {
    name: 'Default'
    tier: 'Standard'
    capacity: 2
  }
}

