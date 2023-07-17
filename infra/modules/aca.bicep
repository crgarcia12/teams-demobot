param environmentPrefix string
param location string = resourceGroup().location

param containerAppEnvironmentId string
param repositoryImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
param registryName string
param minReplicas int = 1
param maxReplicas int = 1
param appInsightsInstrumentationKey string 
param appInsightsConnectionString string 
param appConfigConnectionString string 

var name = '${environmentPrefix}-aca'
var registryPassword = listCredentials(resourceId('Microsoft.ContainerRegistry/registries', registryName), '2022-12-01').passwords[0].value
var registryUsername = listCredentials(resourceId('Microsoft.ContainerRegistry/registries', registryName), '2022-12-01').username //2021-06-01-preview

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
  {
    name: 'AzureAppConfig'
    value: appConfigConnectionString
  }
  {
    name: 'RevisionLabel'
    value: 'BetaDisabled'
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
    }
    template: {
      containers: [
        {
          image: repositoryImage
          name: name
          env: envVars
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
