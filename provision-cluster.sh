#!/bin/bash

# This is a sample command to create emr cluster
# aws emr create-cluster 
# --release-label emr-5.2.0 
# --applications Name=Ganglia Name=Hadoop Name=Hive Name=Hue Name=Mahout Name=Pig Name=Tez 
# --ec2-attributes '{"KeyName":"emr_key","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-4b26cc2e","EmrManagedSlaveSecurityGroup":"sg-5010ad35","EmrManagedMasterSecurityGroup":"sg-5110ad34"}' 
# --service-role EMR_DefaultRole 
# --enable-debugging --log-uri 's3://aws-logs-194674848290-us-west-1/elasticmapreduce/' 
# --name 'My cluster' 
# --instance-groups '[{"InstanceCount":2,"InstanceGroupType":"CORE","InstanceType":"m3.xlarge","Name":"Core Instance Group"},{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"m3.xlarge","Name":"Master Instance Group"}]' 
# --scale-down-behavior TERMINATE_AT_INSTANCE_HOUR 
# --region us-west-1

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

username=`echo $USER | tr -d ' '`
clustername=`date '+%Y%m%d%H%M%S'`_$username
echo "Create EMR cluster for $username"

# The identifier for the EMR release
release_label=" --release-label emr-5.2.0"
# Create an Amazon EMR cluster with applications
applications=" --applications Name=Ganglia Name=Hadoop Name=Hive Name=Hue Name=Mahout Name=Pig Name=Tez"
# Specify ec2 attribute
ec2_attributes=" --ec2-attributes KeyName=$ec2_key_name,InstanceProfile=EMR_EC2_DefaultRole,SubnetId=$subnet_id,EmrManagedSlaveSecurityGroup=$emr_slave_sg,EmrManagedMasterSecurityGroup=$emr_master_sg"
# Service role
service_role=" --service-role EMR_DefaultRole"
# Enable debugging
enable_debugging=" --enable-debugging --log-uri $s3_log_url"
# The name of the cluster
name=" --name $clustername"
# A specification of the number and type of Amazon EC2 instances to create instance groups in a cluster.
instance_groups=" --instance-groups InstanceGroupType=MASTER,InstanceCount=$master_counts,InstanceType=$instance_type InstanceGroupType=CORE,InstanceCount=$core_counts,InstanceType=$instance_type"
# scale down
scale=" --scale-down-behavior TERMINATE_AT_INSTANCE_HOUR"
# region
region=" --region $emr_region"
# configuration
configurations=" --configurations file://$hive_configuration"

# query exist running cluster
ret=`aws emr list-clusters --cluster-states 'WAITING' $region --query Clusters[*].[Id,Name] --output text`
cluster_id=`echo $ret | awk '{ if (match($2,"'$username'")) {print $1} }'`
if [ $cluster_id ]; then
    echo "Cluster $cluster_id is still running, so skip EMR cluster creation"
else
    # create emr cluster
    cluster_id=`aws emr create-cluster $release_label $applications $ec2_attributes $service_role $enable_debugging $name $instance_groups $region $configurations --query 'ClusterId' --output text`
    if [ $? -ne 0 ]; then
        echo "Encountered failure while creating EMR cluster"
        exit
    fi
    echo "Cluster $cluster_id is creating, this might take minutes to provision a EMR cluster"
fi

cluster_state=0
emr_endpoint=''
waiting_time=60
retry=0
max_retry=10

while [ $cluster_state == 0 ] && [ $retry -le $max_retry ];
do
    # query emr cluster status
    ret=`aws emr describe-cluster --cluster-id $cluster_id $region --query Cluster.[Status.State,MasterPublicDnsName] --output text`

    for value in $ret
    do
        if [ $value != 0 ] && [ $value == 'WAITING' ]; then
            cluster_state=1
        else
            emr_endpoint=$value
            break
        fi
    done

    # sleep every 3 sec
    loop=$(( $waiting_time/3 ))
    while [ $cluster_state == 0 ] && [ $loop -gt 0 ]
    do
        echo -n "."
        sleep 3
        loop=$(( $loop-1 ))
    done
    retry=$(( $retry+1 ))
done

if [ $retry -gt $max_retry ] && [ $cluster_state == 0 ]; then
    echo "Detect EMR status timeout, please check AWS console directly."
else
    echo "EMR is provisioned, please access to $emr_endpoint"
fi
