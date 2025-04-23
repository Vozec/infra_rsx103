Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  # DNS - VM0 - Réseau 1 & 2 
  config.vm.define "vm0" do |vm0|
    vm0.vm.hostname = "dns"
    vm0.vm.network "private_network", ip: "192.168.30.100"  # Réseau privé
    vm0.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
    vm0.vm.provision "shell", inline: <<-SHELL
      # Mise à jour des paquets et installation de dnsmasq
      sudo apt-get update -y
      sudo DEBIAN_FRONTEND=noninteractive apt-get install -y dnsmasq

      # Désactivation de systemd-resolved, car nous allons utiliser dnsmasq
      sudo systemctl stop systemd-resolved
      sudo systemctl disable systemd-resolved

      # Ajout des entrées locales dans la configuration de dnsmasq
      sudo bash -c 'echo "address=/prometheus.monentreprise.local/192.168.30.101" >> /etc/dnsmasq.conf'
      sudo bash -c 'echo "address=/grafana.monentreprise.local/192.168.30.101" >> /etc/dnsmasq.conf'
      sudo bash -c 'echo "address=/alertmanager.monentreprise.local/192.168.30.101" >> /etc/dnsmasq.conf'

      sudo bash -c 'echo "address=/www.monentreprise.com/192.168.30.102" >> /etc/dnsmasq.conf'
      sudo bash -c 'echo "address=/traefik.monentreprise.com/192.168.30.102" >> /etc/dnsmasq.conf'
      sudo bash -c 'echo "address=/authelia.monentreprise.com/192.168.30.102" >> /etc/dnsmasq.conf'
      
      sudo bash -c 'echo "address=/firewall.local/192.168.30.103" >> /etc/dnsmasq.conf'

      # Ajout de 8.8.8.8 comme serveur DNS de secours
      sudo bash -c 'echo "server=8.8.8.8" >> /etc/dnsmasq.conf'

      # Redémarrage de dnsmasq pour appliquer les modifications
      sudo systemctl restart dnsmasq
    SHELL
  end

  # Monitoring - VM1 - Réseau 1
  config.vm.define "vm1" do |vm1|
    vm1.vm.hostname = "monitoring"
    vm1.vm.network "private_network", ip: "192.168.30.101"  # Réseau privé
    vm1.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
    end
    vm1.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_docker.yaml"
      ansible.verbose = "v"
    end    
    vm1.vm.provision "ansible" do |ansible|
      ansible.config_file = "ansible.cfg"
      ansible.playbook = "configs_ansible/install_monitoring.yaml"
      ansible.verbose = "v"
    end
    vm1.vm.provision "shell", inline: <<-SHELL
      # Installer Nginx
      sudo apt-get update -y
      sudo apt-get install -y nginx net-tools

      # Copier la configuration Nginx
      sudo cp /vagrant/configs_services/monitoring.conf /etc/nginx/sites-available/monitoring

      # Activer la configuration Nginx
      sudo ln -s /etc/nginx/sites-available/monitoring /etc/nginx/sites-enabled/
      sudo rm /etc/nginx/sites-enabled/default
      sudo systemctl restart nginx

      # Set custom DNS
      echo "nameserver 192.168.30.100" | sudo tee /etc/resolv.conf > /dev/null
    SHELL
  end

  # Services - VM2 - Réseau 1
  config.vm.define "vm2" do |vm2|
    vm2.vm.hostname = "services"
    vm2.vm.network "private_network", ip: "192.168.30.102"  # Réseau privé
    vm2.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
    end
    vm2.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_docker.yaml"
      ansible.verbose = "v"
    end
    vm2.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_services.yaml"
      ansible.verbose = "v"
    end
    vm2.vm.provision "shell", inline: <<-SHELL
      echo "nameserver 192.168.30.100" | sudo tee /etc/resolv.conf > /dev/null
    SHELL
  end

  # Firewall and Routing - VM3 (Ubuntu agissant comme routeur) - VM3 fait office de passerelle
  config.vm.define "vm3" do |vm3|
    vm3.vm.hostname = "router"
    vm3.vm.box = "ubuntu/focal64"
    vm3.vm.network "private_network", ip: "192.168.30.103"  # Réseau privé
    vm3.vm.network "private_network", ip: "192.168.40.103"  # Réseau publique
    vm3.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
    end
    vm3.vm.provision "shell", inline: <<-SHELL
      # Activer le routage IP
      sudo sysctl -w net.ipv4.ip_forward=1
      sudo echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
      sudo sysctl -p

      # Configurer le NAT pour masquer les adresses priv
      sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

      # Autoriser uniquement VM4 à passer par VM3 pour aller sur le réseau privé
      sudo iptables -F
      sudo iptables -A FORWARD -s 192.168.40.104 -d 192.168.30.0/24 -p tcp --dport 80 -j ACCEPT
      sudo iptables -A FORWARD -s 192.168.40.104 -d 192.168.30.0/24 -p tcp --dport 443 -j ACCEPT
      sudo iptables -A FORWARD -s 192.168.40.104 -d 192.168.30.0/24 -p tcp --dport 53 -j ACCEPT
      sudo iptables -A FORWARD -s 192.168.40.104 -d 192.168.30.0/24 -p tcp --dport 22 -j ACCEPT
      sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.30.0/24 -j REJECT
      sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.40.0/24 -j ACCEPT

      # Sauvegarder les règles iptables
      sudo mkdir -p /etc/iptables
      sudo sh -c 'iptables-save > /etc/iptables/rules.v4'

      # Setup custom DNS
      echo "nameserver 192.168.30.100" | sudo tee /etc/resolv.conf > /dev/null
    SHELL
  end

  # SSH Gateway - VM4 - Réseau 2
  config.vm.define "vm4" do |vm4|
    vm4.vm.hostname = "ssh-gateway"
    vm4.vm.network "private_network", ip: "192.168.40.104"  # Réseau publique
    vm4.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
    end
    vm4.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update -y --fix-missing
      sudo apt-get install -y curl nmap
      sudo ip route add 192.168.30.0/24 via 192.168.40.103

      # Set custom DNS
      echo "nameserver 192.168.30.100" | sudo tee /etc/resolv.conf > /dev/null
    SHELL
  end

  # Attacker - VM5
  config.vm.define "vm5" do |vm5|
    vm5.vm.hostname = "attacker"
    vm5.vm.network "private_network", ip: "192.168.40.105"  # Réseau publique
    vm5.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
    end
    vm5.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update -y --fix-missing
      sudo apt-get install -y curl nmap
      sudo ip route add 192.168.30.0/24 via 192.168.40.103
    SHELL
  end

end
