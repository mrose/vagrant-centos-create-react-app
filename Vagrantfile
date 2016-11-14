# -*- mode: ruby -*-
# vi: set ft=ruby :

load 'config'

Vagrant.require_version ">= 1.8.6"

Vagrant.configure("2") do |config|

  config.vm.box = VAGRANT_VM_BOX
  config.vm.box_check_update = VAGRANT_VM_BOX_CHECK_UPDATE
  config.vm.network :private_network, ip: PRIVATE_NETWORK_IP
  config.vm.hostname = HOSTNAME

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", MEMORY]
      # vb.customize ["modifyvm", :id, "--cpus", cpus]
    vb.customize ["modifyvm", :id, "--ioapic", "on" ]
  end

  config.vm.provision "shell", path:"provision.sh", name:"provision", args:"/vagrant/config"

  # add personal ssh key to vagrant so ssh to git will work
  ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
  config.vm.provision 'shell', inline: "echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys", privileged: false
  # allow ssh agent forwarding
  config.ssh.forward_agent = true

  config.vm.provision "shell", path:"createReactApp.sh", name:"createReactApp", args:"/vagrant/config"

  # dnw why???
  # config.vm.synced_folder "opt/", "/opt"
end
