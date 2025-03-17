# Vagrant

- Désactiver les symlinks pour les dossiers partagés
```bash
setx VAGRANT_DISABLE_VBOXSYMLINKCREATE 1
export VAGRANT_DISABLE_VBOXSYMLINKCREATE=1
```

# Utilisation de Vagrant
```
vagrant up
vagrant halt
vagrant destroy
vagrant ssh vm1
vagrant ssh vm2
vagrant ssh vm3
vagrant provision vm1
vagrant provision vm2
vagrant provision vm3
```

## Configuration du Pare-feu

### Isolation de VM1 et VM2
- Seules les connexions provenant de VM3 sont autorisées vers VM1 et VM2.
- Les règles suivantes sont appliquées :
  - `ufw allow from 192.168.56.103 to any port 22`
  - `ufw deny from any to 192.168.56.101`
  - `ufw deny from any to 192.168.56.102`

### Configuration de VM3 comme Passerelle
- VM3 est configurée pour rediriger le trafic entre les réseaux public et privé.
- Les commandes suivantes sont exécutées :
  - `sysctl -w net.ipv4.ip_forward=1`
  - `iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE`

### Documentation de la configuration du pare-feu
- La configuration du pare-feu est réalisée à l'aide des règles UFW et des commandes iptables.
- Les règles UFW sont utilisées pour autoriser ou refuser les connexions entrantes et sortantes.
- Les commandes iptables sont utilisées pour configurer le routage et le masquage des adresses IP.