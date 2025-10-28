@description('AI Hub Name')
param aiHubName string

@description('AI Hub Id')
param aiHubPrincipalId string

@description('AI Project Id')
param aiProjectPrincipalId string

@description('AI Services Name')
param aiServicesName string

@description('AI Services Id')
param aiServicesPrincipalId string


@description('Storage Name')
param storageName string

@description('Private Endpoint IDs for Storage, AI Services, and Search')
param storagePrivateEndpointName string
param aiServicesPrivateEndpointName string


var role = {
  SearchIndexDataContributor: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
  SearchServiceContributor: '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
  SearchIndexDataReader: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
  StorageBlobDataReader: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
  StorageBlobDataContributor: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  CognitiveServicesOpenAiContributor: 'a001fd3d-188f-4b5d-821b-7da978bf7442'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}



resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageName
}

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-10-01-preview' existing = {
  name: aiHubName
}

resource storagePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' existing ={
  name:storagePrivateEndpointName
}

resource aiServicesPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' existing ={
  name:aiServicesPrivateEndpointName
}




// AI Service Identity



resource storageBlobDataContributorAI 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'StorageBlobDataContributorAI')
  scope: storage
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role.StorageBlobDataContributor)
    principalId: aiServicesPrincipalId
    principalType: 'ServicePrincipal'
  }
}


resource aiHubReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'StorageBlobDataReaderAIHub')
  scope: aiHub
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role.StorageBlobDataReader)
    principalId: aiHubPrincipalId
    principalType: 'ServicePrincipal'
  }
}



// AI Project Identity Assignments


resource aiProjectStorageReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'AIProjectStorageReader')
  scope: storagePrivateEndpoint
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role.Reader)
    principalId: aiProjectPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource aiProjectAiServicesReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'AIProjectAiServicesReader')
  scope: aiServicesPrivateEndpoint
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role.Reader)
    principalId: aiProjectPrincipalId
    principalType: 'ServicePrincipal'
  }
}



output aiHubPrincipalId string = aiHubPrincipalId
output aiProjectPrincipalId string = aiProjectPrincipalId
output aiServicesPrincipalId string = aiServicesPrincipalId

