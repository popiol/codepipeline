# Semantive DevOps assignment

## Overview

The task has been completed using AWS services and Terraform. There is no Kubernetes in the solution, instead the container is started directly by docker-compose. Continues deployment is maintained by AWS CodePipeline and CodeBuild. The application is deployed on a single EC2 instance, but it can be easily configured to scale to multiple instances with AWS ELB and Auto Scaling. All named AWS resources have prefixes consisted of application name and application version. The version is the same as the name of the repo branch that has been deployed.

## Initial build and deployment

1. Clone the repo to a machine with access to the target AWS account
1. Go to terraform directory and set all neccesarry variables:
  <pre>cp config.tfvars.template config.tfvars
  vi config.tfvars</pre>
  - **`aws_region`**, the default region for the AWS account
  - **`ssh_pub_key`**, the public key used for connecting to EC2 instances
  - **`ssh_priv_key`**, the private key used for connecting to EC2 instances
  - `app_id`, consists of application name and version
  - `app`, application name
  - `app_ver`, application version (branch name)
  - `tags`, the default tags for AWS resources
  - **`statefile_bucket`**, name of an existing bucket where the state file is going to be stored
  - `timezone`, Time zone used on EC2 instances
  - **`keys_bucket`**, name of an existing bucket where the state file is going to be stored
  - `github_token`, token used for connecting to github repository
  - `github_user`, Github user name
  - `github_repo`, Github repo name
  - `crud_rest_key`, secret key used by the cassandra-crud-rest app
  
  You only need to set the parameters in bold.
  
1. Go to the base directory and run `./deploy.sh`

This will start EC2 istance and configue CodePipeline with the following stages: Source, Build, Deploy, Smoke Test.

## Source

