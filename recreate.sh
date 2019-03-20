kubectl delete serviceaccount tiller --namespace kube-system
kubectl delete clusterrolebinding tiller-cluster-rule
helm reset --force



helm init
kubectl create serviceaccount --namespace kube-system tiller && \
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller && \
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

#check when tiller is ready
DONE=0
while [ $DONE -eq 0 ]; do
   sleep 5;
   tiller="`kubectl get pods -n kube-system | grep tiller-deploy | awk '{ print $3 }'`"
   if [[ $tiller -eq 'Running'  ]]; then DONE=1 ; fi;
done

#helm init --wait --tiller-namespace "$namespace"
helm install stable/nginx-ingress --namespace "$namespace" --set controller.replicaCount=2 --name kube

#check when ingress is ready
DONE=0
while [ $DONE -eq 0 ]; do
   ingress="`kubectl get service -l app=nginx-ingress --namespace "$namespace" | grep kube-nginx-ingress-controller | awk '{ print $4; }'`"
   if [[ $ingress != '<pending>' ]]; then lb_ip=$ingress && DONE=1 ; fi;
   sleep 5;
done

PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$lb_ip')].[id]" --output tsv)
az network public-ip update --ids $PUBLICIPID --dns-name $dnsPrefix
kubectl delete serviceaccount tiller --namespace kube-system
