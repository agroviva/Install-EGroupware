#!/bin/bash


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
    #read -p "Where is the data located?: " host
    host="e00.agroviva.net"
    port="2712"

    generateSSHKey $host $port

    # scp -P $port -r root@$host:/usr/share/egroupware/cao/  /usr/share/egroupware/cao/
    # scp -P $port -r root@$host:/usr/share/egroupware/attendance/  /usr/share/egroupware/attendance/
    # scp -P $port -r root@$host:/usr/share/egroupware/threecx/  /usr/share/egroupware/threecx/

    sudo chmod 600 ~/.ssh/id_rsa
    sudo chmod 600 ~/.ssh/id_rsa.pub
    sudo chmod 644 ~/.ssh/known_hosts
    sudo chmod 755 ~/.ssh

    rsync -u -r -v -e 'ssh -i ~/.ssh/id_rsa -p 2712' root@$host:/usr/share/egroupware/agroviva/*  /usr/share/egroupware/agroviva/
    rsync -u -r -v -e 'ssh -i ~/.ssh/id_rsa -p 2712' root@$host:/usr/share/egroupware/cao/*  /usr/share/egroupware/cao/
    rsync -u -r -v -e 'ssh -i ~/.ssh/id_rsa -p 2712' root@$host:/usr/share/egroupware/attendance/*  /usr/share/egroupware/attendance/
    rsync -u -r -v -e 'ssh -i ~/.ssh/id_rsa -p 2712' root@$host:/usr/share/egroupware/threecx/*  /usr/share/egroupware/threecx/
    rsync -u -r -v -e 'ssh -i ~/.ssh/id_rsa -p 2712' root@$host:/usr/share/egroupware/wiki/*  /usr/share/egroupware/wiki/


    rsync -u --exclude 'tmp/*' -r -v -e 'ssh -i ~/.ssh/id_rsa -p 2712' root@$host:/var/lib/egroupware/egw00/*  /var/lib/egroupware/egw00/
    # rsync -u --exclude 'tmp/*' -r -v -e 'ssh -i ~/.ssh/id_rsa -p 2712' root@$host:/var/lib/egroupware/egw03/*  /var/lib/egroupware/egw03/
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
    mkdir -p /usr/share/egroupware

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
    tail -n 12 /var/lib/egroupware/egroupware-docker-install.log
    echo "--------------------------------------------------------------------------------"
    echo "--------------------------------------------------------------------------------"
}

if packageISInstalled 'egroupware-docker'; then
    echo "EGroupware Package is already installed!"
    sleep 3
else
    read -p "Do you want to install EGroupware (y/n)?: " choice
    case "$choice" in 
    y|Y ) installEGroupware;;
    n|N ) echo "BYE!";;
    * ) installEGroupware;;
    esac
fi
