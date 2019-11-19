# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
	my_vb_name = "vbox-afr"
	my_fw_port = 2201

	# Every Vagrant development environment requires a box. search for boxes at https://vagrantcloud.com/search.
	config.vm.box = "ubuntu/xenial64"
	config.vm.hostname = "#{my_vb_name}"

	config.vm.box_check_update = false

	config.vm.network "public_network"
	config.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", disabled: "true"
	config.vm.network :forwarded_port, guest: 22, host: "#{my_fw_port}", auto_correct: true

	config.vm.provider "virtualbox" do |vb|
		vb.gui = false
		vb.memory = "1024"
		vb.name = "#{my_vb_name}"
		vb.customize ["modifyvm", :id, "--usb", "on"]
		vb.customize ["modifyvm", :id, "--usbehci", "on"]
		vb.customize ["modifyvm", :id, "--usbxhci", "on"]
	end

	config.vm.provision "shell", 
	inline: <<-ENV_CONFIG
		echo "dash dash/sh boolean false" | debconf-set-selections
		DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

		export LANGUAGE=en_US.UTF-8
		export LANG=en_US.UTF-8
		export LC_ALL=en_US.UTF-8
		locale-gen en_US.UTF-8
		update-locale LANG=en_US.UTF-8

		timedatectl set-ntp true
		timedatectl set-timezone 'Asia/Taipei'

		#apt-get update
		#apt-get install apt-file
		#apt-file update
	ENV_CONFIG
end
