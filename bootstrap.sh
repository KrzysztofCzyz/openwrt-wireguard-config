echo "Remember to set all variables!"
address=192.168.1.1
address_after_reboot=192.168.2.1

wait_for_connection(){
  while ! timeout 5 bash -c "</dev/tcp/$1/22" 2>/dev/null; do echo "WAITING FOR CONNECTION to $address ..."; done
}

send_script(){
  ssh root@$1 < $2
}

echo "WAITING FOR ROUTER..."
wait_for_connection $address

echo "CHANGING IP..."
send_script $address scripts/first.ash

echo "WAITING FOR ROUTER TO COME BACK UP..."
wait_for_connection $address_after_reboot

echo "CONNECTING TO MASTER ROUTER..."
send_script $address_after_reboot scripts/wireless-repeater.ash

echo "WAITING FOR ROUTER TO COME BACK UP..."
wait_for_connection $address_after_reboot

echo "REMOVING DEFAULT RADIO..."
send_script $address_after_reboot scripts/remove-default-radio.ash

echo "WAITING FOR ROUTER TO COME BACK UP..."
wait_for_connection $address_after_reboot

echo "SETTING UP DDNS SERVICE..."
send_script $address_after_reboot scripts/ddns.ash

echo "SETTING UP WIREGUARD..."
send_script $address_after_reboot scripts/wireguard.ash

wait_for_connection $address_after_reboot
echo "CONFIGURATION FINISHED!"
