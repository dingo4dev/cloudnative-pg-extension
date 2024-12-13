# Reference: https://cloudnative-pg.io/blog/creating-container-images/
ARG PG_MAJOR="17"
ARG ORACLE_VERSION="19.25.0.0.0"
FROM ghcr.io/cloudnative-pg/postgresql:$PG_MAJOR-bullseye

USER root

RUN  echo Postgresql Major Version: $PG_MAJOR && echo Oracle instant client version: $ORACLE_VERSION


# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    unzip \
    libaio1 \
    postgresql-server-dev-$PG_MAJOR \
    && rm -rf /var/lib/apt/lists/*

# Install Oracle Instant Client for support oracle 11g
RUN mkdir -p /opt/oracle && \
    cd /opt/oracle && \
    wget https://download.oracle.com/otn_software/linux/instantclient/$(echo $ORACLE_VERSION | tr -d '.')/instantclient-basiclite-linux.x64-$ORACLE_VERSION-dbru.zip && \
    wget https://download.oracle.com/otn_software/linux/instantclient/$(echo $ORACLE_VERSION | tr -d '.')/instantclient-sdk-linux.x64-$ORACLE_VERSION-dbru.zip && \
    mv instantclient-basiclite-linux.x64-$ORACLE_VERSION-dbru.zip instantclient-basiclite-linuxx64.zip && \
    mv instantclient-sdk-linux.x64-$ORACLE_VERSION-dbru.zip instantclient-sdk-linuxx64.zip && \
    unzip instantclient-basiclite-linuxx64.zip && \
    unzip instantclient-sdk-linuxx64.zip && \
    rm -f instantclient-basiclite-linuxx64.zip instantclient-sdk-linuxx64.zip && \
    echo /opt/oracle/instantclient* > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig

ENV ORACLE_HOME=/opt/oracle/instantclient*
ENV LD_LIBRARY_PATH=$ORACLE_HOME

# Clone and build oracle_fdw
RUN git clone https://github.com/laurenz/oracle_fdw.git \
    && cd oracle_fdw \
    && make ORACLE_HOME=$ORACLE_HOME \
    && make install

# Add extension to postgresql.conf
# RUN echo "shared_preload_libraries = 'oracle_fdw'" >> /usr/share/postgresql/postgresql.conf.sample

# Cleanup
RUN apt-get remove -y build-essential git postgresql-server-dev-$PG_MAJOR \
    && apt-get autoremove -y \
    && apt-get clean

# Change the uid of postgres to 26
RUN usermod -u 26 postgres
USER 26