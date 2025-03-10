# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/focal64" # Utilisation d'Ubuntu 20.04 LTS comme base
  config.vm.provision "shell", inline: <<-SHELL
      apt-get update --fix-missing
      apt-get install -y software-properties-common
      apt-add-repository --yes --update ppa:ansible/ansible
      apt-get install -y ansible
    SHELL

    # VM1 – Monitoring & Supervision (Prometheus & Grafana)
    config.vm.define "vm1" do |vm1|
      vm1.vm.hostname = "monitoring"
      vm1.vm.network "private_network", ip: "192.168.10.101"
      # vm1.vm.network "private_network", ip: "fd00:20::101", netmask: "64"
      vm1.vm.provider "virtualbox" do |vb|
        vb.memory = "4096"
        vb.cpus = 2
      end
      vm1.vm.provision "ansible" do |ansible|
        ansible.playbook = "configs_ansible/install_docker.yaml"
        ansible.verbose = "v"
      end
    end
  
    # # VM2 – Reverse Proxy (Traefik)
    # config.vm.define "vm2" do |vm2|
    #   vm2.vm.hostname = "reverse-proxy"
    #   vm2.vm.network "private_network", ip: "192.168.10.102"
    #   vm2.vm.network "private_network", ip: "fd00:20::102", netmask: "64"
    #   vm2.vm.provider "virtualbox" do |vb|
    #     vb.memory = "1024"
    #     vb.cpus = 1
    #   end
    # end
  
    # # VM3 – Firewall (PFsense)
    # config.vm.define "vm3" do |vm3|
    #   vm3.vm.hostname = "firewall"
    #   vm3.vm.network "private_network", ip: "192.168.10.103"
    #   vm3.vm.network "private_network", ip: "192.168.30.103"
    #   vm3.vm.network "private_network", ip: "fd00:20::103", netmask: "64"
    #   vm3.vm.provider "virtualbox" do |vb|
    #     vb.memory = "2048" # Plus de mémoire pour le firewall
    #     vb.cpus = 2
    #   end
    # end
  
    # # VM4 – Service Exposé (Serveur Web Nginx)
    # config.vm.define "vm4" do |vm4|
    #   vm4.vm.hostname = "web-server"
    #   vm4.vm.network "private_network", ip: "192.168.30.104"
    #   vm4.vm.network "private_network", ip: "fd00:20::104", netmask: "64"
    #   vm4.vm.provider "virtualbox" do |vb|
    #     vb.memory = "1024"
    #     vb.cpus = 1
    #   end
    # end
  
    # # VM5 – Machine de gestion SSH
    # config.vm.define "vm5" do |vm5|
    #   vm5.vm.hostname = "ssh-gateway"
    #   vm5.vm.network "private_network", ip: "192.168.10.105"
    #   vm5.vm.network "private_network", ip: "fd00:20::105", netmask: "64"
    #   vm5.vm.provider "virtualbox" do |vb|
    #     vb.memory = "512"
    #     vb.cpus = 1
    #   end
  
    #   # Provisionnement pour installer SSH et configurer l'accès aux autres machines
    #   vm5.vm.provision "shell", inline: <<-SHELL
    #     apt-get update
    #     apt-get install -y openssh-client
    #     echo "Configuration SSH terminée."
    #   SHELL
    # end
    
  end