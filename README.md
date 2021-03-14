# Azure GitOps Demo

Demo GitOps practices to deploy to Azure using GitHub Actions, Helm, AKS and ArgoCD.

## Prerequisites

* Azure CLI
* GH command line

### Logging into the Azure CLI

If you have multiple subscriptions then set subscription after completing the login.

```sh
az login
az account list
az account set --subscription="{SubscriptionID}"
```

### Create a Service Principal

Create a service principal to be used by your GitHub Actions. Create at the subscripition level with the Contributor role.

```sh
SP_AZURE_CREDENTIALS=az ad sp create-for-rbac --name "http://{ServicePrincipalName}" --sdk-auth --role Contributor \
     --scopes /subscriptions/{SubscriptionID}
```

Set the response as a secret in your GitHub repository settings so that it may be used by your GitHub Actions.
We do that directly using the GH comand line.

```sh
gh auth login
gh secret set AZURE_CREDENTIALS --body "$SP_AZURE_CREDENTIALS"
```

Set the SubscriptionID as a secret in your GitHub repository settings so that it may be used by your GitHub Actions.
We do that directly using the GH comand line.

```sh
gh secret set SUBSCRIPTION_ID --body "{SubscriptionID}"
```

### Configure keys

```sh
deploymentName=gitops-demo
# This generates a passphrase with 128 bits of entropy
clusterPassword=$(dd if=/dev/urandom bs=16 count=1 2>/dev/null | base64 | sed 's/=//g')
# Generate SSH Key
ssh-keygen \
    -m PEM \
    -t rsa \
    -b 4096 \
    -C $deploymentName \
    -f key.rsa \
    -N $clusterPassword
```

For now we will simply copy the public RSA key into the parameters file.

## Run the workflow

You may trigger the deploy workflow manually from the GitHub website.

## Clean up deployment

```sh
resourceGroupName={resource group name}
az group delete --name $resourceGroupName --yes --no-wait
```

## Appendix

### Deploy the ARM template from local

Added default values to the template when running local.

```sh
deploymentName=gitops-demo
resourceGroupName=rg-gitops-demo
location=australiaeast
az group create -l $location -n $resourceGroupName
az deployment group create \
  --name $deploymentName \
  --resource-group $resourceGroupName \
  --template-file "./infrastructure/aks/arm-templates/azuredeploy.json" \
  --parameters @"./infrastructure/aks/arm-templates/azuredeploy.parameters.json"

```

### Deploy the Bicep template from local

Added default values to the template when running local.

```sh
deploymentName=gitops-demo
resourceGroupName=rg-gitops-demo
location=australiaeast
az group create -l $location -n $resourceGroupName
az deployment group create \
  --name $deploymentName \
  --resource-group $resourceGroupName \
  --template-file "./infrastructure/aks/main.bicep" \
  --parameters "./infrastructure/aks/main.parameters.dev.json"

```

## References

* <https://docs.github.com/en/actions/learn-github-actions/introduction-to-github-actions>
* <https://github.com/Azure/actions>
* <https://github.com/marketplace/actions/azure-login>
* <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-rm-template>
* <https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-tutorial-create-first-bicep?tabs=azure-cli>
