param vnetName string
param location string
param gatewayName string
param publicIpName string
param rootCertData string
param deployVpnGateway bool = false
param dnsResolverName string

module vNet 'vnet.bicep' = { 
  name: 'vNet'
  params: { 
     vnetLocation:location
     vnetName:vnetName
     dnsResolverName:dnsResolverName
  }
}

module vpnGateway 'vpn-gateway.bicep' = if (deployVpnGateway) { 
  name: 'vpnGateway'
  params: {
    location:location
    vnetId: vNet.outputs.vnetId
    publicIpName: publicIpName
    gatewayName: gatewayName
    rootCertData:rootCertData
    
  }
}

output vnetId string = vNet.outputs.vnetId
output agentSubnetId string = vNet.outputs.agentSubnetId
