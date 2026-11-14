#!/bin/bash

# Interrompre le script en cas d'erreur
set -e

Mettre à jour le système :
sudo apt update && sudo apt upgrade -y

Installer le paquet Snap Nextcloud :
sudo snap install nextcloud

Configurer un compte administrateur en ligne de commande :
sudo nextcloud.manual-install [nom_utilisateur] [mot_de_passe]

Activer le HTTPS (optionnel mais conseillé via Let's Encrypt) :
sudo nextcloud.enable-https lets-encrypt

initialisation login/mot de passe (admin/std&nextcloud)