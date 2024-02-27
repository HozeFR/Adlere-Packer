## Pré-requis
Exécution de plusieurs commandes:

    export VCENTER_PACKER_PASSWORD=YourVCenterPassword
    export SSH_USER=YourVCenterAccountUsername
    export SSH_PASSWORD=YourVCenterAccountPassword

Puis initialisation de Packer:

    packer init
    packer validate
    packer build MonFichierTemplate
