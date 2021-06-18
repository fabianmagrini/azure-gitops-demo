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

## References

* <https://docs.github.com/en/actions/learn-github-actions/introduction-to-github-actions>
* <https://github.com/Azure/actions>
* <https://github.com/marketplace/actions/azure-login>
* <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-rm-template>
* <https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-tutorial-create-first-bicep?tabs=azure-cli>
* <https://blog.argoproj.io/5-gitops-best-practices-d95cb0cbe9ff>
* <https://argoproj.github.io/argo-cd/operator-manual/cluster-bootstrapping/#app-of-apps-pattern>
* <https://argocd-applicationset.readthedocs.io/en/stable/Geting-Started/>

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

### Getting Started with Argo CD

Install Argo CD

```sh
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Download Argo CD CLI

```sh
brew install argocd
```

Access The Argo CD API Server using Port Forwarding

```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Login Using The CLI

Argo CD 1.8 and earlier

```sh
argocd version
# The initial password is autogenerated to be the pod name of the Argo CD API server. This can be retrieved with the command:
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
# Using the username admin and the password from above, login to Argo CD's IP or hostname:
argocd login localhost:8080
# Change the password using the command:
argocd account update-password
```

Argo CD v1.9 and later

The initial password for the admin account is auto-generated and stored as clear text in the field password in a secret named argocd-initial-admin-secret in your Argo CD installation namespace.

```sh
# You can simply retrieve this password using kubectl:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
# Using the username admin and the password from above, login to Argo CD's IP or hostname:
argocd login localhost:8080
# Change the password using the command:
argocd account update-password

```

You can now connect to <https://localhost:8080> to get to the UI and use the credentials set in the step above.

Creating Apps Via CLI

You can access Argo CD using port forwarding: add --port-forward-namespace argocd flag to every CLI command or set ARGOCD_OPTS environment variable: export ARGOCD_OPTS='--port-forward-namespace argocd'

```sh
export ARGOCD_OPTS='--port-forward-namespace argocd'
argocd app create dotnet-api-template --repo https://github.com/fabianmagrini/dotnet-api-template.git --path charts/template-api --dest-server https://kubernetes.default.svc --dest-namespace default
```

Syncing via CLI

```sh
argocd app get dotnet-api-template
argocd app sync dotnet-api-template
```

Install ApplicationSet into an existing Argo CD install

```sh
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/applicationset/v0.1.0/manifests/install.yaml
```

### Connect to the cluster on Azure

```sh
resourceGroupName=rg-gitops-demo
clusterName=clu-gitops
az aks get-credentials --resource-group $resourceGroupName --name $clusterName
```

### Argo CD App of Apps

```sh
# Create the Dev Project
kubectl apply -f argocd/appofappspattern/projects/project-dev.yml
argocd proj list
# Create any required namespaces
kubectl create namespace apps-dev
# Create the Root App. Use kubectl as the Argo CD Application is a custom Kubernetes resource
kubectl apply -f argocd/appofappspattern/apps-dev.yml
# Sync the Root App and its children
argocd app sync -l app.kubernetes.io/instance=appbundle-apps-dev
```

List all pods and services in all namespaces

```sh
kubectl get pods --all-namespaces
kubectl get services --all-namespaces 
```

Cleanup

```sh
argocd app delete appbundle-apps-dev
```

### ApplicationSet

```sh
# Create the Dev Project
kubectl apply -f argocd/applicationset/project-dev.yml
argocd proj list
# Create any required namespaces
kubectl create namespace apps-dev
# Create the ApplicationSet. Use kubectl as the Argo CD ApplicationSet is a custom Kubernetes resource
kubectl apply -f argocd/applicationset/applicationset-dev.yml
```

List all applicationsets and applications in all namespaces

```sh
kubectl get applicationset,application -A
argocd app list
```

Cleanup

```sh
kubectl delete ApplicationSet dotnet-api-template --cascade=orphan
```
