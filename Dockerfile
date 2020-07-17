FROM php:7.2-apache

RUN apt-get update && apt-get install -y libxml2-dev zlib1g-dev unzip libcurl3-dev libpng-dev

RUN docker-php-ext-install pdo_mysql zip gd mysqli soap
RUN touch /var/www/html/xdebug.log

RUN a2enmod rewrite
RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >>  /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_connect_back=off" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.idekey=docker" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_host=host.docker.internal" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_log=/var/www/html/xdebug.log" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.default_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini

ENV PORT 8080
RUN sed -i "/^\s*Listen 80/c\Listen $PORT" /etc/apache2/*.conf \
    && sed -i "/^\s*<VirtualHost \*:80>/c\<VirtualHost \*:$PORT>" /etc/apache2/sites-available/000-default.conf \
    && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

EXPOSE 8080
