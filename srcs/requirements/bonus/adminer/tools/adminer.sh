#!bin/bash

while ! test -f /var/www/html/wp-config.php; do
    echo "Waiting for config.php..."
    sleep 2
done

mkdir -p /var/run/php

mv /adminer.php /var/www/html/

exec "$@"