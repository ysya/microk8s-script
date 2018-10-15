#!/usr/bin/env bash

set -e  # exit immediately on error
set -u  # fail on undeclared variables

error() {
    printf '\E[31m'; echo "$@"; printf '\E[0m'
}

# Ensure we run as root ..
if [[ $EUID -ne 0 ]]; then
    error "This script should run using sudo or as the root user"
    exit 1
fi

# VM and K8S steps
snap install microk8s --classic
snap install kubectl --classic
echo "Waiting 15 seconds for kubernetes services.."
sleep 15 # wait for microk8s to come up properly
microk8s.enable dns dashboard
microk8s.enable storage
microk8s.enable gpu

# This gets around an open issue with all-in-one installs
iptables -P FORWARD ACCEPT

## KSONNET
wget https://github.com/ksonnet/ksonnet/releases/download/v0.13.0/ks_0.13.0_linux_amd64.tar.gz -O ksonnet.tar.gz
mkdir -p ksonnet
tar -xvf ksonnet.tar.gz -C ksonnet --strip-components=1
cp ksonnet/ks /usr/local/bin
rm -fr ksonnet

# Remind the user of the next steps
printf "\nBefore running install-kubeflow.sh, please 'export GITHUB_TOKEN=<your token>'\n"