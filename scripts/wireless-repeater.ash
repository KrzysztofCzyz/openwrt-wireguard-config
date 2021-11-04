echo "Create wireless WAN network (wwan)"
uci set network.wwan=interface
uci set network.wwan.proto='dhcp'
uci commit network

echo "Create the bridge between lan and WWAn"
uci set network.repeater_bridge=interface
uci set network.repeater_bridge.proto='relay'
uci set network.repeater_bridge.network='lan wwan'
uci commit network

echo "Configure firewall"
uci set firewall.@zone[0].network='lan repeater_bridge wwan'
uci set firewall.@zone[0].masq='1'
uci set firewall.@zone[0].mtu_fix='1'
uci commit firewall

echo "Configure dhcp for LAN"
uci set dhcp.lan.ignore='1'
uci commit

echo "Enable wireless device"
uci set wireless.radio0.hwmode='11g'
uci set wireless.radio0.country='00'
uci set wireless.radio0.channel='1'
uci set wireless.radio0.disabled='0'
uci commit wireless

echo "Create my internal AP"
uci set wireless.myap=wifi-iface
uci set wireless.myap.device='radio0'
uci set wireless.myap.mode='ap'
uci set wireless.myap.encryption='psk2'
uci set wireless.myap.key='<PASSWORD_TO_ROUTER>'
uci set wireless.myap.ssid='<SSID_OF_ROUTER>'
uci set wireless.myap.network='lan'
uci commit wireless

echo "Connect to an existing WIFI"
uci set wireless.wifi_local=wifi-iface
uci set wireless.wifi_local.network='wwan'
uci set wireless.wifi_local.ssid='PXP44'
uci set wireless.wifi_local.encryption='psk2'
uci set wireless.wifi_local.device='radio0'
uci set wireless.wifi_local.mode='sta'
uci set wireless.wifi_local.bssid='<SID_OF_MASTER_ROUTER>'
uci set wireless.wifi_local.key='<PASSWORD_OF_MASTER_ROUTER>'
uci commit wireless

echo "Turning on WIFI"
echo "WARNING: IF PASSWORD IS UNCHANGED THE ROUTER IS AT RISK"
wifi && echo "WIFI IS TURNED ON!"
echo "CONFIGURATION FOR WIRELESS REPEATER IS COMPLETE!"
echo "REBOOTING" && reboot now
