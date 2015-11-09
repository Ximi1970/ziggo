#!/bin/bash
#
#
EMAIL=your.name@gmail.com
EMAIL_LOGIN=your.name@gmail.com
EMAIL_PASS=your.password

MODEM_IP=192.168.178.1

#
# Login
#
curl -L -s -c cookie_checkip.txt -d "Zigloginnaam=ziggo&Zigpassword=draadloos" http://$MODEM_IP/goform/login_zig > /dev/null

#
# Status page, get IP
#
CUR_IP=`curl -L -s -c cookie_checkip.txt http://$MODEM_IP/Status.asp | grep "InternetIPAddress" | sed -e "s?.*<b>\(.*\)</b>.*?\1?"`

#
# Logout
#
curl -L -s -b cookie_checkip.txt -c cookie_checkip.txt --referer http://$MODEM_IP/Status.asp http://$MODEM_IP/logout.asp > /dev/null
rm -f cookie_checkip.txt

#
# Get the old IP
#
OLD_IP=`cat /tmp/ip.txt 2>/dev/null`

#
# New IP?
#
if [ "$CUR_IP" != "$OLD_IP" ] && [ -z "$CUR_IP" ] ; then
    #
    #	IP changed, mail the change
    #
    echo "IP: $CUR_IP" | mailx -S smtp-use-starttls -S ssl-verify=ignore -S smtp-auth=login -S smtp=smtp://smtp.gmail.com:587 -S smtp-auth-user=$EMAIL_LOGIN -S smtp-auth-password=$EMAIL_PASS $EMAIL

    if [ "$?" == "0" ] ; then
	echo $CUR_IP > /tmp/ip.txt
    fi
fi
