#!/usr/bin/env bash
set -e
set -u
set -x

apt-get update
apt-get install -y vim tree curl net-tools

sudo -u root curl https://get.docker.com | sh
usermod -aG docker vagrant
chown vagrant:docker /etc/docker -R

echo "192.168.33.12    nexus.test" >> /etc/hosts

mkdir /usr/share/ca-certificates/test
cp /data/ca.crt /usr/share/ca-certificates/test/ca.crt

echo 'test/ca.crt' >> /etc/ca-certificates.conf
update-ca-certificates

docker build -t nexus.test/hello /data/hello
docker build -t myclair /data/myclair
docker network create --attachable internal
docker run -d --name postgres -e POSTGRES_PASSWORD=password --network internal postgres ; sleep 15 # Give postgres time to start up
docker run -d --name clair -p 6060:6060 -p 6061:6061 --network internal -v /data/config.yaml:/etc/clair/config.yaml -v /data/myclair/hosts:/etc/hosts myclair

wget https://s3.amazonaws.com/clairctl/latest/clairctl-linux-amd64
mv clairctl-linux-amd64 /usr/bin/clairctl
chmod 777 /usr/bin/clairctl

cp /data/README /home/vagrant/README.exe
chown vagrant:vagrant /home/vagrant/README.exe

apt-get install -y apache2
rm /var/www/html -rf
mkdir /home/vagrant/reports
chown vagrant:vagrant /home/vagrant/reports
chmod 766 /home/vagrant/reports
ln -s /home/vagrant/reports /var/www/html
