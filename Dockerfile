FROM wordpress:4-php7.2-fpm
VOLUME /var/www/html/
VOLUME /var/www/.composer
VOLUME /var/www/.wp-cli
WORKDIR /var/www/html/src

RUN \
cd /tmp; \
COMPOSER_SETUP='/tmp/composer-setup.php' && \
EXPECTED_SIGNATURE="$(curl https://composer.github.io/installer.sig)" && \
curl -s https://getcomposer.org/installer -o $COMPOSER_SETUP && \
ACTUAL_SIGNATURE="$(php -r "echo hash_file('SHA384', '/tmp/composer-setup.php');")" && \
[ $ACTUAL_SIGNATURE != $EXPECTED_SIGNATURE ] && >&2 echo 'ERROR: Invalid installer signature' && exit 1; \
php $COMPOSER_SETUP --quiet; \
rm $COMPOSER_SETUP; \
mv /tmp/composer.phar /usr/local/bin/composer;

RUN apt-get update; \
    apt-get install -y \
    mysql-client \
    less \
    sudo \
    locales \
    locales-all \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

    
RUN \
    curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o wp-cli.phar; \
    chmod +x wp-cli.phar; \
    sudo mv wp-cli.phar /usr/local/bin/wp;

RUN pecl install redis && docker-php-ext-enable redis
RUN pecl install xdebug

ENV LC_ALL es_CL.UTF-8
ENV LANG es_CL.UTF-8
ENV LANGUAGE es_CL.UTF-8

RUN \
    apt-get update && \
    apt-get install libldap2-dev -y && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap

USER www-data
