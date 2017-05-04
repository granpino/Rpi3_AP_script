#!/bin/bash
#
# Raspberry Pi2 and Pi3 "Jessie lite" Access Point using dnsmasq
#by: User
#

###################################################
#set default values
###################################################
# General
CURRENT_AUTHOR="User"

# Network Interface
IP4_ADDRESS=192.168.1.140
IP4_GATEWAY=192.168.1.1
IP4_NETMASK=255.255.255.0

# Wifi Access Point
AP_COUNTRY=US
AP_CHAN=6
AP_SSID=RpiAP
AP_PASSPHRASE=raspberry

clear
echo ""
###################################################
echo "Performing a series of prechecks..."
echo "==================================="
###################################################


#check current user privileges
  (( `id -u` )) && echo "This script MUST be ran with root privileges, try prefixing with sudo. i.e sudo $0" && exit 1

#check that internet connection is available
# the hosts below are selected for their high availability,

((ping -w5 -c3 google.com || ping -w5 -c3 wikipedia.org) > /dev/null 2>&1) && echo "Internet connectivity - OK" || (echo "** Internet connection not found, Internet connectivity is required for this script to complete.**" && exit 0)
echo ""
echo ""

#pre-checks complete#####################################################

#clear the screen
#clear

# Get Input from User
echo "Capture User Settings:"
echo "======================"
echo "Please answer the following questions."
echo "Hitting return will continue with the default option"
echo
echo

read -p "IPv4 Address [$IP4_ADDRESS]: " -e t1
if [ -n "$t1" ]; then IP4_ADDRESS="$t1";fi


read -p "IPv4 netmask [$IP4_NETMASK]: " -e t1
if [ -n "$t1" ]; then IP4_NETMASK="$t1";fi

# wifi settings
read -p "Wifi Country [$AP_COUNTRY]: " -e t1
if [ -n "$t1" ]; then AP_COUNTRY="$t1";fi

read -p "Wifi Channel Name [$AP_CHAN]: " -e t1
if [ -n "$t1" ]; then AP_CHAN="$t1";fi

read -p "Wifi SSID [$AP_SSID]: " -e t1
if [ -n "$t1" ]; then AP_SSID="$t1";fi

read -p "Wifi PassPhrase (min 8 max 63 characters) [$AP_PASSPHRASE]: " -e t1
if [ -n "$t1" ]; then AP_PASSPHRASE="$t1";fi

###################################################
# Get Decision from User
###################################################

  echo "#####################################################"
  echo 
  echo 
  echo

# Point of no return
  read -p "Do you wish to continue and Setup RPi as an Access Point? (y/n) " RESP
  if [ "$RESP" = "y" ]; then

  clear
  echo "Configuring RPI as an Access Point...."
  # update system
  echo ""
  echo "#####################PLEASE WAIT##################"######
  echo -en "Package list update                                "
  apt-get -qq update 
  echo -en "[OK]\n"

  echo -en "Adding packages                                    "
  apt-get -y -qq install hostapd dnsmasq > /dev/null 2>&1
  echo -en "[OK]\n"


# backup the existing interfaces file
  echo -en "Backup /etc/network/interfaces file                "
cp /etc/network/interfaces /etc/network/interfaces.bak
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi

# create the following network interface file based on user input
  echo -en "Create new network interface configuration         "
cat <<EOF > /etc/network/interfaces
#created by $0
auto lo
iface lo inet loopback
 
auto eth0
allow-hotplug eth0
iface eth0 inet static
        address $IP4_ADDRESS
        netmask $IP4_NETMASK
        gateway $IP4_GATEWAY


#auto wlan0
allow-hotplug wlan0
iface wlan0 inet static
address 192.168.42.1
netmask 255.255.255.0
network 192.168.42.0
broadcast 192.168.42.255

#up iptables-restore < /etc/iptables.ipv4.nat
EOF
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi

# make executable at boot
  echo -en "restart dhcpcd                                     "
service dhcpcd restart
ifdown wlan0; ifup wlan0
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi


#create the hostapd configuration to match what the user has provided
  echo -en "Create hostapd.conf file                           "
  cat <<EOF > /etc/hostapd/hostapd.conf
#created by $0
interface=wlan0
driver=nl80211
ssid=$AP_SSID
hw_mode=g
channel=$AP_CHAN
ieee80211n=1
wmm_enabled=1
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]
wpa=2
wpa_passphrase=$AP_PASSPHRASE
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
auth_algs=1
ignore_broadcast_ssid=0
macaddr_acl=0
EOF
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi

#creat the default file to point at the configuration file
  echo -en "Create /etc/default/hostapd.conf file              "
  cat <<EOF > /etc/default/hostapd
#created by $0
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi

#creat the default file to point at the configuration file
  echo -en "Create /etc/dnsmasq.conf file                      "
  cat <<EOF > /etc/dnsmasq.conf
#created by $0
interface=wlan0
listen-address=192.168.42.1
bind-interfaces
server=8.8.8.8 
domain-needed 
bogus-priv
dhcp-range=192.168.42.50,192.168.42.100,12h

EOF
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi

#create sysctl.conf file ==============================
  echo -en "Create sysctl.conf file                            "
  cp /etc/sysctl.conf /etc/sysctl.conf.bak
  cat <<EOF > /etc/sysctl.conf
#created by $0s
#kernel.printk = 3 4 1 3
net.ipv4.ip_forward=1
#vm.swappiness=1
#vm.min_free_kbytes = 8192

EOF
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi


# configure NAT 
  echo -en "setup IP forward                                   "
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi




# iptables IPv4 ===============================
  echo -en "iptables IPv4 setup                                "
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi


#make sure it is permanent
  echo -en "make Iptables permanent                            "
sh -c "iptables-save > /etc/iptables.ipv4.nat"
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi

# make executable at boot
  echo -en "making sure it starts at boot                      "
update-rc.d hostapd enable
update-rc.d dnsmasq enable
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo -en "[FAIL]\n"
    echo ""
    exit $rc
  else
    echo -en "[OK]\n"
  fi


  echo "###################INSTALL COMPLETE###############"######
  echo "The services will now be restarted to activate the changes"
  read -p "Press [Enter] key to restart services..."

  
# Restart the access point software
    echo -en "starting hostapd"
service hostapd start
    echo ""
# Restart dnsmasq ===============================
    echo -en "starting dnsmasq"
    echo ""
service dnsmasq start
####################################################################
else
echo "exiting..."
fi
exit 0



