#!/usr/bin/env bash
set -e
set -u
set -x

##########################################################################
#                                                                        #
# First we update apt, and install some general purpose debugging tools  #
#                                                                        #
##########################################################################

apt-get update
apt-get install -y vim tree curl net-tools

####################################################################
#                                                                  #
# Everything is done in the /data directory, which is synced from  #
# the host by Vagrant                                              #
#                                                                  #
####################################################################

cd /data

######################################
#                                    #
# Now we install docker the easy way #
#                                    #
######################################

sudo -u root curl -sSfL https://get.docker.com | sh
usermod -aG docker vagrant

#######################################################################################################
#                                                                                                     #
# A hosts file entry, and the installation of a CA certificate is needed to use the docker repository #
#                                                                                                     #
#######################################################################################################

echo "192.168.33.10    nexus.test" >> /etc/hosts
mkdir /usr/share/ca-certificates/test
cp /data/ca.crt /usr/share/ca-certificates/test/ca.crt
echo 'test/ca.crt' >> /etc/ca-certificates.conf
update-ca-certificates

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#


########################################
#                                      #
# Installing and running Clair scanner #
#                                      #
########################################

docker build -t myclair /data/myclair
docker network create --attachable internal
docker run -d --name postgres -e POSTGRES_PASSWORD=password --network internal postgres ; sleep 15 # Give postgres time to start up
docker run -d --name clair -p 6060:6060 -p 6061:6061 --network internal -v /data/config.yaml:/etc/clair/config.yaml -v /data/myclair/hosts:/etc/hosts myclair


#######################################################################################
#                                                                                     #
# Installing and running Clairctl                                                     #
# Note that in order to push to Clair, Clairctl requires write access to /etc/docker  #
#                                                                                     #
#######################################################################################

wget https://s3.amazonaws.com/clairctl/latest/clairctl-linux-amd64 --quiet
mv clairctl-linux-amd64 /usr/bin/clairctl
chmod 777 /usr/bin/clairctl
chown vagrant:docker /etc/docker -R

##################################################################
#                                                                #
# Copying the executable acceptance script to the home directory #
#                                                                #
##################################################################

cp /data/README /home/vagrant/README.exe
chown vagrant:vagrant /home/vagrant/README.exe
