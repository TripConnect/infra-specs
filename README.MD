# Database setup
Setup all system databases that includes:  
- Mysql
- MongoDB
## Local lab
In local environment, the services will run directly in the host and the databses will run as container to support deployment process.  
Create the databases and expose these ports:
```sh
docker-compose -f k8s/local/docker-compose.yml up --force-recreate
```
