#!/bin/bash
###
### Contents Ubuntu 18.04 LTS (Bionic) automatic deployment of sNow! in HA to conduct CI
### Copyright (C) 2018  Jordi Blasco <jordi.blasco@hpcnow.com>
###
### This program is free software: you can redistribute it and/or modify
### it under the terms of the GNU General Public License as published by
### the Free Software Foundation, either version 3 of the License, or
### (at your option) any later version.
###
### This program is distributed in the hope that it will be useful,
### but WITHOUT ANY WARRANTY; without even the implied warranty of
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
### GNU General Public License for more details.
###
### You should have received a copy of the GNU General Public License
### along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

### Fetching CI setup
version=master
cd /root
git clone https://github.com/HPCNow/sNow.git
cd sNow
cp -p /root/sNow/tests/ci/ubuntu/single-snow.conf . 
if [[ -e /sNow/etc/snow.conf ]]; then
    wget -O /etc/netplan/01-netcfg.yaml "https://raw.githubusercontent.com/HPCNow/snow-ci/master/ubuntu/netplan_snow02" --no-check-certificate
else
    wget -O /etc/netplan/01-netcfg.yaml "https://raw.githubusercontent.com/HPCNow/snow-ci/master/ubuntu/netplan_snow01" --no-check-certificate
fi
export SNOW_EULA=accepted
./install.sh $version

apt update
apt upgrade -y

cat /root/sNow/tests/ci/ubuntu/hosts >> /etc/hosts

### Enable First Boot actions
cp -p /root/sNow/tests/ci/ubuntu/first_boot.service /lib/systemd/system/
cp -p /root/sNow/tests/ci/ubuntu/first_boot /usr/local/bin/first_boot
chmod 700 /usr/local/bin/first_boot
mkdir -p /usr/local/first_boot
chmod 700 /usr/local/first_boot
chown root /usr/local/first_boot

### Enable stage 01
cp -p /root/sNow/test/ci/ubuntu/single-stage-01.sh /usr/local/first_boot/
chmod 700 /usr/local/first_boot/single-stage-01.sh
systemctl enable first_boot
