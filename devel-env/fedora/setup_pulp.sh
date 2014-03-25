#!/bin/bash
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config

yum install -y mongodb mongodb-server
systemctl enable mongod
systemctl restart mongod

yum install -y qpid-cpp-server
echo "auth=no" >> /etc/qpidd.conf

yum install -y wget
wget http://repos.fedorapeople.org/repos/pulp/pulp/fedora-pulp.repo -O /etc/yum.repos.d/fedora-pulp.repo
yum --disablerepo="pulp-v2-stable" --enablerepo="pulp-v2-testing" -y groupinstall pulp-server pulp-admin
sudo -u apache pulp-manage-db

./config_pulp.sh 

systemctl enable qpidd 
systemctl restart qpidd

systemctl enable httpd
systemctl restart httpd

systemctl enable pulp_workers.service
systemctl restart pulp_workers.service 

systemctl enable pulp_resource_manager.service
systemctl restart pulp_resource_manager.service

systemctl enable pulp_celerybeat.service
systemctl restart pulp_celerybeat.service

##
## Hack:  restart httpd again
# I have noticed errors if I don't restart httpd again, after prior block of services started.
# Only error I saw in /var/log/messages was the below issue:
#  DuplicateKeyError: E11000 duplicate key error index: pulp_database.users.$login_-1  dup key: { : "admin" }
#  Mar 25 14:03:52 localhost pulp: pulp.server.webservices.application:CRITICAL: *************************************************************
#  Mar 25 14:03:52 localhost pulp: pulp.server.webservices.application:ERROR: The Pulp server encountered an unexpected failure during initialization
#
# If I restart httpd then pulp is happy.
# I saw this behavior with pulp RPM: pulp-server-2.4.0-0.6.alpha.fc20.noarch
##
systemctl restart httpd
./create_simple_repo_and_sync.sh

echo ""
echo "======="
echo "To ssh into your development environment you may either:"
echo " ssh vagrant@172.31.2.100    (username and password are both 'vagrant') "
echo " vagrant ssh     (from your host machine, this command will ssh automatically into the VM)"
echo "  Note:  on the VM, the git checkout is shared with the host at the path '/vagrant'"
echo ""
