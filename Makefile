REGISTRY ?= gcr.io

VERSION ?= $(shell git describe --tags --always --dirty)

IMAGE ?= centos/api

NAME ?= $(shell echo $(IMAGE) | tr '/' '-')

PORTS ?= -p 8080:8080

DB_PORT ?= 3306
DB_USER ?= api
DB_PASS ?= api
DB_NAME ?= api

PROJECT_ID ?= qwerty

build: build-db build-api push gcloud-config build-k8s

gcloud-config: 
	gcloud config set project $(PROJECT_ID)
	gcloud config set compute/zone europe-west2-a

build-k8s:
	gcloud container clusters create helloworld1 --num-nodes=3 --zone europe-west2-a
	gcloud container clusters get-credentials helloworld1
	kubectl run hello-server --image=$(REGISTRY)/$(IMAGE) --port 8080
	kubectl expose deployment hello-server --type=LoadBalancer --port 80 --target-port 8080

build-api:
	docker build 	--build-arg DB_HOST=$(DB_HOST) \
			--build-arg DB_PORT=$(DB_PORT) \
			--build-arg DB_USER=$(DB_USER) \
			--build-arg DB_PASS=$(DB_PASS) \
			--build-arg DB_NAME=$(DB_NAME) \
			--force-rm -t $(IMAGE):$(VERSION) .

build-db:
	gcloud sql instances create hello-db-server --tier=db-n1-standard-2 --region=europe-west2 --assign-ip
	gcloud sql users set-password root --host % --instance hello-db-server --password $(DB_PASS)
	gcloud sql users create $(DB_USER) --instance hello-db-server --host % --password $(DB_PASS)
	gcloud sql databases create $(DB_NAME) --instance=hello-db-server
	DB_HOST := $(shell gcloud sql instances describe hello-db-server |grep ipAddress: | awk '{print $NF}')
	mysql -h $(DB_HOST) -P $(DB_PORT) -u $(DB_USER) -p$(DB_PASS) -D $(DB_NAME) < db.sql

push:
	gcloud auth configure-docker
	docker push $(REGISTRY)/$(IMAGE):$(VERSION)

upgrade-api:
	kubectl set image deployment/hello-server hello-server=$(REGISTRY)/$(IMAGE):$(VERSION)

upgrade: build-api push upgrade-api


start:
	docker run -d --name $(NAME) $(PORTS) $(IMAGE):$(VERSION)

stop:
	docker stop $(NAME)

destroy-k8s:
	kubectl delete service hello-server
	gcloud container clusters delete helloworld1


