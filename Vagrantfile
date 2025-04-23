Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  # VM0 - Machine administrateur
  config.vm.define "vm0" do |vm0|
    vm0.vm.hostname = "admin"
    vm0.vm.network "private_network", ip: "192.168.40.10"
    vm0.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
    vm0.vm.provision "shell", inline: <<-SHELL
      sudo ip route add 192.168.20.0/24 via 192.168.40.30
      sudo ip route add 192.168.30.0/24 via 192.168.40.30
      echo "nameserver 192.168.20.40" | sudo tee /etc/resolv.conf > /dev/null
    SHELL
  end

  # VM1 -- OpenVPN administration
  config.vm.define "vm1" do |vm1|
    vm1.vm.hostname = "openvpn-admin"
    vm1.vm.network "private_network", ip: "192.168.40.20"
    vm1.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
  end

  # VM2 - Services internes
  config.vm.define "vm2" do |vm2|
    vm2.vm.hostname = "services"
    vm2.vm.network "private_network", ip: "192.168.30.10"
    vm2.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 1
    end
  end

  # VM3 - Firewall: Interne <-> Admin <-> DMZ 
  config.vm.define "vm3" do |vm3|
    vm3.vm.hostname = "firewall-internal"
    vm3.vm.network "private_network", ip: "192.168.30.30"
    vm3.vm.network "private_network", ip: "192.168.20.30"
    vm3.vm.network "private_network", ip: "192.168.40.30"
    vm3.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
    vm3.vm.provision "shell", path: "./configs_firewalls/setup_internal.sh"
    vm3.vm.provision "shell", inline: <<-SHELL
      echo "nameserver 192.168.20.40" | sudo tee /etc/resolv.conf > /dev/null
    SHELL
  end

  # VM4 - Services exposés 
  config.vm.define "vm4" do |vm4|
    vm4.vm.hostname = "services-exposed"
    vm4.vm.box = "ubuntu/focal64"
    vm4.vm.network "private_network", ip: "192.168.20.10"
    vm4.vm.provider "virtualbox" do |vb|
      vb.memory = "3072"
      vb.cpus = 1
    end
    vm4.vm.provision "shell", inline: <<-SHELL
      sudo ip route add 192.168.30.0/24 via 192.168.20.30
      echo "nameserver 192.168.20.40" | sudo tee /etc/resolv.conf > /dev/null
    SHELL
  end

  # VM5 - OpenVPN interne
  config.vm.define "vm5" do |vm5|
    vm5.vm.hostname = "openvpn-internal"
    vm5.vm.network "private_network", ip: "192.168.20.20"
    vm5.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
    vm5.vm.provision "shell", inline: <<-SHELL
      sudo ip route add 192.168.30.0/24 via 192.168.20.30
      sudo ip route add 192.168.40.0/24 via 192.168.20.30
      echo "nameserver 192.168.20.40" | sudo tee /etc/resolv.conf > /dev/null
    SHELL
  end

  # VM6 - DNS
  config.vm.define "vm6" do |vm6|
    vm6.vm.hostname = "dns"
    vm6.vm.network "private_network", ip: "192.168.20.40"
    vm6.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
    vm6.vm.provision "shell", path: "./configs_services/setup_dns.sh"
    vm6.vm.provision "shell", inline: <<-SHELL
      sudo ip route add 192.168.30.0/24 via 192.168.20.30
    SHELL
  end

  # VM7 - Firewall DMZ <-> Public
  config.vm.define "vm7" do |vm7|
    vm7.vm.hostname = "firewall-dmz"
    vm7.vm.network "private_network", ip: "192.168.20.50"
    vm7.vm.network "private_network", ip: "192.168.10.50"
    vm7.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
    vm7.vm.provision "shell", path: "./configs_firewalls/setup_front.sh"
    vm7.vm.provision "shell", inline: <<-SHELL
      sudo ip route add 192.168.40.0/24 via 192.168.20.30
      echo "nameserver 192.168.20.40" | sudo tee /etc/resolv.conf > /dev/null
    SHELL
  end

  # VM8 - Machine publique
  config.vm.define "vm8" do |vm8|
    vm8.vm.hostname = "public-machine"
    vm8.vm.network "private_network", ip: "192.168.10.10"
    vm8.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
    vm8.vm.provision "shell", inline: <<-SHELL
      sudo ip route add 192.168.20.0/24 via 192.168.10.50
      sudo ip route add 192.168.40.0/24 via 192.168.10.50
      echo "nameserver 192.168.20.40" | sudo tee /etc/resolv.conf > /dev/null
    SHELL
    vm8.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update -y --fix-missing &&  apt-get install -y curl nmap inetutils-traceroute
    SHELL
  end


end
