
# Copyright NYC Data Science Academy
# Distributed under the terms of the MIT License.

FROM nycdsa/hadoop-base:0.3

LABEL maintainer="Shu Yan <yanshu.usc@gmail.com>"
LABEL description="This image sets up a hadoop cluster with tez/hive/pig"

USER root

RUN echo 'Installing packages'
RUN	apt update \
  && apt -y upgrade \
  && apt install -y --no-install-recommends \
  	 g++ \
  	 build-essential \
  	 maven \
  	 autoconf \
  	 libtool \
  	 automake \
  && rm -rf /var/lib/apt/lists/*

# Install Mysql
RUN apt update \
	&& DEBIAN_FRONTEND=noninteractive apt -y install mysql-server \
	&& usermod -d /var/lib/mysql/ mysql

# Install protobuf
RUN echo 'Installing protobuf'
COPY protobuf-2.5.0 /tmp/protobuf-2.5.0
RUN cd /tmp/protobuf-2.5.0 \
	&& chmod +x autogen.sh && ./autogen.sh \
	&& chmod +x configure && ./configure --prefix=/usr --disable-dependency-tracking \
	&& make && make install \
	&& rm -r /tmp/protobuf-2.5.0


USER hadoop
COPY conf/ /conf/

# Install tez
RUN echo 'Installing Tez'

ENV TEZ_CONF_DIR=$HADOOP_CONF_DIR
ENV TEZ_HOME=/usr/local/apache-tez-0.9.1-src
ENV TEZ_JARS=$TEZ_HOME
ENV HADOOP_CLASSPATH=${HADOOP_CLASSPATH}:${TEZ_CONF_DIR}:${TEZ_JARS}/*:${TEZ_JARS}/lib/*

COPY apache-tez-0.9.1-src $TEZ_HOME
RUN sudo chown -R hadoop:hadoop /usr/local/apache-tez-0.9.1-src \
	&& sudo ln -s $TEZ_HOME /usr/local/tez \
	&& cp /conf/pom.xml /usr/local/tez/pom.xml \
	&& cp /conf/tez-site.xml $TEZ_CONF_DIR/tez-site.xml \
	&& cp /conf/mapred-site.xml $HADOOP_CONF_DIR/mapred-site.xml \
	&& cd $TEZ_HOME \
	&& mvn clean install -DskipTests=true -Dmaven.javadoc.skip=true \
	&& tar xzvf tez-dist/target/tez-0.9.1-minimal.tar.gz -C $TEZ_JARS


# Install Hive
RUN echo 'Installing Hive'

ENV HIVE_HOME=/usr/local/apache-hive-2.3.4-bin
ENV HIVE_CONF_DIR=$HIVE_HOME/conf
ENV HCAT_HOME=$HIVE_HOME/hcatalog
ENV PATH=$PATH:$HIVE_HOME/bin:$HCAT_HOME/bin

COPY apache-hive-2.3.4-bin $HIVE_HOME
RUN sudo chown -R hadoop:hadoop $HIVE_HOME \
	&& sudo ln -s $HIVE_HOME /usr/local/hive \
	&& cp /conf/hive-site.xml $HIVE_CONF_DIR/hive-site.xml 

# Install mysql connector
ENV mysql_conn_var=8.0.15
RUN sudo dpkg -i /conf/mysql-connector-java_${mysql_conn_var}-1ubuntu18.10_all.deb \
 	&& sudo apt install -f \
 	&& sudo ln -s /usr/share/java/mysql-connector-java-${mysql_conn_var}.jar $HIVE_HOME/lib/mysql-connector-java.jar


# Install Pig
RUN echo 'Installing Pig'

ENV PIG_HOME=/usr/local/pig-0.17.0
ENV PIG_CONF_DIR=$PIG_HOME/conf
ENV PIG_CLASSPATH=$HADOOP_CLASSPATH/HADOOP_CONF_DIR
ENV PATH=$PATH:$PIG_HOME/bin

COPY pig-0.17.0 $PIG_HOME
RUN sudo chown -R hadoop:hadoop $PIG_HOME \
	&& sudo ln -s $PIG_HOME /usr/local/pig \ 
	&& cp /conf/pig.properties $PIG_CONF_DIR/pig.properties

COPY start-hadoop.sh /usr/local/bin/

# Delete slf4j to prevent SLF4J binding warning
# RUN sudo rm /usr/local/hadoop-2.9.2/share/hadoop/common/lib/slf4j-log4j12-1.7.25.jar
RUN sudo rm /usr/local/apache-hive-2.3.4-bin/lib/log4j-slf4j-impl-2.6.2.jar
RUN sudo rm /usr/local/apache-tez-0.9.1-src/lib/slf4j-log4j12-1.7.10.jar
  
