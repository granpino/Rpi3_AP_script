# Rpi3-access-point-script
Yet another Raspberry pi access point installation script.
There are 2 scripts included. One for the embedded wifi ont the Pi, and the other for an external wifi dongle in case you want to use a long range antenna. The script was tested with a fresh install of Jessie Lite. 
Transfer the script to the Pi and execute with sudo ./rpi3_dnsmasq_AP.sh or ./rpi3_dnsmasq_AP_USB.sh depending on wht you need. I tested the rpi3_dnsmasq_AP_USB with a Edimax usb wifi dongle. This is a RTL8188 adapter. 
The default ethernet IP address is 192.168.1.140 and the Wlan is 192.168.42.1, you can change these by editing the script. The wifi is named RpiAP and the password is raspberry.
