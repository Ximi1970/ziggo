#!/bin/bash
#
#
EMAIL=your.name@gmail.com
EMAIL_LOGIN=your.name@gmail.com
EMAIL_PASS=your.password

MODEM_IP=192.168.178.1
MODEM_LOGIN=ziggo
MODEM_PASSWORD=draadloos

IP_LOG=/tmp/ip.txt

COOKIE=/tmp/cookie_alertchange.txt

#
# Login
#
curl --connect-timeout 5 --max-time 5 -L -s -c $COOKIE -d "Zigloginnaam=$MODEM_LOGIN&Zigpassword=$MODEM_PASSWORD" http://$MODEM_IP/goform/login_zig > /dev/null

if [ "$?" == "0" ] ; then
    #
    # Status page, get IP
    #
    CUR_IP=`curl --connect-timeout 5 --max-time 5 -L -s -c $COOKIE http://$MODEM_IP/Status.asp | grep "InternetIPAddress" | sed -e "s?.*<b>\(.*\)</b>.*?\1?"`

    #
    # Logout
    #
    curl  --connect-timeout 5 --max-time 5 -L -s -b $COOKIE -c $COOKIE --referer http://$MODEM_IP/Status.asp http://$MODEM_IP/logout.asp > /dev/null

    #
    # Get the old IP
    #
    OLD_IP=`cat $IP_LOG 2>/dev/null`

    #
    # New IP?
    #
    if [ "$CUR_IP" != "$OLD_IP" ] && [ -n "$CUR_IP" ] && [ "$CUR_IP" != "0.0.0.0" ] ; then
        #
        # IP changed, mail the change
        #
        echo "IP: $CUR_IP" | mailx -s "IP changed" -S smtp-use-starttls -S ssl-verify=ignore -S smtp-auth=login -S smtp=smtp://smtp.gmail.com:587 -S smtp-auth-user=$EMAIL_LOGIN -S smtp-auth-password=$EMAIL_PASS $EMAIL

        if [ "$?" == "0" ] ; then
	    echo $CUR_IP > $IP_LOG
        fi
    fi
fi

#
# Cleanup
#
rm -f $COOKIE
