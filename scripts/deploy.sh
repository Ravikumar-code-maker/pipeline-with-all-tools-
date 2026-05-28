#!/bin/bash

echo "================================"
echo "Starting Deployment"
echo "================================"

#####################################
# Maven Build
#####################################

mvn clean package

if [ $? -ne 0 ]
then
    echo "Maven Build Failed"
    exit 1
fi

#####################################
# Upload WAR To Nexus
#####################################

mvn deploy \
-Dusername=$NEXUS_USER \
-Dpassword=$NEXUS_PASS

#####################################
# Docker Login
#####################################

echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

#####################################
# Docker Build
#####################################

docker build -t $IMAGE_NAME .

#####################################
# Docker Push
#####################################

docker push $IMAGE_NAME

#####################################
# GCP Authentication
#####################################

gcloud auth activate-service-account --key-file=$GCP_KEY

gcloud config set project devops-project

#####################################
# Terraform
#####################################

cd terraform

terraform init

terraform apply \
-var="project=devops-project" \
-var="region=us-central1" \
-auto-approve

cd ..

#####################################
# Kubernetes Authentication
#####################################

export KUBECONFIG=$KUBECONFIG_FILE

kubectl get nodes

#####################################
# Ansible
#####################################

cd ansible

ansible-playbook \
-i inventory.ini \
--private-key=$SSH_KEY \
-u $SSH_USER \
install-tools.yml

cd ..

#####################################
# Kubernetes Deployment
#####################################

kubectl apply -f deployment.yaml

kubectl apply -f service.yaml

echo "================================"
echo "Deployment Successful"
echo "================================"
