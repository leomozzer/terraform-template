#!/bin/bash

varFile=prod.tfvars

# Change to the Terraform directory
cd ./terraform-live

# Run Terraform destroy and confirm with "yes"
terraform destroy -auto-approve -var-file=$varFile

# Optionally, you can uncomment the following line to remove the tfstate file after destroy
# rm -f terraform.tfstate

# Provide feedback to the user
echo "Terraform destroy completed."