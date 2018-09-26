#!/bin/sh

K8_FOLDER=./kubernetes
K8_SECRETS=./secrets

case "$1" in

  secrets)
    kubectl delete secret metabase-db-cred
    kubectl create secret generic metabase-db-cred \
      --from-file=username=$K8_SECRETS/metabase-db-username.txt \
      --from-file=password=$K8_SECRETS/metabase-db-password.txt

    kubectl delete secret cloudsql-gcp-key
    kubectl create secret generic cloudsql-gcp-key \
      --from-file=cloudsql-gcp-key.json=secrets/cloudsql-gcp-key.json
    ;;

  delete)
    kubectl delete \
      -f metabase/k8-deployment.yaml \
      -f metabase/k8-service.yaml \
      -f metabase/k8-ingress.yaml
    ;;

  create)
    kubectl create \
      -f metabase/k8-deployment.yaml \
      -f metabase/k8-service.yaml \
      -f metabase/k8-ingress.yaml
    ;;

  *)
    echo "Usage: "$1" {secrets|delete|create}"
    exit 1
esac

exit 0
