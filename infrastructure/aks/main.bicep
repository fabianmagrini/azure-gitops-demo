// Common parameters

@description('The tags to apply to Managed Cluster resource.')
param resourceTags object = {
  Environment: 'Dev'
  Project: 'Azure-GitOps-Demo'
}

// Log Analytics parameters
@description('Enable Log analytics workspace')
param enableLogAnalyticsWorkspace bool = true

@description('The prefix for the Log analytics workspace name.')
param workspaceName string = 'gitopsdemo'

// ACR parameters

@description('The name of the Azure Container Registry.')
param registryName string = uniqueString('gitopsdemoacr')

// AKS parameters

@description('The name of the Managed Cluster resource.')
param clusterName string = 'clu-gitops'

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string = 'gitopsdemo'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string = 'cluadmin'

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string

module logAnalyticsWorkspace './loganalytics.bicep'  = if(enableLogAnalyticsWorkspace) {
  name: 'workspace-${workspaceName}'
  params: {
    workspaceNamePrefix: workspaceName
    resourceTags: resourceTags
  }
}

module acr 'acr.bicep' = {
  name: registryName  
  params: {
    registryName: registryName
    resourceTags: resourceTags
  }
}

module aks './aks-cluster.bicep' = {
  name: clusterName
  params: {
    clusterName: clusterName
    dnsPrefix: dnsPrefix
    linuxAdminUsername: linuxAdminUsername
    sshRSAPublicKey: sshRSAPublicKey
    resourceTags: resourceTags
  }
}

output acrLoginServer string = acr.outputs.loginServer
output controlPlaneFQDN string = aks.outputs.controlPlaneFQDN
