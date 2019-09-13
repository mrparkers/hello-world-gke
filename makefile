MAKEFLAGS += --silent
.PHONY: tf-docker tf-init tf-plan tf-apply

tf-docker:
	docker build images/gcloud-terraform -t gcloud-terraform:latest

tf-init: tf-docker
	docker run -v $$(pwd)/tf:/usr/src gcloud-terraform terraform init

tf-plan: tf-docker
	docker run -v $$(pwd)/tf:/usr/src -v $$HOME/.config/gcloud:/root/.config/gcloud gcloud-terraform terraform plan

tf-apply: tf-docker
	docker run -v $$(pwd)/tf:/usr/src -v $$HOME/.config/gcloud:/root/.config/gcloud gcloud-terraform terraform apply
