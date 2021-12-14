#!/bin/bash

cd /usr/share/egroupware
rm -rf cao/
rm -rf attendance/
git clone https://github.com/agroviva/cao
git clone https://github.com/agroviva/attendance
docker-compose -f /etc/egroupware-docker/docker-compose.yml restart egroupware
