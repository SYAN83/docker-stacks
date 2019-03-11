
# Copyright NYC Data Science Academy
# Distributed under the terms of the MIT License.

FROM nycdsa/hadoop-notebook:0.4

LABEL maintainer="Shu Yan <yanshu.usc@gmail.com>"
LABEL description="This image sets up a hadoop cluster with tez/hive/pig"

USER root

# Install Spark
RUN echo 'Installing Spark'

ARG SPARK_DOWNLOAD=spark-2.4.0-bin-without-hadoop

ENV SPARK_HOME=/usr/local/spark-2.4.0
ENV SPARK_CONF_DIR=$SPARK_HOME/conf
ENV PATH=$PATH:$SPARK_HOME/bin

COPY $SPARK_DOWNLOAD $SPARK_HOME
RUN sudo chown -R hadoop:hadoop $SPARK_HOME \
  && sudo ln -s $SPARK_HOME /usr/local/spark

USER hadoop

COPY conf/* /conf/

RUN cp /conf/spark-defaults.conf /usr/local/spark/conf/spark-defaults.conf
RUN cp /conf/spark-env.sh /usr/local/spark/conf/spark-env.sh

RUN chmod +x /usr/local/spark/conf/spark-env.sh \
  && sudo jar cv0f /conf/spark-libs.jar -C $SPARK_HOME/jars/ .

RUN sudo mkdir /opt/conda/share/jupyter/kernels/pyspark \
  && sudo cp /conf/kernel.json /opt/conda/share/jupyter/kernels/pyspark/kernel.json


COPY start-hadoop.sh /usr/local/bin/

# Spark Web UI
EXPOSE 4040
# Spark Master web UI port
EXPOSE 18080


