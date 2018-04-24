#!/bin/bash
###
### Contents Debian Stretch automatic deployment of sNow! in HA to conduct CI
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


### sNow Servers Configuration
cd /root/snow-tools
wget -O snow.conf "https://raw.githubusercontent.com/HPCNow/snow-ci/master/debian/snow.conf" --no-check-certificate
if [[ -e /sNow/snow-tools/etc/snow.conf ]]; then
    wget -O /etc/network/interfaces "https://raw.githubusercontent.com/HPCNow/snow-ci/master/debian/interfaces_snow02" --no-check-certificate
else
    wget -O /etc/network/interfaces "https://raw.githubusercontent.com/HPCNow/snow-ci/master/debian/interfaces_snow01" --no-check-certificate
fi

cd /root
wget -O hosts "https://raw.githubusercontent.com/HPCNow/snow-ci/master/debian/hosts" --no-check-certificate
cat ./hosts >> /etc/hosts

### HA Configuration
wget -O corosync.conf "https://raw.githubusercontent.com/HPCNow/snow-ci/master/debian/corosync.conf" --no-check-certificate
wget -O active-domains.conf "https://raw.githubusercontent.com/HPCNow/snow-ci/master/debian/active-domains.conf" --no-check-certificate
wget -O setup_domains_ha.sh "https://raw.githubusercontent.com/HPCNow/snow-ci/master/debian/setup_domains_ha.sh" --no-check-certificate
chmod 700 setup_domains_ha.sh


### BeeGFS Configuration
cd /etc/apt/sources.list.d/
wget https://www.beegfs.io/release/latest-stable/dists/beegfs-deb9.list
wget -q https://www.beegfs.io/release/latest-stable/gpg/DEB-GPG-KEY-beegfs -O- | apt-key add -
apt update
apt upgrade -y
echo "
/beegfs/snow/testing/home                     /home          none  noauto,x-systemd.automount,x-systemd.device-timeout=60,_netdev,bind,x-systemd.requires=/beegfs/snow/testing/home   0 0
/beegfs/snow/testing/sNow                     /sNow          none  noauto,x-systemd.automount,x-systemd.device-timeout=60,_netdev,bind,x-systemd.requires=/beegfs/snow/testing/sNow 0 0
" >> /etc/fstab
