# -*- mode: ruby -*-
# vi: set ft=ruby :


# Note for making the Fedora 20 box:
# We had to make 2 changes to have network interfaces named ethX
# 1) Modify grub2.cfg to have a boot param of "biosdevname=0"
# 2) ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules
# Below link has more info:
#  https://github.com/mitchellh/vagrant/issues/2614#issuecomment-32593093

$setup_script = <<EOF
cd /vagrant/devel-env/fedora
./setup_pulp.sh | tee log_setup_pulp
EOF

Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.vm.box = "fedora_20.box"
  config.vm.box_url = "https://vagrantcloud.com/jwmatthews/fedora_20/version/1/provider/virtualbox.box"

  config.vm.hostname = "pulp.example.com"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network :private_network, ip: "172.31.2.100"

  config.vm.provision :shell, :inline => $setup_script
end
