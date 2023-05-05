param location string
param storageName string
param appInsightName string
param subnetId string 
param fileShareName string

var suffix = uniqueString(resourceGroup().id)

resource storageLogicApp 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageName
}

resource insight 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightName
}

resource hostingPlanFE 'Microsoft.Web/serverfarms@2018-11-01' = {
  name: 'asp-${suffix}'
  location: location
  sku: {
    tier: 'WorkflowStandard'
    name: 'WS1'
  }
  kind: 'windows'
}

resource logiapp 'Microsoft.Web/sites@2021-02-01' = {
  name: 'logi-${suffix}'
  location: location
  kind: 'workflowapp,functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {    
    virtualNetworkSubnetId: subnetId
    siteConfig: {
      netFrameworkVersion: 'v6.0'      
      appSettings: [
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }       
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)'
        }         
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'FUNCTIONS_V2_COMPATIBILITY_MODE'
          value: 'true'
        }     
        {
          name: 'WORKFLOWS_SUBSCRIPTION_ID'
          value: subscription().subscriptionId
        }
        {
          name: 'WORKFLOWS_LOCATION_NAME'
          value: location
        }
        {
          name: 'WORKFLOWS_RESOURCE_GROUP_NAME'
          value: resourceGroup().name
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~16'
        }      
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: insight.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: insight.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageLogicApp.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageLogicApp.id, storageLogicApp.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageLogicApp.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageLogicApp.id, storageLogicApp.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: fileShareName
        }
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '1'         
        } 
      ]
      use32BitWorkerProcess: true
    }
    serverFarmId: hostingPlanFE.id
    clientAffinityEnabled: false    
  }
}
