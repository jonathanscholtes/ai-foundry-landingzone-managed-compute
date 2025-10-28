targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name which is used to generate a short unique hash for each resource')
param environmentName string

@minLength(1)
@maxLength(64)
@description('Name which is used to generate a short unique hash for each resource')
param projectName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Flag to control VPN Gateway deployment')
param deployVpnGateway bool = false

param deployOnlineEndpoints bool = false

param rootCertData string

@description('Timestamp for the deployment')
param timestamp string

@description('Target deletion timestamp in RFC1123 format')
param targetAutoDeletionTime string

var resourceToken = uniqueString(environmentName, projectName, location, az.subscription().subscriptionId, timestamp)
var gatewayName = 'vgw-${projectName}-${environmentName}-${resourceToken}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${projectName}-${environmentName}-${location}-${resourceToken}'
  location: location
}

module networking 'core/networking/main.bicep' = {
  name: 'networking'
  scope: resourceGroup 
  params: { 
    location: location
    vnetName: 'vnet-${projectName}-${environmentName}-${resourceToken}'
    gatewayName: gatewayName
    publicIpName: 'pip-${projectName}-${environmentName}-${resourceToken}'
    rootCertData:rootCertData
    deployVpnGateway:deployVpnGateway
    dnsResolverName:'pdnsr-${projectName}-${environmentName}-${resourceToken}'
  }
}

module security 'core/security/main.bicep' = {
  name: 'security'
  scope: resourceGroup
  params:{
    keyVaultName: 'kv${projectName}${resourceToken}'
    managedIdentityName: 'id-${projectName}-${environmentName}'
    location: location
    vnetId: networking.outputs.vnetId
  }
}

module monitor 'core/monitor/main.bicep' = { 
  name:'monitor'
  scope: resourceGroup
  params:{ 
   location:location 
   logAnalyticsName: 'log-${projectName}-${environmentName}'
   applicationInsightsName: 'appi-${projectName}-${environmentName}'
  }
}

module data 'core/data/main.bicep' = {
  name: 'data'
  scope: resourceGroup
  params:{
    projectName:projectName
    resourceToken:resourceToken
    location: location
    identityName:security.outputs.managedIdentityName
    vnetId: networking.outputs.vnetId
  }
}

module platform 'core/platform/main.bicep' = { 
  name: 'platform'
  scope: resourceGroup
  params: { 
    containerRegistryName: 'cr${projectName}${environmentName}${resourceToken}'
    location:location
    vnetId: networking.outputs.vnetId
    managedIdentityName: security.outputs.managedIdentityName

  }
}

module azureai 'core/ai/main.bicep' = {
  name: 'azure-ai'
  scope: resourceGroup
  params: {
    projectName:projectName
    environmentName:environmentName
    resourceToken:resourceToken
    location: location
    keyVaultId: security.outputs.keyVaultID
    applicationInsightsId: monitor.outputs.applicationInsightsId
    identityName:security.outputs.managedIdentityName
    vnetId: networking.outputs.vnetId
    subnetName: 'aiSubnet'
    storageAccountId:data.outputs.storageAccountId
    storageAccountTarget: data.outputs.storageAccountBlobEndPoint
    storageAccountName:data.outputs.storageAccountName
    targetAutoDeletionTime:targetAutoDeletionTime
    agentSubnetId: networking.outputs.agentSubnetId
    containerRegistryID: platform.outputs.containerRegistryID
    deployOnlineEndpoints:deployOnlineEndpoints
    storagePrivateEndpointName:data.outputs.blobPrivateEndpointName
  }

}



output resourceGroupName string = resourceGroup.name

