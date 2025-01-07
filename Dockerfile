FROM alpine:latest

# Installation des dépendances nécessaires
RUN apk add --no-cache \
    curl \
    wget \
    unzip \
    git \
    bash

# Installation de Terraform
RUN wget https://releases.hashicorp.com/terraform/1.7.2/terraform_1.7.2_linux_amd64.zip \
    && unzip terraform_1.7.2_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_1.7.2_linux_amd64.zip

# Définition du répertoire de travail
WORKDIR /terraform

# Point d'entrée par défaut
ENTRYPOINT ["terraform"]
