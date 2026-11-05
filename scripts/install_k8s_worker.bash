#!/bin/bash

# Interrompre le script en cas d'erreur
set -e


echo "===================================================="
echo " Installation d'un worker  "
echo "===================================================="
sudo kubeadm join <IP_DU_MASTER>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
