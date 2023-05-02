### Create K3d
The following command will create a k3d cluster

```make create_k3d```

### install postgres define host and deploy app

This will install postgres via helm with a given password, that will be saved in the k8s secrets.
You can choose the password you want
```
export POSTGRES_PASSWORD=test1234 
make install_postgres 
make add_host
make deploy
```


### build and test
This should be added to a CI process but since it's a zip file it's not possible

Create application docker image and push to dockerhub
```make build```

E2E test for the application in docker-compose
```make test```



