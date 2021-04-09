@description('The name of the Managed Cluster resource.')
param clusterName string = 'clu-gitops'

@description('The location of the Managed Cluster resource.')
param location string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string = 'gitopsdemo'

@minValue(0)
@maxValue(1023)
@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
param osDiskSizeGB int = 0

@minValue(1)
@maxValue(50)
@description('The number of nodes for the cluster.')
param agentCount int = 3

@description('The size of the Virtual Machine.')
param agentVMSize string = 'Standard_DS2_v2'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string = 'cluadmin'

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string

@allowed([
  'Linux'
])
@description('The type of operating system.')
param osType string = 'Linux'

@description('Log analytics workspace id')
param workspaceId string = ''

@description('The tags to apply to Managed Cluster resource.')
param resourceTags object = {
  Environment: 'Dev'
  Project: 'Azure-GitOps-Demo'
}

resource aks 'Microsoft.ContainerService/managedClusters@2021-02-01' = {
  name: clusterName
  location: location
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        mode: 'System'
        vmSize: agentVMSize
        osType: osType
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
    addonProfiles: {
      omsagent: empty(workspaceId) ? json('null') : {
        config: {
          logAnalyticsWorkspaceResourceID: workspaceId
        }
        enabled: true
      }
    }
  }
}

output id string = aks.id
output name string = aks.name
output controlPlaneFQDN string = reference(clusterName).fqdn
