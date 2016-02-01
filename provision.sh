#!/bin/bash

echo "-------- PROVISIONING VCS ------------"
echo "--------------------------------------"
apt-get update
apt-get -y install subversion git


echo "-------- PROVISIONING JAVA -----------"
echo "--------------------------------------"

## See http://askubuntu.com/questions/190582/installing-java-automatically-with-silent-option
echo debconf shared/accepted-oracle-license-v1-1 select true | \
  debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | \
  debconf-set-selections

## Install java 1.7
## See http://www.webupd8.org/2012/06/how-to-install-oracle-java-7-in-debian.html
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee /etc/apt/sources.list.d/webupd8team-java.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
apt-get update
apt-get -y install oracle-java7-installer

echo "-------- PROVISIONING JENKINS --------"
echo "--------------------------------------"

# URL: http://localhost:6060
# Home: /var/lib/jenkins
# Start/Stop: /etc/init.d/jenkins
# Config: /etc/default/jenkins
# Jenkins log: /var/log/jenkins/jenkins.log
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get -y install jenkins

# Move Jenkins to port 6060
sed -i 's/8080/6060/g' /etc/default/jenkins
/etc/init.d/jenkins restart

echo "-------- PROVISIONING TOMCAT ---------"
echo "--------------------------------------"


## Install Tomcat (port 8080)
# This gives us something to deploy builds into
# CATALINA_BASE=/var/lib/tomcat7
# CATALINE_HOME=/usr/share/tomcat7
export JAVA_HOME="/usr/lib/jvm/java-7-oracle"
apt-get -y install tomcat7

# Work around a bug in the default tomcat start script
sed -i 's/export JAVA_HOME/export JAVA_HOME=\"\/usr\/lib\/jvm\/java-7-oracle\"/g' /etc/init.d/tomcat7
/etc/init.d/tomcat7 stop
/etc/init.d/tomcat7 start

echo "-------- PROVISIONING ANT ------------"
echo "--------------------------------------"
apt-get update
apt-get -y install ant


echo "-------- PROVISIONING DONE ------------"
echo "-- Jenkins: http://localhost:6060      "
echo "-- Tomcat7: http://localhost:7070      "
echo "---------------------------------------"

echo "-------- PLUGINS ----------------------"
echo "-- Installing plugins                  "
echo "---------------------------------------"

echo "Waiting Jenkins to launch on 6060..."
until [ "`curl --head --silent http://localhost:6060/cli/ | grep '200 OK'`" != "" ];
do
  sleep 0.1
done
echo "Jenkins launched, installing plugins..."

cd
wget http://localhost:6060/jnlpJars/jenkins-cli.jar
java -jar jenkins-cli.jar -s http://localhost:6060 install-plugin git checkstyle cloverphp crap4j dry htmlpublisher jdepend plot pmd violations warnings xunit chucknorris greenballs
java -jar jenkins-cli.jar -s http://localhost:6060 safe-restart
echo "finished installing plugins."

echo "Setup Jenkins template for PHP projects..."
cd
wget http://localhost:6060/jnlpJars/jenkins-cli.jar
curl -L https://raw.githubusercontent.com/sebastianbergmann/php-jenkins-template/master/config.xml | \
     java -jar jenkins-cli.jar -s http://localhost:6060 create-job php-template
java -jar jenkins-cli.jar -s http://localhost:6060 reload-configuration
echo "Jenkins template setup done."
