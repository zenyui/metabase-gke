# Metabase in Google Kubernetes Engine

This repo demonstrates deploying Metabase as a docker container in Google Kubernetes Engine (GKE).

### Kubernetes config

Specifically, this Kubernetes (k8s) configuration comprises:
- `k8-deployment.yaml`<br>[Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) of pod template with metabase docker image and ["sidecar"](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine) container running GCP cloud sql proxy for database access.

- `k8-service.yaml`<br>[NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport) service to open automatic "high port" on each node that the loadbalancer can proxy

- `k8-ingress.yaml`<br>[Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) resource that loadbalances traffic and terminates SSL/TLS. This configuration utilizes the ["gce" loadbalancer class](https://github.com/kubernetes/ingress-gce)

### Preparation

- Download the GKE credentials:
```sh
gcloud container clusters get-credentials <cluster_name>
```

- Apply GKE credentials as `kubectl` [context](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#context):
  - List available contexts:
  ```sh
  kubectl config get-contexts
  ```
  - Set context:
  ```sh
  kubectl config use-context <context>
  ```

- Reserve a GCP [static ip](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address):
```
gcloud compute addresses create metabase-ip --global
```

- Create a [Cloud SQL for MySQL instance](https://cloud.google.com/sql/docs/mysql/create-instance)
```
gcloud sql instances create metabase-db --tier=<tier> --region=<regeion>
```

- Create a [service account](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine?hl=ja#2_create_a_service_account)

- Create a [proxyuser](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine?hl=ja#3_create_the_proxy_user)
```
gcloud sql users create proxyuser cloudsqlproxy~% --instance=metabase-db --password=<password>
```

- Get the [instance connection name](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine?hl=ja#4_get_your_instance_connection_name)

- Create a database via [Cloud SQL Proxy](https://cloud.google.com/sql/docs/mysql/connect-docker)
```
mysql -u proxyuser -h 127.0.0.1 -P 3306 -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 101786
Server version: 5.7.14-google (Google)

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> create database metabase;
```

- [Install Helm](https://github.com/ahmetb/gke-letsencrypt/blob/master/10-install-helm.md)

- [Install cert-manager](https://github.com/ahmetb/gke-letsencrypt/blob/master/20-install-cert-manager.md)

- [Set up Let‘s Encrypt](https://github.com/ahmetb/gke-letsencrypt/blob/master/30-setup-letsencrypt.md)

- Get a [certificate](https://github.com/ahmetb/gke-letsencrypt/blob/master/50-get-a-certificate.md)
```
kubectl apply -f k8-certificate.yaml
```

- Modify `./metabase/k8-deployment.yaml`:
  - replace `<INSTANCE_CONNETION_STRING>` with your cloud_sql_proxy [connection string](https://cloud.google.com/sql/docs/mysql/connect-admin-proxy)
  - Update all environment vars prefixed `MB_DB_...` to match your cloud_sql_proxy configuration

- Create `./secrets/cloudsql-gcp-key.json` with GCP service account key

- Create metabase user credentials as text files:
```sh
echo -n "proxyuser" > secrets/metabase-db-username.txt
echo -n <password> > secrets/metabase-db-password.txt
```

### Run

Provided shell script `k8.sh` can create and delete this Kuberentes configuration in the cluster.

- To create secrets, issue `k8.sh secrets`
- Deploy metabase to the cluster with `k8.sh create`
- Delete everything with `k8.sh delete`

### Resources
- [Official Metabase Container Instructions](https://www.metabase.com/docs/latest/operations-guide/running-metabase-on-docker.html)
