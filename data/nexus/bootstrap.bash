#!/usr/bin/env bash
set -e
set -u
set -x

cd /data

apt-get update
apt-get install -y vim tree curl net-tools wget haproxy openjdk-8-jdk

wget https://sonatype-download.global.ssl.fastly.net/nexus/3/nexus-3.5.1-02-unix.tar.gz 2>&1 > /dev/null

tar zxvf nexus-3.5.1-02-unix.tar.gz
/data/nexus-3.5.1-02/bin/nexus start

echo -e "\n\n The Docker repo will start in a few minutes \n\n"

while ! curl 'http://127.0.0.1:8081/#admin/' 2> /dev/null | grep -e '<title>Nexus Repository Manager</title>' ;
do
    echo "Waiting 5 more seconds for nexus to start so we can create the docker repo" ;
    sleep 5 ;
done

curl 'http://127.0.0.1:8081/service/extdirect' -H 'Content-Type: application/json' --data-binary '{"action":"coreui_Repository","method":"create","data":[{"attributes":{"docker":{"httpPort":10000,"v1Enabled":true},"storage":{"blobStoreName":"default","strictContentTypeValidation":true,"writePolicy":"ALLOW"}},"name":"docker","format":"","type":"","url":"","online":true,"checkbox-1255-inputEl":true,"checkbox-1258-inputEl":false,"recipe":"docker-hosted"}],"type":"rpc","tid":11}' -u 'admin:admin123'

mv haproxy.cfg /etc/haproxy/haproxy.cfg
service haproxy start
service haproxy restart
