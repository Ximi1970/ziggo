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

    page.onLoadFinished = function(){
        page.open("http://"+domain+"/Status.asp");
 
        page.onLoadFinished = function(){
       
            console.log(page.content);
            phantom.exit();
        };
        
    };
  }
});
EOF

#
# Get the ip from the status page
#
CUR_IP=`phantomjs $JAVASCRIPT $MODEM_IP $MODEM_LOGIN $MODEM_PASSWORD | grep "Internet IP Address" | sed -e "s?.*<b>\(.*\)</b>.*?\1?"`

#
# Cleanup
#
rm -f $JAVASCRIPT

if [ -n "$CUR_IP" ] && [ "$CUR_IP" != "0.0.0.0" ] ; then 
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

        #
        # Create javascript
        #
        JAVASCRIPT=/tmp/modem_reboot.js
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

    page.onLoadFinished = function(){
 
        page.open("http://"+domain+"/Devicerestart.asp", function(status) {
            if (status === "success") {
                page.evaluate(function() {
                    document.forms[0].devicerestart.value = "1";
                    document.forms[0].submit();
                });
            }
            
            page.onLoadFinished = function() {
                phantom.exit();
            };
            
        });
                 
        page.onLoadFinished = function() {
            phantom.exit();
        };
        
    };
  }
});
EOF
        
        #
        #   Reboot modem
        #
        phantomjs $JAVASCRIPT $MODEM_IP $MODEM_LOGIN $MODEM_PASSWORD
        
        #
        # Cleanup
        #
        rm -f $JAVASCRIPT
    fi
fi
