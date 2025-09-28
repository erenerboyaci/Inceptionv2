#!/bin/bash
set -e

DB_PASS="$(cat /run/secrets/db_password)"
DB_ROOT_PASS="$(cat /run/secrets/db_root_password)"

NEEDS_INIT=false
if [ ! -d "/var/lib/mysql/mysql" ]; then
    NEEDS_INIT=true
    echo "Initializing MariaDB database..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
else
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    temp_pid="$!"
    
    until mysqladmin --socket=/run/mysqld/mysqld.sock ping &>/dev/null; do
        echo "Waiting for MariaDB to check existing users..."
        sleep 1
    done
    
    USER_EXISTS=false
    if mysql --socket=/run/mysqld/mysqld.sock -e "SELECT User FROM mysql.user WHERE User='${DB_USER}'" 2>/dev/null | grep -q "${DB_USER}"; then
        USER_EXISTS=true
    elif mysql --socket=/run/mysqld/mysqld.sock -uroot -p"${DB_ROOT_PASS}" -e "SELECT User FROM mysql.user WHERE User='${DB_USER}'" 2>/dev/null | grep -q "${DB_USER}"; then
        USER_EXISTS=true
    fi
    
    if [ "$USER_EXISTS" = false ]; then
        echo "Custom users missing, reinitializing..."
        NEEDS_INIT=true
    fi
    
    mysqladmin --socket=/run/mysqld/mysqld.sock shutdown 2>/dev/null || \
    mysqladmin --socket=/run/mysqld/mysqld.sock -uroot -p"${DB_ROOT_PASS}" shutdown 2>/dev/null
    wait "$temp_pid"
fi

if [ "$NEEDS_INIT" = true ]; then
    
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    pid="$!"
    
    until mysqladmin --socket=/run/mysqld/mysqld.sock ping &>/dev/null; do
        echo "Waiting for temporary MariaDB instance..."
        sleep 1
    done
    
    echo "Setting up database and users..."
    mariadb --socket=/run/mysqld/mysqld.sock <<-EOSQL
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
		DELETE FROM mysql.user WHERE User='';
		DROP DATABASE IF EXISTS test;
		CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
		CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
		CREATE USER IF NOT EXISTS '${WP_USER_ADMIN}'@'%' IDENTIFIED BY '${DB_ROOT_PASS}';
		GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
		GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${WP_USER_ADMIN}'@'%';
		FLUSH PRIVILEGES;
	EOSQL
    
    mysqladmin --socket=/run/mysqld/mysqld.sock -uroot -p"${DB_ROOT_PASS}" shutdown
    wait "$pid"
    
    echo "Database initialization completed."
fi

echo "Starting MariaDB as PID 1..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
