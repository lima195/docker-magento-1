FROM php:7.1-fpm

RUN usermod -u 1000 www-data
ARG DEBIAN_FRONTEND=noninteractive

# ENV GOPATH /root/gocode

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

# Get repository and install wget and vim
RUN apt-get update && apt-get install --no-install-recommends -y \
        wget \
        vim \
        git \
        apt-utils \
        unzip

# Install PHP extensions deps
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        zlib1g-dev \
        libicu-dev \
        g++ \
        unixodbc-dev \
        libxml2-dev \
        libaio-dev \
        # libmemcached-dev \
        freetds-dev \
		libssl-dev \
		openssl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/local/bin/composer \
	&& composer global require hirak/prestissimo --no-plugins --no-scripts

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
            iconv \
            mbstring \
            intl \
            mcrypt \
            gd \
            mysqli \
            pdo_mysql \
            soap \
            zip \
            xmlrpc \
            opcache

# Install APCu and APC backward compatibility
# RUN pecl install apcu \
#     && pecl install apcu_bc-1.0.3 \
#     && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
#     && docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

# Install PHPUnit
# RUN wget https://phar.phpunit.de/phpunit.phar -O /usr/local/bin/phpunit \
#     && chmod +x /usr/local/bin/phpunit

# Install Xdebug
RUN apt-get update \
    && pecl install -f xdebug \
    && docker-php-ext-enable xdebug \
    # && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20160303/xdebug.so" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=docker" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_host=172.22.0.1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

## Mailhog
# RUN apt-get update && apt-get install -q -y ssmtp mailutils && rm -rf /var/lib/apt/lists/*  \
#     && apt-get update \ 
#     && apt-get install -y golang-go \ 
#     && echo $HOME \
#     && mkdir $HOME/gocode \
#     && echo "export GOPATH=/root/gocode" >> ~/.profile \
#     && /bin/bash -c "source ~/.profile" \
#     && go get github.com/mailhog/MailHog \
#     && go get github.com/mailhog/mhsendmail

# ENV GOPATH $HOME/gocode

# RUN ln /root/gocode/bin/mhsendmail /usr/local/bin/mail \
#     && ln /root/gocode/bin/mhsendmail /usr/local/bin/sendmail \
#     && ln /root/gocode/bin/mhsendmail /usr/local/bin/mhsendmail \
#     && mv /usr/bin/mail /usr/bin/mail_bkp \
#     && ln /root/gocode/bin/mhsendmail /usr/bin/mail \
#     && ln /root/gocode/bin/mhsendmail /usr/bin/sendmail \
#     && ln /root/gocode/bin/mhsendmail /usr/bin/mhsendmail

# COPY ./etc/php_ini/php.ini /usr/local/etc/php/
# COPY ./etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf
# test Mailhog
# php -r "\$from = \$to = 'your.emailaddress@gmail.com'; \$x = mail(\$to, 'subject'.time(), 'Hello World', 'From: '. \$from); var_dump(\$x);"
#/etc/ssmtp/ssmtp.conf

#magerun-n98 install
COPY ./bin/n98-magerun.phar /usr/share/nginx/www/

# Clean repository
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./bin/* /usr/local/bin/

# Remove all docker images, containers and network
# 