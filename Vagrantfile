# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Every Vagrant virtual environment requires a box to build off of.
  # Named boxes, like this one, don't need a URL, since the are looked up
  # in the "vagrant cloud" (https://vagrantcloud.com)
  config.vm.box = "ubuntu/trusty64"

  # Publish guest port 6060 on host port 6060
  config.vm.network "forwarded_port", guest: 6060, host: 6060
  config.vm.network "forwarded_port", guest: 8080, host: 7070

  config.vm.provider "virtualbox" do |vb|
  #   # Don't boot with headless mode. Use for debugging
  #   vb.gui = true

  #   # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  # Provision the box using a shell script
  # This script is copied into the box and then run
  config.vm.provision :shell, :privileged => true, :path => "provision.sh"



end
