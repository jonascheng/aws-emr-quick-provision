# Quick way to provision and terminate AWS EMR cluster

This repo includes two shell script files

* provision-cluster.sh to provision one EMR cluster
* terminate-active-cluster.sh to terminate all active EMR cluster(s)

In addition to the script files, it supports storing metastore information on persistent storage. You can do this by overriding the default location of the MySQL database in Hive to persistent storage, either on an Amazon RDS MySQL instance.

## Prerequisites

* Create EMR_DefaultRole / EMR_EC2_DefaultRole

Use the AWS CLI to create the default roles using the create-default-roles subcommand. For more information, see [Create and Use IAM Roles with the AWS CLI](http://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles-creatingroles.html#emr-iam-roles-createdefaultwithcli).

Type the following command to create default roles using the AWS CLI:

```aws emr create-default-roles ```


The output of the command lists the contents of the default Amazon EMR role, *EMR_DefaultRole*; the the default EC2 instance profile, *EMR_EC2_DefaultRole*.

> [When I try to create a new EMR cluster, I receive the error "EMR_DefaultRole is invalid." How can I resolve this?](https://aws.amazon.com/premiumsupport/knowledge-center/emr-default-role-invalid/)

* Create an Amazon RDS MySQL

* Create a configuration file *hiveConfiguration.json*

Replacing *ConnectionURL*, *ConnectionUserName*, *ConnectionPassword*

```json
[
  {
    "Classification": "hive-site",
    "Properties": {
      "javax.jdo.option.ConnectionURL": "jdbc:mysql:\/\/emrdb.cjvsmtqgrrcb.ap-northeast-1.rds.amazonaws.com:3306\/hive?createDatabaseIfNotExist=true",
      "javax.jdo.option.ConnectionDriverName": "org.mariadb.jdbc.Driver",
      "javax.jdo.option.ConnectionUserName": "username",
      "javax.jdo.option.ConnectionPassword": "secret"
    }
  }
]
```

* Modify variables inside script files base on your AWS configurations

```shell
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
```

## References

* [Create a Hive Metastore Outside the Cluster](http://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-dev-create-metastore-outside.html)
* [AWS CLI Command for EMR](http://docs.aws.amazon.com/cli/latest/reference/emr/index.html)
* [Work with Steps Using the CLI and Console](http://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-work-with-steps.html)
