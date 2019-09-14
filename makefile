MAKEFLAGS += --silent
.PHONY: tf-docker tf-init tf-plan tf-apply app-build app-run

tf-docker:
	docker build images/gcloud-terraform -t gcloud-terraform:latest

tf-init: tf-docker
	docker run -v $$(pwd)/tf:/usr/src gcloud-terraform terraform init

tf-plan: tf-docker
	docker run -v $$(pwd)/tf:/usr/src -v $$HOME/.config/gcloud:/root/.config/gcloud gcloud-terraform terraform plan

tf-apply: tf-docker
	docker run -it -v $$(pwd)/tf:/usr/src -v $$HOME/.config/gcloud:/root/.config/gcloud gcloud-terraform terraform apply

app-build:
	docker build app -t hello-world-app:latest

app-run: app-build
	docker run -it --rm -p 5555:5555 hello-world-node-app:latest
