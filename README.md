# Metabase in Google Kubernetes Engine

This repo demonstrates deploying Metabase as a docker container in Google Kubernetes Engine (GKE).

Specifically, this Kkubernetes (k8s) configuration comprises:
- `k8-deployment.yaml`<br>Configuration for k8s deployment with metabase docker image and "sidecar" container running GCP cloud sql proxy for database access.

- `k8-service.yaml`<br>NodePort service to open automatic "high port" on each node that the loadbalancer can proxy

- `k8-ingress.yaml`<br>Ingress resource that loadbalances traffic and terminates SSL/TLS

Resources:
- [Official Metabase Container Instructions](https://www.metabase.com/docs/latest/operations-guide/running-metabase-on-docker.html)
