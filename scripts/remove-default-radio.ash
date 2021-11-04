echo "REMOVING DEFAULT RADIO DEVICE FOR THE ROUTER"
uci delete -q wireless.default_radio0
uci commit wireless
echo "REBOOTING" && reboot
