param location string = 'canadacentral'
@secure()
param adminUsername string
@secure()
param adminPassword string


var suffix = uniqueString(resourceGroup().id)
var fileshareName = 'filesharelogicapp'

module vnet 'modules/networking/vnet.bicep' = {
  name: 'vnet'
  params: {
    location: location
  }
}

module jumpbox 'modules/compute/jumpbox.bicep' = {
  name: 'jumpbox'
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername
    location: location
    subnetId: vnet.outputs.jumpboxSubnetId
  }
}

module bastion 'modules/bastion/bastion.bicep' = {
  name: 'bastion'
  params: {
    location: location
    subnetId: vnet.outputs.subnetBastionId    
    suffix: suffix
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
  dependsOn: [
    deployPeLogicAppStorage
  ]  
  name: 'privateDNSZoneLinkLgApp'
  params: {
    location: location
    storageName: storageLogicApp.outputs.storageName
    subnetId: vnet.outputs.peSubnetLogicAppId
    vnetId: vnet.outputs.vnetIdLogicApp
  }
}

module privateDNSZoneLinkAssetStorage 'modules/networking/privatednszoneblob.link.bicep' = {
  dependsOn: [
    deployPeLogicAppStorage    
  ]  
  name: 'privateDNSZoneLinkAssetStorage'
  params: {
    location: location
    storageName: storageAsset.outputs.storageName
    subnetId: vnet.outputs.peSubnetStorageId
    vnetId: vnet.outputs.vnetIdStorage
  }
}

module storageAsset 'modules/storage/storage.bicep' = {
  name: 'storageAsset'
  params: {
    location: location    
    name: 'stra${suffix}'    
  }
}

module containerFiles 'modules/storage/container.bicep' = {
  name: 'containerFiles'
  params: {
    containerName: 'files'
    storageName: storageAsset.outputs.storageName
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
    storageAssetName: storageAsset.outputs.storageName
    subnetId: vnet.outputs.subnetWebDelegation
  }
}


output logicAppName string = logicApp.name
