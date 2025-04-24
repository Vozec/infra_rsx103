#!/bin/bash

# Activer le routage IP (immédiat + persistant)
sudo sysctl -w net.ipv4.ip_forward=1
sudo grep -q '^net.ipv4.ip_forward=1' /etc/sysctl.conf || echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf > /dev/null
sudo sysctl -p > /dev/null

# Nettoyage des règles existantes
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -X
sudo iptables -t nat -X

# Politique par défaut : DROP sur FORWARD (sécurisé)
sudo iptables -P FORWARD DROP

# NAT : masquerading pour la sortie vers enp0s8 & enp0s9
sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o enp0s9 -j MASQUERADE

# Autoriser les connexions déjà établies ou liées
sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Autoriser uniquement certains ports entre réseau Public (192.168.10.0/24) et DMZ (192.168.20.0/24)
ALLOWED=( "80/tcp" "443/tcp" "53/udp" "9091/tcp")

for rule in "${ALLOWED[@]}"; do
    IFS="/" read port proto <<< "$rule"

    # Entrée : DMZ → Interne & DMZ -> Admin
    sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.30.0/24 -p $proto --dport $port -j ACCEPT
    sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.40.0/24 -p $proto --dport $port -j ACCEPT

    # Sortie : Interne → DMZ & Admin -> DMZ
    sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.20.0/24 -p $proto --dport $port -j ACCEPT
    sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.20.0/24 -p $proto --dport $port -j ACCEPT
done

# Autorise uniquement le VPN (port custom 999) à aller de public à Admin
sudo iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.40.0/24 -p udp --dport 999 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.40.0/24 -p udp --dport 999 -j ACCEPT

# Bloquer explicitement tout autre trafic
sudo iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.30.0/24 -j REJECT
sudo iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.40.0/24 -j REJECT
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.30.0/24 -j REJECT
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.40.0/24 -j REJECT

# Sauvegarder les règles iptables
sudo mkdir -p /etc/iptables
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'