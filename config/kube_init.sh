#!/bin/bash

#set timezone

sudo echo "${timezone}" > /etc/timezone

#copy vim config file

sudo echo "${vimrc}" > /etc/vim/vimrc.local

#copy docker-compose.yml

cd /tmp

echo "${docker_compose}" > ./docker-compose.yml

#install kubectl

#curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

#chmod +x ./kubectl

#sudo mv ./kubectl /usr/local/bin/kubectl

#install docker

sudo apt-get update 

sudo apt-get install -y docker.io

#install docker compose

sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

#install minikube
	
#curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 

#chmod +x minikube 

#sudo mv minikube /usr/local/bin/

#start minikube

#sudo minikube start --vm-driver=none

#install AWS CLI

sudo apt-get install -y awscli

#login to AWS ECR

sudo $(aws ecr get-login --no-include-email --region ${aws_region})

sudo docker-compose up -d

