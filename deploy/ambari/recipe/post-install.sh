#!/usr/bin/env bash

set -o errexit

cp /opt/alluxio/deploy/ambari/recipe/alluxio-masterd /etc/init.d/
cp /opt/alluxio/deploy/ambari/recipe/alluxio-workerd /etc/init.d/
cp /opt/alluxio/deploy/ambari/recipe/alluxio-proxyd /etc/init.d/

chkconfig --add alluxio-masterd
chkconfig --add alluxio-workerd
chkconfig --add alluxio-proxyd

# Add log dir
mkdir -p /var/log/alluxio
chown -R alluxio:alluxio /var/log/alluxio

# Add directory for pidfile
mkdir -p /var/run/alluxio
chown -R alluxio:alluxio /var/run/alluxio

# Add alluxio permissions to alluxio working directory
chown -R alluxio:alluxio /opt/alluxio

# Add all extension jars to /opt/alluxio/lib
mkdir /opt/alluxio/lib
for f in `ls /opt/alluxio/underfs/*/target/*1.7.1-SNAPSHOT.jar`; do
    ln -s $f /opt/alluxio/lib
done

# Format journal local directory
sudo -u alluxio ./bin/alluxio format -s
