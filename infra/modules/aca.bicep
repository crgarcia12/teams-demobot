param environmentPrefix string
param location string = resourceGroup().location

param containerAppEnvironmentId string
param registryName string
param appInsightsInstrumentationKey string 
param appInsightsConnectionString string 
//param appConfigConnectionString string 

var name = '${environmentPrefix}-aca'
var registryPassword = 'kD3J7FICJfDAGQCm99FMydSRcGIAi1cAfAf+up6jXQ+ACRBcg3bp' //listCredentials(resourceId('Microsoft.ContainerRegistry/registries', registryName), '2022-12-01').passwords[0].value
var registryUsername = 'crgaracabotacr' //listCredentials(resourceId('Microsoft.ContainerRegistry/registries', registryName), '2022-12-01').username //2021-06-01-preview

// create the various config pairs
var envVars = [
  {
    name: 'ASPNETCORE_ENVIRONMENT'
    value: 'Development'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appInsightsInstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: appInsightsConnectionString
  }
  // {
  //   name: 'AzureAppConfig'
  //   value: appConfigConnectionString
  // }
  {
    name: 'RevisionLabel'
    value: 'BetaDisabled'
  }
  {
    name: 'Environment'
    value: 'blue'
  }
]


resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' ={
  name: name
  location: location
  properties:{
    managedEnvironmentId: containerAppEnvironmentId
    configuration: {
      activeRevisionsMode: 'multiple'
      secrets: [
        {
          name: 'container-registry-password'
          value: registryPassword
        }
      ]      
      registries: [
        {
          server: registryName
          username: registryUsername
          passwordSecretRef: 'container-registry-password'
        }
      ]
      ingress: {
        external: true
        targetPort: 80
        transport: 'http'
        allowInsecure: true
      }
      dapr: {
        enabled: true
        appId: 'generator'
        appProtocol: 'http'
        appPort: 3000
        enableApiLogging: true
      }
    }
    template: {
      containers: [
        {
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          name: 'v015'
          env: envVars
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
