## How to deploy 

    terraform init -backend-config backend.config -reconfigure

    terraform plan -var-file terraform.tfvars

    terraform apply -var-file terraform.tfvars -auto-approve


## How to Destroy the cluster

    terraform destroy -var-file terraform.tfvars -auto-approve  