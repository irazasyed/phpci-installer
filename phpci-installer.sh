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

# Setup Database - Uses Homestead's standard create MySQL script.
info "Setting up MySQL Database."
sudo bash /vagrant/scripts/create-mysql.sh $DB_NAME

info "Adding MySQL Config."
touch $MYSQL_CONF
cat >$MYSQL_CONF <<EOF
[mysqld]
max_allowed_packet=64M
innodb_log_file_size=512M
innodb_log_buffer_size=768M
EOF
sudo service mysql restart

# Run PHPCI Install
info "Starting PHPCI Console Install."
php ./console phpci:install --url=$DEFAULT_URL --db-host=localhost --db-name=$DB_NAME --db-user=homestead --db-pass=secret --admin-name=homestead --admin-pass=$ADMIN_PASSWORD --admin-mail=$ADMIN_EMAIL

# Setup Cron - Makes sure there is no cron job already set.
info "Setting up Cron Job!"
croncmd="php ${DEFAULT_PATH}/console phpci:run-builds"
cronjob="* * * * * $croncmd"
cat <(fgrep -i -v "${croncmd}" <(crontab -l)) <(echo "${cronjob}") | crontab -
sudo service cron restart

# Provision
info "Provisioning PHPCI"
sudo bash /vagrant/scripts/serve.sh $DEFAULT_DOMAIN $(pwd)/public

info "*********************"
info "Install success."
info "You can access it at:"
note "http://${DEFAULT_DOMAIN}"
info "*********************"
info "Don't forget to add the domain to /etc/hosts file on your main machine!"
