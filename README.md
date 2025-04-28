# Vagrant

- Désactiver les symlinks pour les dossiers partagés
```bash
setx VAGRANT_DISABLE_VBOXSYMLINKCREATE 1
export VAGRANT_DISABLE_VBOXSYMLINKCREATE=1
```

- ajouter le bon subnet dans la config Vbox:
```bash
echo '* 192.168.0.0/16' > /etc/vbox/networks.conf
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

## Setup de l'infra

```bash
$ vagrant up
$ ansible-playbook -i ./configs_services/inventory.yaml ./configs_ansible/install_elk.yaml
$ vagrant ssh services_dmz -c "docker compose -f /opt/traefik/docker-compose.yml logs peertube | grep -A1 root"
$ vagrant ssh openvpn_dmz -c 'cat /opt/openvpn/openvpn/client-interne.ovpn' > client-interne.ovpn
```
