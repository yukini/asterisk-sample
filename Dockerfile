FROM --platform=linux/amd64 ubuntu:24.04

ENV asterisk_version=20.8.1

RUN apt-get update && \ 
    apt-get install -y build-essential vim wget curl lsof git && \ 
    apt-get install -y \
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
  ./configure --with-pjproject-bundled --with-jansson-bundled 

RUN cd asterisk-${asterisk_version} && \
  make menuselect.makeopts && \ 
  menuselect/menuselect \
     --enable codec_opus \
     --enable res_crypto \
     --enable res_http_websocket \
     --enable res_pjsip_transport_websocket menuselect.makeopts && \
  make -j4 && \
  make install && \
  make samples 

RUN apt install -y ssl-cert nginx supervisor 
RUN make-ssl-cert generate-default-snakeoil 

# RUN contrib/scripts/ast_tls_cert -C localhost -O "My Organization" -b 2048 -d /etc/asterisk/keys 

RUN git clone https://github.com/InnovateAsterisk/Browser-Phone.git 
RUN cp -r Browser-Phone/Phone/* /var/www/html/ 

COPY nginx.default.conf /etc/nginx/sites-available/default

COPY pjsip.conf       /etc/asterisk/pjsip.conf
COPY extensions.conf  /etc/asterisk/extensions.conf
COPY http.conf       /etc/asterisk/http.conf

# Supervisorの設定ファイルを作成
# RUN mkdir -p /etc/supervisor/conf.d
# COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# デフォルトのコマンド
# CMD ["/usr/bin/supervisord"]
