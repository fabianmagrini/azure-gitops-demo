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
gh secret set AZURE_CREDENTIALS --body $SP_AZURE_CREDENTIALS
```
