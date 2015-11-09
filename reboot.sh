#!/bin/bash
#
#
MODEM_IP=192.168.178.1

#
# Login
#
curl -L -s -c cookie_reboot.txt -d "Zigloginnaam=ziggo&Zigpassword=draadloos" http://$MODEM_IP/goform/login_zig > /dev/null

#
# Modem restart
#
curl -L -s -c cookie_reboot.txt --referer http://$MODEM_IP/Devicerestart.asp -d "mtenRestore=Device+Restart&devicerestart=1" http://$MODEM_IP/goform/Devicerestart > /dev/null
rm -f cookie_reboot.txt
