param vnetId string
param location string
param storageName string
param subnetId string
param deployFileStorage bool = false
param deployQueueStorage bool = false
param deployTableStorage bool = false

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' existing = { 
  name: storageName
}

var privateStorageFileDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
var privateStorageBlobDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var privateStorageQueueDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'
var privateStorageTableDnsZoneName = 'privatelink.table.${environment().suffixes.storage}'
var privateEndpointFileStorageName = '${storage.name}-file-private-endpoint'
var privateEndpointBlobStorageName = '${storage.name}-blob-private-endpoint'
var privateEndpointQueueStorageName = '${storage.name}-queue-private-endpoint'
var privateEndpointTableStorageName = '${storage.name}-table-private-endpoint'
var virtualNetworkLinksSuffixFileStorageName = '${privateStorageFileDnsZoneName}-link'
var virtualNetworkLinksSuffixBlobStorageName = '${privateStorageBlobDnsZoneName}-link'
var virtualNetworkLinksSuffixQueueStorageName = '${privateStorageQueueDnsZoneName}-link'
var virtualNetworkLinksSuffixTableStorageName = '${privateStorageTableDnsZoneName}-link'

resource privateStorageFileDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (deployFileStorage) {
  name: privateStorageFileDnsZoneName
  location: 'global'
}

resource privateStorageBlobDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageBlobDnsZoneName
  location: 'global'
}

resource privateStorageQueueDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (deployQueueStorage) {
  name: privateStorageQueueDnsZoneName
  location: 'global'
}

resource privateStorageTableDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (deployTableStorage) {
  name: privateStorageTableDnsZoneName
  location: 'global'
}

resource privateStorageFileDnsZoneName_virtualNetworkLinksSuffixFileStorage 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (deployFileStorage) {
  parent: privateStorageFileDnsZone
  name: virtualNetworkLinksSuffixFileStorageName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateStorageBlobDnsZoneName_virtualNetworkLinksSuffixBlobStorage 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' =  {
  parent: privateStorageBlobDnsZone
  name: virtualNetworkLinksSuffixBlobStorageName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateStorageQueueDnsZoneName_virtualNetworkLinksSuffixQueueStorage 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (deployQueueStorage) {
  parent: privateStorageQueueDnsZone
  name: virtualNetworkLinksSuffixQueueStorageName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateStorageTableDnsZoneName_virtualNetworkLinksSuffixTableStorage 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (deployTableStorage) {
  parent: privateStorageTableDnsZone
  name: virtualNetworkLinksSuffixTableStorageName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// Private Endpoint


resource privateEndpointFileStorage 'Microsoft.Network/privateEndpoints@2020-06-01' = if (deployFileStorage) {
  name: privateEndpointFileStorageName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageQueuePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }
}

resource privateEndpointBlobStorage 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointBlobStorageName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageQueuePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource privateEndpointQueueStorage 'Microsoft.Network/privateEndpoints@2020-06-01' = if (deployQueueStorage) {
  name: privateEndpointQueueStorageName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageQueuePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'queue'
          ]
        }
      }
    ]
  }
}

resource privateEndpointTableStorage 'Microsoft.Network/privateEndpoints@2020-06-01' = if (deployTableStorage) {
  name: privateEndpointTableStorageName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageQueuePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'table'
          ]
        }
      }
    ]
  }
}

resource privateEndpointFileStorageName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = if (deployFileStorage) {
  parent: privateEndpointFileStorage
  name: 'default'  
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateStorageFileDnsZone.id
        }
      }
    ]
  }
}

resource privateEndpointBlobStorageName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  parent: privateEndpointBlobStorage
  name: 'default'  
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateStorageBlobDnsZone.id
        }
      }
    ]
  }
}

resource privateEndpointQueueStorageName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = if (deployQueueStorage) {
  parent: privateEndpointQueueStorage
  name: 'default'  
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateStorageQueueDnsZone.id
        }
      }
    ]
  }
}

resource privateEndpointTableStorageName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = if (deployTableStorage) {
  parent: privateEndpointTableStorage
  name: 'default'  
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateStorageTableDnsZone.id
        }
      }
    ]
  }
}

