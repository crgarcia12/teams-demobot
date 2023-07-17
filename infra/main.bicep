targetScope = 'subscription'

param location string = 'westeurope'
var environmentPrefix = 'crgar-aca-bot'



// resource group created in target subscription
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

// create the azure app configuration
module appConfig 'modules/app_config.bicep' ={
  scope: resourceGroup  
  name: 'appConfiguration'
  params: {
    location: location
    environmentPrefix: environmentPrefix
    featureFlagKey: 'Beta'
    featureFlagLabelEnabled: 'BetaEnabled'
  }
}

// create the various config pairs
var shared_config = [
  {
    name: 'ASPNETCORE_ENVIRONMENT'
    value: 'Development'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: env.outputs.appInsightsInstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: env.outputs.appInsightsConnectionString
  }
  {
    name: 'AzureAppConfig'
    value: appConfig.outputs.appConfigConnectionString
  }
  {
    name: 'RevisionLabel'
    value: 'BetaDisabled'
  }
]

module acr 'modules/acr.bicep' = {
  scope: resourceGroup
  name: 'acr'
  params: {
    environmentPrefix: environmentPrefix
    location: location
  }
}

var acrName = replace(toLower('${environmentPrefix}-acr'), '-', '')
// create the service container app
module frontend 'modules/aca.bicep' = {
  scope: resourceGroup
  name: 'frontend'
  params: {
    environmentPrefix: environmentPrefix
    location: location
    containerAppEnvironmentId: env.outputs.id
    registryName: acrName
    envVars: shared_config
  }
  // We need dependson because biceps does not know that acr.name should be a dependency
  dependsOn: [
    env
    appConfig
    acr
  ]
}


// /subscriptions/14506188-80f8-4dc6-9b28-250051fc4ee4/resourceGroups/crgar-aca-bot-rg/providers/Microsoft.ContainerRegistry/registries/crgaracabotacr
// /subscriptions/14506188-80f8-4dc6-9b28-250051fc4ee4/providers/Microsoft.ContainerRegistry/registries/crgaracabotacr
// /subscriptions/14506188-80f8-4dc6-9b28-250051fc4ee4/resourceGroups/crgar-aca-bot-rg/providers/Microsoft.ContainerRegistry/registries/crgaracabotacr
