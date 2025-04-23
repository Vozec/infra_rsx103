#!/bin/bash

# Activer le routage IP
sudo sysctl -w net.ipv4.ip_forward=1
sudo echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Configurer le NAT pour masquer les adresses priv
sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

# Autoriser uniquement certains port pour aller sur le réseau DMZ (entrée et sorties)
ALLOWED=( "80/tcp" "443/tcp" "53/udp" "1194/udp" "22/tcp")

for rule in "${ALLOWED[@]}"; do
    IFS="/" read port proto <<< "$rule"

    # Entrée : Public → DMZ
    sudo iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.0/24 -p $proto --dport $port -j ACCEPT
    # Sortie : DMZ → Public
    sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.10.0/24 -p $proto --dport $port -j ACCEPT
done

# Bloquer tout le reste entre Public <-> DMZ
sudo iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.0/24 -j REJECT
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.10.0/24 -j REJECT

# Ajouter une route pour aller sur le réseau admin directement
sudo ip route add 192.168.40.0/24 via 192.168.20.30

# Autorise uniquement le VPN (port 999) à aller de public à Admin
sudo iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.40.0/24 -p udp --dport 999 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.40.0/24 -j REJECT

# Sauvegarder les règles iptables
sudo mkdir -p /etc/iptables
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'