#!/bin/bash

LOG=/tmp/logfile
rm -rf /tmp/logfile

############ Functions ########

### Colors ####
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
M="\e[35m"
C="\e[36m"
N="\e[0m]"


### Status-function #########
stat() {
    if [ $? -eq 0 ]; then
    echo "${G}Sucessful${N}"
    else
    echo "${R}Un-sucessfull-please refer log file at the location $LOG${N}"
    fi
}


#### Check-whether root user or not ########
id=$(id -u)
if [ $id -ne 0 ]; then 
echo "${R} You should be a root user to perform this action${N}"
exit 1
fi

#### Web-Server-Installation ##########

echo "${B}Installing httpd-server${N}"
yum install httpd -y &>> $LOG
stat $?

echo "${B}Updating proxy-config${N}"
echo 'ProxyPass "/student" "http://APP-SERVER-IPADDRESS:8080/student"
ProxyPassReverse "/student"  "http://APP-SERVER-IPADDRESS:8080/student"' > /etc/httpd/conf.d/app-proxy.conf
stat $?

echo "${B}Downloading index-file${N}"
curl -s https://s3-us-west-2.amazonaws.com/studentapi-cit/index.html -o /var/www/html/index.html &>> $LOG
stat $?

echo "${B}Enabling-starting httpd${N}"
systemctl enable httpd &>> $LOG
stat $?
systemctl start httpd &>> $LOG
stat $?
