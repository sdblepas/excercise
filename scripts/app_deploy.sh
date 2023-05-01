#!/bin/bash
set -o errexit
set -o pipefail
#set -o xtrace

if ! which helm &> /dev/null; then
    echo "Error: helm command not found. Please install it and try again."
    exit 1
fi

NAMESPACE=$1
if [[ -z $NAMESPACE ]]; then
  echo "Error: NAMESPACE is null"
  exit 1
fi

APP_NAME=$2
if [[ -z $APP_NAME ]]; then
  echo "Error: APP_NAME is null"
  exit 1
fi

DOMAIN=$3
if [[ -z $DOMAIN ]]; then
  echo "Error: DOMAIN is null"
  exit 1
fi

POSTGRES_PASSWORD=$4
if [[ -z $POSTGRES_PASSWORD ]]; then
  echo "Error: POSTGRES_PASSWORD is null"
  exit 1
fi

read -p "Do you want to continue? It will upgrade/install the app (y/n): " response
if [[ $response != "y" ]]; then
    echo "Exiting the script."
    exit 0
fi

helm upgrade --install $APP_NAME ./helm/ --namespace $NAMESPACE -f helm/values.yaml --set app.name=$APP_NAME --set deployment.imageTag=latest --set ingress.hostname=$DOMAIN --set secret.data.DB_URL="postgresql://postgres:${POSTGRES_PASSWORD}@postgres-postgresql:5432/postgres"
