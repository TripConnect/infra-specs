# Introduction

The infra management repository

# Setup

## Local lab

In the local environment, the microservices will run directly in the localhost and other resources (database, kafka,
etc) will run as containers and expose these ports.

```sh
# Up
docker-compose -f infra/local/docker-compose.yml up --force-recreate
# Down
docker-compose -f infra/local/docker-compose.yml down
# Status
docker-compose -f infra/local/docker-compose.yml ps
```

Dashboard:

- Kafka UI: http://localhost:8080

## Development lab

In the staging environment, the infra and microservices will all run in the Kubernetes environment.

### Setup service mesh infra

#### Create the necessary keyspace

```sh
kubectl create namespace tripconnect
```

```sh
kubectl create namespace consul
```

#### Add Helm repo and install

```sh
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
```

```sh
helm install consul hashicorp/consul --namespace consul --set global.name=consul --set server.replicas=1 --set client.enabled=true --set ui.enabled=true --set connectInject.enabled=true
```

#### Define label for sidecar injection

```sh
kubectl label namespace tripconnect consul.hashicorp.com/connect-inject=enabled
````

### Control snippet for infra and business backend services

```sh
# Up
kubectl apply -f infra/k8s-dev/infra/application.yml
kubectl apply -f infra/k8s-dev/infra --recursive

kubectl apply -f infra/k8s-dev/services --recursive

kubectl apply -f infra/k8s-dev/dashboard/dashboard.yml
kubectl apply -f infra/k8s-dev/dashboard --recursive

# Down
kubectl delete -f infra/k8s-dev/infra/application.yml
kubectl delete -f infra/k8s-dev/infra --recursive

kubectl delete -f infra/k8s-dev/services --recursive

kubectl delete -f infra/k8s-dev/dashboard/dashboard.yml
kubectl delete -f infra/k8s-dev/dashboard --recursive

# Status
kubectl get all -n tripconnect
```

Dashboard:

- Kafka UI: http://localhost:30080
- Kubernetes
  dashboard: http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/pod?namespace=tripconnect (
  `kubectl proxy` required). How to setup? following
  the [step by step documentation](https://andrewlock.net/running-kubernetes-and-the-dashboard-with-docker-desktop/)
  with manifest sources
  of [dashboard](https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml), [metric server](https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml).
- Consul dashboard: http://localhost:8500/ui/dc1/services