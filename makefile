MAKEFLAGS += --silent
.PHONY: docker-build tf-init tf-plan tf-apply tf-destroy app-build app-run up down

docker-build:
	docker build . -t hello-world-gke:latest

tf-init: docker-build
	docker run -v $$(pwd)/tf:/usr/src hello-world-gke terraform init

tf-fmt: docker-build
	docker run -v $$(pwd)/tf:/usr/src hello-world-gke terraform fmt

tf-plan: docker-build
	docker run -it -v $$(pwd)/tf:/usr/src -v $$HOME/.config/gcloud:/root/.config/gcloud hello-world-gke terraform plan

tf-apply: docker-build
	docker run -it -v $$(pwd)/tf:/usr/src -v $$HOME/.config/gcloud:/root/.config/gcloud hello-world-gke terraform apply

tf-destroy: docker-build
	docker run -it -v $$(pwd)/tf:/usr/src -v $$HOME/.config/gcloud:/root/.config/gcloud hello-world-gke terraform destroy

app-build:
	docker build app -t hello-world-app:latest

app-run: app-build
	docker run -it --rm -p 5555:5555 hello-world-node-app:latest

up: docker-build
	docker run -it \
		-v $$(pwd)/tf:/usr/src \
		-v $$(pwd)/k8s:/usr/src/k8s \
		-v $$(pwd)/scripts:/usr/src/scripts \
		-v $$HOME/.config/gcloud:/root/.config/gcloud \
		hello-world-gke ./scripts/up.sh

down: docker-build
	docker run -it \
		-v $$(pwd)/tf:/usr/src \
		-v $$(pwd)/k8s:/usr/src/k8s \
		-v $$(pwd)/scripts:/usr/src/scripts \
		-v $$HOME/.config/gcloud:/root/.config/gcloud \
		hello-world-gke ./scripts/down.sh
