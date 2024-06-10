FROM ubuntu:24.04

ENV asterisk_version=20.8.1

RUN apt update && \ 
    apt install -y build-essential vim wget curl lsof git && \ 
    apt install -y \
      libedit-dev \
      ncurses-dev \
      sqlite3 \
      libnewt-dev \
      libssl-dev \
      libncurses5-dev \
      subversion \
      libsqlite3-dev \
      libjansson-dev \
      libxml2-dev \
      uuid-dev 

WORKDIR /root 

RUN wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${asterisk_version}.tar.gz && \ 
  tar xf asterisk-${asterisk_version}.tar.gz && \
  cd asterisk-${asterisk_version} && \
  ./contrib/scripts/get_mp3_source.sh && \
  ./contrib/scripts/install_prereq install && \
  ./configure --with-jansson-bundled 

RUN cd asterisk-${asterisk_version} && \
  make -j4 

RUN cd asterisk-${asterisk_version} && \
  make install 

RUN cd asterisk-${asterisk_version} && \
  make samples 

COPY ./pjsip.conf       /etc/asterisk/pjsip.conf
COPY ./extensions.conf  /etc/asterisk/extensions.conf
COPY ./http.conf       /etc/asterisk/http.conf

