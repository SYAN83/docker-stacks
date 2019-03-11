#!/bin/bash

# start ssh server
sudo /etc/init.d/ssh start
# set hadoop environment
sed -i "/export JAVA_HOME=/c\JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" $HADOOP_CONF_DIR/hadoop-env.sh
# start mysql
sudo chown -R mysql:mysql /var/lib/mysql
sudo /etc/init.d/mysql start
# mysql create hive user
sudo mysql -uroot -e "CREATE USER IF NOT EXISTS 'hive'@'localhost' IDENTIFIED BY 'hive_passwd';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'hive'@'localhost';
GRANT ALL PRIVILEGES ON metastore.* TO 'hive'@'localhost';
FLUSH PRIVILEGES;"
# create hive initial database schema
schematool -dbType mysql -initSchema
# mysql create hadoop user
sudo mysql -uroot -e "CREATE DATABASE IF NOT EXISTS hadoop;
CREATE USER IF NOT EXISTS 'hadoop'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO 'hadoop'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;"

tez_ver=tez-0.9.1
spark_ver=spark-2.4.0

# start hdfs
$HADOOP_HOME/sbin/start-dfs.sh
# create HDFS directory
if ! $($HADOOP_HDFS_HOME/bin/hdfs dfs -test -d /user) ; then
    echo "Creating user directory"
    $HADOOP_HDFS_HOME/bin/hdfs dfs -mkdir /user
    $HADOOP_HDFS_HOME/bin/hdfs dfs -mkdir /user/hadoop
    $HADOOP_HDFS_HOME/bin/hdfs dfs -chown hadoop:hadoop /user/hadoop
    echo "Creating directory for hive"
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/hive/warehouse
    $HADOOP_HOME/bin/hdfs dfs -chown -R hadoop:hadoop /user/hive/
    $HADOOP_HOME/bin/hdfs dfs -chmod g+w /user/hive/warehouse
fi
if ! $($HADOOP_HDFS_HOME/bin/hdfs dfs -test -d /apps) ; then
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /apps/${tez_ver} 
    $HADOOP_HOME/bin/hdfs dfs -copyFromLocal /usr/local/tez/tez-dist/target/${tez_ver}.tar.gz /apps/${tez_ver}/
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /apps/${spark_ver}
    $HADOOP_HOME/bin/hdfs dfs -copyFromLocal /conf/spark-libs.jar /apps/${spark_ver}/
fi

# start yarn
$HADOOP_YARN_HOME/sbin/yarn-daemon.sh start resourcemanager
$HADOOP_YARN_HOME/sbin/yarn-daemon.sh start nodemanager
# start historyserver
$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver

# welcome screen
echo
figlet -f slant Hadoop Stack
echo "                                Powered By NYC Data Science Academy"
echo 
cat /etc/lsb-release | grep DISTRIB_DESCRIPTION | cut -d \" -f2
mysql --version
hadoop version | head -n 1
hive --version | head -n 1
pig --version | head -n 1
spark-submit --version
echo