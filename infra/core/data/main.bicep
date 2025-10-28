param projectName string
param resourceToken string
param location string
param identityName string
param vnetId string


var storageAccountName ='sa${projectName}${resourceToken}'


module storage 'storage/main.bicep' = {
name: 'storage'
params:{
  identityName:identityName
   location:location
   storageAccountName:storageAccountName
   vnetId: vnetId
}
}

output blobPrivateEndpointName string = storage.outputs.blobPrivateEndpointName
output storageAccountBlobEndPoint string = storage.outputs.storageAccountBlobEndPoint
output storageAccountName string = storageAccountName
output storageAccountId string = storage.outputs.storageAccountId

