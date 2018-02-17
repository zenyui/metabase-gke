# Metabase in Google Kubernetes Engine

This repo demonstrates deploying Metabase as a docker container in Google Kubernetes Engine (GKE).

Specifically, this Kkubernetes (k8s) configuration comprises:
- `k8-deployment.yaml`<br>configuration for k8s deployment with metabase docker image and "sidecar" container running GCP cloud sql proxy for database access.

- [docker instructions](https://www.metabase.com/docs/latest/operations-guide/running-metabase-on-docker.html)
