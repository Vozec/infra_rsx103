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

## Récupération du mdp peertube

```bash
vagrant ssh vm4 -c "docker compose -f /opt/traefik/docker-compose.yml logs peertube | grep -A1 root"
WARN[0000] /opt/traefik/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
peertube-1  | [www.monentreprise.com:443] 2025-04-24 16:04:29.486 info: Username: root
peertube-1  | [www.monentreprise.com:443] 2025-04-24 16:04:29.486 info: User password: saquserusufejugi
```