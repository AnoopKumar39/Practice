#!/bin/bash

LOG=/tmp/logfile
sudo rm -rf /tmp/logfile
APPUSER=student
TOMCAT_VERSION=$(curl -s "https://archive.apache.org/dist/tomcat/tomcat-8/?C=M;O=A" | grep 8.5 | tail -1 | awk '{print $5}' | awk -F '"' '{print $2}' | sed -e 's/v//' -e 's/\///') &>> $LOG
TOMCAT_DIR=/home/${APPUSER}/apache-tomcat-${TOMCAT_VERSION}
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
print() {
    echo -e "${B}$1${N}"
}

#### Check-whether root user or not ########
id=$(id -u)
if [ $id -ne 0 ]; then 
print "You should be a root user to perform this action"
exit 1
fi

#### Web-Server-Installation ##########

echo -e "${B}Installing httpd-server${N}"
yum install httpd -y &>> $LOG
stat

echo -e "${B}Updating proxy-config${N}"
echo 'ProxyPass "/student" "http://localhost:8080/student"
ProxyPassReverse "/student"  "http://localhost:8080/student"' > /etc/httpd/conf.d/app-proxy.conf
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
cd /home/${APPUSER}
wget https://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz &>> $LOG
stat
echo -e "${B}Unarchiving tomcat${N}"
tar -xf apache-tomcat-${TOMCAT_VERSION}.tar.gz &>> $LOG
stat

#### Download application file and jdbc driver ######
cd ${TOMCAT_DIR}
echo -e "${B}Downloading war file${N}"
wget https://s3-us-west-2.amazonaws.com/studentapi-cit/student.war -O webapps/student.war &>> $LOG
stat
echo -e "${B}Downloading jdbc driver ${N}"
wget https://s3-us-west-2.amazonaws.com/studentapi-cit/mysql-connector.jar -O lib/mysql-connector.jar &>> $LOG
stat

### Setting-up context.xml #####
echo -e "${B}Modifying context.xml file${N}"
sed -i -e '$ i <Resource name="jdbc/TestDB" auth="Container" type="javax.sql.DataSource" maxTotal="100" maxIdle="30" maxWaitMillis="10000" username="USERNAME" password="PASSWORD" driverClassName="com.mysql.jdbc.Driver" url="jdbc:mysql://RDS-DB-ENDPOINT:3306/DATABASE"/>' conf/context.xml
stat
echo -e "${B}Changing tomcat permissions${N}"
cd /home/student
chown -R ${APPUSER}:${APPUSER} apache-tomcat-${TOMCAT_VERSION}
stat

#### Starting tomcat #####
cd ${TOMCAT_DIR}
bin/startup.sh &>> $LOG
stat