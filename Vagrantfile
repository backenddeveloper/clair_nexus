# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box_check_update = false
  config.vm.box = "debian/stretch64"

  config.vm.define "nexus" do |nexus| 
    nexus.vm.network "private_network", ip: "192.168.33.10"
    nexus.vm.synced_folder "data/nexus", "/data", type: "rsync", rsync__auto: true
    nexus.vm.provision "shell", inline: "/data/bootstrap.bash"
  end

  config.vm.define "docker" do |docker| 
    docker.vm.network "private_network", ip: "192.168.33.11"
    docker.vm.synced_folder "data/docker", "/data", type: "rsync", rsync__auto: true
    docker.vm.provision "shell", inline: "/data/bootstrap.bash"
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end

end
