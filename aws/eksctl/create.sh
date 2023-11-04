#!/bin/bash

set -eoux pipefail

# https://docs.aws.amazon.com/eks/latest/userguide/cni-custom-network.html
# https://github.com/eksctl-io/eksctl/blob/main/examples/15-managed-nodes.yaml

cluster_name=eks-demo-ip
vpc_stack=eks-demo-ip-vpc-stack
vpc_cf_template_url="https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml"

vpc_cidr="10.0.0.0/16"
private01_cidr="10.0.186.0/27"
private02_cidr="10.0.192.0/27"
public01_cidr="10.0.208.0/27"
public02_cidr="10.0.224.0/27"

# This stack provisions NATs, make sure to delete it
aws cloudformation create-stack --stack-name $vpc_stack \
  --template-url $vpc_cf_template_url \
  --parameters ParameterKey=VpcBlock,ParameterValue=$vpc_cidr \
               ParameterKey=PrivateSubnet01Block,ParameterValue=$private01_cidr \
               ParameterKey=PrivateSubnet02Block,ParameterValue=$private02_cidr \
               ParameterKey=PublicSubnet01Block,ParameterValue=$public01_cidr \
               ParameterKey=PublicSubnet02Block,ParameterValue=$public02_cidr

# check manually: aws cloudformation describe-stacks --stack-name my-eks-custom-networking-vpc --query Stacks\[\].StackStatus  --output text
aws cloudformation wait  stack-create-complete --stack-name $vpc_stack

vpc_id=$(aws cloudformation describe-stacks --stack-name $vpc_stack --query 'Stacks[0].Outputs[?OutputKey==`VpcId`].OutputValue' --output=text)

subnet_id_1=$(aws cloudformation describe-stack-resources --stack-name $vpc_stack \
    --query "StackResources[?LogicalResourceId=='PrivateSubnet01'].PhysicalResourceId" --output text)
subnet_id_2=$(aws cloudformation describe-stack-resources --stack-name $vpc_stack \
    --query "StackResources[?LogicalResourceId=='PrivateSubnet02'].PhysicalResourceId" --output text)

public_subnet_id_1=$(aws cloudformation describe-stack-resources --stack-name $vpc_stack \
    --query "StackResources[?LogicalResourceId=='PublicSubnet01'].PhysicalResourceId" --output text)
public_subnet_id_2=$(aws cloudformation describe-stack-resources --stack-name $vpc_stack \
    --query "StackResources[?LogicalResourceId=='PublicSubnet02'].PhysicalResourceId" --output text)

az_1=$(aws ec2 describe-subnets --subnet-ids $subnet_id_1 --query 'Subnets[*].AvailabilityZone' --output text)
az_2=$(aws ec2 describe-subnets --subnet-ids $subnet_id_2 --query 'Subnets[*].AvailabilityZone' --output text)

cat <<EOF > eks-config.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: $cluster_name
  region: $AWS_REGION

vpc:
  id: $vpc_id
  subnets:
    private:
      $az_1:
        id: $subnet_id_1
      $az_2:
        id: $subnet_id_2

    public:
      $az_1:
        id: $public_subnet_id_1
      $az_2:
        id: $public_subnet_id_2

managedNodeGroups:
  - name: managed-ng-orig
    labels: {role: worker}
    availabilityZones: [$az_1, $az_2]
    minSize: 2
    maxSize: 6
    volumeSize: 40
    instanceTypes: ["t3.small", "t3.medium"]
    spot: true

    updateConfig:
      maxUnavailable: 1

    iam:
      withAddonPolicies:
        autoScaler: true

cloudWatch:
  clusterLogging:
    enableTypes: ["scheduler"]
    # all supported types: "api", "audit", "authenticator", "controllerManager", "scheduler"
    # supported special values: "*" and "all"
    logRetentionInDays: 1

EOF

eksctl create cluster -f ./eks-config.yaml


# Install Cluster Autoscaler
helm repo add autoscaler https://kubernetes.github.io/autoscaler

helm install cluster-autoscaler autoscaler/cluster-autoscaler -n kube-system \
    --set autoDiscovery.clusterName=$cluster_name \
    --set awsRegion=$AWS_REGION
