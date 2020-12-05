FROM php:7.4-fpm-alpine3.12

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

RUN apk add --no-cache curl libpng-dev libzip-dev \
## grav instalation
    && docker-php-ext-install ${PHP_EXTENSIONS} \
    && curl -s -L ${GRAV_URL} -o ${GRAV_PATH} \
    && unzip ${GRAV_PATH} -d /var/www/html \
    && mv /var/www/html/${GRAV_VARIANT}/* . \
    && mv /var/www/html/${GRAV_VARIANT}/.htaccess . \
    && rm -rf ${GRAV_PATH} /var/www/html/${GRAV_VARIANT}

RUN if [ -n "${GRAV_PLUGINS}" ]; then echo "Installing Grav plugins ${GRAV_PLUGINS}"; bin/gpm install ${GRAV_PLUGINS}; fi
RUN chown -R ${GRAV_USER}:${GRAV_GROUP} ${GRAV_WORKING_DIRS}
