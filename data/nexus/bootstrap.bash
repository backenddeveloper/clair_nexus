#!/usr/bin/env bash
set -e
set -u
set -x

############################################################
#                                                          #
# First we install HAProxy and the requirements for nexus  #
#                                                          #
############################################################

apt-get update
apt-get install -y vim tree curl net-tools wget haproxy openjdk-8-jdk

####################################################################
#                                                                  #
# Everything is done in the /data directory, which is synced from  #
# the host by Vagrant                                              #
#                                                                  #
####################################################################

cd /data

#############################################################################
#                                                                           #
# We grab a known version of Nexus OSS from sonatype, untar it and start it #
#                                                                           #
#############################################################################

wget https://sonatype-download.global.ssl.fastly.net/nexus/3/nexus-3.5.1-02-unix.tar.gz --quiet

tar zxvf nexus-3.5.1-02-unix.tar.gz
/data/nexus-3.5.1-02/bin/nexus start

######################################################################
#                                                                    #
# Now we wait for Nexus manager to start. We can see it has started  #
# when the web GUI returns useful HTML                               #
#                                                                    #
######################################################################

echo -e "\n\n The Docker repo will start in a few minutes \n\n"

while ! curl 'http://127.0.0.1:8081/#admin/' 2> /dev/null | grep -e '<title>Nexus Repository Manager</title>' ;
do
    echo "Waiting 5 more seconds for nexus to start so we can create the docker repo" ;
    sleep 5 ;
done

#################################################################################
#                                                                               #
# Now that the admin GUI is up, we use it to create a hosted Docker repositiory #
# that listens on port 10000                                                    #
#                                                                               #
#################################################################################

curl 'http://127.0.0.1:8081/service/extdirect' -s \
-H 'Content-Type: application/json' \
-u 'admin:admin123' \
--data-binary @- << EOF
{
    "action":"coreui_Repository",
    "method":"create",
    "data":[
         {
              "attributes":
              {
                   "docker":
                   {
                       "httpPort":10000,
                       "v1Enabled":true
                   },
                   "storage":
                   {
                       "blobStoreName":"default",
                       "strictContentTypeValidation":true,
                       "writePolicy":"ALLOW"
                   }
              },
              "name":"docker",
              "format":"",
              "type":"",
              "url":"",
              "online":true,
              "checkbox-1255-inputEl":true,
              "checkbox-1258-inputEl":false,
              "recipe":"docker-hosted"
         }
    ],
    "type":"rpc",
    "tid":11
}
EOF

############################################################################################
#                                                                                          #
# HAProxy listens on port 80 and redirects to HTTPS, and listens on port 443, terminating  #
# SSL and backing on to localhost port 10000 (the docker repo)                             #
#                                                                                          #
############################################################################################

mv haproxy.cfg /etc/haproxy/haproxy.cfg
service haproxy restart
