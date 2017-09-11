#!/usr/bin/env bash
set -e
set -u
set -x

apt-get update
apt-get install -y vim tree curl net-tools

sudo -u root curl https://get.docker.com | sh

usermod -aG docker vagrant

cp /data/Dockerfile /home/vagrant/
chown vagrant /home/vagrant/Dockerfile

echo "192.168.33.12    nexus.test" >> /etc/hosts

mkdir /usr/share/ca-certificates/test
cp /data/ca.crt /usr/share/ca-certificates/test/ca.crt

echo 'test/ca.crt' >> /etc/ca-certificates.conf
update-ca-certificates

docker build -t nexus.test/hello hello
docker build -t myclair myclair
docker network create --attachable internal
docker run -d --name postgres -e POSTGRES_PASSWORD=password --network internal postgres
docker run -d --name clair -p 6060:6060 -p 6061:6061 --network internal -v /data/config.yaml:/etc/clair/config.yaml myclair

wget https://s3.amazonaws.com/clairctl/latest/clairctl-linux-amd64
chmod +X clairctl-linux-amd64
mv clairctl-linux-amd64 /usr/bin/clairctl

cp /data/README /home/vagrant/README.exe
chown vagrant:vagrant /home/vagrant/README.exe
