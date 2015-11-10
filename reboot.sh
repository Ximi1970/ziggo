#!/bin/bash
#
#
MODEM_IP=192.168.178.1
MODEM_LOGIN=ziggo
MODEM_PASSWORD=draadloos

COOKIE=/tmp/cookie_reboot.txt

#
# Login
#
curl -L -s -c $COOKIE -d "Zigloginnaam=$MODEM_LOGIN&Zigpassword=$MODEM_PASSWORD" http://$MODEM_IP/goform/login_zig > /dev/null

#
# Modem restart
#
curl -L -s -c $COOKIE --referer http://$MODEM_IP/Devicerestart.asp -d "mtenRestore=Device+Restart&devicerestart=1" http://$MODEM_IP/goform/Devicerestart > /dev/null
rm -f $COOKIE
