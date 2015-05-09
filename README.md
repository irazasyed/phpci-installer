PHPCI Installer
=========================
[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](LICENSE)


> [PHPCI][1] Installer for Laravel Homestead.
> Simple shell script that automatically installs the [PHPCI][1] with no user interaction required on a Laravel Homestead box.

## Pre-Requisites

- [Laravel Homestead][2] configured and running.

### Important!

The script drops the `phpci` database if it already exists and creates a new one. So if you already have a database with such name, make sure to either rename it or change the database name by forking this repo before installation.

## Installation

**1.** SSH into your Laravel Homestead Box (`homestead ssh`) and `cd` into Code/Projects Directory.

**2.** If you're fine with the default config and don't want to make any changes, Just fire the following command & jump to step 3:

```
$ curl -sSL http://lk.gd/phpci-install | bash
```

**(Optional) Custom Config:** If you'd like to use custom config, pass the following arguments with appropriate values:

```
-s <domain> <admin_email> <admin_password> <custom_phpci_dirname>
``` 

All the above arguments are optional, you can set all or the each of the ones you want in same order.

**Example**:

```
$ curl -sSL http://lk.gd/phpci-install | bash -s phpci.vm phpci@homestead.vm 123456 phpci
```

**3.**  Open the `/etc/hosts` file on your main machine and add `192.168.10.10 phpci.app` where `192.168.10.10` is the default IP of your homestead box and `phpci.app` is the default domain to access PHPCI or the one you passed in step 2 otherwise.

**4.** Go to [http://phpci.app](http://phpci.app) and Login into the panel using the login credentials shown at the end of the installation or the default.

**5.** **(Optional)** You can follow the [PHPCI wiki](https://github.com/Block8/PHPCI/wiki) for other configurations.

## Default Config

1. Default directory - `phpci`
2. Default domain - `phpci.app`
3. Database - Creates `phpci` database and uses `homestead` user with default password.
4. Admin Email: `phpci@homestead.vm`
5. Admin Password: `secret`

> **Note:** The script uses the standard homestead `create-mysql.sh` script to create the database.


## Additional information

Any issues, please [report here](https://github.com/irazasyed/phpci-installer/issues)

Inspired to create this script by this [tutorial](https://medium.com/@genealabs/how-to-install-phpci-in-homestead-5ee0b022e8be) by [Mike Bronner](https://medium.com/@genealabs)

## Contributions

Contributions are welcome, Please create a PR.

## License

[MIT](LICENSE) © [Syed Irfaq R.](http://lk.gd/irazasyed)

[1]: https://www.phptesting.org/
[2]: http://laravel.com/docs/homestead
