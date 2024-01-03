#!/bin/bash

WORKING_DIR=./terraform-live
ENVIRONMENT=prod
STORAGE_ACCOUNT_NAME=stac

# Change to the Terraform directory
cd $WORKING_DIR

#Copy provider and backend file create locally to tffiles container
az storage blob download \
    --container-name $ENVIRONMENT-tf-files \
    --file provider.tf \
    --name provider.tf \
    --account-name $STORAGE_ACCOUNT_NAME \
    --overwrite

az storage blob download \
    --container-name $ENVIRONMENT-tf-files \
    --file backend.tf \
    --name backend.tf \
    --account-name $STORAGE_ACCOUNT_NAME \
    --overwrite

az storage blob download \
    --container-name states \
    --file $ENVIRONMENT.tfstate \
    --name $ENVIRONMENT.tfstate \
    --account-name $STORAGE_ACCOUNT_NAME \
    --overwrite