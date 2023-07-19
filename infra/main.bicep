targetScope = 'subscription'

param location string = 'westeurope'
var environmentPrefix = 'crgar-aca-bot'



// // resource group created in target subscription
resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${environmentPrefix}-rg'
  location: location
}

// create the aca environment
module env 'modules/environment.bicep' = {
  scope: resourceGroup
  name: 'containerAppEnvironment'
  params: {
    environmentPrefix: environmentPrefix
    location: location
  }
}

// // create the azure app configuration
// module appConfig 'modules/app_config.bicep' ={
//   scope: resourceGroup  
//   name: 'appConfiguration'
//   params: {
//     location: location
//     environmentPrefix: environmentPrefix
//     featureFlagKey: 'Beta'
//     featureFlagLabelEnabled: 'BetaEnabled'
//   }
// }

// module acr 'modules/acr.bicep' = {
//   scope: resourceGroup
//   name: 'acr'
//   params: {
//     environmentPrefix: environmentPrefix
//     location: location
//   }
// }

var acrName = replace(toLower('${environmentPrefix}-acr'), '-', '')
module frontend 'modules/aca.bicep' = {
  scope: resourceGroup
  name: 'frontend'
  params: {
    environmentPrefix: environmentPrefix
    location: location
    containerAppEnvironmentId: env.outputs.id
    registryName: acrName
    appInsightsInstrumentationKey: env.outputs.appInsightsInstrumentationKey
    appInsightsConnectionString: env.outputs.appInsightsConnectionString
    //appConfigConnectionString: appConfig.outputs.appConfigConnectionString
  }
  // We need dependson because biceps does not know that acr.name should be a dependency
  dependsOn: [
    env
    //appConfig
    //acr
  ]
}
