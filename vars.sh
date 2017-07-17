#!/bin/bash

################################################################
# Please modify this session base on your AWS configurations
################################################################
# EC2 ssh key
ec2_key_name="ec2-key-name"
# subnet
subnet_id="subnet-b422f5c2"
# security group for master node
emr_master_sg="sg-d9c50ebf"
# security group for slave node(s)
emr_slave_sg="sg-8ac40fec"
# region
emr_region="us-west-1"
# hive configuration
hive_configuration="hiveConfiguration.json"
# instance type for both master and slave nodes
instance_type="m3.xlarge"
# counts of master node
master_counts="1"
# counts of slave node
core_counts="2"
# log to s3
s3_log_url="s3://aws-logs-194674848290-us-west-1/elasticmapreduce"
################################################################
