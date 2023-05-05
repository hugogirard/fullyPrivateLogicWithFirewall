param location string = 'canadacentral'

var suffix = uniqueString(resourceGroup().id)
var fileshareName = 'filesharelogicapp'

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
    name: 'strl${suffix}'    
  }
}

module fileshare 'modules/storage/fileshare.bicep' = {
  name: 'fileshare'
  params: {
    filesharename: fileshareName
    storagename: storageLogicApp.outputs.storageName
  }
}

module deployPeLogicAppStorage 'modules/networking/private.endpoint.bicep' = {
  name: 'deployPeLogicAppStorage'
  params: {
    location: location
    storageName: storageLogicApp.outputs.storageName
    subnetId: vnet.outputs.peSubnetLogicAppId
    vnetId: vnet.outputs.vnetIdLogicApp
  }
}

module privateDNSZoneLinkLgApp 'modules/networking/privatednszoneblob.link.bicep' = {
  name: 'privateDNSZoneLinkLgApp'
  params: {
    location: location
    storageName: storageLogicApp.outputs.storageName
    subnetId: vnet.outputs.peSubnetLogicAppId
    vnetId: vnet.outputs.vnetIdLogicApp
  }
}

module storageAsset 'modules/storage/storage.bicep' = {
  name: 'storageAsset'
  params: {
    location: location    
    name: 'stra${suffix}'    
  }
}

module monitoring 'modules/monitoring/workspace.bicep' = {
  name: 'monitoring'
  params: {
    location: location
  }
}

module logicApp 'modules/logicapp/logicapp.bicep' = {
  name: 'logicApp'
  params: {
    appInsightName: monitoring.outputs.insightName
    fileShareName: fileshareName
    location: location
    storageName: storageLogicApp.outputs.storageName
    subnetId: vnet.outputs.subnetWebDelegation
  }
}
