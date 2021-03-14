@description('The name of the Managed Cluster resource.')
param clusterName string = 'clu-gitops'

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string = 'gitopsdemo'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string = 'cluadmin'

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string

@description('The tags to apply to Managed Cluster resource.')
param resourceTags object = {
  Environment: 'Dev'
  Project: 'Azure-GitOps-Demo'
}
module aks './aks.bicep' = {
  name: clusterName
  params: {
    clusterName: clusterName
    dnsPrefix: dnsPrefix
    linuxAdminUsername: linuxAdminUsername
    sshRSAPublicKey: sshRSAPublicKey
    resourceTags: resourceTags
  }
}

output controlPlaneFQDN string = aks.outputs.controlPlaneFQDN