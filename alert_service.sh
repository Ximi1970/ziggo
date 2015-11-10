#!/bin/bash
#
#
EMAIL=your.name@gmail.com
EMAIL_LOGIN=your.name@gmail.com
EMAIL_PASS=your.password

MODEM_IP=192.168.178.1
MODEM_LOGIN=ziggo
MODEM_PASSWORD=draadloos

SERVICE_PORT=22

COOKIE=/tmp/cookie_service.txt

#
# Login
#
curl -L -s -c $COOKIE -d "Zigloginnaam=$MODEM_LOGIN&Zigpassword=$MODEM_PASSWORD" http://$MODEM_IP/goform/login_zig > /dev/null

#
# Status page, get IP
#
CUR_IP=`curl -L -s -c $COOKIE http://$MODEM_IP/Status.asp | grep "InternetIPAddress" | sed -e "s?.*<b>\(.*\)</b>.*?\1?"`

#
# Check the ssh service
#
nc -z -w 2 $CUR_IP $SERVICE_PORT > /dev/null

if [ "$?" == "1" ] ; then
    #
    # Service unreachable
    #
    echo "Service unreachable, rebooting modem." | mailx -s "Service unreachable" -S smtp-use-starttls -S ssl-verify=ignore -S smtp-auth=login -S smtp=smtp://smtp.gmail.com:587 -S smtp-auth-user=$EMAIL_LOGIN -S smtp-auth-password=$EMAIL_PASS $EMAIL

    #
    # Reboot modem
    #
    curl -L -s -c $COOKIE --referer http://$MODEM_IP/Devicerestart.asp -d "mtenRestore=Device+Restart&devicerestart=1" http://$MODEM_IP/goform/Devicerestart > /dev/null
else
    #
    # Logout
    #
    curl -L -s -b $COOKIE -c $COOKIE --referer http://$MODEM_IP/Status.asp http://$MODEM_IP/logout.asp > /dev/null
fi

#
# Cleanup
#
rm -f $COOKIE
