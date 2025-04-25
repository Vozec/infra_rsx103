#!/bin/bash

# Activer le forwarding IP
echo "1" | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null

# Réinitialiser les règles
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

# Politique par défaut
sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD DROP

# NAT Masquerade pour chaque interface
sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o enp0s9 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o enp0s10 -j MASQUERADE

# Autoriser connexions établies
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# === Règles .20 -> .30 et .40 : ports 53, 80, 443 uniquement ===
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.30.0/24 -p tcp -m multiport --dports 53,80,443 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.30.0/24 -p udp --dport 53 -j ACCEPT

sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.40.0/24 -p tcp -m multiport --dports 53,80,443 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.40.0/24 -p udp --dport 53 -j ACCEPT

# === Règles .30 <-> .40 : ports 80, 8080, 389 uniquement ===
# .30 -> .40
sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.40.0/24 -p tcp -m multiport --dports 80,8080,389 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.40.0/24 -p udp --dport 389 -j ACCEPT

# .40 -> .30
sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.30.0/24 -p tcp -m multiport --dports 80,8080,389 -j ACCEPT
sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.30.0/24 -p udp --dport 389 -j ACCEPT
