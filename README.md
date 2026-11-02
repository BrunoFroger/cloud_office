# cloud_office

procedure d'installation

- installer ubuntu server sur la machine
    - options a selectionner
        - installer openssh_server
    - valeurs utilisées pour la configuration du serveur
        - langage : francais
        - clavier : francais
        - nom :k8smaster
        - nom machine k8smaster
        - nom utilisateur : k8smaster
        - passwd : k8s&master
- qpres installation sur machine cible (serveur)
    - mettre a jour os
        - sudo apt-get update
        - sudo apt-get -y upgrade
    - installer tools
        - sudo apt install net-tools
    - generer cle publique ssh 
        - cd .ssh
        - ssh-keygen -N "" -f id_rsa
- sur github
    - copier la cle ssh publique generee dans les settings
- sur machine cible (serveur)
    - recuperer depot git d'install
        - git clone git@github.com:BrunoFroger/cloud_office.git
        - recuperer @IP : ifconfig | grep "192.168"
- sur machine distante (dev)
    - se connecter au serveur
        - ssh 