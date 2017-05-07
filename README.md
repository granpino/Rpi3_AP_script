# Rpi3-access-point-script
Yet another Raspberry pi access point installation script. 
I have created 2 scripts by copying parts from several sources to make the installation of an Access Point on the Raspberry Pi 3 in one step. I am not a programmer and can not garantee it will work for you. The script was tested with a fresh install of Jessie Lite. 

The script rpi3_dnsmaq_AP.sh is made for the Rpi3 by using the built-in wifi antenna, while the rpi3_dnsmasq_AP_USB.sh is ment to be used with an external more powefull wifi antenna like the LB-LINK long range adapter.
The script uses Hostapd and dnsmasq and is made to automatically download the required apps and create the required config files. You must have the Raspberry pi connected to the internet with a cable not wifi.

Installation.
from the terminal window type:
sudo git clone https://github.com/granpino/Rpi3_AP_script.git
cd Rpi3_AP_script
sudo ./rpi3_dnsmasq_AP.sh

After the installation, reboot the Rpi. By using your Cell Phone connect to the wifi service RpiAP, enter the password raspberry. You should now have internet on your phone if everything went well.

The default ethernet IP address is 192.168.1.140 and the Wlan is 192.168.42.1, you can change these by editing the script. The wifi is named RpiAP and the password is raspberry.
