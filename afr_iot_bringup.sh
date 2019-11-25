#! /bin/sh

afr_source_zip="$1"
thing_name="$2"

afr_source_dir=''
afr_build_dir='build'

wifi_ssid="WIFI_SSID"
wifi_password="wifi-password"
wifi_security="eWiFiSecurityWPA2"

set_path_file=$HOME/set_PATH_ESP-IDF.sh

show_usage () {
	cat <<EOF

Usage:
      $0 <afr_source_zip> <your_thing_name>
Ex:
      $0 freertos--201910.00.zip myIot-node

EOF
}

do_init () {
	if [ "$thing_name" = "" ]; then
		show_usage
		exit 1
	fi

	if [ ! -f "$afr_source_zip" ]; then
		echo "no such file: $afr_source_zip"
		exit 1
	fi

	if [ ! -f "$set_path_file" ]; then
		echo "no such file: $set_path_file"
		exit 1
	fi
}

untar_afr_tarball() {
	unzip $afr_source_zip
	afr_source_dir=$PWD/AmazonFreeRTOS
	afr_build_dir=$afr_source_dir/build

	chmod a+x $afr_source_dir/vendors/espressif/esp-idf/tools/idf.py
}

aws_config_quick_start () {
	cd $afr_source_dir/tools/aws_config_quick_start

	sed -i "s/\$thing_name/$thing_name/g"       configure.json
	sed -i "s/\$wifi_ssid/$wifi_ssid/g"         configure.json
	sed -i "s/\$wifi_password/$wifi_password/g" configure.json
	sed -i "s/\$wifi_security/$wifi_security/g" configure.json

	python SetupAWS.py setup
}

build_afr_source () {
	source $set_path_file
	cd $afr_source_dir
	cmake -DVENDOR=espressif -DBOARD=esp32_wrover_kit -DCOMPILER=xtensa-esp32 -S . -B $afr_build_dir
	cmake --build $afr_build_dir
}

idf_flash () {
	$afr_source_dir/vendors/espressif/esp-idf/tools/idf.py erase_flash flash -B $afr_build_dir
}

idf_monitor () {
	$afr_source_dir/vendors/espressif/esp-idf/tools/idf.py monitor -p /dev/ttyUSB1 -B $afr_build_dir
}

do_done () {
	aws iot list-things
	cat <<EOF

1. Subscribe topic: iotdemo/# on
   https://console.aws.amazon.com/iot/home/#/test

2. Erase & Flash
   cd $afr_source_dir
   $afr_source_dir/vendors/espressif/esp-idf/tools/idf.py erase_flash flash -B $afr_build_dir

3. UART monitor:
   cd $afr_source_dir
   $afr_source_dir/vendors/espressif/esp-idf/tools/idf.py monitor -p /dev/ttyUSB1 -B $afr_build_dir

EOF
	if [ `ls /dev/ttyUSB* 2>/dev/null | wc -l` -eq 0 ]; then
		echo "Warning: There is no /dev/ttyUSB*"
		#exit 1
	fi
}

do_main () {
	do_init
	untar_afr_tarball
	aws_config_quick_start
	build_afr_source
	#idf_flash
	do_done
	#idf_monitor
}

do_main
