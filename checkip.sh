#!/bin/bash
#
#
MODEM_IP=192.168.178.1

#
# Login
#
curl -L -s -c cookie_checkip.txt -d "Zigloginnaam=ziggo&Zigpassword=draadloos" http://$MODEM_IP/goform/login_zig > /dev/null

#
# Status page
#
WORLD_IP=`curl -L -s -c cookie_checkip.txt http://$MODEM_IP/Status.asp | grep "InternetIPAddress" | sed -e "s?.*<b>\(.*\)</b>.*?\1?"`

#
# Logout
#
curl -L -s -b cookie_checkip.txt -c cookie_checkip.txt --referer http://$MODEM_IP/Status.asp http://$MODEM_IP/logout.asp > /dev/null
rm -f cookie_checkip.txt

echo "My internet address is: "$WORLD_IP
