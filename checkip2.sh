#!/bin/bash
#
#
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

var domain = system.args[1]
var user = system.args[2]
var pass = system.args[3]

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
WORLD_IP=`phantomjs $JAVASCRIPT $MODEM_IP $MODEM_LOGIN $MODEM_PASSWORD | grep "Internet IP Address" | sed -e "s?.*<b>\(.*\)</b>.*?\1?"`

#
# Cleanup
#
rm -f $JAVASCRIPT

#
# Tell the user
#
echo "My internet address is: -"$WORLD_IP"-"
