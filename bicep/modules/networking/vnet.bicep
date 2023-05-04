param location string


resource nsgDefault 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: 'nsg-default'
  location: location
  properties: {
    securityRules: [
      
    ]
  }
}

resource vnetHub 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: 'vnet-hub'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '12.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '12.0.0.0/24'
        }
      }          
    ]
  }
}

resource vnetSpokeLgApp 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: 'vnet-logic-app'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-web-integration'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsgDefault.id
          }
        }
      }
      {
        name: 'snet-pe'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
      {
        name: 'snet-jumpbox'
        properties: {
          addressPrefix: '10.0.3.0/27'
          networkSecurityGroup: {
            id: nsgDefault.id
          }
        }
      }            
    ]
  }
}

resource vnetSpokeStorage 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: 'vnet-storage'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '11.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-pe'
        properties: {
          addressPrefix: '11.0.0.0/24'
        }
      }           
    ]
  }
}

// Peer hub to spoke vnets
resource peeringHubSpokeLg 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  parent: vnetHub
  name: 'hub-to-spoke-logic-app'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnetSpokeLgApp.id
    }
  }
}

resource peeringSpokeLgToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  parent: vnetSpokeLgApp
  name: 'spoke-logic-app-to-hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnetHub.id
    }
  }
}

resource peeringHubSpokeStorage 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  parent: vnetHub
  name: 'hub-to-spoke-storage'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnetSpokeStorage.id
    }
  }
}

resource peeringSpokeStorageToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  parent: vnetSpokeStorage
  name: 'spoke-storage-to-hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnetHub.id
    }
  }
}

output firewallSubnetId string = vnetHub.properties.subnets[0].id
output peSubnetLogicAppId string = vnetSpokeLgApp.properties.subnets[1].id
output vnetIdLogicApp string = vnetSpokeLgApp.id
output peSubnetStorageId string = vnetSpokeStorage.properties.subnets[0].id
output vnetIdStorage string = vnetSpokeStorage.id
