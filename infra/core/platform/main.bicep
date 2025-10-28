param containerRegistryName string
param location string
param vnetId string


@description('The name of the user-assigned managed identity used by the container app.')
param managedIdentityName string

module containerregistry 'registry/container-registry.bicep' = {
  name: 'containerregistry'
  params: {
    containerRegistryName: containerRegistryName
    location: location
    managedIdentityName:managedIdentityName

  }

}

module containerPe 'registry/container-registry-pe.bicep' = {
  name: 'containerPe'
  params: { 
 containerRegistryName:containerRegistryName
  location:location 
   vnetId: vnetId
   subnetName:'servicesSubnet'

  }
dependsOn:[containerregistry]
}


output containerRegistryID string = containerregistry.outputs.containerRegistryID
output containerRegistryName string = containerregistry.outputs.containerRegistryName
