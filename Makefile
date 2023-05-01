
APP_NAME=address-book
DOCKER_REPO=sdblepas/vim
DOMAIN=address-book.kube.pm
CLUSTER_NAME=k3d
NAMESPACE=default


create_k3d:
	bash scripts/k3d_setup.sh $(CLUSTER_NAME)

install_postgres:
	bash scripts/postgres_setup.sh $(NAMESPACE) $(POSTGRES_PASSWORD)

add_host:
	echo "127.0.0.1 $(DOMAIN)" | sudo tee -a /etc/hosts
	cat /etc/hosts

build:
	docker build -t $(DOCKER_REPO):latest .
	docker push $(DOCKER_REPO):latest

test:
	docker rm -f flask_app flask_db
	docker-compose up -d --force-recreate --build
	bash scripts/app_test.sh
	docker-compose down

deploy:
	bash scripts/app_deploy.sh $(NAMESPACE) $(APP_NAME) $(DOMAIN) $(POSTGRES_PASSWORD)