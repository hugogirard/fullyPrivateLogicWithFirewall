param location string
param subnetId string
param suffix string

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: 'pip-bastion'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2022-07-01' = {
  name: 'bas-${suffix}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: publicIpAddress.id
          }
        }
      }
    ]
  }
}
