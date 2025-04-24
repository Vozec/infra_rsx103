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

# Autoriser le trafic entre les sous-réseaux internes (sans réécrire l'IP source)
sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.20.0/24 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.40.0/24 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.30.0/24 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.40.0/24 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.30.0/24 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.20.0/24 -j ACCEPT

# Ajouter des règles pour marquer les connexions
sudo iptables -t mangle -A FORWARD -m state --state NEW -j CONNMARK --set-mark 1
sudo iptables -t mangle -A FORWARD -m connmark --mark 1 -j ACCEPT

# Journaliser le trafic bloqué
sudo iptables -A FORWARD -j LOG --log-prefix "Traffic Blocked: " --log-level 4

# Autoriser les connexions déjà établies ou liées
sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Autoriser uniquement certains ports entre les sous-réseaux spécifiques (exemple pour la DMZ et l'Interne)
ALLOWED=( "80/tcp" "8080/tcp" "443/tcp" "53/udp" "389/tcp")

for rule in "${ALLOWED[@]}"; do
    IFS="/" read port proto <<< "$rule"

    # Entrée : DMZ → Interne & DMZ → Admin
    sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.30.0/24 -p $proto --dport $port -j ACCEPT
    sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.40.0/24 -p $proto --dport $port -j ACCEPT

    # Sortie : Interne → DMZ & Admin → DMZ
    sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.20.0/24 -p $proto --dport $port -j ACCEPT
    sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.20.0/24 -p $proto --dport $port -j ACCEPT
done

# Autoriser uniquement le VPN (port custom 999) à aller de public à Admin
sudo iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.40.0/24 -p udp --dport 999 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.40.0/24 -p udp --dport 999 -j ACCEPT

# Bloquer explicitement tout autre trafic entre réseaux
sudo iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.30.0/24 -j REJECT
sudo iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.40.0/24 -j REJECT
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.30.0/24 -j REJECT
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.40.0/24 -j REJECT

# Sauvegarder les règles iptables
sudo mkdir -p /etc/iptables
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
