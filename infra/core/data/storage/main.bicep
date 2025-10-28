param storageAccountName string
param location string
param identityName string
param vnetId string


var dnsZones = [
  'privatelink.blob.core.windows.net'
  'privatelink.file.core.windows.net'
  'privatelink.queue.core.windows.net'
  'privatelink.table.core.windows.net'
]

var endpointTypes = ['blob', 'file', 'queue', 'table']


module storageAccount 'modules/blob-storage-account.bicep' ={
  name: 'storageAccount'
  params:{
     location: location
     storageAccountName:storageAccountName
     vnetId:vnetId
     subnetName:'dataSubnet'
  }
}

module storageContainers 'modules/blob-storage-containers.bicep' = {
  name: 'storageContainers'
  params: {
    storageAccountName: storageAccountName
  }
  dependsOn:[storageAccount]
}

module storageRoles 'modules/blob-storage-roles.bicep' = {
  name: 'storageRoles'
  params:{
    identityName:identityName
     storageAccountName:storageAccountName
  }
  dependsOn:[storageAccount]
}

// Loop through all endpoint types
module privateEndpoints 'modules/storage-private-endpoint.bicep' = [for endpoint in endpointTypes: {
  name: '${storageAccountName}-${endpoint}-pe'
  params: {
    storageAccountId: storageAccount.outputs.storageAccountId
    storageAccountName: storageAccountName
    location: location
    vnetId: vnetId
    subnetName: 'servicesSubnet'
    endpointType: endpoint
    dnsZoneName: dnsZones[indexOf(endpointTypes, endpoint)]
  }
}]

// Find the index of "blob" in endpointTypes
var blobIndex = indexOf(endpointTypes, 'blob')


output blobPrivateEndpointName string = privateEndpoints[blobIndex].outputs.privateEndpointName
output storageAccountBlobEndPoint string = storageAccount.outputs.storageAccountBlobEndPoint
output storageAccountId string = storageAccount.outputs.storageAccountId
