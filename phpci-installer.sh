#!/bin/bash

#------------------------------------------------------------------------------
#                       PHPCI Installer for Laravel Homestead
#------------------------------------------------------------------------------
#
# Project URL:  https://github.com/irazasyed/phpci-installer
#

##################
# Default Config #
##################
DEFAULT_DOMAIN=phpci.app
DEFAULT_DIRNAME=phpci
DB_NAME=phpci
MYSQL_CONF=~/.my.cnf

##################
# PHPCI Defaults #
##################
DEFAULT_URL=http://$DEFAULT_DOMAIN
ADMIN_USERNAME=phpci
ADMIN_PASSWORD=secret
ADMIN_EMAIL=phpci@homestead.vm

[[ "$1" ]] && DEFAULT_DOMAIN=$1
[[ "$2" ]] && ADMIN_EMAIL=$2
[[ "$3" ]] && ADMIN_PASSWORD=$3
[[ "$4" ]] && DEFAULT_DIRNAME=$4

DEFAULT_PATH=$PWD/$DEFAULT_DIRNAME

#
# Helper function to output in color
#
coloredEcho() {
    tput setaf $2;
    echo "$1";
    tput sgr0;
}

info() {
    coloredEcho "$1" 2;
}

note() {
    coloredEcho "$1" 3;
}

info "****************************"
info " Welcome to PHPCI Installer"
info "****************************"

# Download PHPCI & Run Composer Install
info "Downloading and Installing PHPCI Dependencies."
composer create-project block8/phpci $DEFAULT_PATH --keep-vcs --no-dev --prefer-dist
cd $DEFAULT_PATH && composer du -o

# Increase PHP Memory Limit
info "Increasing PHP Memory Limit."
sudo sed -i "s/memory_limit = .*/memory_limit = 1024M/" /etc/php5/cli/php.ini

# Setup Database
info "Setting up MySQL Database."
mysql -u$DB_USER -p$DB_PASSWORD -e "DROP DATABASE IF EXISTS \`${DB_NAME}\`; CREATE DATABASE \`${DB_NAME}\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci";
sudo service mysql restart

info "Adding MySQL Config."
touch $MYSQL_CONF
cat >$MYSQL_CONF <<EOF
[mysqld]
max_allowed_packet=64M
innodb_log_file_size=512M
innodb_log_buffer_size=768M
EOF

# Run PHPCI Install
info "Starting PHPCI Console Install."
php ./console phpci:install --url=http://$DEFAULT_DOMAIN --db-host=$DB_HOST --db-name=$DB_NAME --db-user=$DB_USER --db-pass=$DB_PASSWORD --admin-name=$1 --admin-pass=$2 --admin-mail=$3

# Setup Cron
info "Setting up Cron Job!"
croncmd="php $(pwd)/console phpci:run-builds"
cronjob="* * * * * $croncmd"
cat <(fgrep -i -v "${croncmd}" <(crontab -l)) <(echo "${cronjob}") | crontab -

# Provision
info "Provisioning PHPCI"
sudo bash /vagrant/scripts/serve.sh $DEFAULT_DOMAIN $(pwd)/public

info "*********************"
info "Install success."
info "You can access it at:"
note "http://${DEFAULT_DOMAIN}"
info "*********************"
info "Don't forget to add the domain to /etc/hosts file on your main machine!"
