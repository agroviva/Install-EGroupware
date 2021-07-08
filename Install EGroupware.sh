# scp -P 2712 -r root@e00.agroviva.net:/usr/share/egroupware/cao/  /usr/share/egroupware/cao/
# scp -P 2712 -r root@e00.agroviva.net:/usr/share/egroupware/attendance/  /usr/share/egroupware/attendance/
# scp -P 2712 -r root@e00.agroviva.net:/usr/share/egroupware/threecx/  /usr/share/egroupware/threecx/

rsync -u -r -v -e 'ssh -p 2712' root@e00.agroviva.net:/usr/share/egroupware/cao/*  /usr/share/egroupware/cao/
rsync -u -r -v -e 'ssh -p 2712' root@e00.agroviva.net:/usr/share/egroupware/attendance/*  /usr/share/egroupware/attendance/
rsync -u -r -v -e 'ssh -p 2712' root@e00.agroviva.net:/usr/share/egroupware/threecx/*  /usr/share/egroupware/threecx/
rsync -u -r -v -e 'ssh -p 2712' root@e00.agroviva.net:/usr/share/egroupware/wiki/*  /usr/share/egroupware/wiki/


rsync -u --exclude 'tmp/*' -r -v -e 'ssh -p 2712' root@e00.agroviva.net:/var/lib/egroupware/egw00/*  /var/lib/egroupware/egw00/
rsync -u --exclude 'tmp/*' -r -v -e 'ssh -p 2712' root@e00.agroviva.net:/var/lib/egroupware/egw03/*  /var/lib/egroupware/egw03/