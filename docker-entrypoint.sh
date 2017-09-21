#!/bin/sh
set -e

VERSION_SRC=$(cat /usr/src/APP_VERSION)
[ -f /var/www/html/APP_VERSION ] \
    && VERSION_VOLUME=$(cat /var/www/html/APP_VERSION) \
    || VERSION_VOLUME=""

if [ "$VERSION_VOLUME" != "$VERSION_SRC" ]; then
    rsync -ax --delete --chown www-data:root \
        --exclude /cache/ \
        --exclude /config.php \
        --exclude /feed-icons/ \
        --exclude /lock/ \
        /usr/src/app/ \
        /var/www/html/

    cp /usr/src/APP_VERSION /var/www/html/APP_VERSION
fi

STATIC_FOLDERS="cache feed-icons lock"
for FOLDER in ${STATIC_FOLDERS}; do
    if [ ! -d /var/www/html/${FOLDER} ]; then
        rsync -ax /usr/src/app/${FOLDER}/ /var/www/html/${FOLDER}/
    fi
done

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php "$@"
fi

exec "$@"

