#!/usr/bin/env bash
set -e
set -o errexit

cp /opt/alluxio/deploy/ambari/recipe/alluxio-masterd /etc/init.d/
ln -sf /opt/alluxio/deploy/ambari/recipe/alluxio-master.service /etc/systemd/system/

cp /opt/alluxio/deploy/ambari/recipe/alluxio-workerd /etc/init.d/
ln -sf /opt/alluxio/deploy/ambari/recipe/alluxio-worker.service /etc/systemd/system/

cp /opt/alluxio/deploy/ambari/recipe/alluxio-proxyd /etc/init.d/
ln -sf /opt/alluxio/deploy/ambari/recipe/alluxio-proxy.service /etc/systemd/system/

systemctl enable alluxio-master.service
systemctl enable alluxio-worker.service
systemctl enable alluxio-proxy.service

chkconfig --add alluxio-masterd
chkconfig --add alluxio-workerd
chkconfig --add alluxio-proxyd

# Increase nofile and nproc limits for alluxio users
mkdir -p /etc/security/limits.d
cp /opt/alluxio/deploy/ambari/recipe/limits.d-alluxio.conf /etc/security/limits.d/alluxio.conf

# Add log dir
mkdir -p /var/log/alluxio
chown -R alluxio:alluxio /var/log/alluxio

# Add directory for pidfile
mkdir -p /var/run/alluxio
chown -R alluxio:alluxio /var/run/alluxio

# Add alluxio permissions to alluxio working directory
chown -R alluxio:alluxio /opt/alluxio

# Add all extension jars to /opt/alluxio/lib
mkdir -p /opt/alluxio/lib
for f in `ls /opt/alluxio/underfs/*/target/*-jar-with-dependencies.jar`; do
    ln -s $f /opt/alluxio/lib
done

# Format journal local directory
sudo -u alluxio ./bin/alluxio format -s

# Add alluxio underFSStorage dir
mkdir -p /opt/alluxio/underFSStorage
chown -R alluxio:alluxio /opt/alluxio/underFSStorage
