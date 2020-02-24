# Semantive DevOps assignment

## Overview

The task has been completed using AWS services and Terraform. There is no Kubernetes in the solution, instead the container is started directly by docker-compose. Continues deployment is maintained by AWS CodePipeline and CodeBuild. The application is deployed on a single EC2 instance, but it can be easily configured to scale to multiple instances with AWS ELB and Auto Scaling. All named AWS resources have prefixes consisted of application name and application version. The version is the same as the name of the repo branch that has been deployed.

## Initial deployment

1. Clone repo to machine with access to the target AWS account
1. Go to the base directory and run `./deploy.sh`

