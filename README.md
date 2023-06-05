## Quick Tutorial on Docker, Kubernetes, Istio

### Before you start
1. make sure you have a running k8s cluster in Azure or AWS
2. follow https://istio.io/latest/docs/setup/install/helm/ to install istio to your cluster (before you have any apps installed)

### Get External IP of the Istio
1. run `kubectl get svc -n istio-ingress` and copy the EXTERNAL-IP
2. deploy the app by running `kubectl apply -f docker-demo-app.yaml`
3. run `curl http://20.241.138.16/api/values` and you notice you only get `["value1","value2"]` back
4. but if you run `curl http://20.241.138.16/api/values --header "x-user: test"` you always get `["canary 1","canary 2"]`. This demonstrate one feature of Envoy proxy
