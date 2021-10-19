#!/bin/bash

# How to access the database in a docker container
# docker exec -it egroupware-db bash
# mysql -u root -p
# find password under /etc/egroupware-docker/.env

# How to restart Docker
# service docker restart

# How to install a Let's Encrypt Certificate
# apt install certbot python3-certbot-apache
# nano /etc/apache2/sites-enabled/000-default.conf   // Set SERVER-NAME
# certbot --apache -d SERVER-NAME
# certbot renew --dry-run

generateSSHKey()
{
    # make sure to run this with /bin/bash, NOT /bin/sh

    echo
    echo This script will help you setup ssh public key authentication.

    host=$1
    port=$2

    if [ -n "$host" ]; then
        echo -n "user[$USER]: "

        #If user not provided use current user
        if [ -z "$usr" ]; then
        usr=$USER
        fi

        echo -n "port[$port] "
        if [ -z "$port" ]; then
        port=22
        fi

        echo "Setting up RSA authentication for ${usr}@${host} (port $port)..."
        if [ -f ~/.ssh/id_rsa.pub ]; then
        echo "RSA public key OK."
        else
        ssh-keygen -b 4096 -f ~/.ssh/id_rsa -N ""
        fi

        echo "Appending your RSA public key to the server's authorized_keys"
        scp -P $port ~/.ssh/id_rsa.pub ${usr}@${host}:~/

        # Append public key to authorized keys and fix common
        # permission problems, eg. a group-writable .ssh dir,
        # or authorized_keys being readable by others.
        ssh ${usr}@${host} -p $port "if [ ! -d ~/.ssh ]; then
        mkdir ~/.ssh
        fi
        chmod 700 ~/.ssh
        cat ~/id_rsa.pub >> ~/.ssh/authorized_keys
        chmod 0600 ~/.ssh/authorized_keys
        rm ~/id_rsa.pub"
        echo
        echo "You should see the following message without being prompted for anything now..."
        echo
        ssh ${usr}@${host} -p $port "echo !!! Congratulations, you are now logged in as ${usr}@${host} !!!"
        echo
        echo "If you were prompted, public key authentication could not be configured..."

        echo
        echo "Enter a blank servername when done."
        echo
    fi

    echo "End of configuration."
}

upgradePackages()
{
    echo "About to Upgrade all the packages!"
    sleep 3
    sudo apt update && sudo apt upgrade -y
}

syncDirectories()
{
    # read -p "Where is the data located?: " host
    # read -p "SSH-Port?: " port
    host=138.201.206.170
    port=2712
    read -p "EGroupware-Instance e.g. egw00 " instance

    generateSSHKey $host $port
 
    sudo chmod 600 ~/.ssh/id_rsa
    sudo chmod 600 ~/.ssh/id_rsa.pub
    sudo chmod 644 ~/.ssh/known_hosts
    sudo chmod 755 ~/.ssh

    mkdir -p /usr/share/egroupware
    # Sync OLD Apps
    rsync -u -r -v -e "ssh -i ~/.ssh/id_rsa -p ${port}" root@$host:/usr/share/egroupware/agroviva/*  /usr/share/egroupware/agroviva/
    # rsync -u -r -v -e "ssh -i ~/.ssh/id_rsa -p ${port}" root@$host:/usr/share/egroupware/cao/*  /usr/share/egroupware/cao/
    # rsync -u -r -v -e "ssh -i ~/.ssh/id_rsa -p ${port}" root@$host:/usr/share/egroupware/attendance/*  /usr/share/egroupware/attendance/
    # rsync -u -r -v -e "ssh -i ~/.ssh/id_rsa -p ${port}" root@$host:/usr/share/egroupware/threecx/*  /usr/share/egroupware/threecx/
    # rsync -u -r -v -e "ssh -i ~/.ssh/id_rsa -p ${port}" root@$host:/usr/share/egroupware/wiki/*  /usr/share/egroupware/wiki/

    #Sync Files
    rsync -u --exclude 'tmp/*' -r -v -e "ssh -i ~/.ssh/id_rsa -p ${port}" root@$host:/var/lib/egroupware/$instance/*  /var/lib/egroupware/$instance/

    chown www-data:www-data /var/lib/egroupware/$instance/
    chown www-data:www-data * /var/lib/egroupware/$instance/ -R
    chmod 755 * /var/lib/egroupware/$instance/ -R
    chmod 700 /var/lib/egroupware/$instance/files/activesync/
    rm -rf /var/lib/egroupware/$instance/temp/
    rm -rf /var/lib/egroupware/$instance/tmp/
    chown www-data:www-data * /usr/share/egroupware/ -R
    service docker restart
}

installEGroupware()
{
    echo "Installing EGroupware!"
    sleep 3
    
    echo 'deb http://download.opensuse.org/repositories/server:/eGroupWare/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/server:eGroupWare.list
    sudo apt install gnupg # required, but not installed by apt-key add in Debian 10 
    wget -nv https://download.opensuse.org/repositories/server:eGroupWare/xUbuntu_20.04/Release.key -O - | sudo apt-key add -

    upgradePackages

    apt install apache2 egroupware-docker -y
    /etc/egroupware-docker/use-epl.sh

    syncDirectories
    outputCredentials
}

packageISInstalled()
{
    dpkg -s $1 &> /dev/null
    if [ $? -eq 0 ]; then
       return 0
    else
        return 1
    fi
}

outputCredentials()
{
    echo "--------------------------------------------------------------------------------"
    echo "--------------------------------------------------------------------------------"
    tail -n 40 /var/lib/egroupware/egroupware-docker-install.log
    echo "--------------------------------------------------------------------------------"
    echo "--------------------------------------------------------------------------------"
}

if packageISInstalled 'egroupware-docker'; then
    echo "EGroupware Package is already installed!"
    sleep 3
    syncDirectories
    outputCredentials

else
    read -p "Do you want to install EGroupware (y/n)?: " choice
    case "$choice" in 
    y|Y ) installEGroupware;;
    n|N ) echo "BYE!";;
    * ) installEGroupware;;
    esac
fi
