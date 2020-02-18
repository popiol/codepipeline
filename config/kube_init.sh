#!/bin/bash

#install kubectl

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

#install docker

sudo apt-get update 

sudo apt-get install docker.io -y

#install minikube
	
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 

chmod +x minikube 

sudo mv minikube /usr/local/bin/

#start minikube

sudo minikube start --vm-driver=none

