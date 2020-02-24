#!/bin/bash

#set timezone

sudo echo "${timezone}" > /etc/timezone

#copy vim config file

sudo echo "${vimrc}" > /etc/vim/vimrc.local

#copy docker-compose.yml

cd /tmp

echo "${docker_compose}" > ./docker-compose.yml

#install docker

sudo apt-get update 

sudo apt-get install -y docker.io

#install docker compose

sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

#install AWS CLI

sudo apt-get install -y awscli

#login to AWS ECR

sudo $(aws ecr get-login --no-include-email --region ${aws_region})

sudo docker tag ${app_id}:${image_tag} ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${app_id}:${image_tag}

sudo docker-compose up -d

