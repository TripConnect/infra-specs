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
