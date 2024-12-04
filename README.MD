# Introduction
The infra management repository
# Setup
## Local lab
In local environment, the services will run directly in the host and the databses will run as container to support deployment process.  
Create the databases and expose these ports:
```sh
docker-compose -f k8s/local/docker-compose.yml up --force-recreate
```
Dashboard:  
- Kafka: http://localhost:8080
## Staging
```sh
kubectl create namespace tripconnect
kubectl apply -f k8s/staging/infra -n tripconnect
```
