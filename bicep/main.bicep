param location string = 'canadacentral'

var suffix = uniqueString(resourceGroup().id)

module vnet 'modules/networking/vnet.bicep' = {
  name: 'vnet'
  params: {
    location: location
  }
}

module firewall 'modules/firewall/firewall.bicep' = {
  name: 'firewall'
  params: {
    location: location
    subnetId: vnet.outputs.firewallSubnetId
    suffix: suffix
  }
}

module storageLogicApp 'modules/storage/storage.bicep' = {
  name: 'storageLogicApp'
  params: {
    location: location
    kind: 'Storage'
    name: 'strl${suffix}'    
  }
}

module storageAsset 'modules/storage/storage.bicep' = {
  name: 'storageAsset'
  params: {
    location: location
    kind: 'StorageV2'
    name: 'stra${suffix}'    
  }
}
