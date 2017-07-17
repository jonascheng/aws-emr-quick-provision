#!/bin/bash

# for awscli in ubuntu
export PATH=${PATH}:/usr/local/bin

# import variables
source ./vars.sh

# region
region=" --region $emr_region"

cluster_id_list=`aws emr list-clusters --active --query 'Clusters[*].Id' --output text $region`

for cluster_id in $cluster_id_list
do
    echo "terminating $cluster_id"
    aws emr terminate-clusters --cluster-id $cluster_id $region
done
