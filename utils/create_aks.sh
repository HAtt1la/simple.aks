#!/bin/bash
set -euo pipefail

#define flags
while getopts t:ssh: flag
do
    case "${flag}" in
        t) tfflag=${OPTARG};;
        ssh) sshkey=${OPTARG};;

    esac
done

if [ -z ${tfflag} ] 
    then 
        echo "use the -t flag. It can be plan apply destroy"
        exit1
    fi

#set SSH key from a pub file. if the pub file not in this directory, path expected
if [ -z "${sshkey}" ] 
then 
    echo "the ssh path have to contain the keyfile.pub e.g. id_rsa.pub"
    exit 1
else
    SSH_KEY="$sshkey"
fi

#these are came from a local file spvars.json where the service principal details stored
SERVICE_PRINCIPAL=$(cat spvars.json | jq -r '.appId')
SERVICE_PRINCIPAL_SECRET=$(cat spvars.json | jq -r '.password')
TENANT_ID=$(cat spvars.json| jq -r '.tenant')
#except this one
SUBSCRIPTION='699aca9a-b142-414d-91d7-ab25b8ff988d'


if [[ -z $SERVICE_PRINCIPAL || -z $SERVICE_PRINCIPAL_SECRET || -z $TENANT_ID || -z $SUBSCRIPTION || -z $SSH_KEY ]]
    then 
        echo "One of the necessary variable missing"
        exit1
    fi

terraform -chdir='../terraform' init

terraform -chdir='../terraform' $tfflag \
    -var "serviceprinciple_id=$SERVICE_PRINCIPAL" \
    -var "serviceprinciple_key=$SERVICE_PRINCIPAL_SECRET" \
    -var "tenant_id=$TENANT_ID" \
    -var "subscription_id=$SUBSCRIPTION" \
    -var "ssh_key=$SSH_KEY"

