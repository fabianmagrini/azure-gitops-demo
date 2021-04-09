@description('Prefix string for Log analytics workspace name')
@minLength(2)
@maxLength(16)
param workspaceNamePrefix string

@description('The location for the Log analytics workspace.')
param location string = resourceGroup().location

@description('The SKU of the workspace.')
param sku string = 'pergb2018'

@description('The workspace data retention in days.')
@minValue(30)
@maxValue(730)
param retentionDays int = 90

@description('The tags to apply to the Log analytics workspace.')
param resourceTags object = {}

var subscriptionId = subscription().subscriptionId
var logAnalyticsWorkspaceName = '${workspaceNamePrefix}-${subscriptionId}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: resourceTags
  properties: any({
    retentionInDays: retentionDays
    features: {
      searchVersion: 1
    }
    sku: {
      name: sku
    }
  })
}


output id string = logAnalyticsWorkspace.id
output name string = logAnalyticsWorkspace.name
