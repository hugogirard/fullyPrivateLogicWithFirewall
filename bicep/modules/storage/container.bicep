param storageName string
param containerName string

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${storageName}/default/${containerName}'  
  properties: {
    publicAccess: 'None'
  }
}
