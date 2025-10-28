param gatewayVnetName string
param applicationVnetName string


resource vnetLocal 'Microsoft.Network/virtualNetworks@2023-04-01' existing =  {
  name: gatewayVnetName
}

resource vnetPeer 'Microsoft.Network/virtualNetworks@2023-04-01' existing =  {
  name: applicationVnetName
}

// Peering from Local VNet to Peer VNet
resource localToPeer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: 'localToPeer'
  parent: vnetLocal
  properties: {
    remoteVirtualNetwork: {
      id: vnetPeer.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
  }
}

// Peering from Peer VNet back to Local VNet (Bidirectional)
resource peerToLocal 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: 'peerToLocal'
  parent: vnetPeer
  properties: {
    remoteVirtualNetwork: {
      id: vnetLocal.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: true
  }
}
