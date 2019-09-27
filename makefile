MAKEFLAGS += --silent
.PHONY: docker-build tf-init tf-plan tf-apply tf-destroy app-build app-run shell up down

docker-build:
	docker build . -t hello-world-gke:latest

tf-init: docker-build
	docker run -v $$(pwd)/tf:/usr/src hello-world-gke terraform init

tf-fmt: docker-build
	docker run -v $$(pwd)/tf:/usr/src hello-world-gke terraform fmt

tf-plan: tf-init
	docker run -it -v $$(pwd)/tf:/usr/src -v $$HOME/.config/gcloud:/root/.config/gcloud hello-world-gke terraform plan

tf-apply: tf-init
	docker run -it -v $$(pwd)/tf:/usr/src -v $$HOME/.config/gcloud:/root/.config/gcloud hello-world-gke terraform apply

tf-destroy: tf-init
	docker run -it -v $$(pwd)/tf:/usr/src -v $$HOME/.config/gcloud:/root/.config/gcloud hello-world-gke terraform destroy

app-build:
	docker build app -t hello-world-app:latest

app-run: app-build
	docker run -it --rm -p 5555:5555 hello-world-node-app:latest

shell: tf-init
	docker run -it --rm \
		-v $$(pwd)/tf:/usr/src \
		-v $$(pwd)/k8s:/usr/src/k8s \
		-v $$(pwd)/scripts:/usr/src/scripts \
		-v $$HOME/.config/gcloud:/root/.config/gcloud \
		hello-world-gke sh

up: tf-init
	docker run -it \
		-v $$(pwd)/tf:/usr/src \
		-v $$(pwd)/k8s:/usr/src/k8s \
		-v $$(pwd)/scripts:/usr/src/scripts \
		-v $$HOME/.config/gcloud:/root/.config/gcloud \
		hello-world-gke ./scripts/up.sh

down: tf-init
	docker run -it \
		-v $$(pwd)/tf:/usr/src \
		-v $$(pwd)/k8s:/usr/src/k8s \
		-v $$(pwd)/scripts:/usr/src/scripts \
		-v $$HOME/.config/gcloud:/root/.config/gcloud \
		hello-world-gke ./scripts/down.sh
