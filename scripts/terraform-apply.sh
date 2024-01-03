#!/bin/bash
WORKING_DIR=./terraform-live
ENVIRONMENT=prod
PLAN_FILE=$ENVIRONMENT.plan
STORAGE_ACCOUNT_NAME=stac

# Change to the Terraform directory
cd $WORKING_DIR

az storage blob download \
    --file provider.tf \
    --name provider.tf \
    --account-name $STORAGE_ACCOUNT_NAME \
    --container-name $ENVIRONMENT-tf-files

az storage blob download \
    --file backend.tf \
    --name backend.tf \
    --account-name $STORAGE_ACCOUNT_NAME \
    --container-name $ENVIRONMENT-tf-files

 az storage blob download \
    --file $PLAN_FILE \
    --name $PLAN_FILE \
    --account-name $STORAGE_ACCOUNT_NAME \
    --container-name $ENVIRONMENT-tf-files

 az storage blob download \
    --file $ENVIRONMENT.tfvars \
    --name $ENVIRONMENT.tfvars \
    --account-name $STORAGE_ACCOUNT_NAME \
    --container-name $ENVIRONMENT-tf-files

terraform init -reconfigure

#https://stackoverflow.com/questions/70049758/terraform-for-each-one-by-one
TF_CLI_ARGS_apply="-parallelism=1"
# Run Terraform apply using the saved plan file
terraform apply $PLAN_FILE

# Provide feedback to the user
echo "Terraform apply completed."