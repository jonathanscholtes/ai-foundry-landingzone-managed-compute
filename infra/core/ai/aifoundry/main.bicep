
param projectName string
param environmentName string
param resourceToken string
param location string
param identityName string
param vnetId string
param subnetName string
param applicationInsightsId string
param storageAccountId string
param storageAccountTarget string
param storageAccountName string
param agentSubnetId string
param deployOnlineEndpoints bool = false



@description('Resource ID of the key vault resource for storing connection strings')
param keyVaultId string

@description('Target deletion timestamp in RFC1123 format')
param targetAutoDeletionTime string

param containerRegistryID string

var aiServicesName  = 'ais-${projectName}-${environmentName}-${resourceToken}'
var aiProjectName  = 'prj-${projectName}-${environmentName}-${resourceToken}'

module aiServices 'modules/azure-ai-services.bicep' = {
  name: 'aiServices'
  params: {
    aiServicesName: aiServicesName
    location: location
    identityName: identityName
    customSubdomain: 'openai-app-${resourceToken}'
    vnetId:vnetId
    subnetName:subnetName
  }
}

module aiServicePE 'modules/ai-service-private-endpoint.bicep' = { 
  name: 'aiServicePE'
  params: { 
     aiServicesName:aiServicesName
      location:location
      vnetId:vnetId
      subnetName:'servicesSubnet'
  }
  dependsOn:[aiServices]
}

module aiHub 'modules/ai-hub.bicep' = {
  name: 'aihub'
  params:{
    aiHubName: 'hub-${projectName}-${environmentName}-${resourceToken}'
    aiHubDescription: 'Hub for demo'
    aiServicesResourceId:aiServices.outputs.aiservicesID
    aiServicesEndpoint: '${aiServices.outputs.OpenAIEndPoint}/'
    keyVaultResourceId: keyVaultId
    location: location
    aiHubFriendlyName: 'AI Demo Hub'
    appInsightsResourceId:applicationInsightsId
    managedIdentityName:identityName
    storageAccountResourceId:storageAccountId
    blobStorageEndpoint:storageAccountTarget
    storageAccountName:storageAccountName
    blobContainerName:'workspace'
    containerRegistryID:containerRegistryID
  }
  dependsOn:[aiServicePE]
}

module aihubPE 'modules/ai-hub-private-endpoint.bicep' = { 
  name: 'aihubPE'
  params: { 
    aiHubName: 'hub-${projectName}-${environmentName}-${resourceToken}'
    location:location
    subnetName:'servicesSubnet'
    vnetId:vnetId
    resourceToken:resourceToken
  }
  dependsOn:[aiHub]
}

module aiProject 'modules/ai-project.bicep' = {
  name: 'aiProject'
  params:{
    aiHubResourceId:aiHub.outputs.aiHubResourceId
    location: location
    aiProjectName: aiProjectName
    aiProjectFriendlyName: 'AI Demo Project'
    aiProjectDescription: 'Project for demo'  
  
  }
  dependsOn:[aihubPE]
}

module aiModels 'modules/ai-models.bicep' = {
  name:'aiModels'
  params:{
    aiServicesName:aiServicesName
  }
  dependsOn:[aiServices]
}


module addCapabilityHost 'modules/add-capability-host.bicep' = {
  name: 'addCapabilityHost'
  params: {
    capabilityHostName: '${environmentName}-${resourceToken}'
    aiHubName: aiHub.outputs.aiHubName
    aiProjectName: aiProjectName
    aiSearchConnectionName: aiHub.outputs.aiServicesConnectionName
    aoaiConnectionName: aiHub.outputs.aiServicesConnectionName
    customerSubnetId:agentSubnetId
  }
  dependsOn:[aiProject]
}

module aiOnlineEndpoints 'modules/online-endpoints/main.bicep' = if (deployOnlineEndpoints){
  name: 'aiOnlineEndpoints'
  params: { 
    aiProjectName:aiProjectName
    location:location
    identityName:identityName
    environmentName:environmentName
    resourceToken:resourceToken
    targetAutoDeletionTime:targetAutoDeletionTime
  }
  dependsOn:[aiProject,addCapabilityHost]
}


output aiservicesTarget string = aiServices.outputs.aiservicesTarget
output OpenAIEndPoint string = aiServices.outputs.OpenAIEndPoint
output aiHubPrincipalId string = aiHub.outputs.aiHubPrincipalId
output aiProjectPrincipalId string = aiProject.outputs.aiProjectPrincipalId
output aiHubName string = aiHub.outputs.aiHubName
output aiServicesName string = aiServices.outputs.aiServicesName
output aiServicesPrincipalId string = aiServices.outputs.aiServicesPrincipalId
output aiServicesPrivateEndpointName string = aiServicePE.outputs.aiServicesPrivateEndpointName
