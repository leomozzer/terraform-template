#!/bin/bash

WORKING_DIR=./terraform-live
ENVIRONMENT=prod
STORAGE_ACCOUNT_NAME=stac

VAR_FILE=$ENVIRONMENT.tfvars
PLAN_FILE=$ENVIRONMENT.plan

# Change to the Terraform directory
cd $WORKING_DIR

#Run terraform formating
terraform fmt

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
    --file $ENVIRONMENT.tfvars \
    --name $ENVIRONMENT.tfvars \
    --account-name $STORAGE_ACCOUNT_NAME \
    --container-name $ENVIRONMENT-tf-files

# Initialize Terraform (if not already initialized)
terraform init -reconfigure

# Run Terraform plan and save the output to a plan file
terraform plan -var-file=$VAR_FILE -out=$PLAN_FILE
echo "Terraform plan completed"

az storage blob upload \
    --container-name $ENVIRONMENT-tf-files \
    --file $PLAN_FILE \
    --name $PLAN_FILE \
    --account-name $STORAGE_ACCOUNT_NAME \
    --overwrite

az storage blob upload \
    --container-name $ENVIRONMENT-tf-files \
    --file $VAR_FILE \
    --name $VAR_FILE \
    --account-name $STORAGE_ACCOUNT_NAME \
    --overwrite

# Optionally, you can print the plan to the console
# terraform show -json tfplan | jq '.'
