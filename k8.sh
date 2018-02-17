#!/bin/sh

K8_FOLDER=./kubernetes
K8_SECRETS=./secrets

case "$1" in

  secrets)
    kubectl delete secret metabase-db-cred
    kubectl create secret generic metabase-db-cred \
      --from-file=username=secrets/metabase-db-username.txt \
      --from-file=password=secrets/metabase-db-password.txt

    kubectl delete secret cloudsql-gcp-key
    kubectl create secret generic cloudsql-gcp-key --from-file=cloudsql-gcp-key.json=secrets/cloudsql-gcp-key.json

    kubectl delete secret eataly-io-tls
    kubectl create secret generic eataly-io-tls \
      --from-file=tls.key=$K8_SECRETS/eataly.io.tls.key \
      --from-file=tls.crt=$K8_SECRETS/eataly.io.tls.crt
    ;;

  delete)
    kubectl delete \
      -f $2/k8-deployment.yaml \
      -f $2/k8-service.yaml \
      -f $2/k8-ingress.yaml
    ;;

  create)
    kubectl create \
      -f $2/k8-deployment.yaml \
      -f $2/k8-service.yaml \
      -f $2/k8-ingress.yaml
    ;;

  *)
    echo "Usage: "$1" {secrets|delete|create}"
    exit 1
esac

exit 0
