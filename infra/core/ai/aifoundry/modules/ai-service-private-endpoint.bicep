param aiServicesName string
param location string
param vnetId string
param subnetName string

var privateEndpointName = '${aiServicesName}-pe'


var cognitiveServicesPrivateDnsZoneName = 'privatelink.cognitiveservices.azure.com'
var openAiPrivateDnsZoneName = 'privatelink.openai.azure.com'
var aiServicesPrivateDnsZoneName = 'privatelink.services.ai.azure.com'



resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiServicesName

}

resource aiServicesPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: '${vnetId}/subnets/${subnetName}'
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: aiServices.id
            privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
          groupIds: [
            'account'
          ]
          
        }
      }
    ]
  }
  dependsOn: [
    aiServices
  ]
}

resource cognitiveServicesPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: cognitiveServicesPrivateDnsZoneName
  location: 'global'
}

resource openAiPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: openAiPrivateDnsZoneName
  location: 'global'
}

resource cognitiveServicesVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: cognitiveServicesPrivateDnsZone
  name: uniqueString(vnetId)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource openAiVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: openAiPrivateDnsZone
  name: uniqueString(vnetId)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource aiServicesPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: aiServicesPrivateDnsZoneName
  location: 'global'
}

// Link this DNS zone to your VNet
resource aiServicesPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: aiServicesPrivateDnsZone
  name: uniqueString(vnetId)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource aiServicesPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  parent: aiServicesPrivateEndpoint
  name: 'default'
  properties: {
  privateDnsZoneConfigs: [
    {
      name: replace(openAiPrivateDnsZoneName, '.', '-')
      properties: {
        privateDnsZoneId: openAiPrivateDnsZone.id
      }
    }
    {
      name: replace(cognitiveServicesPrivateDnsZoneName, '.', '-')
      properties: {
        privateDnsZoneId: cognitiveServicesPrivateDnsZone.id
      }
    }
    {
      name: replace(aiServicesPrivateDnsZoneName, '.', '-')
      properties: {
        privateDnsZoneId: aiServicesPrivateDnsZone.id
      }
    }
  ]
}
}


output aiServicesPrivateEndpointName string = privateEndpointName
