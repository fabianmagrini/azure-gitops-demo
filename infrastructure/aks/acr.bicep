@description('The name of the Azure Container Registry.')
param registryName string = uniqueString('gitopsdemoacr')

@description('The location of the Azure Container Registry resource.')
param location string = resourceGroup().location

@description('The tags to apply to Azure Container Registry resource.')
param resourceTags object = {
  Environment: 'Dev'
  Project: 'Azure-GitOps-Demo'
}

resource acr 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: registryName
  location: location
  tags: resourceTags
  sku: {
    name: 'Basic'
  }
}

output id string = acr.id
output name string = acr.name
output loginServer string = acr.properties.loginServer
