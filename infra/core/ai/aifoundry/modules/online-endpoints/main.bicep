
@description('Name of the AI project')
param aiProjectName string

param environmentName string
param resourceToken string
param location string
param identityName string

@description('Target deletion timestamp in RFC1123 format')
param targetAutoDeletionTime string


module phiOnlineEndpoint 'phi-online-endpoint.bicep' = {
  name: 'phiOnlineEndpoint'
  params: { 
    aiProjectName: aiProjectName
    location:location
    managedIdentityName: identityName
    onlineEndpointName:'phi-${environmentName}-${resourceToken}'
    targetAutoDeletionTime:targetAutoDeletionTime
  }

}





