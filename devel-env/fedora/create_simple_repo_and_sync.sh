#!/bin/sh

pulp-admin login --username admin --password admin
pulp-admin rpm repo create --repo-id pulp_unittest --feed http://jmatthews.fedorapeople.org/pulp_unittest/
pulp-admin rpm repo sync run --repo-id pulp_unittest