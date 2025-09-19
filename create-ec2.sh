#!/usr/bin/env bash

set -euo pipefail

region="us-west-2"
key_name="bcitkey"

source ./infrastructure_data

# Get most recent Debian AMI
debian_ami=$(aws ec2 describe-images \
  --owners "136693071363" \
  --filters 'Name=name,Values=debian-*-amd64-*' 'Name=architecture,Values=x86_64' 'Name=virtualization-type,Values=hvm' \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text)

# Create security group allowing SSH and HTTP from anywhere
security_group_id=$(aws ec2 create-security-group --group-name MySecurityGroup \
 --description "Allow SSH and HTTP" --vpc-id $vpc_id --query 'GroupId' \
 --region $region \
 --output text)

aws ec2 authorize-security-group-ingress --group-id $security_group_id \
 --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $region

aws ec2 authorize-security-group-ingress --group-id $security_group_id \
 --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $region

# Launch an EC2 instance in the public subnet
instance_id=$(aws ec2 run-instances \
  --image-id $debian_ami \
  --count 1 \
  --instance-type t2.micro \
  --key-name $key_name \
  --security-group-ids $security_group_id \
  --associate-public-ip-address \
  --subnet-id $subnet_id \
  --region $region \
  --query 'Instances[0].InstanceId' \
  --output text)

# wait for ec2 instance to be running
aws ec2 wait instance-running --instance-ids $instance_id

# Get the public IP address of the EC2 instance
public_ip=$(aws ec2 describe-instances \
  --instance-ids $instance_id \
  --region $region \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

# Write instance data to a file
echo "Public IP: $public_ip" > instance_data
