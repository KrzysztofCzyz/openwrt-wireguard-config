# Router configuration scripts

Scripts in this repo:
- soft factory reset for the router
- rebooting
- setting up ddns
- setting up client router connection
- wireguard server & 3 clients

How into:
- prepare (DDNS provider)[https://freedns.afraid.org/dynamic/] or look into (clients)[https://openwrt.org/docs/guide-user/services/ddns/client]
- (prepare an image with wireguard-tools)[https://openwrt.org/faq/build_image_for_devices_with_only_4mb_flash]
- (flash the device)[https://openwrt.org/docs/guide-quick-start/factory_installation]
- look into scripts dir and change the variables to accomodate your needs
- run bootstrap.sh (if you wanna be sure, run the refresh.ash script on the target device beforehand)
- create a backup and extract it
- plug in all wireguard server clients with .conf files
- enable wireguard port forwarding in your master router

Other considerations:
- Remove ssh access to the device and dropbear config (will need a factory reset to connect again, DO NOT DO THIS ON IMAGE BUILDING LEVEL - IT WILL BRICK THE DEVICE!)
