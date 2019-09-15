FROM google/cloud-sdk:262.0.0-alpine

WORKDIR /usr/src

ARG TERRAFORM_VERSION="0.12.8"
ARG HELM_VERSION="v3.0.0-beta.3"
ARG KUBECTL_VERSION="v1.14.3"
ARG JQ_VERSION="1.6"

RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin && \
    rm terraform.zip && \
    terraform --version

RUN wget -O helm.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -xvf helm.tar.gz && \
    mv linux-amd64/helm /usr/local/bin && \
    rm -rf helm.tar.gz linux-amd64 && \
    helm version

RUN wget -O kubectl.tar.gz https://dl.k8s.io/${KUBECTL_VERSION}/kubernetes-client-linux-amd64.tar.gz && \
    tar -xvf kubectl.tar.gz && \
    mv kubernetes/client/bin/kubectl /usr/local/bin && \
    rm -rf kubectl.tar.gz kubernetes && \
    kubectl version --client

RUN wget -O jq https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 && \
    chmod +x jq && \
    mv jq /usr/local/bin && \
    jq --version
