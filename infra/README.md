This repository contains Terraform code to provision the AWS resources

Prerequisites:

* AWS Credentials plugin installed on Jenkins
* Create AWS credetnails secrets in Jenkins -> secret id name -> aws-devops-creds

This infra is run by Jenkinsfiles/Jenkinsfile.infra


Resources created by this infra scripts are:

* Amazon EKS Cluster (Elastic Kubernetes Service)

* Amazon ECR Repository (Elastic Container Registry)

* VPC, Subnets, and Security Groups

* IAM Roles & Policies required for EKS and worker nodes

* Node Group


