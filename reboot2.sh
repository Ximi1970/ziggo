#!/bin/bash
#
#
MODEM_IP=192.168.178.1
MODEM_LOGIN=ziggo
MODEM_PASSWORD=draadloos

#
# Create javascript
#
JAVASCRIPT=/tmp/reboot.js
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
# Reboot modem
#
phantomjs $JAVASCRIPT $MODEM_IP $MODEM_LOGIN $MODEM_PASSWORD

#
# Cleanup
#
rm -f $JAVASCRIPT
