uci set network.lan.ipaddr='192.168.2.1' && echo "SET"
uci commit && echo "COMMITED"
echo "REBOOTING" && reboot now
