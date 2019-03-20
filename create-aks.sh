#!/bin/sh
set -e; # first task must finish before executing task 2

printf -- 'Before running this scpript be aware:\n';
printf -- '???';
printf -- '\n';

read -r -p "Do you want to proceed? (y/n): " response

if [[ $response != [yY] ]]; then exit 0; fi;

dnsPrefix='myk8s'
k8s_name='k8s2'
location='eastus'
namespace='kube-system'
nginx_ingress_name='nginx-ingress-kube-system'
resourceGroupName='k8s2'
servicePrincipalClientId=''
servicePrincipalClientSecret=''
templateFilePath='./template/template.json'
parametersFilePath='./template/parameter.json'

#set -x
az group create -g $resourceGroupName -l $location && \
az group deployment create --name "$k8s_name" --resource-group "$resourceGroupName" \
	--template-file "$templateFilePath" --parameters "$parametersFilePath"
az aks get-credentials --name "$k8s_name" --resource-group "$resourceGroupName" --overwrite-existing
helm init
kubectl create serviceaccount --namespace $namespace tiller && \
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller && \
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

#check when tiller is ready
DONE=0
while [ $DONE -eq 0 ]; do
   sleep 7;
   tiller="`kubectl get pods -n kube-system | grep tiller-deploy | awk '{ print $3 }'`"
   echo $tiller
   if [ "$tiller" = "Running"  ]; then echo tiller ok && DONE=1 ; fi;
done

#helm init --wait --tiller-namespace "$namespace"
helm install stable/nginx-ingress --namespace "$namespace" --set controller.replicaCount=2 --name kube

#check when ingress is ready
DONE=0
while [ $DONE -eq 0 ]; do
   ingress="`kubectl get service -l app=nginx-ingress --namespace "$namespace" | grep kube-nginx-ingress-controller | awk '{ print $4; }'`"
   echo $ingress
   if [ "$ingress" != "<pending>" ]; then lb_ip=$ingress && DONE=1 ; fi;
   sleep 5;
done

PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$lb_ip')].[id]" --output tsv)
az network public-ip update --ids $PUBLICIPID --dns-name $dnsPrefix

