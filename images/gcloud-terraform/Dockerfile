FROM google/cloud-sdk:262.0.0-alpine

WORKDIR /usr/src

ARG TERRAFORM_VERSION="0.12.8"

RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin && \
    rm terraform.zip && \
    terraform --version

CMD ["terraform"]
