#!/bin/bash

DB_PASS="$(cat /run/secrets/db_password)"

rm -f /var/lib/mysql/aria_log_control
rm -f /var/lib/mysql/*.pid
rm -f /run/mysqld/mysqld.sock

service mariadb start

sleep 5

if ! mariadb -e "SELECT 1;" > /dev/null 2>&1; then
    echo "Mariadb Error."
    exit 1
fi

mariadb -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mariadb -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';"
mariadb -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"
mariadb -e "FLUSH PRIVILEGES;"

mariadb -e "SHUTDOWN;"

exec "$@"
