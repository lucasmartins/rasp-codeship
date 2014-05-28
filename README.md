Rasp CodeShip
=============

This script expects both `CODESHIP_TOKEN` and `CODESHIP_PROJECT` environment variables to be set.

Install
=======

```bash
$ sudo su
# apt-get update
# apt-get install ruby # you can script this down to a simple ShellScript, but I like the rubies...
```

Log into your Pi and clone this repo!

## Run on Boot

Assuming you're using Raspbian, Occidentalis, or other Debian derived distros:

```bash
$ sudo su
# touch /etc/init.d/rasp-codeship
# chmod 755 /etc/init.d/rasp-codeship
# update-rc.d rasp-codeship defaults
```

This is a init script you should put into `/etc/init.d/rasp-codeship`
```bash
#!/bin/bash
export CODESHIP_TOKEN=
export CODESHIP_PROJECT=
ruby /home/pi/rasp-codeship/start.rb > /var/log/rasp-codeship.log
```
