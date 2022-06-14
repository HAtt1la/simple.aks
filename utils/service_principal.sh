#!/bin/bash

if [ -z "$1" ] 
    then 
        echo "Before creating AKS you ahve to create a service principal"
        echo "This script create it, save the credentials to the spvars.json file"
        echo "and assign it to the azure subscription."
        echo "Arguments:"
        echo "create - create the service principal"
        echo "delete - delete the service principal. if spvars.json available"
        echo ""
        exit 1
    fi

SUBSCRIPTION='699aca9a-b142-414d-91d7-ab25b8ff988d'


if [ "$1" == "create" ]
    then    
        az ad sp create-for-rbac --skip-assignment --name aks-sp -o json > spvars.json
        SERVICE_PRINCIPAL=$(cat spvars.json | jq -r '.appId')

        # Grant contributor role over the subscription to our service principal
        az role assignment create --assignee $SERVICE_PRINCIPAL \
        --scope "/subscriptions/$SUBSCRIPTION" \
        --role Contributor
fi

if [ "$1" == "delete" ]
    then
        SERVICE_PRINCIPAL=$(cat spvars.json | jq -r '.appId')
        az ad sp delete --id $SERVICE_PRINCIPAL
fi

