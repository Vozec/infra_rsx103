# Vagrant

- Désactiver les symlinks pour les dossiers partagés
```bash
setx VAGRANT_DISABLE_VBOXSYMLINKCREATE 1
```


# Utilisation de Vagrant
```
vagrant up
vagrant halt
vagrant destroy
vagrant ssh vm1
vagrant ssh vm1
vagrant provision vm1
```

# A fix: 
```
PS C:\Users\arthu\Desktop\rsx103> vagrant provision vm1
==> vm1: Running provisioner: shell...
    vm1: Running: inline script
    vm1: Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
    vm1: Hit:2 http://ppa.launchpad.net/ansible/ansible/ubuntu focal InRelease
    vm1: Hit:3 http://archive.ubuntu.com/ubuntu focal-updates InRelease
    vm1: Hit:4 http://security.ubuntu.com/ubuntu focal-security InRelease
    vm1: Hit:5 http://archive.ubuntu.com/ubuntu focal-backports InRelease
    vm1: Reading package lists...
    vm1: Reading package lists...
    vm1: Building dependency tree...
    vm1: Reading state information...
    vm1: software-properties-common is already the newest version (0.99.9.12).
    vm1: 0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
    vm1: Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
    vm1: Hit:2 http://security.ubuntu.com/ubuntu focal-security InRelease
    vm1: Hit:3 http://archive.ubuntu.com/ubuntu focal-updates InRelease
    vm1: Hit:4 http://ppa.launchpad.net/ansible/ansible/ubuntu focal InRelease
    vm1: Hit:5 http://archive.ubuntu.com/ubuntu focal-backports InRelease
    vm1: Reading package lists...
    vm1: Reading package lists...
    vm1: Building dependency tree...
    vm1: Reading state information...
    vm1: ansible is already the newest version (5.10.0-1ppa~focal).
    vm1: 0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
==> vm1: Running provisioner: ansible...
Windows is not officially supported for the Ansible Control Machine.
Please check https://docs.ansible.com/intro_installation.html#control-machine-requirements
Vagrant gathered an unknown Ansible version:


and falls back on the compatibility mode '1.8'.

Alternatively, the compatibility mode can be specified in your Vagrantfile:
https://www.vagrantup.com/docs/provisioning/ansible_common.html#compatibility_mode
    vm1: Running ansible-playbook...
PYTHONUNBUFFERED=1 ANSIBLE_NOCOLOR=true ANSIBLE_HOST_KEY_CHECKING=false ANSIBLE_SSH_ARGS='-o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes -o ControlMaster=auto -o ControlPersist=60s' ansible-playbook --connection=ssh --timeout=30 --limit="vm1" --inventory-file=C:/Users/arthu/Desktop/rsx103/.vagrant/provisioners/ansible/inventory -v configs_ansible/install_docker.yaml
The Ansible software could not be found! Please verify
that Ansible is correctly installed on your host system.

If you haven't installed Ansible yet, please install Ansible
on your host system. Vagrant can't do this for you in a safe and
automated way.
Please check https://docs.ansible.com for more information.
PS C:\Users\arthu\Desktop\rsx103>
```