#!/bin/bash

sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y dnsmasq

# Désactivation de systemd-resolved, car on utilise dnsmasq
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

# Ajout des entrées locales dans la configuration de dnsmasq
sudo bash -c 'echo "address=/prometheus.monentreprise.com/192.168.20.10" >> /etc/dnsmasq.conf'
sudo bash -c 'echo "address=/grafana.monentreprise.com/192.168.20.10" >> /etc/dnsmasq.conf'
sudo bash -c 'echo "address=/alertmanager.monentreprise.com/192.168.20.10" >> /etc/dnsmasq.conf'

sudo bash -c 'echo "address=/vpn-admin.monentreprise.com/192.168.40.10" >> /etc/dnsmasq.conf'
sudo bash -c 'echo "address=/lldap.monentreprise.com/192.168.20.10" >> /etc/dnsmasq.conf'

sudo bash -c 'echo "address=/monentreprise.com/192.168.20.10" >> /etc/dnsmasq.conf'
sudo bash -c 'echo "address=/traefik.monentreprise.com/192.168.20.10" >> /etc/dnsmasq.conf'
sudo bash -c 'echo "address=/vpn-internal.monentreprise.com/192.168.20.20" >> /etc/dnsmasq.conf'

sudo bash -c 'echo "address=/authelia.monentreprise.com/192.168.20.10" >> /etc/dnsmasq.conf'
sudo bash -c 'echo "address=/gitlab.monentreprise.com/192.168.20.10" >> /etc/dnsmasq.conf'

# Ajout de 8.8.8.8 comme serveur DNS de fallback
sudo bash -c 'echo "server=8.8.8.8" >> /etc/dnsmasq.conf'

# Redémarrage de dnsmasq pour appliquer les modifications
sudo systemctl restart dnsmasq

