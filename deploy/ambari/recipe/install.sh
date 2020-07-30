#!/bin/bash
set -e

# Install Centos 6 prerequisites
source <(curl -s https://raw.githubusercontent.com/bazaarvoice/alluxio/branch-1.8/deploy/ambari/recipe/install_centos-rhel_prerequisites.sh?$RANDOM)

# Pre-install
source <(curl -s https://raw.githubusercontent.com/bazaarvoice/alluxio/branch-1.8/deploy/ambari/recipe/pre-install.sh?$RANDOM)

# Install Alluxio
source <(curl -s https://raw.githubusercontent.com/bazaarvoice/alluxio/branch-1.8/deploy/ambari/recipe/install_alluxio_centos-rhel.sh?$RANDOM)

# Post-install
source <(curl -s https://raw.githubusercontent.com/bazaarvoice/alluxio/branch-1.8/deploy/ambari/recipe/post-install.sh?$RANDOM)
