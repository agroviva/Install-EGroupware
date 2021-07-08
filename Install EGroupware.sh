echo 'deb http://download.opensuse.org/repositories/server:/eGroupWare/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/server:eGroupWare.list
sudo apt install gnupg # required, but not installed by apt-key add in Debian 10 
wget -nv https://download.opensuse.org/repositories/server:eGroupWare/xUbuntu_20.04/Release.key -O - | sudo apt-key add -
sudo apt update
sudo apt upgrade -y

apt install apache2 egroupware-docker -y
mkdir -p /usr/share/egroupware


# scp -P 2712 -r root@e00.agroviva.net:/usr/share/egroupware/cao/  /usr/share/egroupware/cao/
# scp -P 2712 -r root@e00.agroviva.net:/usr/share/egroupware/attendance/  /usr/share/egroupware/attendance/
# scp -P 2712 -r root@e00.agroviva.net:/usr/share/egroupware/threecx/  /usr/share/egroupware/threecx/

rsync -u -r -v -e 'ssh -p 2712' root@e00.agroviva.net:/usr/share/egroupware/cao/*  /usr/share/egroupware/cao/
rsync -u -r -v -e 'ssh -p 2712' root@e00.agroviva.net:/usr/share/egroupware/attendance/*  /usr/share/egroupware/attendance/
rsync -u -r -v -e 'ssh -p 2712' root@e00.agroviva.net:/usr/share/egroupware/threecx/*  /usr/share/egroupware/threecx/
rsync -u -r -v -e 'ssh -p 2712' root@e00.agroviva.net:/usr/share/egroupware/wiki/*  /usr/share/egroupware/wiki/


rsync -u --exclude 'tmp/*' -r -v -e 'ssh -p 2712' root@e00.agroviva.net:/var/lib/egroupware/egw00/*  /var/lib/egroupware/egw00/
rsync -u --exclude 'tmp/*' -r -v -e 'ssh -p 2712' root@e00.agroviva.net:/var/lib/egroupware/egw03/*  /var/lib/egroupware/egw03/