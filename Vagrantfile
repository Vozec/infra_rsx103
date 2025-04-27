Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  # VM6 - Machine administrateur
  config.vm.define "ldap_admin" do |vm6|
    vm6.vm.hostname = "admin"
    vm6.vm.network "private_network", ip: "192.168.40.10"
    vm6.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
    vm6.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_docker.yaml"
      ansible.verbose = "v"
    end
    vm6.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_ldap.yaml"
      ansible.verbose = "v"
    end
    vm6.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_services/setup_ssh.yaml"
      ansible.verbose = "v"
    end
    vm6.vm.provision "shell", inline: <<-SHELL
      echo "nameserver 192.168.20.40" | sudo tee /etc/resolv.conf > /dev/null
      sudo ip route add 192.168.10.0/24 via 192.168.40.30
      sudo ip route add 192.168.20.0/24 via 192.168.40.30
      sudo ip route add 192.168.30.0/24 via 192.168.40.30
    SHELL
  end

  # VM3 - OpenVPN administration
  config.vm.define "openvpn_admin" do |vm3|
    vm3.vm.hostname = "openvpn-admin"
    vm3.vm.network "private_network", ip: "192.168.40.20"
    vm3.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = 1
    end
    vm3.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_docker.yaml"
      ansible.verbose = "v"
    end
    vm3.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_services/setup_ssh.yaml"
      ansible.verbose = "v"
    end
    vm3.vm.provision "shell", inline: <<-SHELL
      echo "nameserver 192.168.20.40" | sudo tee /etc/resolv.conf > /dev/null
      sudo ip route add 192.168.10.0/24 via 192.168.40.30
      sudo ip route add 192.168.20.0/24 via 192.168.40.30
      sudo ip route add 192.168.30.0/24 via 192.168.40.30
    SHELL
  end

  VM7 - ELK + Fleet
  config.vm.define "elk_admin" do |vm7|
    vm7.vm.hostname = "elk"
    vm7.vm.network "private_network", ip: "192.168.40.14"
    vm7.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 1
    end
    vm7.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_docker.yaml"
      ansible.verbose = "v"
    end
    vm7.vm.provision "shell", inline: <<-SHELL
      echo "nameserver 192.168.20.40" | sudo tee /etc/resolv.conf > /dev/null
      sudo ip route add 192.168.10.0/24 via 192.168.40.30
      sudo ip route add 192.168.20.0/24 via 192.168.40.30
      sudo ip route add 192.168.30.0/24 via 192.168.40.30
    SHELL
    vm7.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_services/setup_ssh.yaml"
      ansible.verbose = "v"
    end
  end


  # VM4 - Services internes
  config.vm.define "<" do |vm4|
    vm4.vm.hostname = "services"
    vm4.vm.network "private_network", ip: "192.168.30.10"
    vm4.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
    vm4.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_docker.yaml"
      ansible.verbose = "v"
    end
    vm4.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_services_internal.yaml"
      ansible.verbose = "v"
    end
    vm4.vm.provision "shell", inline: <<-SHELL
      echo "nameserver 192.168.20.40" | sudo tee /etc/resolv.conf > /dev/null
      sudo ip route add 192.168.10.0/24 via 192.168.30.30
      sudo ip route add 192.168.20.0/24 via 192.168.30.30
      sudo ip route add 192.168.40.0/24 via 192.168.30.30
    SHELL
    vm4.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_services/setup_ssh.yaml"
      ansible.verbose = "v"
    end
  end

  # VM8 - Firewall: Interne <-> Admin <-> DMZ 
  config.vm.define "firewall_internal" do |vm8|
    vm8.vm.hostname = "firewall-internal"
    vm8.vm.network "private_network", ip: "192.168.30.30"
    vm8.vm.network "private_network", ip: "192.168.20.30"
    vm8.vm.network "private_network", ip: "192.168.40.30"
    vm8.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = 1
    end
    vm8.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_docker.yaml"
      ansible.verbose = "v"
    end
    vm8.vm.provision "shell", path: "./configs_firewalls/setup_internal.sh"
    vm8.vm.provision "shell", inline: <<-SHELL
      echo "nameserver 192.168.20.40" | sudo tee /etc/resolv.conf > /dev/null
    SHELL
    vm8.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_services/setup_ssh.yaml"
      ansible.verbose = "v"
    end
  end

  # VM1 - Services exposés 
  config.vm.define "services_dmz" do |vm1|
    vm1.vm.hostname = "services-exposed"
    vm1.vm.box = "ubuntu/focal64"
    vm1.vm.network "private_network", ip: "192.168.20.10"
    vm1.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
    vm1.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_docker.yaml"
      ansible.verbose = "v"
    end
    vm1.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_services_exposed.yaml"
      ansible.verbose = "v"
    end
    vm1.vm.provision "shell", inline: <<-SHELL
      echo "nameserver 192.168.20.40" | sudo tee /etc/resolv.conf > /dev/null
      sudo ip route add 192.168.10.0/24 via 192.168.20.50 
      sudo ip route add 192.168.30.0/24 via 192.168.20.30
      sudo ip route add 192.168.40.0/24 via 192.168.20.30
    SHELL
    vm1.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_services/setup_ssh.yaml"
      ansible.verbose = "v"
    end
  end
  
  VM3 - OpenVPN interne
  config.vm.define "openvpn_dmz" do |vm3|
    vm3.vm.hostname = "openvpn-dmz"
    vm3.vm.network "private_network", ip: "192.168.20.20"
    vm3.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = 1
    end
    vm3.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_docker.yaml"
      ansible.verbose = "v"
    end
    vm3.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_openvpn_interne.yaml"
      ansible.verbose = "v"
    end
    vm3.vm.provision "shell", inline: <<-SHELL
      echo "nameserver 192.168.20.40" | sudo tee /etc/resolv.conf > /dev/null
      sudo ip route add 192.168.10.0/24 via 192.168.20.50
      sudo ip route add 192.168.30.0/24 via 192.168.20.30
      sudo ip route add 192.168.40.0/24 via 192.168.20.30
    SHELL
    vm3.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_services/setup_ssh.yaml"
      ansible.verbose = "v"
    end
  end

  # VM2 - DNS
  config.vm.define "dns_dmz" do |vm2|
    vm2.vm.hostname = "dns"
    vm2.vm.network "private_network", ip: "192.168.20.40"
    vm2.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = 1
    end
    vm2.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_docker.yaml"
      ansible.verbose = "v"
    end
    vm2.vm.provision "shell", inline: <<-SHELL
      sudo ip route add 192.168.10.0/24 via 192.168.20.50
      sudo ip route add 192.168.30.0/24 via 192.168.20.30
      sudo ip route add 192.168.40.0/24 via 192.168.20.30
    SHELL
    vm2.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_services/setup_ssh.yaml"
      ansible.verbose = "v"
    end
    vm2.vm.provision "shell", path: "./configs_services/setup_dns.sh"
  end

  # VM9 - Firewall DMZ <-> Public
  config.vm.define "firewall_dmz" do |vm9|
    vm9.vm.hostname = "firewall-dmz"
    vm9.vm.network "private_network", ip: "192.168.20.50"
    vm9.vm.network "private_network", ip: "192.168.10.50"
    vm9.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = 1
    end
    vm9.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_docker.yaml"
      ansible.verbose = "v"
    end
    vm9.vm.provision "shell", path: "./configs_firewalls/setup_front.sh"
    vm9.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_services/setup_ssh.yaml"
      ansible.verbose = "v"
    end
    vm9.vm.provision "shell", inline: <<-SHELL
      echo "nameserver 192.168.20.40" | sudo tee /etc/resolv.conf > /dev/null
      sudo ip route add 192.168.30.0/24 via 192.168.20.30
      sudo ip route add 192.168.40.0/24 via 192.168.20.30
    SHELL
  end

  # VM0 - Machine publique
  config.vm.define "pc_public" do |vm0|
    vm0.vm.hostname = "public-machine"
    vm0.vm.network "private_network", ip: "192.168.10.10"
    vm0.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = 1
    end
    vm0.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update -y --fix-missing &&  apt-get install -y curl nmap inetutils-traceroute
    SHELL
    vm0.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_xrdp.yaml"
      ansible.verbose = "v"
    end
    vm0.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_ansible/install_docker.yaml"
      ansible.verbose = "v"
    end
    vm0.vm.provision "ansible" do |ansible|
      ansible.playbook = "configs_services/setup_ssh.yaml"
      ansible.verbose = "v"
    end
    vm0.vm.provision "shell", inline: <<-SHELL
      echo "nameserver 192.168.20.40" | sudo tee /etc/resolv.conf > /dev/null
      sudo ip route add 192.168.20.0/24 via 192.168.10.50
      sudo ip route add 192.168.30.0/24 via 192.168.10.50
      sudo ip route add 192.168.40.0/24 via 192.168.10.50      
    SHELL
  end
end