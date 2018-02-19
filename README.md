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

- Modify `./metabase/k8-deployment.yaml`:
  - replace `<INSTANCE_CONNETION_STRING>` with your cloud_sql_proxy [connection string](https://cloud.google.com/sql/docs/mysql/connect-admin-proxy)
  - Update all environment vars prefixed `MB_DB_...` to match your cloud_sql_proxy configuration


- Create `./secrets/cloudsql-gcp-key.json` with GCP service account key

- Create metabase user credentials as text files:
  - `echo -n "metabase" >> secrets/metabase-db-username.txt`
  - `echo -n "password" >> secrets/metabase-db-password.txt`


- Store the SSL/TLS cert and private key as `secrets/tls.crt` and `secrets/tls.key`

### Run

Provided shell script `k8.sh` can create and delete this Kuberentes configuration in the cluster.

- To create secrets, issue `k8.sh secrets`
- Deploy metabase to the cluster with `k8.sh create`
- Delete everything with `k8.sh delete`

### Resources
- [Official Metabase Container Instructions](https://www.metabase.com/docs/latest/operations-guide/running-metabase-on-docker.html)
