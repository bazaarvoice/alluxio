#!/bin/bash
set -e
if [ ! -d "/opt/alluxio" ]; then
    git clone -b branch-1.7 https://github.com/bazaarvoice/alluxio.git /opt/alluxio
fi
cd /opt/alluxio
git pull
mvn -e clean package -DskipTests -Phadoop-2.7 -Phive -Dcheckstyle.skip=true -Dlicense.skip=true -Dfindbugs.skip=true -Dmaven.javadoc.skip=true

# link alluxio client runtime jar to hive-server2 and hive client auxlib directory

# get the current HDP version. assuming that there's only 1 version running, else it will just grab the first version
cat >/tmp/symlink-alluxio-client-jar.sh <<"EOL"
while true; do
    if [ -d "/usr/hdp" ]; then
        HDP_VERSION=`ls /usr/hdp/ | grep -v current | head -1`
        while true; do
            if [ ! -z "/usr/hdp/$HDP_VERSION" ]; then
                while true; do
                    if [ -d "/usr/hdp/$HDP_VERSION/hive" ]; then
                        mkdir -p /usr/hdp/$HDP_VERSION/hive/auxlib
                        ln -s /opt/alluxio/core/client/runtime/target/alluxio-core-client-runtime-1.7.2-SNAPSHOT-jar-with-dependencies.jar \
                          /usr/hdp/$HDP_VERSION/hive/auxlib/alluxio-core-client-runtime.jar
                        break;
                    else
                        echo "A hive app is not installed under /usr/hdp/$HDP_VERSION. sleep 10s ..."
                        sleep 10;
                    fi
                done

                while true; do
                    if [ -d "/usr/hdp/$HDP_VERSION/hive2" ]; then
                        mkdir -p /usr/hdp/$HDP_VERSION/hive2/auxlib
                        ln -s /opt/alluxio/core/client/runtime/target/alluxio-core-client-runtime-1.7.2-SNAPSHOT-jar-with-dependencies.jar \
                          /usr/hdp/$HDP_VERSION/hive2/auxlib/alluxio-core-client-runtime.jar
                        break;
                    else
                        echo "A hive2 app is not installed under /usr/hdp/$HDP_VERSION. sleep 10s ..."
                        sleep 10;
                    fi
                done
                break;
            else
                echo "A hdp version is not installed under /usr/hdp. sleep 10s ..."
                sleep 10;
            fi
        done
        break;
    else
        echo "/usr/hdp directory is not available. sleep 10s ..."
        sleep 10;
    fi
done
EOL
chmod +x /tmp/symlink-alluxio-client-jar.sh

# run it in the background
/tmp/symlink-alluxio-client-jar.sh > /var/log/symlink-alluxio-client.log 2>&1 &
