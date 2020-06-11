#!/bin/bash

LOG=/tmp/logfile
sudo rm -rf /tmp/logfile
APPUSER=student
TOMCAT_VERSION=$(curl -s "https://archive.apache.org/dist/tomcat/tomcat-8/?C=M;O=A" | grep 8.5 | tail -1 | awk '{print $5}' | awk -F '"' '{print $2}' | sed -e 's/v//' -e 's/\///') &>> $LOG

############ Functions ########

### Colors ####
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
M="\e[35m"
C="\e[36m"
N="\e[0m"


### Status-function #########
stat() {
    if [ $? -eq 0 ]; then
    echo -e "${G}Sucessful${N}"
    else
    echo -e "${R}Un-sucessfull-please refer log file at the location $LOG${N}"
    fi
}


#### Check-whether root user or not ########
id=$(id -u)
if [ $id -ne 0 ]; then 
echo -e "${R} You should be a root user to perform this action${N}"
exit 1
fi

#### Web-Server-Installation ##########

echo -e "${B}Installing httpd-server${N}"
yum install httpd -y &>> $LOG
stat

echo -e "${B}Updating proxy-config${N}"
echo 'ProxyPass "/student" "http://APP-SERVER-IPADDRESS:8080/student"
ProxyPassReverse "/student"  "http://APP-SERVER-IPADDRESS:8080/student"' > /etc/httpd/conf.d/app-proxy.conf
stat

echo -e "${B}Downloading index-file${N}"
curl -s https://s3-us-west-2.amazonaws.com/studentapi-cit/index.html -o /var/www/html/index.html &>> $LOG
stat

echo -e "${B}Enabling httpd${N}"
systemctl enable httpd &>> $LOG
stat
echo -e "${B}Starting httpd${N}"
systemctl start httpd &>> $LOG
stat

######## Application-Server-Installation ###########
###### Creating application user ########
echo -e "${B}Creating application user${N}"
id $APPUSER &>> $LOG
if [ $? -eq 0 ]; then
true
else
useradd $APPUSER &>> $LOG
fi
stat

##### Installing java #####
echo -e "${B}Installing java${N}"
yum install java -y &>> $LOG
stat

#### Download and unarchire tomcat ####
echo -e "${B}Downloading tomcat${N}"
echo "${TOMCAT_VERSION}"
wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.56/bin/apache-tomcat-8.5.56.tar.gz &>> $LOG
stat

#cd apache-tomcat-${TOMCAT_VERSION}
