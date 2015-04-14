PHPCI Installer
=========================

[![Latest Version](https://img.shields.io/github/release/irazasyed/phpci-installer.svg?style=flat-square)](https://github.com/irazasyed/phpci-installer/releases)
[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](LICENSE)


> [PHPCI][1] Installer for Laravel Homestead.
> Simple shell script that automatically installs the [PHPCI][1] with minimal user interaction on a Laravel Homestead box. Easy to get started quickly!

## Quick start


### Prerequisite

- [Laravel Homestead][2]

### Important!

The script drops the `phpci` database if it already exists and creates a new one. So if you already have a database with such name, make sure to either rename it or change the database name by forking this repo before installation.

### Installation

1. SSH into your Laravel Homestead Box (`homestead ssh`) and `cd` into Code/Projects Directory.
2. `$ curl -sSL http://lk.gd/phpci-install | bash` Follow the on-screen instructions.
3.  Open the `/etc/hosts` file on your main machine and add `192.168.10.10 phpci.app` where `192.168.10.10` is the default IP of your homestead box.
4. Go to [http://phpci.app](http://phpci.app)
5. (Optional) You can follow the [PHPCI wiki](https://github.com/Block8/PHPCI/wiki) for other configurations.

### Default Config

1. Default directory - `phpci`
2. Default domain - `phpci.app`
3. Database - Creates `phpci` database and uses `homestead` user with default password.

> **Note:** The script assumes the database username and password in your homestead box is the default and has not been changed.

## License

[MIT](LICENSE) © [Syed Irfaq R.](http://lk.gd/irazasyed)


## Additional information

Any issues, please [report here](https://github.com/irazasyed/phpci-installer/issues)

## Contributions

Contributions are welcome, Please create a PR.

[1]: https://www.phptesting.org/
[2]: http://laravel.com/docs/homestead