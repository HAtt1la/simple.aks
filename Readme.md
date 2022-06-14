# AKS POC with Terraform

## Pre-requistes:
- Terraform
- Kubectl
- Azure subscription
- Azure (probably higher access) right to create service principal and assign role
- Azure cli
- ssh keypair

## This terraform template will deploy:
- create a resource group for the components 
- deploy aks under the created resource group
- with 2 node and with minimal resources: `standard_b2s`
- nginx example app



## Usage with script:
1. go to `aks-poc/utils` folder: `cd aks-poc/utils`
2. create ssh-keypair if you don't have already: `ssh-keygen -t rsa -b 4096`
3. Login to your Azure subscription: `az login`
### Create service principal
*Kubernetes needs a service account to manage our Kubernetes cluster*

4. use the script with the `create` argument `./service_principal.sh create` 

*this will create a service principal, save the data to spvars.json and grant contributor role over the subscription to our service principal*
### Create cluster and example nginx
5. use the script with plan flag, and provide the ssh public key file `./create_aks.sh -t plan -ssh id_rsa.pub`

*this will initialize terraform, pass all necessary values from the spvars.json file, and make a plan resource group missing error expected, it is not created yet.*

6. use the script with apply flag, and provide the ssh public key file `./create_aks.sh -t apply -ssh id_rsa.pub`

*this will create the aks and deploy nginx*
7. prepare kubectl with aks credentials:
`az aks get-credentials --resource-group aks-poc-1 --name aks-poc-1`
8. Check the external ip for the example nginx `kubectl get svc` *(also confirm if kubectl working)*
```
kubectl get svc
NAME                TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
kubernetes          ClusterIP      10.0.0.1       <none>         443/TCP        10m
terraform-example   LoadBalancer   10.0.155.214   104.40.3.143   80:31484/TCP   6m43s
```
9. copy the external ip to the browser to check nginx deafult page.

### Clean up
1. use the `create_aks.sh` script with destroy flag, and provide the ssh public key file `./create_aks.sh -t apply -ssh id_rsa.pub`
2. use the `service_principal.sh` script with the `delete` argument `./service_principal.sh delete` 

## Manual deploy

1. go to `aks-poc/terraform/` folder: `cd aks-poc/terraform/utils`
2. create ssh-keypair if you don't have already: `ssh-keygen -t rsa -b 4096` pass it to a variable `SSH_KEY=$(cat id_rsa.pub)`
3. Login to your Azure subscription: `az login`
### Create service principal
4. Create service principal and save details to a file:
`az ad sp create-for-rbac --skip-assignment --name aks-sp -o json > spvars.json`
5. Pass the Azure subscription id to a variable: `SUBSCRIPTION='<SUBSCRIPTION ID HERE>'` *-this is the playground id*
6. Pass the service proncipal id to a variable: `SERVICE_PRINCIPAL=$(cat spvars.json | jq -r '.appId')`
7. Grant contributor role over the subscription to our service principal

    ```
    az role assignment create --assignee $SERVICE_PRINCIPAL \
    --scope "/subscriptions/$SUBSCRIPTION" \
    --role Contributor
    ```

### Create cluster and example nginx
8. to use terraform properly we need 2 more variables, set them up from the `spvars.json`:
```
SERVICE_PRINCIPAL_SECRET=$(cat spvars.json | jq -r '.password')
TENANT_ID=$(cat spvars.json| jq -r '.tenant')
```
9. Initialize terraform `terraform init`
10. run terraform plan:
```
terraform plan -var serviceprinciple_id=$SERVICE_PRINCIPAL \
    -var serviceprinciple_key="$SERVICE_PRINCIPAL_SECRET" \
    -var tenant_id=$TENTANT_ID \
    -var subscription_id=$SUBSCRIPTION \
    -var ssh_key="$SSH_KEY"
```
11. IF everything looks good deploy it with terraform apply *resource group missing error expected, it is not created yet.*
```
terraform apply -var serviceprinciple_id=$SERVICE_PRINCIPAL \
    -var serviceprinciple_key="$SERVICE_PRINCIPAL_SECRET" \
    -var tenant_id=$TENTANT_ID \
    -var subscription_id=$SUBSCRIPTION \
    -var ssh_key="$SSH_KEY"
```
12. Grab AKS config: `az aks get-credentials -n aks-getting-started -g aks-getting-started`
13. Check the external ip for the example nginx `kubectl get svc` *(also confirm if kubectl working)*
```
kubectl get svc
NAME                TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
kubernetes          ClusterIP      10.0.0.1       <none>         443/TCP        10m
terraform-example   LoadBalancer   10.0.155.214   104.40.3.143   80:31484/TCP   6m43s
```

### Clean up
1. terraform will delete everything with `destroy`
```
terraform destroy -var serviceprinciple_id=$SERVICE_PRINCIPAL \
    -var serviceprinciple_key="$SERVICE_PRINCIPAL_SECRET" \
    -var tenant_id=$TENTANT_ID \
    -var subscription_id=$SUBSCRIPTION \
    -var ssh_key="$SSH_KEY"
```
2. Delete the service principal: `az ad sp delete --id $SERVICE_PRINCIPAL`




