# Introduction
The infra management repository
# Setup
## Local lab
In the local environment, the microservices will run directly in the localhost and other resources (database, kafka, etc) will run as containers and expose these ports.  
```sh
# Up
docker-compose -f k8s/local/docker-compose.yml up --force-recreate
# Down
docker-compose -f k8s/local/docker-compose.yml down
# Status
docker-compose -f k8s/local/docker-compose.yml ps
```
Dashboard:  
- Kafka UI: http://localhost:8080
## Development lab
In the staging environment, the infra and microservices will all run on the Kubernetes environment.
```sh
# Up
kubectl apply -f k8s/development/infra --recursive -n tripconnect
kubectl apply -f k8s/development/services --recursive -n tripconnect
kubectl apply -f k8s/development/dashboard --recursive
# Down
kubectl delete -f k8s/development --recursive -n tripconnect
kubectl delete -f k8s/development/dashboard --recursive
# Status
kubectl get all -n tripconnect
```
Dashboard:  
- Kafka UI: http://localhost:30080
- Kubernetes dashboard: http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/pod?namespace=tripconnect (`kubectl proxy` required). How to setup? following the [step by step documentation](https://andrewlock.net/running-kubernetes-and-the-dashboard-with-docker-desktop/) with manifest sources of [dashboard](https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml), [metric server](https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml).
