#!/usr/bin/env bash

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
function coloredEcho(){
    local exp=$1;
    local color=$2;
    if ! [[ $color =~ '^[0-9]$' ]] ; then
       case $(echo $color | tr '[:upper:]' '[:lower:]') in
        black) color=0 ;;
        red) color=1 ;;
        green) color=2 ;;
        yellow) color=3 ;;
        blue) color=4 ;;
        magenta) color=5 ;;
        cyan) color=6 ;;
        white|*) color=7 ;; # white or invalid color
       esac
    fi
    tput setaf $color;
    echo "$exp";
    tput sgr0;
}

coloredEcho "****************************" green
coloredEcho " Welcome to PHPCI Installer" green
coloredEcho "****************************" green

# Download PHPCI & Run Composer Install
coloredEcho "Downloading and Installing PHPCI Dependencies." green
composer create-project block8/phpci $DEFAULT_DIRNAME --keep-vcs --no-dev --prefer-dist
cd $DEFAULT_DIRNAME && composer install --no-dev --prefer-dist --optimize-autoloader

# Increase PHP Memory Limit
coloredEcho "Increasing PHP Memory Limit." green
sudo sed -i "s/memory_limit = .*/memory_limit = 1024M/" /etc/php5/cli/php.ini

# Setup Database
coloredEcho "Setting up MySQL Database." green
mysql -u$DB_USER -p$DB_PASSWORD -e "DROP DATABASE IF EXISTS \`${DB_NAME}\`; CREATE DATABASE \`${DB_NAME}\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci";
sudo service mysql restart

coloredEcho "Adding MySQL Config." green
touch $MYSQL_CONF
cat >$MYSQL_CONF <<EOF
[mysqld]
max_allowed_packet=64M
innodb_log_file_size=512M
innodb_log_buffer_size=768M
EOF

# Run PHPCI Install
coloredEcho "Starting PHPCI Console Install." green
php ./console phpci:install --url=http://$DEFAULT_DOMAIN --db-host=$DB_HOST --db-name=$DB_NAME --db-user=$DB_USER --db-pass=$DB_PASSWORD

# Setup Cron
coloredEcho "Setting up Cron Job!" green
croncmd="php $(pwd)/console phpci:run-builds"
cronjob="* * * * * $croncmd"
cat <(fgrep -i -v "$croncmd" <(crontab -l)) <(echo "$cronjob") | crontab -

# Provision
coloredEcho "Provisioning PHPCI" green
sudo bash /vagrant/scripts/serve.sh $DEFAULT_DOMAIN $(pwd)/public

coloredEcho "*********************" green
coloredEcho "Install success." green
coloredEcho "You can access it at:" green
coloredEcho "http://${DEFAULT_DOMAIN}" yellow
coloredEcho "*********************" green
coloredEcho "Don't forget to add the domain to /etc/hosts file on your main machine!" green
