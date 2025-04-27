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
sudo iptables -t nat -A POSTROUTING -o enp0s10 -j MASQUERADE

# Autoriser les connexions déjà établies ou liées
sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# .20 et .30
sudo iptables -A FORWARD -s 192.168.20.10 -d 192.168.30.10 -p tcp --dport 80 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.20.10 -p tcp --dport 80 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.20.10 -d 192.168.30.10 -p tcp --dport 443 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.20.10 -p tcp --dport 443 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.20.40 -p udp --dport 53 -j ACCEPT

# .20 et .40
sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.20.10 -p tcp --dport 80 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.20.10 -p tcp --dport 443 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.20.40 -p udp --dport 53 -j ACCEPT

sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.40.14 -p tcp --dport 9200 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.40.14 -p tcp --dport 8220 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.20.0/24 -p tcp --dport 22 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.20.20 -d 192.168.40.10 -p tcp --dport 389 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.20.20 -d 192.168.40.10.20 -p udp --dport 1194 -j ACCEPT

# .30 et .40
sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.30.10 -p tcp --dport 8080 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.40.10 -p tcp --dport 389 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.40.14 -p tcp --dport 9200 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.40.14 -p tcp --dport 8220 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.30.0/24 -p tcp --dport 22 -j ACCEPT


# (DEBUG) Autoriser ICMP entre tous les réseaux
# sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.30.0/24 -p icmp -j ACCEPT
# sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.20.0/24 -p icmp -j ACCEPT
# sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.40.0/24 -p icmp -j ACCEPT
# sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.20.0/24 -p icmp -j ACCEPT
# sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.40.0/24 -p icmp -j ACCEPT
# sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.30.0/24 -p icmp -j ACCEPT

# Bloquer explicitement tout autre trafic
sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.40.0/24 -j REJECT
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.30.0/24 -j REJECT
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.40.0/24 -j REJECT

# Sauvegarder les règles iptables
sudo mkdir -p /etc/iptables
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'