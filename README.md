# ziggo
Bash scripts to control your Ziggo EPC 3928 modem using cURL, phantomjs, mailx and nc (netcat).
  * checkip.sh: Get your internet IP. Uses cURL. (Old firmware)
  * checkip2.sh: Get your internet IP. Uses phantomjs.
  * reboot.sh: Reboot your modem. Uses cURL. (Old firmware)
  * reboot2.sh: Reboot your modem. Uses phantomjs.
  * alert_ipchange.sh: Send an email alert when the Internet IP changes. Uses cURL, mailx. (Old firmware)
  * alert_ipchange2.sh: Send an email alert when the Internet IP changes. Uses phantomjs, mailx.
  * alert_service.sh: Send an email alert and reboot the modem when a service is unreachable. Uses cURL, mailx, nc (netcat) (Old firmware)
  * alert_service2.sh: Send an email alert and reboot the modem when a service is unreachable. Uses phantomjs, mailx, nc (netcat)

You can put the script(s) in /etc/cron.hourly for example to do a check every hour. Do not forget to change the file mode bits to 700 and set the owner to root.root,  so only root can run, read and write.
