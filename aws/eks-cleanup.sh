#!/bin/bash

set -eoux pipefail

cluster_name=eks-test-network
vpc_stack=eks-test-vpc-stack

eksctl delete cluster --name=$cluster_name

vpc_id=$(aws cloudformation describe-stacks --stack-name $vpc_stack --query 'Stacks[0].Outputs[?OutputKey==`VpcId`].OutputValue' --output=text)

# in next iteratation can use additional tags to filter only subnets that are not part of stacks
subnets=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" --filters "Name=vpc-id,Values=$vpc_id" --query 'Subnets[*].{SubnetId: SubnetId}' --output text)
for s in ${subnets[@]}; do
  aws ec2 delete-subnet --subnet-id $s
done

aws cloudformation delete-stack --stack-name my-eks-custom-networking-vpc
