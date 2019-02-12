# Copyright (c) IBM Corporation 2016 
# Distributed under the terms of the MIT License.

# Hadoop distribution
ARG HADOOP_DISTRIBUTION=hadoop-2.9.2

# Ubuntu image 
FROM ubuntu:18.10

LABEL maintainer="Shu Yan <yanshu.usc@gmail.com>"
LABEL description="This image sets up a single-node hadoop cluster in pseudo-distributed mode where each Hadoop daemon runs in a separate Java process"

USER root

# Update system & install all dependencies
RUN	apt update \
  && apt -y upgrade \
  && apt install -y --no-install-recommends \
  	 openjdk-8-jdk \
  	 ssh \
  	 rsync \
  	 sudo \
  	 ca-certificates \
  	 vim \
  	 wget \
  	 locales \
     git \
     figlet \
  && rm -rf /var/lib/apt/lists/*

# Create hadoop user
RUN adduser --disabled-password --gecos '' hadoop
RUN adduser hadoop sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER hadoop
WORKDIR /home/hadoop

# Install Hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop-2.9.2
ENV PATH=${PATH}:${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin

COPY hadoop-2.9.2 ${HADOOP_HOME}
COPY conf/ /conf/

# Setup passphraseless ssh
RUN ssh-keygen -t rsa -P '' -f ${HOME}/.ssh/id_rsa
RUN cat ${HOME}/.ssh/id_rsa.pub >> ${HOME}/.ssh/authorized_keys
RUN chmod 0600 ${HOME}/.ssh/authorized_keys
RUN cp /conf/ssh_config $HOME/.ssh/config

# Configure environment
ENV HADOOP_PREFIX=${HADOOP_HOME}
ENV HADOOP_COMMON_HOME=${HADOOP_HOME}
ENV HADOOP_MAPRED_HOME=${HADOOP_HOME}
ENV HADOOP_HDFS_HOME=${HADOOP_HOME}
ENV HADOOP_YARN_HOME=${HADOOP_HOME}
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV YARN_CONF_DIR=${HADOOP_CONF_DIR}
ENV HADOOP_CLASSPATH=${JAVA_HOME}/lib/tools.jar

# Configure hadoop
RUN sudo chown -R hadoop:hadoop ${HADOOP_HOME}
RUN sudo ln -s ${HADOOP_HOME} /usr/local/hadoop
RUN cp /conf/core-site.xml ${HADOOP_CONF_DIR}/core-site.xml \
  && cp /conf/hdfs-site.xml ${HADOOP_CONF_DIR}/hdfs-site.xml \
  && cp /conf/mapred-site.xml ${HADOOP_CONF_DIR}/mapred-site.xml \
  && cp /conf/yarn-site.xml ${YARN_CONF_DIR}/yarn-site.xml

# Set permissions
RUN chmod 744 -R ${HADOOP_HOME}

# Format HDFS
RUN ${HADOOP_HOME}/bin/hdfs namenode -format

# ResourceManager WebUI
EXPOSE 8088
# NameNode/DataNode WebUI
EXPOSE 50070
EXPOSE 50075
# JobTracker/TaskTracker WebUI
EXPOSE 50030
EXPOSE 50060
# MapReduce JobHistory Server
EXPOSE 19888
# Jupyter notebook Port
EXPOSE 8888

COPY start.sh /usr/local/bin/
ENTRYPOINT start.sh; bash

