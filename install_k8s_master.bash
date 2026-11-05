#!/bin/bash

# Interrompre le script en cas d'erreur
set -e


echo "===================================================="
echo " Installation du master (control plane) "
echo "===================================================="
echo "Pour initialiser le cluster (sur le Control Plane uniquement) :"
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

echo "copier dans un fichier la dernière ligne d'excution de ce script mentionnant la commande kubadm join a executer sur les workers"
