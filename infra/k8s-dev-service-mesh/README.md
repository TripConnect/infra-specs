# K8S Dev Service Mesh

Setup service mesh, infra, backend services, dashboards, and observability for the dev cluster.

## Run From Scratch

```sh
kubectl create namespace tripconnect
kubectl create namespace consul

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm repo update

helm install consul hashicorp/consul --namespace consul --set global.name=consul --set server.replicas=1 --set client.enabled=true --set ui.enabled=true --set connectInject.enabled=true
kubectl label namespace tripconnect consul.hashicorp.com/connect-inject=enabled

helm upgrade --install tripconnect-infra .\infra\k8s-dev-helm --namespace tripconnect -f .\infra\k8s-dev-helm\values\infra.yml
helm upgrade --install observability .\infra\k8s-dev-helm --namespace tripconnect -f .\infra\k8s-dev-helm\values\observability.yml

helm upgrade --install config-service .\infra\k8s-dev-helm --namespace tripconnect -f .\infra\k8s-dev-helm\values\deployment\config-service.yml
helm upgrade --install gateway-service .\infra\k8s-dev-helm --namespace tripconnect -f .\infra\k8s-dev-helm\values\deployment\gateway-service.yml
helm upgrade --install user-service .\infra\k8s-dev-helm --namespace tripconnect -f .\infra\k8s-dev-helm\values\deployment\user-service.yml
helm upgrade --install chat-service .\infra\k8s-dev-helm --namespace tripconnect -f .\infra\k8s-dev-helm\values\deployment\chat-service.yml
helm upgrade --install twofa-service .\infra\k8s-dev-helm --namespace tripconnect -f .\infra\k8s-dev-helm\values\deployment\twofa-service.yml
```

## Deploy Service Mesh

Namespaces:
```sh
kubectl create namespace tripconnect
kubectl create namespace consul
```

Helm repo:
```sh
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
```

Consul:
```sh
helm install consul hashicorp/consul --namespace consul --set global.name=consul --set server.replicas=1 --set client.enabled=true --set ui.enabled=true --set connectInject.enabled=true
```

Sidecar injection:
```sh
kubectl label namespace tripconnect consul.hashicorp.com/connect-inject=enabled
```

## Deploy Infra

Helm:
```sh
helm upgrade --install tripconnect-infra .\infra\k8s-dev-helm --namespace tripconnect -f .\infra\k8s-dev-helm\values\infra.yml
```

Manifest:
```sh
kubectl apply -f infra/k8s-dev-service-mesh/infra/application.yml
kubectl apply -f infra/k8s-dev-service-mesh/infra --recursive
```

## Deploy BE Services

Helm-based services with OpenTelemetry env:
```sh
helm upgrade --install config-service .\infra\k8s-dev-helm --namespace tripconnect -f .\infra\k8s-dev-helm\values\deployment\config-service.yml
helm upgrade --install gateway-service .\infra\k8s-dev-helm --namespace tripconnect -f .\infra\k8s-dev-helm\values\deployment\gateway-service.yml
helm upgrade --install user-service .\infra\k8s-dev-helm --namespace tripconnect -f .\infra\k8s-dev-helm\values\deployment\user-service.yml
helm upgrade --install chat-service .\infra\k8s-dev-helm --namespace tripconnect -f .\infra\k8s-dev-helm\values\deployment\chat-service.yml
helm upgrade --install twofa-service .\infra\k8s-dev-helm --namespace tripconnect -f .\infra\k8s-dev-helm\values\deployment\twofa-service.yml
```

Manifest:
```sh
kubectl apply -f infra/k8s-dev-service-mesh/services --recursive
```

Use one deployment path for infra/services in a fresh cluster. The Helm path is preferred when using OTel + Jaeger.

## OTel + Jaeger

```sh
helm upgrade --install observability .\infra\k8s-dev-helm --namespace tripconnect -f .\infra\k8s-dev-helm\values\observability.yml
kubectl -n tripconnect port-forward svc/jaeger 16686:16686 # Expose Jaeger UI
```

Open `http://localhost:16686`.

## Dashboard

Install Headlamp:
```shell
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm repo update
helm install headlamp-ui headlamp/headlamp --namespace kube-system
kubectl -n kube-system create serviceaccount headlamp-admin
kubectl create clusterrolebinding headlamp-admin --serviceaccount=kube-system:headlamp-admin --clusterrole=cluster-admin
kubectl -n kube-system create token headlamp-ui # Gen token
```

Metrics server:
```shell
kubectl delete deployment metrics-server -n kube-system --ignore-not-found
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Port-forward:
```shell
kubectl -n kube-system port-forward svc/headlamp-ui 4466:80 # Expose K8S dashboard
kubectl port-forward svc/gateway-service -n tripconnect 31071:31071 # Expose gateway
kubectl port-forward svc/consul-ui -n consul 8500:80 # Export Consul UI dashboard
kubectl -n tripconnect port-forward svc/jaeger 16686:16686 # Expose Jaeger UI
```

URLs:
- Headlamp: `http://localhost:4466`
- Gateway: `localhost:31071`
- Consul UI: `http://localhost:8500`
- Jaeger UI: `http://localhost:16686`
- Kubernetes dashboard: `http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/pod?namespace=tripconnect` (`kubectl proxy` required). How to set up? Follow the [step-by-step documentation](https://andrewlock.net/running-kubernetes-and-the-dashboard-with-docker-desktop/) with manifest sources of [dashboard](https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml), [metric server](https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml).

## Check

```sh
kubectl get all -n tripconnect
kubectl get all -n consul
helm list -n tripconnect
helm history config-service -n tripconnect
```

## Down

```sh
kubectl delete -f infra/k8s-dev-service-mesh/infra/application.yml
kubectl delete -f infra/k8s-dev-service-mesh/infra --recursive
kubectl delete -f infra/k8s-dev-service-mesh/services --recursive
```

## Troubleshooting

When Consul cannot start after a long time:
```shell
helm uninstall consul -n consul
kubectl delete pvc --all -n consul
kubectl delete namespace consul
```

Helm release history is namespace-scoped. If `helm history config-service` returns `release: not found`, check the release in `tripconnect`:
```shell
helm history config-service -n tripconnect
helm list -n tripconnect
```
