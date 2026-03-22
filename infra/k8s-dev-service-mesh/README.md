# Setup service mesh infra

## Create the necessary keyspace

```sh
kubectl create namespace tripconnect
```

```sh
kubectl create namespace consul
```

## Add Helm repo

```sh
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
```

## Install Helm manifest

```sh
helm install consul hashicorp/consul --namespace consul --set global.name=consul --set server.replicas=1 --set client.enabled=true --set ui.enabled=true --set connectInject.enabled=true
```

## Define label for sidecar injection

```sh
kubectl label namespace tripconnect consul.hashicorp.com/connect-inject=enabled
````

## Control commands

### Up

ls

```sh
kubectl apply -f infra/k8s-dev-service-mesh/infra/application.yml
kubectl apply -f infra/k8s-dev-service-mesh/infra --recursive

kubectl apply -f infra/k8s-dev-service-mesh/dashboard/dashboard.yml
kubectl apply -f infra/k8s-dev-service-mesh/dashboard --recursive

kubectl apply -f infra/k8s-dev-service-mesh/services --recursive
```

### Down

```sh
kubectl delete -f infra/k8s-dev-service-mesh/infra/application.yml
kubectl delete -f infra/k8s-dev-service-mesh/infra --recursive

kubectl delete -f infra/k8s-dev-service-mesh/dashboard/dashboard.yml
kubectl delete -f infra/k8s-dev-service-mesh/dashboard --recursive

kubectl delete -f infra/k8s-dev-service-mesh/services --recursive
```

### Check

```sh
# Status
kubectl get all -n tripconnect
```

# Dashboard

- Kubernetes
  dashboard: http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/pod?namespace=tripconnect (
  `kubectl proxy` required). How to set up? follow
  the [step-by-step documentation](https://andrewlock.net/running-kubernetes-and-the-dashboard-with-docker-desktop/)
  with manifest sources
  of [dashboard](https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml), [metric server](https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml).