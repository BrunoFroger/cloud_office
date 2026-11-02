#!/bin/bash

# Interrompre le script en cas d'erreur
set -e

echo "===================================================="
echo " Activation des modules du noyau et configuration réseau"
echo "===================================================="
# Désactivation de la mémoire SWAP (requis par Kubernetes)
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Chargement des modules du noyau requis
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configuration des paramètres sysctl pour le réseau Kubernetes
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Appliquer les modifications sysctl
sudo sysctl --system

echo "===================================================="
echo " Installation du runtime : Containerd"
echo "===================================================="
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Ajout de la clé GPG officielle de Docker (pour containerd)
sudo mkdir -p /etc/apt/keyrings
echo "================= curl docker.gpg ================="
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# https://download.docker.com/linux/ubuntu/gpg
# Ajout du dépôt Docker
echo "================= ajout au depot docker ==============="
#echo \
#  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://docker.com \
#  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "Ajout du dépôt officiel Docker dans les sources APT..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Installation de containerd
echo "================= installation de containerd  ==============="
sudo apt-get update
sudo apt-get install -y containerd.io

# Configuration par défaut de containerd avec SystemdCgroup activé
echo "================= configuration de containerd  ==============="
sudo mkdir -p /etc/containerd
echo "================= mise a jour config.toml ===================="
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Redémarrage de containerd pour appliquer la configuration
echo "================= redemarrage containerd ====================="
sudo systemctl restart containerd
sudo systemctl enable containerd

echo "===================================================="
echo " Installation de Kubeadm, Kubelet et Kubectl (v1.31)"
echo "===================================================="
# Ajout de la clé GPG pour les paquets Kubernetes
K8S_VERSION=v1.37
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Ajout du dépôt de paquets Kubernetes v1.31
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Installation des paquets
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# Blocage des versions pour éviter les mises à jour automatiques involontaires
sudo apt-mark hold kubelet kubeadm kubectl

echo "===================================================="
echo " Installation terminée avec succès !"
echo "===================================================="
echo "Pour initialiser le cluster (sur le Control Plane uniquement) :"
echo "👉 sudo kubeadm init --pod-network-cidr=10.244.0.0/16"
