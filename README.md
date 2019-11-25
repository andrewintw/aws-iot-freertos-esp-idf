# aws-iot-freertos-esp-idf

Amazon FreeRTOS quick start for ESP-WROVER-KIT

## 0. Prepare

1. create [AWS IAM](https://console.aws.amazon.com/iam/home) user and get credentials info
	* Access Key ID
	* Secret Access Key
2. download a:FreeRTOS source zip file from https://console.aws.amazon.com/freertos
3. prepare your wifi connection info
	* WiFi SSID
	* WiFi Password
	* WiFi Security


## 1. Startup a VM via vagrant

in vagrant folder: 

	/drives/c/home/ws/VMs/aws-iot > ls -al
	total 14138
	drwxr-xr-x    1 andrew   UsersGrp         0 Nov 19 11:35 .
	dr-xr-x---    1 andrew   UsersGrp         0 Nov 18 10:33 ..
	-rwxr-xr-x    1 andrew   UsersGrp      1330 Nov 19 10:19 Vagrantfile
	-rwxr-xr-x    1 andrew   UsersGrp  28928339 Nov 19 09:49 aFreeRTOS-ESP-IDF-201910.00.zip
	-rwxr-xr-x    1 andrew   UsersGrp      4576 Nov 19 11:29 afr_dev_env_setup.sh
	-rwxr-xr-x    1 andrew   UsersGrp      2573 Nov 19 11:24 afr_iot_bringup.sh

do `vagrant up` to startup a ubuntu VM


## 2. ssh to VM

ssh 127.0.0.1:2201 use the key: `.vagrant/machines/default/virtualbox/private_key`


## 3. Setup development environment

for Amazon FreeRTOS and ESP-WROVER-KIT board, run the following command:

according to your user credentials info, change variables in afr_dev_env_setup.sh

	vagrant@vbox-afr:~$ /vagrant/afr_dev_env_setup.sh 

## 4. Build, Run and Test

1. connect your board to Linux and made sure you got /dev/ttyUSB* node
2. according to your wifi connection info, change variables in afr_iot_bringup.sh
3. run afr_iot_bringup.sh <afr_source_zip> <your_thing_name>
4. Subscribe topic: `iotdemo/#` on [AWS IoT console](https://console.aws.amazon.com/iot/home/#/test)
2. UART monitor: `$afr_source_dir/vendors/espressif/esp-idf/tools/idf.py monitor -p /dev/ttyUSB1 -B $afr_build_dir`

The variables that you need to modify:

	aws_cfg_access_key_id='BKIARR2NK7URSO63RWOW'
	aws_cfg_secret_access_key='+Z0j3aRtO3A3c3DviM/pFPN5zbqNyzZg51pi5fJ0'
	aws_cfg_default_region='ap-northeast-1'
	aws_cfg_default_output='json'
	
	wifi_ssid="WIFI_2.4G_SSID"
	wifi_password="WIFI_password"
	wifi_security="eWiFiSecurityWPA2"


~ END ~
