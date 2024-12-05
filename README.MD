# Introduction
The infra management repository
# Setup
## Local lab
In the local environment, the services will run directly in the host and the databses will run as container to support deployment process.  
Create the databases and expose these ports:
```sh
docker-compose -f k8s/local/docker-compose.yml up --force-recreate
```
Dashboard:  
- Kafka UI: http://localhost:8080
## Staging lab
In the staging environment, the infra and microservices will all run on the Kubernetes environment.
1. Initialize infrastructure
```sh
kubectl create namespace tripconnect
kubectl apply -f k8s/staging/infra -n tripconnect
```
2. Deploy all services
```sh
kubectl apply -f k8s/staging/services -n tripconnect
```
Dashboard:  
- Kafka UI: http://localhost:30080