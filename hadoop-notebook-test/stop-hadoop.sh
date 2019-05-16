#!/bin/bash

# stop yarn
$HADOOP_YARN_HOME/sbin/yarn-daemon.sh stop resourcemanager
$HADOOP_YARN_HOME/sbin/yarn-daemon.sh stop nodemanager
# stop historyserver
$HADOOP_MAPRED_HOME/sbin/mr-jobhistory-daemon.sh stop historyserver
# stop hdfs
$HADOOP_HDFS_HOME/sbin/stop-dfs.sh
