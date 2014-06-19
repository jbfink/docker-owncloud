FROM ubuntu:12.04
MAINTAINER Rainer Jung "rainer.jung@gmail.com"

##### CONFIG
ENV APP_DATA /var/www/owncloud/data
ENV SSL_SUBJ /C=DE/ST=BY/L=Munich/O=Private/CN=files.rjung.org
##### END CONFIG

RUN echo 'deb http://archive.ubuntu.com/ubuntu precise multiverse' >> /etc/apt/sources.list
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise universe' >> /etc/apt/sources.list
RUN echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/community/xUbuntu_12.04/ /' >> /etc/apt/sources.list.d/owncloud.list
RUN apt-get install -y wget python-software-properties

RUN add-apt-repository ppa:nginx/stable

RUN wget -qO - http://download.opensuse.org/repositories/isv:ownCloud:community/xUbuntu_12.04/Release.key  | apt-key add -
RUN apt-get -y update
RUN apt-get install -y nginx owncloud openssl php5-common php5-cli php5-fpm

# Generate SSL certificate
RUN cd ~
RUN openssl req -new -newkey rsa:2048 -days 1825 -nodes -x509 -subj $SSL_SUBJ -keyout owncloud.key -out owncloud.crt
RUN mkdir /etc/nginx/certs
RUN mv owncloud.* /etc/nginx/certs/

ADD ./site-owncloud /etc/nginx/sites-available/owncloud
RUN ln -s /etc/nginx/sites-available/owncloud /etc/nginx/sites-enabled/
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/listen\ \=\ 127.0.0.1:9000/listen\ =\ \/var\/run\/php5-fpm.sock/g" /etc/php5/fpm/pool.d/www.conf

ADD start.sh start.sh

VOLUME ["/var/www/owncloud/data"]

EXPOSE 443

CMD ["/start.sh"]

