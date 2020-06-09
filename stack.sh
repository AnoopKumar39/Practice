#!/bin/bash

LOG=/tmp/logfile
rm -rf /tmp/logfile

############ Functions ########

### Status-function #########
stat() {
    if [ $? -eq 0 ]; then
    echo "Sucessful"
    else
    echo "Un-sucessfull-please refer log file at the location $LOG"
}


#### Check-whether root user or not ########
id=$(id -u)
if [ $id -ne 0 ]; then 
echo "You should be a root user to perform this action"
exit 1
fi

#### Web-Server-Installation ##########

echo "Installing httpd-server"
yum install httpd -y &>> $LOG
stat $?

echo "Updating proxy-config"
echo 'ProxyPass "/student" "http://APP-SERVER-IPADDRESS:8080/student"
ProxyPassReverse "/student"  "http://APP-SERVER-IPADDRESS:8080/student"' > /etc/httpd/conf.d/app-proxy.conf
stat $?

echo "Downloading index-file"
curl -s https://s3-us-west-2.amazonaws.com/studentapi-cit/index.html -o /var/www/html/index.html &>> $LOG
stat $?

echo "Enabling-starting httpd"
systemctl enable httpd &>> $LOG
stat $?
systemctl start httpd &>> $LOG
stat $?
