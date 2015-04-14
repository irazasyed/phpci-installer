#!/bin/bash

#------------------------------------------------------------------------------
#                       PHPCI Installer for Laravel Homestead
#------------------------------------------------------------------------------
#
# Project URL:  https://github.com/irazasyed/phpci-installer
#


# Default Config
DEFAULT_DOMAIN=phpci.app
DEFAULT_DIRNAME=phpci

DB_HOST=localhost
DB_NAME=phpci
DB_USER=homestead
DB_PASSWORD=secret

MYSQL_CONF=~/.my.cnf

#
# Helper function to output in color
#
coloredEcho(){
    tput setaf $2;
    echo "$1";
    tput sgr0;
}

coloredEcho "****************************" 2
coloredEcho " Welcome to PHPCI Installer" 2
coloredEcho "****************************" 2

# Download PHPCI & Run Composer Install
coloredEcho "Downloading and Installing PHPCI Dependencies." 2
composer create-project block8/phpci $DEFAULT_DIRNAME --keep-vcs --no-dev --prefer-dist
cd $DEFAULT_DIRNAME && composer install --no-dev --prefer-dist --optimize-autoloader

# Increase PHP Memory Limit
coloredEcho "Increasing PHP Memory Limit." 2
sudo sed -i "s/memory_limit = .*/memory_limit = 1024M/" /etc/php5/cli/php.ini

# Setup Database
coloredEcho "Setting up MySQL Database." 2
mysql -u$DB_USER -p$DB_PASSWORD -e "DROP DATABASE IF EXISTS \`${DB_NAME}\`; CREATE DATABASE \`${DB_NAME}\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci";
sudo service mysql restart

coloredEcho "Adding MySQL Config." 2
touch $MYSQL_CONF
cat >$MYSQL_CONF <<EOF
[mysqld]
max_allowed_packet=64M
innodb_log_file_size=512M
innodb_log_buffer_size=768M
EOF

# Run PHPCI Install
coloredEcho "Starting PHPCI Console Install." 2
php ./console phpci:install --url=http://$DEFAULT_DOMAIN --db-host=$DB_HOST --db-name=$DB_NAME --db-user=$DB_USER --db-pass=$DB_PASSWORD

# Setup Cron
coloredEcho "Setting up Cron Job!" 2
croncmd="php $(pwd)/console phpci:run-builds"
cronjob="* * * * * $croncmd"
cat <(fgrep -i -v "${croncmd}" <(crontab -l)) <(echo "${cronjob}") | crontab -

# Provision
coloredEcho "Provisioning PHPCI" 2
sudo bash /vagrant/scripts/serve.sh $DEFAULT_DOMAIN $(pwd)/public

coloredEcho "*********************" 2
coloredEcho "Install success." 2
coloredEcho "You can access it at:" 2
coloredEcho "http://${DEFAULT_DOMAIN}" 3
coloredEcho "*********************" 2
coloredEcho "Don't forget to add the domain to /etc/hosts file on your main machine!" 2
