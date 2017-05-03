# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.7.4"
Vagrant.configure(2) do | global |

  global.vm.box = 'landregistry/centos'
  # global.vm.provision :shell,
  #   inline: 'sudo yum update -q -y'
  global.vm.provision :shell,
    inline: 'echo "PATH=/vagrant/bin:$PATH" >> /etc/bashrc'

  # Use shared Cachier cache
  if Vagrant.has_plugin?("vagrant-cachier")
    global.cache.scope = :box
  end

  # Manage Virtualbox Guest Additions
  if Vagrant.has_plugin?("vagrant-vbguest")
    global.vbguest.auto_update = false
  end

  nodes = [
    {
      :name => 'frontend-01',
      :addr => '192.168.99.11'
    },
    {
      :name => 'frontend-02',
      :addr => '192.168.99.12'
    },
    {
      :name => 'backend-01',
      :addr => '192.168.99.21'
    },
    {
      :name => 'backend-02',
      :addr => '192.168.99.22'
    }
  ]

  nodes.each_with_index do | node, i |
    global.vm.define node[:name] do | config |
      config.vm.hostname = node[:name]
      config.vm.network :private_network,
        ip: node[:addr],
        virtualbox_inet: true
      config.vm.provision :shell,
        path: "bin/python.sh",
        privileged: true
      config.vm.provision :shell,
        path: "bin/tomcat.sh",
        privileged: true
      config.vm.provision :shell,
        path: "bin/ha-provision.sh",
        privileged: true
    end
  end

end
