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



Dear candidate,

You can write in Python (preferred), NodeJS and Golang. If you are not familiar with any of these, please let us know and we’ll resolve it.

If you have any questions don’t hesitate to ask me.

# The exercise:
We want to build an employee address book REST API, running on Kubernetes and using PostgreSQL as backend DB.

# Required flow (& features):
- POST method on /create path - new employee will be added to the address book.
- GET method on /list path - JSON with all employees will be returned.
- GET method on /employee with employee ID - JSON with single employee will be returned
  Each employee record should contain the following fields/keys - Name, Last Name, Date of Birth, Phone Number, Job Title and Employee ID.
- Employee ID field should be unique and there should be no possibility to add more than one employee with the same ID.
- Log for each successful create and delete operation should be written to the logs table.
- GET method on /log should return JSON with 50 last log entries.

# Tools we’ll use:

- Kubernetes - https://k3d.io/
- Helm - https://helm.sh/

# Non functional requirements:

- API should be available on http://address-book.kube.pm URL using built-in (k3d) ingress controller, listening on port 80.
- Add Make file or bash script that will start k3d on Linux/Mac PC and deploy the application.
- The user and password for PostgreSQL DB should be stored in Kubernetes secret as part of the Helm chart.
- Host dockerized PostgreSQL on the Kubernetes cluster
- Application should use stored Kubernetes secret credentials to connect to the DB.



### Assignment submission
Once you are absolutly sure you finished the assigment, please upload your solution 
