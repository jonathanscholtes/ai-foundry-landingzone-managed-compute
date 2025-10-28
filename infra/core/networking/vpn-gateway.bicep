param location string
param vnetId string 
param gatewayName string 
param publicIpName string 
param gatewaySubnetName string = 'gatewaySubnet'
param rootCertData string




resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    
    publicIPAllocationMethod: 'Static'
  }
}

resource vnetGateway 'Microsoft.Network/virtualNetworkGateways@2023-05-01' = {
  name: gatewayName
  location: location
  properties: {
    ipConfigurations: [
      {

        name: 'vnetGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            
            id: publicIP.id
          }
          subnet: {
            id: '${vnetId}/subnets/${gatewaySubnetName}'   
          }
        }
      }

    ]
    enablePrivateIpAddress: true 
    activeActive: false    
    enableBgp: true       
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    sku: {
      name: 'VpnGw2'       
      tier: 'VpnGw2'
    }

    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          '172.17.33.0/24'
        ]
      }
    
      vpnClientProtocols: [
        'OpenVPN'
      ]
      vpnAuthenticationTypes: ['Certificate']
      vpnClientRootCertificates: [
        {
          name: 'P2SRootCert'
          properties:{
          publicCertData: rootCertData  // Injecting Base64 certificate data
          }
        }
      ]
      
      
    }
   
  }
}
