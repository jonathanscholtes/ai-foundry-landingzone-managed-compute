
@description('Name of the AI project')
param aiProjectName string

param environmentName string
param resourceToken string
param location string
param identityName string

@description('Target deletion timestamp in RFC1123 format')
param targetAutoDeletionTime string




module qwenOnlineEndpoint 'qwen-online-endpoint.bicep' = {
  name: 'qwenOnlineEndpoint'
  params: { 
    aiProjectName: aiProjectName
    location:location
    managedIdentityName: identityName
    onlineEndpointName:'qwen-${environmentName}-${resourceToken}'
    targetAutoDeletionTime:targetAutoDeletionTime
  }

}





