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
# Infra release
Install shared development dependencies once, then deploy each service as its own release.
```sh
helm upgrade --install tripconnect-infra .\infra\k8s-dev-helm -f .\infra\k8s-dev-helm\values\infra.yml
```

# Observability
This chart can install Jaeger all-in-one and an OpenTelemetry Collector. Service deployments receive standard OTEL env vars by default and export traces to `http://otel-collector:4317`.

## Dry run
```sh
helm template observability .\infra\k8s-dev-helm -f .\infra\k8s-dev-helm\values\observability.yml
helm template gateway-service .\infra\k8s-dev-helm -f .\infra\k8s-dev-helm\values\deployment\gateway-service.yml
```

## Install or upgrade
```sh
helm upgrade --install observability .\infra\k8s-dev-helm -f .\infra\k8s-dev-helm\values\observability.yml

helm upgrade --install config-service .\infra\k8s-dev-helm -f .\infra\k8s-dev-helm\values\deployment\config-service.yml
helm upgrade --install gateway-service .\infra\k8s-dev-helm -f .\infra\k8s-dev-helm\values\deployment\gateway-service.yml
helm upgrade --install user-service .\infra\k8s-dev-helm -f .\infra\k8s-dev-helm\values\deployment\user-service.yml
helm upgrade --install chat-service .\infra\k8s-dev-helm -f .\infra\k8s-dev-helm\values\deployment\chat-service.yml
helm upgrade --install twofa-service .\infra\k8s-dev-helm -f .\infra\k8s-dev-helm\values\deployment\twofa-service.yml
```

## Open Jaeger
```sh
kubectl -n tripconnect port-forward svc/jaeger 16686:16686
```

Open `http://localhost:16686`, select `gateway-service`, then run the GraphQL query through the gateway. The trace timeline shows which downstream services were called and how long each span took.

If Jaeger only shows `gateway-service` or shows no spans, add OpenTelemetry SDK or auto-instrumentation in the service code and make sure gRPC/HTTP clients propagate W3C `traceparent` context. Helm can provide the collector, Jaeger, and OTEL env vars, but the applications still need to emit spans.

# Tips
When Consul cannot start after a long time
```shell
helm uninstall consul -n consul
kubectl delete pvc --all -n consul
kubectl delete namespace consul
```
