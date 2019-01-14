## Quick Tutorial on Docker, Kubernetes, Istio on Azure Kubernetes Service (AKS)

### Before you start
1. Make sure you download and install `Azure cli`
2. Login to Azure using `az login`
3. Select the correct Subscription using `az account set --subscription` command
4. Install `Chocolatey` (https://chocolatey.org/)
5. Install `kubectl` using Cholatey (https://kubernetes.io/docs/tasks/tools/install-kubectl/)
6. Install `Helm` using Cholatey (https://docs.helm.sh/using_helm/)
   

### Run commands in `setup-steps.sh` using GIT-Bash
Notes:
1. `docker-training` is the name of the Resource group and the Kubernetes cluster (you can name it whatever you want). 
2. the `istio-1.0.5.yml` file is generated using `Helm template` (https://istio.io/docs/setup/kubernetes/helm-install/#option-1-install-with-helm-via-helm-template) with all options enabled. 

`helm install install/kubernetes/helm/istio --name istio --namespace istio-system --set kiali.enabled=true --set grafana.enabled=true --set tracing.enabled=true --set global.configValidation=false
`