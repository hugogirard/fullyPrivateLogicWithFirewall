param storagename string
param filesharename string

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  name: '${storagename}/default/${toLower(filesharename)}' 
}

