#!/bin/bash

# Activer le routage IP
sudo sysctl -w net.ipv4.ip_forward=1
sudo echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Configurer le NAT pour masquer les adresses priv
sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

# Autoriser uniquement certains port pour aller sur le réseau DMZ (entrée et sorties)
# 999 => port custom pour le VPN admin
ALLOWED=( "80/tcp" "443/tcp" "53/udp" "22/tcp" "999/udp") 

for rule in "${ALLOWED[@]}"; do
    IFS="/" read port proto <<< "$rule"s
    
    # Entrée : DMZ → Interne & DMZ -> Admin
    sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.30.0/24 -p $proto --dport $port -j ACCEPT
    sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.40.0/24 -p $proto --dport $port -j ACCEPT

    # Sortie : Interne → DMZ & Admin -> DMZ
    sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.20.0/24 -p $proto --dport $port -j ACCEPT
    sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.20.0/24 -p $proto --dport $port -j ACCEPT
done

# Bloquer tout le reste entre Interne <-> DMZ
sudo iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.0/24 -j REJECT
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.10.0/24 -j REJECT

# Sauvegarder les règles iptables
sudo mkdir -p /etc/iptables
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'