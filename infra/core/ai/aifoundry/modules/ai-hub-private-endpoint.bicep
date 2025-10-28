@description('Name of the Azure AI Hub workspace')
param aiHubName string

@description('Azure region of the deployment')
param location string

@description('Resource ID of the virtual network')
param vnetId string

@description('Name of the subnet for the private endpoint')
param subnetName string

param resourceToken string

var privateEndpointName = '${aiHubName}-private-endpoint'
var privateDnsZoneName = 'privatelink.api.azureml.ms'
var privateDnsZoneName2 = 'privatelink.notebooks.azure.net'
var pvtEndpointDnsGroupName = '${privateEndpointName}/default'

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2023-08-01-preview' existing = {
  name: aiHubName
}


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: '${vnetId}/subnets/${subnetName}'
    }
    customNetworkInterfaceName: '${aiHubName}-nic-${resourceToken}'
    privateLinkServiceConnections: [
      {
        name: aiHubName
        properties: {
          privateLinkServiceId: aiHub.id
          groupIds: ['amlworkspace']
        }
      }
    ]
  }

}

resource privateLinkApi 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.api.azureml.ms'
  location: 'global'
  tags: {}
  properties: {}
}

resource privateLinkNotebooks 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.notebooks.azure.net'
  location: 'global'
  tags: {}
  properties: {}
}

resource vnetLinkApi 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateLinkApi
  name: '${uniqueString(vnetId)}-api'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

resource vnetLinkNotebooks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateLinkNotebooks
  name: '${uniqueString(vnetId)}-notebooks'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}



resource dnsZoneGroupAiHub 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-api-azureml-ms'
        properties: {
            privateDnsZoneId: privateLinkApi.id
        }
      }
      {
        name: 'privatelink-notebooks-azure-net'
        properties: {
            privateDnsZoneId: privateLinkNotebooks.id
        }
      }
    ]
  }
  dependsOn: [
    vnetLinkApi
    vnetLinkNotebooks
  ]
}
