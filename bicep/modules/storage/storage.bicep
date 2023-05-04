param location string
param name string
@allowed([
  'StorageV2'
  'Storage'
])
param kind string

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_LRS'    
  }
  kind: kind
  properties: {
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        
      ]
    }
    supportsHttpsTrafficOnly: true
  }
}

output storageName string = storage.name
