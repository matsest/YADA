param baseName string
param location string

@secure()
param serverPassword string

resource server 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: '${baseName}${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    administratorLogin: 'azure'
    administratorLoginPassword: serverPassword
  }
}

resource db 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: 'mydb'
  location: location
  parent: server
  sku: {
    name: 'Basic'
    capacity: 5
  }
}

output name string = server.name
