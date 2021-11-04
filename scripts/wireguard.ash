# Definitions
WG_IF="vpn"
WG_PORT="51820"
WG_ADDR="192.168.9.1/24"
WG_PKI="keys"
WG_SERV="<YOUR_DOMAIN>"
mkdir -p ${WG_PKI}

echo "GENERATING KEYS"
umask go=
wg genkey | tee wgserver.key | wg pubkey > wgserver.pub

# Server private key
WG_S_KEY="$(cat wgserver.key)"
WG_S_PKEY="$(cat wgserver.pub)"
mv wgserver.key $WG_PKI
mv wgserver.pub $WG_PKI

echo "CONFIGURING WIREGUARD"
# uci rename firewall.@zone[0]="lan"
# uci rename firewall.@zone[1]="wan"
uci del_list firewall.lan.network="${WG_IF}"
uci add_list firewall.lan.network="${WG_IF}"
uci -q delete firewall.wg
uci set firewall.wg="rule"
uci set firewall.wg.name="Allow-WireGuard"
uci set firewall.wg.src="wan"
uci set firewall.wg.dest_port="${WG_PORT}"
uci set firewall.wg.proto="udp"
uci set firewall.wg.target="ACCEPT"
uci commit firewall
/etc/init.d/firewall restart

echo "CONFIGURING WIREGUARD SERVER"
uci -q delete network.${WG_IF}
uci set network.${WG_IF}="interface"
uci set network.${WG_IF}.proto="wireguard"
uci set network.${WG_IF}.private_key="${WG_KEY}"
uci set network.${WG_IF}.listen_port="${WG_PORT}"
uci add_list network.${WG_IF}.addresses="${WG_ADDR}"

echo "ADDING CRON SCRIPTS..."
# Periodically re-resolve inactive peers
# Resolve race conditions
cat << "EOF" >> /etc/crontabs/root
* * * * * /usr/bin/wireguard_watchdog
* * * * * date -s 2030-01-01; /etc/init.d/sysntpd restart
EOF
uci set system.@system[0].cronloglevel="9"

echo "RESTARTING CRON SERVICE"
/etc/init.d/cron restart

echo "REMOVING WIREGUARD CLIENTS"
uci -q delete network.wgclient
uci commit network

echo "ADDING WIREGUARD CLIENTS"
# Configuration parameters
WG_IDS="wgclient wglaptop wgmobile"

# Generate client keys
umask go=
for WG_ID in ${WG_IDS}
do
if [ ! -e "${WG_PKI}/${WG_ID}.pub" ]
then wg genkey \
| tee ${WG_PKI}/${WG_ID}.key \
| wg pubkey > ${WG_PKI}/${WG_ID}.pub
fi
if [ ! -e "${WG_PKI}/${WG_ID}.psk" ]
then wg genpsk > ${WG_PKI}/${WG_ID}.psk
fi
done

# Generate client profiles
WG_SFX="1"
for WG_ID in ${WG_IDS}
do
let WG_SFX++
cat << EOF > ${WG_PKI}/${WG_ID}.conf
[Interface]
Address = ${WG_ADDR%.*}.${WG_SFX}/24
PrivateKey = $(cat ${WG_PKI}/${WG_ID}.key)
DNS = ${WG_ADDR%/*}
[Peer]
PublicKey = ${WG_S_PKEY}
PresharedKey = $(cat ${WG_PKI}/${WG_ID}.psk)
PersistentKeepalive = 25
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = ${WG_SERV}:${WG_PORT}
EOF
done
ls ${WG_PKI}/*.conf

# Back up client profiles
cat << EOF >> /etc/sysupgrade.conf
$(pwd ${WG_PKI})
EOF

# Add VPN peers
WG_SFX="1"
for WG_ID in ${WG_IDS}
do
let WG_SFX++
uci -q delete network.${WG_ID}
uci set network.${WG_ID}="wireguard_${WG_IF}"
uci set network.${WG_ID}.public_key="$(cat ${WG_PKI}/${WG_ID}.pub)"
uci set network.${WG_ID}.preshared_key="$(cat ${WG_PKI}/${WG_ID}.psk)"
uci add_list network.${WG_ID}.allowed_ips="${WG_ADDR%.*}.${WG_SFX}/32"
done
uci commit network
/etc/init.d/network restart


echo "CONFIGURATION COMPLETE. REBOOTING..." && reboot now
