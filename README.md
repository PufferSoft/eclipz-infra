
  
  
  ###

# Admingui Usage

## Prereqs

1. Download the following:
- aws-cli 
- kubectl
- Lens

2. Contact administrator for your AWS credentials.
3. Set your aws profile locally
- type `aws configure` on your command promt
- enter `your aws_access_key_id` and `aws_secret_access_key` when prompted.


## Project Structure

  

Under the `deploy/e2e` folder there project follows the structure below. Each folder will have it's own `README.md`. You'll find the terraform commands needed to manage the module.

  

-  `backend` creates S3 backends for the vpc, EKS cluster and K8s resources.

-  ```eks``` creates an EKS cluster on AWS us-west-2, ECR registrys,

databases and installs addons.

-  ```k8s``` holds all kubernetes yaml and sets up the auxiliary

resources (ingress, argocd application, database secrets) for the

cluster.

-  `k8s/yaml` Contains the yaml files that Argocd will use.

  

## ArgoCD

Under the `k8s/terraform.tfvars` file, replace the variables that comes after the comment block below with your git repo location.

  

############################

# ArgoCD locations

############################

In the `k8s/yaml` folder, you'll find yaml files for the deployment and services for the following microservices. Place each file in the correct repo and point ArgoCD to its location.

  

- admingui-frontend

- admingui-backend

- admingui-controller

  

## Helpful commands

To access the EKS cluster:

    aws eks update-kubeconfig --name eclipz-sandbox-devops-eks

To view ArgoCD:

    kubectl port-forward svc/argo-cd-argocd-server -n argocd 8080:443
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

  To view jenkins
  

    kubectl port-forward svc/jenkins -n jenkins 8083:8080
    kubectl -n jenkins get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 -d; echo
	

## Observations

-  `deploy/e2e/vpc` is not being used currently. `deploy/e2e/eks` creates its own VPC, so the external VPC can be removed safely.
