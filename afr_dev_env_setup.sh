#! /bin/sh

ESP_IDF_TOOLCHAIN="xtensa-esp32-elf"
ESP_IDF_TOOLCHAIN_VER="linux64-1.22.0-80-g6c4433a-5.2.0"
ESP_IDF_TOOLCHAIN_URL="https://dl.espressif.com/dl/${ESP_IDF_TOOLCHAIN}-${ESP_IDF_TOOLCHAIN_VER}.tar.gz"

CMAKE_VER="3.15.5-Linux-x86_64"
CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v3.15.5/cmake-${CMAKE_VER}.tar.gz"

PIP_REQ_FILE="requirements.txt"
PIP_REQ_FILE_URL="https://raw.githubusercontent.com/aws/amazon-freertos/master/vendors/espressif/esp-idf/$PIP_REQ_FILE"

SET_SKEL_SH="install_skel-home.sh"
SET_SKEL_SH_URL="https://raw.githubusercontent.com/andrewintw/skel-home/master/$SET_SKEL_SH"

git_your_name='your.name'
git_your_email="$git_your_name@hostname.com"

aws_cfg_access_key_id='BKIARR2NK7URSO63RWOX'
aws_cfg_secret_access_key='+Z0j3aRtO3A3c3DviM/pFPN5zbqNyzZg51pi5fJ1'
aws_cfg_default_region='ap-northeast-1'
aws_cfg_default_output='json'

do_init () {
	cat << EOF

1. create AWS IAM user and get credentials info
2. according to your info, change aws_cfg_xxx variables in this script

EOF
	sleep 5
}

config_def_shell () {
	echo "dash dash/sh boolean false" | sudo debconf-set-selections
	sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash
}

config_locale() {
	export LANGUAGE=en_US.UTF-8
	export LANG=en_US.UTF-8
	export LC_ALL=en_US.UTF-8
	sudo locale-gen en_US.UTF-8
	sudo update-locale LANG=en_US.UTF-8
	#sudo dpkg-reconfigure locales
}

config_timezone() {
	sudo timedatectl set-ntp true && \
	sudo timedatectl set-timezone 'Asia/Taipei'
}

install_pkgs () {
	local install_opts="-y --no-install-recommends"
	local pkg_basic="lftp tree vim unzip git curl linux-modules-extra-`uname -r`"
	local pkg_esp_idf="gcc make cmake ninja-build ccache \
					  git wget libncurses5-dev flex bison gperf \
					  python \
					  python-pip \
					  python-setuptools \
					  python-serial \
					  python-cryptography \
					  python-future \
					  python-pyparsing"
	sudo apt-get update
	sudo apt-get install $install_opts $pkg_basic $pkg_esp_idf
}

config_def_editor () {
	sudo update-alternatives --set editor /usr/bin/vim.basic
}

install_toolchain () {
	rm -rf ~/toolchain
	mkdir -p ~/toolchain
	cd ~/toolchain
	rm -rf $ESP_IDF_TOOLCHAIN ${ESP_IDF_TOOLCHAIN}-${ESP_IDF_TOOLCHAIN_VER}.tar.gz cmake-${CMAKE_VER}.tar.gz
	wget $ESP_IDF_TOOLCHAIN_URL
	tar -zxvf ${ESP_IDF_TOOLCHAIN}-${ESP_IDF_TOOLCHAIN_VER}.tar.gz
	wget $CMAKE_URL
	tar -zxvf cmake-${CMAKE_VER}.tar.gz
cat << EOF > $HOME/set_PATH_ESP-IDF.sh
#! /bin/sh
TOOLCHAIN_DIR=$HOME/toolchain/$ESP_IDF_TOOLCHAIN
CMAKE_DIR=$HOME/toolchain/cmake-${CMAKE_VER}
export PATH=\$CMAKE_DIR/bin:\$TOOLCHAIN_DIR/bin:${PATH}
EOF
	chmod a+x $HOME/set_PATH_ESP-IDF.sh
}

install_pypkgs () {
	pip install --user wheel
	wget $PIP_REQ_FILE_URL
	pip install --user -r $PIP_REQ_FILE
	pip install --user --upgrade awscli
	pip install --user tornado nose
	pip install --user boto3
}

aws_configure_env () {
	aws configure set aws_access_key_id     $aws_cfg_access_key_id
	aws configure set aws_secret_access_key $aws_cfg_secret_access_key
	aws configure set default.region        $aws_cfg_default_region
	aws configure set default.output        $aws_cfg_default_output

	cat ~/.aws/config
	cat ~/.aws/credentials
}

config_skel_home () {
	cd $HOME
	rm -rf $SET_SKEL_SH
	wget $SET_SKEL_SH_URL
	chmod a+x $SET_SKEL_SH
	$HOME/$SET_SKEL_SH
	sed -i "s/YOUR_EMAIL/$git_your_email/g" ~/.${USER}/config/gitconfig
	sed -i "s/YOUR_NAME/$git_your_name/g"   ~/.${USER}/config/gitconfig
}

config_UART_perm () {
	sudo usermod -a -G dialout $USER
}

config_samba () {
	local install_opts="-y --no-install-recommends"

	sudo apt-get install $install_opts samba

	if [ ! -f /etc/samba/smb.conf.ORIG ]; then
		sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.ORIG
	fi

	sudo bash -c 'cat <<EOF > /etc/samba/smb.conf
[global]
   workgroup = WORKGROUP
	server string = %h server (Samba, Ubuntu)
   dns proxy = no
   log file = /var/log/samba/log.%m
   max log size = 1000
   syslog = 0
   panic action = /usr/share/samba/panic-action %d
   server role = standalone server
   passdb backend = tdbsam
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes
   map to guest = bad user
   usershare allow guests = no
   security = user
[homes]
   comment = Home Directories
   browseable = no
   read only = no
   create mask = 0775
   valid users = %S
EOF'
	(echo $USER; echo $USER) | sudo smbpasswd -a -s $USER
	sudo service smbd restart
}

do_done () {
	cat <<EOF

1. download a:FreeRTOS source zip file from https://console.aws.amazon.com/freertos
2. prepare your wifi connection info
3. according to your info, change variables in afr_iot_bringup.sh
4. run afr_iot_bringup.sh <afr_source_zip> <your_thing_name>

*** please re-login  ***

EOF
}

do_main () {
	do_init
	#config_def_shell	# move to Vagrantfile
	#config_locale		# move to Vagrantfile
	#config_timezone	# move to Vagrantfile
	install_pkgs
	config_def_editor
	install_toolchain
	install_pypkgs
	aws_configure_env
	config_skel_home
	config_UART_perm
	config_samba
	do_done
}

do_main
