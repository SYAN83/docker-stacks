#!/bin/bash

# start ssh server
sudo /etc/init.d/ssh start
# set hadoop environment
sed -i "/export JAVA_HOME=/c\JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" $HADOOP_CONF_DIR/hadoop-env.sh
# start hdfs
$HADOOP_HDFS_HOME/sbin/start-dfs.sh
# create HDFS directory
if ! $($HADOOP_HDFS_HOME/bin/hdfs dfs -test -d /user) ; then
    echo "Creating hadoop directory"
    $HADOOP_HDFS_HOME/bin/hdfs dfs -mkdir /user
fi
if ! $($HADOOP_HDFS_HOME/bin/hdfs dfs -test -d /user/$NB_USER) ; then
    $HADOOP_HDFS_HOME/bin/hdfs dfs -mkdir /user/$NB_USER
    $HADOOP_HDFS_HOME/bin/hdfs dfs -chown $NB_USER:$NB_USER /user/$NB_USER
fi
# start yarn
$HADOOP_YARN_HOME/sbin/yarn-daemon.sh start resourcemanager
$HADOOP_YARN_HOME/sbin/yarn-daemon.sh start nodemanager
# start historyserver
$HADOOP_MAPRED_HOME/sbin/mr-jobhistory-daemon.sh start historyserver
# welcome screen
echo
figlet -f slant Hadoop Base
echo "                                Powered By NYC Data Science Academy"
echo
cat /etc/lsb-release | grep DISTRIB_DESCRIPTION | cut -d \" -f2
hadoop version | head -n 1
echo