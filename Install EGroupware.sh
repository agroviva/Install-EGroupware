#!/bin/bash
STD_MSG="About to Upgrade all the packages!"
echo STD_MSG;

sudo apt update && sudo apt upgrade -y

installEGroupware()
{
    echo 'deb http://download.opensuse.org/repositories/server:/eGroupWare/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/server:eGroupWare.list
    sudo apt install gnupg # required, but not installed by apt-key add in Debian 10 
    wget -nv https://download.opensuse.org/repositories/server:eGroupWare/xUbuntu_20.04/Release.key -O - | sudo apt-key add -

    apt install apache2 egroupware-docker -y
    mkdir -p /usr/share/egroupware

    sync_directories()
}

sync_directories()
{
    STD_MSG="Where is the data located;"
    read sourceEGW

    # scp -P 2712 -r root@sourceEGW:/usr/share/egroupware/cao/  /usr/share/egroupware/cao/
    # scp -P 2712 -r root@sourceEGW:/usr/share/egroupware/attendance/  /usr/share/egroupware/attendance/
    # scp -P 2712 -r root@sourceEGW:/usr/share/egroupware/threecx/  /usr/share/egroupware/threecx/

    rsync -u -r -v -e 'ssh -p 2712' root@sourceEGW:/usr/share/egroupware/cao/*  /usr/share/egroupware/cao/
    rsync -u -r -v -e 'ssh -p 2712' root@sourceEGW:/usr/share/egroupware/attendance/*  /usr/share/egroupware/attendance/
    rsync -u -r -v -e 'ssh -p 2712' root@sourceEGW:/usr/share/egroupware/threecx/*  /usr/share/egroupware/threecx/
    rsync -u -r -v -e 'ssh -p 2712' root@sourceEGW:/usr/share/egroupware/wiki/*  /usr/share/egroupware/wiki/


    # rsync -u --exclude 'tmp/*' -r -v -e 'ssh -p 2712' root@sourceEGW:/var/lib/egroupware/egw00/*  /var/lib/egroupware/egw00/
    # rsync -u --exclude 'tmp/*' -r -v -e 'ssh -p 2712' root@sourceEGW:/var/lib/egroupware/egw03/*  /var/lib/egroupware/egw03/
}

echo "Do you want to install EGroupware"
if [ $1 == 'yes' ]
    then
        echo "Installing EGroupware!"
        installEGroupware()
    fi





sync_directories()