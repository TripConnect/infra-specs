# Lint check
```sh
helm lint infra/k8s-dev-helm/ --set image.name=test,containerPort=8080
```
# Dry run
```sh
helm install k8s-dev-helm ./infra/k8s-dev-helm --dry-run=client --debug --set image.name=test,containerPort=8080
```
# Gen raw manifest
```sh
helm template gateway-service infra/k8s-dev-helm/ -f infra/k8s-dev-helm/values/deployment/gateway-service.yml > gateway-service.yaml
```
# Deployment
## Check history
```shell
helm history config-service
```
## Deployment
Example:
```sh
helm upgrade --install config-service .\infra\k8s-dev-helm -f .\infra\k8s-dev-helm\values\deployment\config-service.yml
```
# Tips
When Consul cannot start after a long time
```shell
helm uninstall consul -n consul
kubectl delete pvc --all -n consul
kubectl delete namespace consul
```
