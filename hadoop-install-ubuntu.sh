#!/usr/bin/bash


###################################################################
#Script Name:  HadoopInstaller                                                                   
#Description: bash script to install hadoop on ubuntu                                                                                 
#Author  	: x64nik
#Email      : https://x64nik.github.io/
###################################################################



line="--------------------------------------------"

echo "Installing latest or desired version of java"
echo "$line"
sudo apt install default-jdk default-jre -y

echo "Installing OpenSSH and configuring it"
echo "$line"
sudo apt install openssh-server openssh-client -y 

echo "Generating SSH RSA keys"
echo "[!] Press ENTER until key is generated [!] "
echo "$line"
ssh-keygen -t rsa

sudo cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys 
sudo chmod 640 ~/.ssh/authorized_keys
echo "Connecting to localhost via SSH"
echo "$line"
#ssh localhost

echo "$line"
read -p "Do you want to download hadoop.tar.gz file (Y/N): " choice0
if [[ "$choice0" == "Y"  ]] || [[ "$choice0" == "y"  ]];
then
	echo "Downloading hadoop-3.3.1.tar.gz"
	echo "$line"
	wget https://downloads.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz
	filename0="hadoop-3.3.1.tar.gz"
	echo "Extracting $filename0"
	echo "$line"
	tar -xvzf $filename0 > /dev/null
	sleep 1
	sudo mv $filename0 /usr/local/hadoop
	sleep 1
	sudo mkdir /usr/local/hadoop/logs
	sleep 1
	sudo chown -R $USER:$USER /usr/local/hadoop
	sleep 1

else
	read -e -p "Enter hadoop file name [it must be in current directory!]: " filename0
fi

filename1=$(echo $filename0 | awk -F .tar '{print $1}')

echo "Extracting $filename0"
echo "$line"
tar -xvzf $filename0 > /dev/null
sleep 1
sudo mv $filename1 /usr/local/hadoop
sleep 1
sudo mkdir /usr/local/hadoop/logs
sleep 1
sudo chown -R $USER:$USER /usr/local/hadoop
sleep 1

echo "Adding ENV variables"
echo "$line"

{
	echo '# HADOOP INSTALLIATION ENV VARIABLES'
	echo 'export HADOOP_HOME=/usr/local/hadoop'
	echo 'export HADOOP_INSTALL=$HADOOP_HOME'
	echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME'
	echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME'
	echo 'export HADOOP_HDFS_HOME=$HADOOP_HOME'
	echo 'export YARN_HOME=$HADOOP_HOME'
	echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native'
	echo 'export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin'
	echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"'

} >> /home/$USER/.bashrc

echo "Restarting bashrc..."
source /home/$USER/.bashrc
echo "$line"
echo "Configuring java Environmental variables"
echo "$line"

javac_path=$(/usr/bin/which javac) 
openjdk_path=$(/usr/bin/readlink -f $javac_path)

echo "$line"

echo "Editing hadoop-env.sh file"
echo "$line"


{
	echo '# java-Openjdk path'
	echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64'
	echo 'export HADOOP_CLASSPATH+="$HADOOP_HOME/lib/*.jar"'

} >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh

echo "Downloading activation-api"
echo "$line"

wget https://jcenter.bintray.com/javax/activation/javax.activation-api/1.2.0/javax.activation-api-1.2.0.jar -P /usr/local/hadoop/lib


source /home/$USER/.bashrc
echo "$line"
echo "$line"
echo "Checking Hadoop version"
hadoop version
echo "$line"
echo "$line"


xml1='<?xml version="1.0" encoding="UTF-8"?>'
xml2='<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>'


echo "Editing core-site.xml"
echo "$line"

{
	echo "$xml1"
	echo "$xml2"
	echo ' '
	echo '<configuration>'
	echo '<property>'
	echo '<name>fs.default.name</name>'
	echo '<value>hdfs://0.0.0.0:9000</value>'
	echo '<description>The default file system URI</description>'
	echo '</property>'
	echo '</configuration>'
	echo ' '
} > /usr/local/hadoop/etc/hadoop/core-site.xml

echo "Creating Namenode & Datanode"
echo "$line"
sudo mkdir -p /home/$USER/hdfs/{namenode,datanode}
sudo chown -R $USER:$USER /home/$USER/hdfs


echo "$line"
echo "Editing hdfs-site.xml file"
echo "$line"

{

	echo "$xml1"
	echo "$xml2"
	echo '<configuration>'
	echo '<property>'
	echo '<name>dfs.replication</name>'
	echo '<value>1</value>'
	echo '</property>'
	echo ''
	echo '<property>'
	echo '<name>dfs.name.dir</name>'
	echo "<value>file:///home/$USER/hdfs/namenode</value>"
	echo '</property>'
	echo ''
	echo '<property>'
	echo '<name>dfs.data.dir</name>'
	echo "<value>file:///home/$USER/hdfs/datanode</value>"
	echo '</property>'
	echo '</configuration>'

} > /usr/local/hadoop/etc/hadoop/hdfs-site.xml

echo "$line"
echo "Editing mapred-site.xml"
echo "$line"

{
	echo "$xml1"
	echo "$xml2"
	echo '<configuration>'
	echo '<property>'
	echo '<name>mapreduce.framework.name</name>'
	echo '<value>yarn</value>'
	echo '</property>'
	echo '</configuration>'
} > /usr/local/hadoop/etc/hadoop/mapred-site.xml


echo "$line"
echo "Editing yarn-site.xml"
echo "$line"

{

	echo "$xml1"
	echo "$xml2"
	echo '<configuration>'
	echo '<property>'
	echo '<name>yarn.nodemanager.aux-services</name>'
	echo '<value>mapreduce_shuffle</value>'
	echo '</property>'
	echo '</configuration>'

} > /usr/local/hadoop/etc/hadoop/yarn-site.xml


hdfs namenode -format

echo "$line"
echo "$line"
echo "*** Installiation done ****"
echo " "
echo "[!] To start hadoop server enter [!]"
echo "start-all.sh"
echo "start-yarn.sh"
echo " "
echo "[!] To stop hadoop server enter [!]"
echo "stop-all.sh"
echo "stop-yarn.sh"

echo "$line"
echo "$line"

echo " "
echo " "
echo "***   ThankYou :)   ***"
echo " "
echo " "
exit 0