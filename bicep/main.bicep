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
