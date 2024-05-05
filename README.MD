# Database setup
Setup these databases:  
- Mysql
- MongoDB
## Local lab
In local environment, the services will run directly in the host and the databses will run as container to support deployment process.  
Create the databases and expose these ports:
```sh
kubectl apply -f k8s/local/databases.yml
```
