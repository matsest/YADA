param baseName string
param location string

param sqlServerName string
@secure()
param sqlServerPassword string

resource env 'Microsoft.App/managedEnvironments@2022-06-01-preview' = {
  name: '${baseName}-aca-env'
  location: location
  properties: {
  }
}

resource api 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: '${baseName}-aca-api'
  location: location
  properties: {
    managedEnvironmentId: env.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
      }
      secrets: [
        {
          name: 'sqlserverpassword'
          value: sqlServerPassword
        }
      ]
    }
    template: {
      scale: {
        minReplicas: 1
        maxReplicas: 10
      }
      containers: [
        {
          name: 'api'
          image: 'erjosito/yadaapi:1.0'
          env: [
            {
              name: 'SQL_SERVER_PASSWORD'
              secretRef: 'sqlserverpassword'
            }
            {
              name: 'SQL_SERVER_FQDN'
              value: sqlServer.properties.fullyQualifiedDomainName
            }
          ]
        }
      ]
    }
  }
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' existing = {
  name: sqlServerName
}

resource fw 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  name: api.name
  parent: sqlServer
  properties: {
    startIpAddress: api.properties.outboundIpAddresses[0]
    endIpAddress: api.properties.outboundIpAddresses[0]
  }
}

resource web 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: '${baseName}-aca-web'
  location: location
  properties: {
    managedEnvironmentId: env.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
      }
    }
    template: {
      scale: {
        minReplicas: 1
        maxReplicas: 10
      }
      containers: [
        {
          name: 'web'
          image: 'erjosito/yadaweb:1.0'
          env: [
            {
              name: 'API_URL'
              value: 'https://${api.properties.configuration.ingress.fqdn}'
            }
          ]
        }
      ]
    }
  }
}

output apiUrl string = 'https://${api.properties.configuration.ingress.fqdn}'
output webUrl string = 'https://${web.properties.configuration.ingress.fqdn}'
