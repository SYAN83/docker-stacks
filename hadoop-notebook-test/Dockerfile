# Copyright NYC Data Science Academy
# Distributed under the terms of the MIT License.

ARG BASE_CONTAINER=jupyter/base-notebook
ARG HADOOP_DISTRIBUTION=hadoop-2.9.2

FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

USER root

# Update system & install all dependencies
RUN	apt update \
  && apt -y upgrade \
  && apt install -y --no-install-recommends \
  	 openjdk-8-jdk \
  	 ssh \
  	 rsync \
  	 vim \
     git \
     figlet \
  && rm -rf /var/lib/apt/lists/*

RUN adduser $NB_USER sudo

# Create hadoop user
# RUN adduser --disabled-password --gecos '' --gid $NB_GID hadoop
# RUN adduser hadoop sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER $NB_UID

# Install Hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop

ENV PATH=${PATH}:${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin

COPY $HADOOP_DISTRIBUTION/* ${HADOOP_HOME}/
COPY conf/ /conf/

RUN sudo ln -s /usr/local/$HADOOP_DISTRIBUTION ${HADOOP_HOME}

# Setup passphraseless ssh
RUN ssh-keygen -t rsa -P '' -f $HOME/.ssh/id_rsa
RUN cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
RUN chmod 0600 $HOME/.ssh/authorized_keys
# RUN cp /conf/ssh_config $HOME/.ssh/config

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
RUN sudo chown -R $NB_UID:$NB_GID ${HADOOP_HOME}

RUN cp /conf/core-site.xml ${HADOOP_CONF_DIR} \
  && cp /conf/hdfs-site.xml ${HADOOP_CONF_DIR}/hdfs-site.xml \
  && cp /conf/mapred-site.xml ${HADOOP_CONF_DIR}/mapred-site.xml \
  && cp /conf/yarn-site.xml ${YARN_CONF_DIR}/yarn-site.xml

# Set permissions
RUN chmod 744 -R ${HADOOP_HOME}

# Format HDFS
RUN ${HADOOP_HOME}/bin/hdfs namenode -format

COPY start-hadoop.sh /usr/local/bin/
COPY stop-hadoop.sh /usr/local/bin/

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

