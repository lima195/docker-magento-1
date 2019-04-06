FROM php:7.1-fpm

RUN apt-get -qq update && apt-get -qq install libxml++2.6-dev > /dev/null
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd mbstring mysqli pdo pdo_mysql soap

RUN apt-get install -y libmcrypt-dev
RUN docker-php-ext-install mcrypt

RUN apt-get install -y libicu-dev
# RUN pecl install intl
RUN docker-php-ext-install intl

RUN apt-get install -y curl

COPY ./bin/init-baseurl /usr/local/bin/
COPY ./bin/n98-magerun.phar /usr/local/bin/

COPY ./etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf 
# WORKDIR /usr/share/nginx/www
# VOLUME /usr/share/nginx/www