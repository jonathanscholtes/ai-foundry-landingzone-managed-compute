param gatewayVnetName string
param applicationVnetName string
param location string
param gatewayName string
param publicIpName string
param rootCertData string


module gatewayVnet 'gateway-vnet.bicep' = { 
  name: 'gatewayVnet'
  params: { 
     location:location
     vnetName:gatewayVnetName
  }
}


module vpnGateway 'vpn-gateway.bicep' = { 
  name: 'vpnGateway'
  params: {
    location:location
    vnetId: gatewayVnet.outputs.vnetId
    publicIpName: publicIpName
    gatewayName: gatewayName
    rootCertData:rootCertData

  }
}

module gatewayPeering 'vnet-peering.bicep' = {
  name:'gatewayPeering'
  params: { 
    gatewayVnetName: gatewayVnetName
    applicationVnetName:applicationVnetName
  }
 dependsOn:[vpnGateway]
}
