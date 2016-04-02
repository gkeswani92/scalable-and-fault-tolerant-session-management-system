#!/bin/bash -ex
echo "Updating"
yum update -y
echo "Updated"
aws configure set aws_access_key_id AKIAISOAOQKZPNRSDTCA
aws configure set aws_secret_access_key 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
aws configure set default.region us-east-1
echo "AWS CONFIGURED"
wget http://169.254.169.254/latest/meta-data/ami-launch-index
ami_value=$(<ami-launch-index)
echo "$ami_value"
rm ami-launch-index
reboot_count=$(aws sdb get-attributes --domain-name "Server_Table" --item-name $ami_value --attribute-names "REBOOT" --query '[Attributes[0].Value]' --output text --no-paginate)
((reboot_count++))
aws sdb put-attributes --domain-name "Server_Table" --item-name $ami_value --attributes Name="REBOOT",Value=$reboot_count,Replace=true
sleep 2
meta_data=$(aws sdb select --select-expression "select * from Server_Table" --output text --no-paginate)
echo $meta_data > server.txt
echo "DB - Finalized"
service tomcat8 start
echo "TOMCAT STARTED"