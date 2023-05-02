#!/bin/bash
set -o errexit
set -o pipefail
#set -o xtrace

if ! which wget &> /dev/null; then
    echo "Error: wget command not found. Please install it and try again."
    exit 1
fi
if ! which jq &> /dev/null; then
    echo "Error: jq command not found. Please install it and try again."
    exit 1
fi
if ! which docker &> /dev/null; then
    echo "Error: docker command not found. Please install it and try again."
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
if ! which nc &> /dev/null; then
    echo "Error: nc command not found. Please install it and try again."
    exit 1
fi

CLUSTER_NAME=$1
if [[ -z $CLUSTER_NAME ]]; then
  echo "Error: CLUSTER_NAME is null"
  exit 1
fi

read -p "Do you want to continue? It will destroy the cluster $CLUSTER_NAME if there is (y/n): " response
if [[ $response != "y" ]]; then
    echo "Exiting the script."
    exit 0
fi

k3d cluster delete ${CLUSTER_NAME}
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
k3d cluster create ${CLUSTER_NAME} -p "80:80@loadbalancer" --agents 2
kubectl get nodes
