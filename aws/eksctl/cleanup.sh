#!/bin/bash

set -oux pipefail

cluster_name=eks-demo-ip
vpc_stack=eks-demo-ip-vpc-stack

eksctl delete cluster --name=$cluster_name

vpc_id=$(aws cloudformation describe-stacks --stack-name $vpc_stack --query 'Stacks[0].Outputs[?OutputKey==`VpcId`].OutputValue' --output=text)

sleep 30
# Key=provisioning,Value=manual
subnets=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" --query 'Subnets[*].{SubnetId: SubnetId}' --output text)
for s in ${subnets[@]}; do
  aws ec2 delete-subnet --subnet-id $s
done

aws cloudformation delete-stack --stack-name $vpc_stack
aws cloudformation wait stack-delete-complete --stack-name $vpc_stack
