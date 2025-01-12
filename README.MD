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
kubectl create namespace tripconnect
kubectl apply -f k8s/development/infra --recursive -n tripconnect
kubectl apply -f k8s/development/services --recursive -n tripconnect
# Down
kubectl delete -f k8s/development --recursive -n tripconnect
# Status
kubectl get pods -n tripconnect
```
Dashboard:  
- Kafka UI: http://localhost:30080
