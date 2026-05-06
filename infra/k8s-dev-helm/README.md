# k8s-dev Helm

Helm chart for the Trip Connect development stack.

## Prerequisites

Create namespaces:
```sh
kubectl create namespace tripconnect
kubectl create namespace consul
```

Add Helm repositories:
```sh
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm repo update
```

Install Consul service mesh:
```sh
helm install consul hashicorp/consul --namespace consul --set global.name=consul --set server.replicas=1 --set client.enabled=true --set ui.enabled=true --set connectInject.enabled=true
```

Enable sidecar injection for application pods:
```sh
kubectl label namespace tripconnect consul.hashicorp.com/connect-inject=enabled
```

## Validate Chart

Lint check:
```sh
helm lint infra/k8s-dev-helm/ --set image.name=test,containerPort=8080
```

Dry run:
```sh
helm install k8s-dev-helm ./infra/k8s-dev-helm --dry-run=client --debug --set image.name=test,containerPort=8080
```

Generate raw manifest:
```sh
helm template gateway-service infra/k8s-dev-helm/ -f infra/k8s-dev-helm/values/deployment/gateway-service.yml > gateway-service.yaml
```

## Deploy Services

Check release history:
```sh
helm history config-service
```

Deploy or upgrade a service:
```sh
helm upgrade --install config-service .\infra\k8s-dev-helm -f .\infra\k8s-dev-helm\values\deployment\config-service.yml
```

Gateway example without rendering shared infra resources:
```sh
helm upgrade --install gateway-service .\infra\k8s-dev-helm -f .\infra\k8s-dev-helm\values\deployment\gateway-service.yml --set infra.kafka.enabled=false --set infra.mongo.enabled=false --set infra.postgres.enabled=false
```

Use the same `infra.*.enabled=false` flags for service releases that do not own the shared Mongo/Postgres/Kafka resources.

## Observability

This chart can install Jaeger all-in-one and an OpenTelemetry Collector. Service deployments receive standard OTEL env vars by default and export traces to `http://otel-collector:4317`.

Dry run:
```sh
helm template observability .\infra\k8s-dev-helm -f .\infra\k8s-dev-helm\values\observability.yml
helm template gateway-service .\infra\k8s-dev-helm -f .\infra\k8s-dev-helm\values\deployment\gateway-service.yml
```

Install or upgrade:
```sh
helm upgrade --install observability .\infra\k8s-dev-helm -f .\infra\k8s-dev-helm\values\observability.yml
```

To trace a GraphQL request, upgrade `gateway-service` and every downstream service involved in that request so each pod has OTEL env vars and application instrumentation enabled.

## Port Forward And Dashboards

Headlamp dashboard:
```shell
helm install headlamp-ui headlamp/headlamp --namespace kube-system
kubectl -n kube-system create serviceaccount headlamp-admin
kubectl create clusterrolebinding headlamp-admin --serviceaccount=kube-system:headlamp-admin --clusterrole=cluster-admin
kubectl -n kube-system create token headlamp-ui # Gen token
kubectl -n kube-system port-forward svc/headlamp-ui 4466:80 # Expose K8S dashboard
```

Gateway:
```shell
kubectl port-forward svc/gateway-service -n tripconnect 31071:31071 # Expose gateway
```

Consul UI:
```shell
kubectl port-forward svc/consul-ui -n consul 8500:80 # Export Consul UI dashboard
```

Jaeger UI:
```shell
kubectl -n tripconnect port-forward svc/jaeger 16686:16686 # Expose Jaeger UI
```

Kafka UI:
```text
http://localhost:30080
```

Dashboard URLs:
- Headlamp: `http://localhost:4466`
- Gateway: `localhost:31071`
- Consul dashboard: `http://localhost:8500/ui/dc1/services`
- Jaeger: `http://localhost:16686`
- Kubernetes dashboard: `http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/pod?namespace=tripconnect` (`kubectl proxy` required). How to set up? Follow the [step-by-step documentation](https://andrewlock.net/running-kubernetes-and-the-dashboard-with-docker-desktop/) with manifest sources of [dashboard](https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml), [metric server](https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml).

## Status Checks

```sh
kubectl get all -n tripconnect
kubectl -n consul get pods
kubectl -n tripconnect get pods,svc,endpoints -l app=jaeger
kubectl -n tripconnect get pods,svc,endpoints -l app=otel-collector
```

## Troubleshooting

When Helm cannot find the HashiCorp repo cache:
```sh
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
```

When Consul cannot start after a long time:
```shell
helm uninstall consul -n consul
kubectl delete pvc --all -n consul
kubectl delete namespace consul
```

If Jaeger port-forward fails with `timed out waiting for the condition`, check whether the Jaeger pod exists and is Ready:
```sh
kubectl -n tripconnect get deploy jaeger otel-collector
kubectl -n tripconnect get events --sort-by=.lastTimestamp
```

If the events show `failed calling webhook "consul-connect-injector.consul.hashicorp.com"`, fix or reinstall Consul first, then restart Jaeger and the collector:
```sh
kubectl -n tripconnect rollout restart deploy/jaeger deploy/otel-collector
```

If Jaeger only shows `gateway-service` or shows no spans, add OpenTelemetry SDK or auto-instrumentation in the service code and make sure gRPC/HTTP clients propagate W3C `traceparent` context. Helm can provide the collector, Jaeger, and OTEL env vars, but the applications still need to emit spans.
