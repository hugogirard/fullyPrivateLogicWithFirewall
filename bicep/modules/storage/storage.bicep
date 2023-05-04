param location string
param name string
@allowed([
  'StorageV2'
  'Storage'
])
param kind string
param createFileShare bool = false
param fileShareName string = 'filelogic'

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

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = if (createFileShare) {
  name: '${storage}/default/${toLower(fileShareName)}'
}

output storageName string = storage.name
