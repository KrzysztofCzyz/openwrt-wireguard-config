#!/bin/ash
echo "ADDING DDNS SERVICE"
cat << "EOF" >> /etc/crontabs/root
3,8,13,18,23,28,33,38,43,48,53,58 * * * * sleep 12 ; /bin/wget --no-check-certificate -O - https://freedns.afraid.org/dynamic/update.php?<PUT YOUR CODE HERE> >> /tmp/freedns_homedomain_jumpingcrab_com.log 2>&1 &
EOF

echo "RESTARTING CRON SERVICE"
/etc/init.d/cron restart
