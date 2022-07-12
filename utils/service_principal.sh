#!/bin/bash

if [ -z "$1" ] 
    then 
        echo "Before creating AKS you have to create a service principal"
        echo "This script create it, save the credentials to the spvars.json file"
        echo "and assign it to the azure subscription."
        echo ""
        echo "Arguments:"
        echo "create - create the service principal"
        echo "delete - delete the service principal. if spvars.json available"
        echo ""
        exit 1
    fi
#fetching subscription id from default account 
SUBSCRIPTION="$(az account list --query "[?isDefault].id" -o tsv)"
if [ -z ${SUBSCRIPTION} ] 
    then 
        echo "missing subscription id. Before run the script, please use: az login - after this, the subscription id is available"
        exit 1
fi

echo $SUBSCRIPTION

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

