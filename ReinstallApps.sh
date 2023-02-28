#!/bin/bash

cd /usr/share/egroupware
rm -rf cao/
rm -rf attendance/
rm -rf threecx/
rm -rf wiki/
git clone https://github.com/agroviva/cao
git clone https://github.com/agroviva/attendance
git clone https://github.com/agroviva/threecx
git clone https://github.com/EGroupware/wiki
docker-compose -f /etc/egroupware-docker/docker-compose.yml restart egroupware
