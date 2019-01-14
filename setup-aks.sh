# login and select the correct subscription
az.cmd login
az.cmd account set --subscription "76d03a17-20be-4175-bbed-ca6d7819c68f"

# create new Azure resource group
az.cmd group create --name rbus-asia --location SoutheastAsia
az.cmd aks create -g rbus-asia -n rbus --location SoutheastAsia --kubernetes-version 1.11.5 --enable-addons http_application_routing --generate-ssh-keys

# switch to the correct cluster
az.cmd aks get-credentials --resource-group rbus-asia --name rbus

#  install Helm
choco install kubernetes-helm

# init helm on the Azure cluster
helm init
# update helm repo
helm repo update

# create service account for helm tiller
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

# Create staging namespace
kubectl create ns staging

# create context to select staging by default
kubectl config set-context rbus-staging --namespace=staging --cluster=rbus --user=clusterUser_rbus-asia_rbus

# change context to staging
kubectl config use-context rbus-staging

# download istio from https://github.com/istio/istio/releases and add istioctl into your PATH
# install istio into your k8s cluster using helm, enalbe kiali, grafana, tracing
# from the location where you download istio from 
cd /c/istio-1.0.5-win/istio-1.0.5

helm install install/kubernetes/helm/istio --name istio --namespace istio-system --set kiali.enabled=true --set grafana.enabled=true --set tracing.enabled=true --set global.configValidation=false

# enable grafana and jaeger 
helm upgrade --recreate-pods --namespace istio-system --set kiali.enabled=true --set grafana.enabled=true --set tracing.enabled=true --set global.configValidation=false --set sidecarInjectorWebhook.enabled=false istio install/kubernetes/helm/istio

# make sure istio is now installed (kiali, zipkin, prometheus, grafana)
kubectl get svc -n istio-system
kubectl get pods -n istio-system

# make sure automatic istio side car injection is enabled for staging and prod https://istio.io/docs/setup/kubernetes/sidecar-injection/#automatic-sidecar-injection
kubectl label namespace staging istio-injection=enabled

# cd into the root of the Git repo
cd /c/AnthonyNguyenData/source/personal/rbus-docker


# create configMap
kubectl.exe create configmap webbffconfigmap --from-file=./src/api-gateway/web.bff/config/configuration.json

# now deploy the app and istio
kubectl.exe apply -f config/k8s/ -f config/istio --record

# get list of pods and make sure there are 2 containers running in each POD (one of them is the istio-proxy)
kubectl.exe get pods

# get details of a pod
kubectl.exe describe pod authentication-service-deploy-5c7874f96d-g6xj4

# get logs from the worker container (your code)
kubectl.exe logs authentication-service-deploy-5c7874f96d-g6xj4 -c worker

# get public IP of Istio ingress
kubectl.exe get svc -n istio-system

# run Grafana and http://localhost:3000/dashboard/db/istio-mesh-dashboard
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 &

# run jaeger
kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686 &

# run kiali
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001
# open http://localhost:20001 and login with admin:admin

# hit the API continously usig CURL
for i in `seq 1 2000`; do curl http://207.46.228.149/api/auth/users; done


# Clean up
# delete resource group
az.cmd group delete --name rbus-asia
az.cmd group delete --name MC_rbus-asia_rbus_southeastasia

# kubectl apply -f <(istioctl kube-inject -f config/k8s/)>
helm del --purge istio
kubectl delete -f install/kubernetes/helm/istio/templates/crds.yaml -n istio-system