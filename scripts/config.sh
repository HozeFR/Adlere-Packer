#!/bin/bash


# Ajout de la clé SSh
mkdir -p /home/${SSH_USER}/.ssh
chmod 700 /home/${SSH_USER}/.ssh
echo ${PUB_KEY_PATH} > /home/${SSH_USER}/.ssh/authorized_keys
chmod 600 /home/${SSH_USER}/.ssh/authorized_keys
chown -R ${SSH_USER}:${SSH_USER} /home/${SSH_USER}/.ssh
