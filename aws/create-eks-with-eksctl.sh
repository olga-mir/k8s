#!/bin/bash

# https://docs.aws.amazon.com/eks/latest/userguide/cni-custom-network.html
# https://github.com/eksctl-io/eksctl/blob/main/examples/15-managed-nodes.yaml

export cluster_name=eks-test-network
account_id=$(aws sts get-caller-identity --query Account --output text)

vpc_stack=eks-test-vpc-stack
vpc_cf_template_url="https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml"

vpc_cidr="10.0.0.0/16"
private01_cidr="10.0.0.0/27"
private02_cidr="10.0.16.0/27"
public01_cidr="10.0.128.0/27"
public02_cidr="10.0.144.0/27"

new_cidr_1="100.64.1.0/24"
new_cidr_2="100.64.2.0/24"

aws cloudformation create-stack --stack-name $vpc_stack \
  --template-url $vpc_cf_template_url \
  --parameters ParameterKey=VpcBlock,ParameterValue=$vpc_cidr \
               ParameterKey=PrivateSubnet01Block,ParameterValue=$private01_cidr \
               ParameterKey=PrivateSubnet02Block,ParameterValue=$private02_cidr \
               ParameterKey=PublicSubnet01Block,ParameterValue=$public01_cidr \
               ParameterKey=PublicSubnet02Block,ParameterValue=$public02_cidr


# check manually: aws cloudformation describe-stacks --stack-name my-eks-custom-networking-vpc --query Stacks\[\].StackStatus  --output text
aws cloudformation wait  stack-create-complete --stack-name $vpc_stack


subnet_id_1=$(aws cloudformation describe-stack-resources --stack-name $vpc_stack \
    --query "StackResources[?LogicalResourceId=='PrivateSubnet01'].PhysicalResourceId" --output text)
subnet_id_2=$(aws cloudformation describe-stack-resources --stack-name $vpc_stack \
    --query "StackResources[?LogicalResourceId=='PrivateSubnet02'].PhysicalResourceId" --output text)



# below is work in progress
exit 0


aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" \
    --query 'Subnets[*].{SubnetId: SubnetId,AvailabilityZone: AvailabilityZone,CidrBlock: CidrBlock}' \
    --output table

aws ec2 describe-vpcs --vpc-ids $vpc_id --query 'Vpcs[*].CidrBlockAssociationSet[*].{CIDRBlock: CidrBlock, State: CidrBlockState.State}' --out table

cat <<EOF >eks-config.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: $cluster_name
  region: $AWS_REGION

managedNodeGroups:
  - name: managed-ng-public
    instanceType: m5.large
    availabilityZones: ["us-west-2a", "us-west-2b"]
    securityGroups:
      attachIDs: ["sg-1", "sg-2"]
    # ssh:
    #   allow: true
    #   publicKeyPath: ~/.ssh/ec2_id_rsa.pub
    #   sourceSecurityGroupIds: ["sg-00241fbb12c607007"]
    labels: {role: worker}
EOF

eksctl create cluster -f ./eks-config.yaml
