#!/bin/bash
set -e

# Adresse IP privée de ce nœud Master (détection automatique)
MASTER_IP=$(hostname -I | awk '{print $1}')

echo "=== 1. Initialisation du cluster avec Kubeadm ==="
# Nous définissons le CIDR pour les Pods (requis par la plupart des réseaux comme Cilium/Calico)
sudo kubeadm init \
  --apiserver-advertise-address=$MASTER_IP \
  --pod-network-cidr=10.244.0.0/16

echo "=== 2. Configuration de Kubectl pour votre utilisateur actif ==="
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "=== 3. Installation du plugin réseau (Cilium CNI) ==="
# Récupération de la dernière version stable de Cilium CLI
CILIUM_CLI_VERSION=$(curl -s https://githubusercontent.com)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi

curl -L --fail --remote-name-all https://github.com{CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

# Déploiement de Cilium dans le cluster
cilium install

echo "=========================================================="
echo " Le nœud Master est initialisé avec succès !"
echo " Vérifiez l'état avec : kubectl get nodes"
echo "=========================================================="