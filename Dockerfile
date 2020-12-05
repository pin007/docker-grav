FROM php:7.4-apache

ARG GRAV_VERSION=1.6.30
# Variant of installation package: grav, grav-admin
ARG GRAV_VARIANT=grav
ARG GRAV_URL=https://getgrav.org/download/core/${GRAV_VARIANT}/${GRAV_VERSION}
ARG GRAV_PATH=/tmp/${GRAV_VARIANT}-v${GRAV_VERSION}.zip
ARG GRAV_USER=www-data
ARG GRAV_GROUP=www-data
ARG GRAV_WORKING_DIRS="assets backup cache images logs tmp user"
ARG GRAV_PLUGINS="admin email error form login markdown-notices problems"

ARG PHP_EXTENSIONS="gd zip"

RUN apt-get update \
    && apt-get upgrade -y \
## base packages and debug tools
    && apt-get install --no-install-recommends --no-install-suggests -y ca-certificates curl less vim-tiny\
    && apt-get install --no-install-recommends --no-install-suggests -y libpng-dev libzip-dev \
    && apt-get install --no-install-recommends --no-install-suggests -y unzip \
## grav instalation
    && a2enmod rewrite \
    && docker-php-ext-install ${PHP_EXTENSIONS} \
    && curl -s -L ${GRAV_URL} -o ${GRAV_PATH} \
    && unzip ${GRAV_PATH} -d /var/www/html \
    && mv -t . /var/www/html/${GRAV_VARIANT}/* /var/www/html/${GRAV_VARIANT}/.htaccess \
    && rm -rf ${GRAV_PATH} /var/www/html/${GRAV_VARIANT} \
## system cleanup after installation
    && apt-get purge --auto-remove -y unzip \
    && apt-get purge --auto-remove -y \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN if [ -n "${GRAV_PLUGINS}" ]; then echo "Installing Grav plugins ${GRAV_PLUGINS}"; bin/gpm install ${GRAV_PLUGINS}; fi
RUN chown -R ${GRAV_USER}:${GRAV_GROUP} ${GRAV_WORKING_DIRS}
