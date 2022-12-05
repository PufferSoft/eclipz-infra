#  Infrastructure Design

 ## Repositories
This project connects the following three repositories:

 - https://github.com/Eclipz-Git/eclipz-infra 
 - https://github.com/Eclipz-Git/controller
 - https://github.com/Eclipz-Git/admingui

## eclipz-infra

Contains all configuration files for managing the infrastructure. The most important directories are:

 - `deploy/e2e/backend`
 - `deploy/e2e/eks`
 - `deploy/e2e/k8s`

### deploy/e2e/backend

 - `eks` - Creates and stores the state of the eks cluster
 - `k8s` - Creates and stores the state of the k8 resources inside the cluster

### deploy/e2e/eks
Creates the following resources:
 - EKS cluster with VPC
 - Installs ArgoCD and other plugins to the cluster. 
	 - You can find the list of plugins under `/infrastructure/argocd/main.tf`
 - ECR registries,
	 - `admingui-frontend`
	 - `admingui-backend`
	 - `admingui-controller`
 - RDS Postgres database

### deploy/e2e/k8s
Adds the following resources to the EKS cluster:

 - ECR image secrets
 - Github secrets pulled from Secrets Manager. Used by ArgoCD for connecting to the organization's repo.
 - `admingui` namespace to hold the application and ingress resources
 - Application to be managed by ArgoCD
       	 - `admingui-frontend` in `yaml/frontend`
       	 - `admingui-backend` in `yaml/backend`
       	 - `admingui-controller` in `yaml/controller`
 - ALB ingress resource
 - Databse connection secrets.

 
## Jenkins Pipeline
 ### github.com/Eclipz-Git/admingui
 
 1. `main` branch recieves a new commit
 2. Jenkins pull from `admingui` and `eclipz-infra` repositories for update.
 3. Builds the frontend and backend images
 4. Uploads the new images and identifies the update with the `BUILD_NUMBER`
 5. Replaces the entire`kustomization.yaml` file with the new image tag.***
 6. The updated inrfastructure repo is committed and ArgoCD syncs the new image to the cluster.

*** Find these files here`eclipz-infra/deploy/e2e/k8s/yaml/(frontend/backend)`
*** All changes manually made directly to this file will be overwritten by the pipeline.

 ### github.com/Eclipz-Git/controller
 
 1. `master` branch recieves a new commit
 2. Jenkins pull from `controller` and `eclipz-infra` repositories for update.
 3. Builds the frontend and backend images
 4. Uploads the new images and identifies the update with the `BUILD_NUMBER`
 5. Replaces the entire`kustomization.yaml` file with the new image tag.***
 6. The updated inrfastructure repo is committed and ArgoCD syncs the new image to the cluster.

*** Find these files here`eclipz-infra/deploy/e2e/k8s/yaml/controller`
*** All changes manually made directly to this file will be overwritten by the pipeline.


 
