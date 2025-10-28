param vnetName string
param location string
param addressPrefix string = '10.1.0.0/16'


resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'gatewaySubnet'
        properties: {
          addressPrefix: '10.1.1.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }    
    ]
  }
}


output vnetId string = vnet.id

