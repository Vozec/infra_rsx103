#!/bin/bash

# Activer le routage IP (immédiat + persistant)
sudo sysctl -w net.ipv4.ip_forward=1
sudo grep -q '^net.ipv4.ip_forward=1' /etc/sysctl.conf || echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf > /dev/null
sudo sysctl -p > /dev/null

# Vider les règles existantes pour partir propre
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

sudo iptables -A FORWARD -i enp0s8 -o enp0s9 -j ACCEPT
sudo iptables -A FORWARD -i enp0s9 -o enp0s8 -j ACCEPT

sudo iptables -A FORWARD -i enp0s8 -o enp0s10 -j ACCEPT
sudo iptables -A FORWARD -i enp0s10 -o enp0s8 -j ACCEPT

sudo iptables -A FORWARD -i enp0s9 -o enp0s10 -j ACCEPT
sudo iptables -A FORWARD -i enp0s10 -o enp0s9 -j ACCEPT

sudo mkdir -p /etc/iptables
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'