## Deploy New Relic with Istio

### Before you start
1. make sure you have a running k8s cluster in Azure or AWS
2. follow https://istio.io/latest/docs/setup/install/helm/ to install istio to your cluster (before you have any apps installed)

### Get External IP of the Istio
1. run `kubectl get svc -n istio-ingress` and copy the EXTERNAL-IP
2. deploy the app by running `kubectl apply -f docker-demo-app.yaml`
3. run `curl http://EXTERNAL-IP/api/values` and you notice you only get `["value1","value2"]` back
4. but if you run `curl http://EXTERNAL-IP/api/values --header "x-user: test"` you always get `["canary 1","canary 2"]`. This demonstrate one feature of Envoy proxy


### Deploy New Relic

```bash
helm repo add newrelic https://helm-charts.newrelic.com

helm repo update

kubectl create namespace newrelic
kubectl label namespace newrelic istio-injection=enabled

# make sure istio is also enabled for newrelic namespace => this command will fail

helm upgrade --install newrelic-bundle newrelic/nri-bundle \
 --set global.licenseKey=$LICENSE_KEY \
 --set global.cluster=istioenabled \
 --namespace=newrelic \
 --set newrelic-infrastructure.privileged=true \
 --set global.lowDataMode=true \
 --set kube-state-metrics.image.tag=v2.6.0 \
 --set kube-state-metrics.enabled=true \
 --set kubeEvents.enabled=true \
 --set newrelic-prometheus-agent.enabled=true \
 --set newrelic-prometheus-agent.lowDataMode=true \
 --set newrelic-prometheus-agent.config.kubernetes.integrations_filter.enabled=false \
 --set logging.enabled=true \
 --set newrelic-logging.lowDataMode=false
 -f newrelicvalues.yml

# delete namespace and recreate it

kubectl delete namespace newrelic
kubectl create namespace newrelic
kubectl label namespace newrelic istio-injection=enabled

# this time create it again with "-f newrelicvalues.yml" flag
helm upgrade --install newrelic-bundle newrelic/nri-bundle \
 --set global.licenseKey=$LICENSE_KEY \
 --set global.cluster=istioenabled \
 --namespace=newrelic \
 --set newrelic-infrastructure.privileged=true \
 --set global.lowDataMode=true \
 --set kube-state-metrics.image.tag=v2.6.0 \
 --set kube-state-metrics.enabled=true \
 --set kubeEvents.enabled=true \
 --set newrelic-prometheus-agent.enabled=true \
 --set newrelic-prometheus-agent.lowDataMode=true \
 --set newrelic-prometheus-agent.config.kubernetes.integrations_filter.enabled=false \
 --set logging.enabled=true \
 --set newrelic-logging.lowDataMode=false \
 -f newrelicvalues.yml

```