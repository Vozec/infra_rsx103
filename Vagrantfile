Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  # Services - VM2 (reverse-proxy) - Réseau 1
  config.vm.define "vm2" do |vm2|
    vm2.vm.hostname = "reverse-proxy"
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
      ansible.playbook = "configs_ansible/install_nginx.yaml"
      ansible.verbose = "v"
    end
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

      # Autoriser uniquement VM4 à passer par VM3 pour aller sur le réseau privé (port 80 et 22)
      sudo iptables -F
      sudo iptables -A FORWARD -s 192.168.40.104 -d 192.168.30.0/24 -p tcp --dport 80 -j ACCEPT
      sudo iptables -A FORWARD -s 192.168.40.104 -d 192.168.30.0/24 -p tcp --dport 22 -j ACCEPT
      sudo iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.30.0/24 -j REJECT
      sudo iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.40.0/24 -j ACCEPT

      # Sauvegarder les règles iptables
      sudo mkdir -p /etc/iptables
      sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
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
