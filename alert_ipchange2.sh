#!/bin/bash
#
#
EMAIL=your.name@gmail.com
EMAIL_LOGIN=your.name@gmail.com
EMAIL_PASS=your.password

MODEM_IP=192.168.178.1
MODEM_LOGIN=ziggo
MODEM_PASSWORD=draadloos

#
# Create javascript
#
JAVASCRIPT=/tmp/get_ip.js
rm -f $JAVASCRIPT

cat > $JAVASCRIPT << EOF
var system = require('system');

var domain = system.args[1];
var user = system.args[2];
var pass = system.args[3];

var page = require('webpage').create();

page.open("http://"+domain+"/login_zig.asp", function(status) {

  if (status === "success") {
    page.evaluate(function(user, pass) {
        document.getElementById("Zigloginnaam").value = user;
        document.getElementById("Zigpassword").value = pass;
        formsubmit();
    }, user, pass);

    page.onLoadFinished = function() {
        page.open("http://"+domain+"/Status.asp");
 
        page.onLoadFinished = function() {
       
            console.log(page.content);
            phantom.exit();
        };
        
    };
  }
});
EOF

#
# IP storage
#
IP_LOG=/tmp/ip.txt

#
# Get the ip from the status page
#
CUR_IP=`phantomjs $JAVASCRIPT $MODEM_IP $MODEM_LOGIN $MODEM_PASSWORD | grep "Internet IP Address" | sed -e "s?.*<b>\(.*\)</b>.*?\1?"`

#
# Cleanup
#
rm -f $JAVASCRIPT

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
