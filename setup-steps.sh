# create new Azure resource group
az.cmd group create --name docker-training --location SoutheastAsia
az.cmd aks create -g docker-training -n docker-training --location SoutheastAsia --kubernetes-version 1.11.5 --enable-addons http_application_routing --generate-ssh-keys

# switch to the correct cluster
az.cmd aks get-credentials --resource-group docker-training --name docker-training

# init helm on the Azure cluster
helm init
# update helm repo
helm repo update

# create service account for helm tiller
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

# install istio 
kubectl.exe create ns istio-system
kubectl.exe apply -f istio-1.0.5.yaml

# WAIT AND make sure ALL istio services is now installed and RUNNING and COMPLETED (kiali, zipkin, prometheus, grafana)
kubectl get svc -n istio-system
kubectl get pods -n istio-system

# make sure automatic istio side car injection is enabled for default namepsace
kubectl label namespace default istio-injection=enabled

# now deploy the app
kubectl.exe apply -f docker-demo-app.yaml --record

# get list of pods and make sure there are 2 containers running in each POD (one of them is the istio-proxy)
kubectl.exe get pods

# get public IP of Istio ingress
kubectl.exe get svc -n istio-system


# now hit http://IP/api/values you should see values 1 and values 2 returned
# now hit http://IP/api/values with header x-user=test (via Postman) you should see canary 1 and canary 2 returned

# run Grafana and open http://localhost:3000/dashboard/db/istio-mesh-dashboard and login with admin:admin
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 &

# run kiali
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001
# open http://localhost:20001 and login with admin:admin

# watch the kiali (http://localhost:20001), select Graph, enable "Traffic Animation" under the Display dropdown
# change refresh frequency to 5 seconds
# select Versioned App from the Graph Type dropdown
# select "Requests percent of total" from the Edge Labels dropdown
# now hit the API continously usig CURL (on 2 or MORE new Console windows)
for i in `seq 1 2000`; do curl http://52.163.207.171/api/values; done
for i in `seq 1 2000`; do curl --header "x-user: test" http://52.163.207.171/api/values; done
