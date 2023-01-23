targetScope = 'subscription'

param baseName string = 'yada-demo'
param location string = 'norwayeast'

@secure()
param serverPassword string

param now string = utcNow()

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: baseName
  location: location
}

module db './modules/db.bicep' = {
  name: 'db-${now}'
  scope: rg
  params: {
    baseName: baseName
    location: location
    serverPassword: serverPassword
  }
}

module aca './modules/aca.bicep' = {
  name: 'aca-${now}'
  scope: rg
  params: {
    baseName: baseName
    location: location
    sqlServerName: db.outputs.name
    sqlServerPassword: serverPassword
  }
}

output webUrl string = aca.outputs.webUrl
output apiUrl string = aca.outputs.apiUrl
