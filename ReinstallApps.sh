#!/bin/bash
cd /etc/egroupware-docker

script_file="custom-agroviva-composer.sh"
cat <<EOL > "$script_file"
#!/bin/bash
# Call original entrypoint
#docker-entrypoint.sh

# Wait for egroupware to be fully up and running
# (Implement any necessary logic to ensure egroupware is ready)

# Execute your script
cd /usr/share/egroupware/agroviva/
php composer.phar update
EOL

chmod +x "$script_file"

cd /usr/share/egroupware
rm -rf agroviva/
rm -rf cao/
rm -rf attendance/
rm -rf threecx/
rm -rf wiki/
git clone https://github.com/agroviva/agroviva
git clone https://github.com/agroviva/cao
git clone https://github.com/agroviva/attendance
git clone https://github.com/agroviva/threecx
git clone https://github.com/EGroupware/wiki
chown -R root:root .
docker-compose -f /etc/egroupware-docker/docker-compose.yml restart egroupware
