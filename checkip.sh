#!/bin/bash
#
#
MODEM_IP=192.168.178.1
MODEM_LOGIN=ziggo
MODEM_PASSWORD=draadloos

COOKIE=/tmp/cookie_checkip.txt

#
# Login
#
curl -L -s -c $COOKIE -d "Zigloginnaam=$MODEM_LOGIN&Zigpassword=$MODEM_PASSWORD" http://$MODEM_IP/goform/login_zig > /dev/null

#
# Status page
#
WORLD_IP=`curl -L -s -c $COOKIE http://$MODEM_IP/Status.asp | grep "InternetIPAddress" | sed -e "s?.*<b>\(.*\)</b>.*?\1?"`

#
# Logout
#
curl -L -s -b $COOKIE -c $COOKIE --referer http://$MODEM_IP/Status.asp http://$MODEM_IP/logout.asp > /dev/null
rm -f $COOKIE

echo "My internet address is: "$WORLD_IP
