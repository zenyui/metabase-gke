# Metabase in Google Kubernetes Engine

This repo demonstrates deploying Metabase as a docker container in Google Kubernetes Engine (GKE).

### Kubernetes config

Specifically, this Kubernetes (k8s) configuration comprises:
- `k8-deployment.yaml`<br>[Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) of pod template with metabase docker image and ["sidecar"](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine) container running GCP cloud sql proxy for database access.

- `k8-service.yaml`<br>[NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport) service to open automatic "high port" on each node that the loadbalancer can proxy

- `k8-ingress.yaml`<br>[Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) resource that loadbalances traffic and terminates SSL/TLS. This configuration utilizes the ["gce" loadbalancer class](https://github.com/kubernetes/ingress-gce)

### Preparation:

- Reserve a GCP [static ip](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address)<br>
`gcloud compute addresses create metabase-ip --global`

- Modify `./metabase/k8-deployment.yaml`:
  - replace `<<INSTANCE_CONNETION_STRING>` with your cloud_sql_proxy [connection string](https://cloud.google.com/sql/docs/mysql/connect-admin-proxy)
  - Update all environment vars prefixed `MB_DB_...` to match your cloud_sql_proxy configuration


- Create `./secrets/cloudsql-gcp-key.json` with GCP service account key

- Create metabase user credentials as text files:
  - `echo -n "metabase" >> secrets/metabase-db-username.txt`
  - `echo -n "password" >> secrets/metabase-db-password.txt`


- Store the SSL/TLS cert and private key as `secrets/tls.crt` and `secrets/tls.key`

Resources:
- [Official Metabase Container Instructions](https://www.metabase.com/docs/latest/operations-guide/running-metabase-on-docker.html)
