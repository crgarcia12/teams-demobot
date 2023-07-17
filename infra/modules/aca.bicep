param environmentPrefix string
param location string = resourceGroup().location

param containerAppEnvironmentId string
param repositoryImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
param envVars array = []
param registryName string
param minReplicas int = 1
param maxReplicas int = 1

var name = '${environmentPrefix}-aca'
var registryPassword = listCredentials(resourceId('Microsoft.ContainerRegistry/registries', registryName), '2022-12-01').passwords[0].value
var registryUsername = listCredentials(resourceId('Microsoft.ContainerRegistry/registries', registryName), '2022-12-01').username //2021-06-01-preview

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
