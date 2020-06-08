#!/bin/bash

LOG=/tmp/logfile
rm -rf /tmp/logfile

#### Web-Server-Installation ##########

echo "Installing httpd-server"
yum install httpd -y &>> LOG
echo $?

echo "Updating proxy-config"
echo 'ProxyPass "/student" "http://APP-SERVER-IPADDRESS:8080/student"
ProxyPassReverse "/student"  "http://APP-SERVER-IPADDRESS:8080/student"' >> /etc/httpd/conf.d/app-proxy.conf &>> LOG
echo $?

echo "Downloading index-file"
curl -s https://s3-us-west-2.amazonaws.com/studentapi-cit/index.html -o /var/www/html/index.html &>> LOG
echo $?

echo "Enabling-starting httpd"
systemctl enable httpd &>> LOG
echo $?
systemctl start httpd &>> LOG
echo $?






