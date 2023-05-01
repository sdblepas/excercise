#!/bin/bash
set -o errexit
set -o pipefail
#set -o xtrace

if ! which jq &> /dev/null; then
    echo "Error: jq command not found. Please install it and try again."
    exit 1
fi
if ! which kubectl &> /dev/null; then
    echo "Error: kubectl command not found. Please install it and try again."
    exit 1
fi
if ! which helm &> /dev/null; then
    echo "Error: helm command not found. Please install it and try again."
    exit 1
fi

NAMESPACE=$1
if [[ -z $NAMESPACE ]]; then
  echo "Error: NAMESPACE is null"
  exit 1
fi

POSTGRES_PASSWORD=$2
if [[ -z $POSTGRES_PASSWORD ]]; then
  echo "Error: POSTGRES_PASSWORD is null"
  exit 1
fi

read -p "Do you want to continue? It will delete the existing Postgres data if there is (y/n): " response
if [[ $response != "y" ]]; then
    echo "Exiting the script."
    exit 0
fi

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm delete postgres -n $NAMESPACE || true
VOLUME=`kubectl get pvc data-postgres-postgresql-0 -o json -n $NAMESPACE --ignore-not-found=true | jq -rc '.spec.volumeName // empty'`
kubectl delete pvc -n $NAMESPACE data-postgres-postgresql-0 --ignore-not-found=true
if [[ ! -z $VOLUME ]]; then
  echo "Volume=$VOLUME"
  kubectl delete pv $VOLUME --ignore-not-found=true
fi
kubectl get pv,pvc
helm upgrade --install postgres bitnami/postgresql --namespace $NAMESPACE -f postgres/values.yaml --set global.postgresql.auth.database=postgres --set global.postgresql.auth.postgresPassword=$POSTGRES_PASSWORD

