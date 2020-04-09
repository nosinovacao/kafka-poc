# Kafka Cluster PoC
This repo contains the PoC for a **Kafka Cluster** running on aks cluster.

## Spinning up the cluster
1.  Create an Azure Service Principal
```bash
## The keyvault is already configured in ZONDEV azure subscription
SERVICE_PRINCIPAL=kafka-poc-sp
SP_PASSWORD=$(az ad sp create-for-rbac --name http://$SERVICE_PRINCIPAL --query password --output tsv)
SP_ID=$(az ad sp show --id http://$SERVICE_PRINCIPAL --query appId --output tsv)

az group create -n <key_vault_resource_group_name> -l northeurope
az group update -n <key_vault_resource_group_name> --set tags.env=dev --set tags.cluster=kafka-poc
az keyvault create -n <key_vault_name> -g <key_vault_resource_group_name> -l northeurope

ssh-keygen -f ~/.ssh/id_rsa_kafka_poc

az keyvault secret set --vault-name <key_vault_name> --name <private_key_name> -f ~/.ssh/id_rsa_kafka_poc.pub > /dev/null
az keyvault secret set --vault-name <key_vault_name> --name <sp_id_name> --value $SP_ID > /dev/null
az keyvault secret set --vault-name <key_vault_name> --name <sp_password_name> --value $SP_PASSWORD > /dev/null
```
2. Create an AKS Cluster
```bash
## Clone this repo to your local envrionment
cd system/
terraform init
terraform validate
terraform plan --out kafkapoc.plan
terraform apply kafkapoc.plan
az aks get-credentials --resource-group <resource_group_name_for_aks_cluster> --name kafka-poc
## If you want k8s dashboard access
az aks get-credentials --resource-group <resource_group_name_for_aks_cluster> --name kafka-poc --admin 
```
3. Install Zookeeper
```bash
kubectl create namespace zookeeper
helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com/
helm repo update
helm install zookeeper --namespace=zookeeper banzaicloud-stable/zookeeper-operator
cat <<EOF | kubectl apply -f -
apiVersion: zookeeper.pravega.io/v1beta1
kind: ZookeeperCluster
metadata:
  name: zookeeper
  namespace: zookeeper
spec:
  replicas: 3
EOF
```
4. Install Kafka Operator & Cluster
```bash
kubectl create namespace kafka
helm install kafka-operator --namespace=kafka banzaicloud-stable/kafka-operator
kubectl create -n kafka -f kafka/00-kafkacluster.yaml
```
5. Install NGINX Ingress Controller
```bash
kubectl create namespace ingress-nginx
helm install nginx --namespace ingress-nginx stable/nginx-ingress --set controller.kind=DaemonSet

## Check if the nginx service has an external IP address
kubectl get service nginx-ingress-controller --namespace ingress-nginx -o wide
```
6. Install Prometheus Operator
```bash
kubectl create namespace monitoring
## Generate the prometheus crd's
./genpromcrds.sh
helm install prometheus --namespace monitoring stable/prometheus-operator -f prometheus/values.yaml --set prometheusOperator.createCustomResource=false
```
7. Install Kafka & Cruise Control ServiceMonitors
```bash
kubectl apply -f kafka/10-kafka-servicemonitor.yaml
kubectl apply -f kafka/20-curisecontrol-servicemonitor.yaml
```
8. Install Kafka AlertRules
```bash
kubectl apply -f kafka/30-kafka-alertrules.yaml
```
9. Install istio
You must have the latest `istioctl` binary on your path.
```bash
istioctl manifest apply -f istio/istioctl-values.yaml

# check that it's working
kubectl -n isito-system get pods
```
10. Start loadtesting with sangrenel
Just apply what's on the `sangrenel.yaml` file.

## Teardown the Cluster
```bash
terraform destroy
```
