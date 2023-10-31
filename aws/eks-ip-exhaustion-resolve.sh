#!/bin/bash

set -eoux pipefail

# https://docs.aws.amazon.com/eks/latest/userguide/cni-custom-network.html

cluster_name=eks-test-network
vpc_stack=eks-test-vpc-stack

new_vpc_cidr="100.64.0.0/20"
new_cidr_1="100.64.1.0/24"
new_cidr_2="100.64.2.0/24"

kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
cluster_security_group_id=$(aws eks describe-cluster --name $cluster_name --query cluster.resourcesVpcConfig.clusterSecurityGroupId --output text)

subnet_id_1=$(aws cloudformation describe-stack-resources --stack-name $vpc_stack \
    --query "StackResources[?LogicalResourceId=='PrivateSubnet01'].PhysicalResourceId" --output text)
subnet_id_2=$(aws cloudformation describe-stack-resources --stack-name $vpc_stack \
    --query "StackResources[?LogicalResourceId=='PrivateSubnet02'].PhysicalResourceId" --output text)

az_1=$(aws ec2 describe-subnets --subnet-ids $subnet_id_1 --query 'Subnets[*].AvailabilityZone' --output text)
az_2=$(aws ec2 describe-subnets --subnet-ids $subnet_id_2 --query 'Subnets[*].AvailabilityZone' --output text)

echo "Associating new CIDR"
aws ec2 associate-vpc-cidr-block --vpc-id $vpc_id --cidr-block $new_vpc_cidr
sleep 60

new_subnet_id_1=$(aws ec2 create-subnet --vpc-id $vpc_id --availability-zone $az_1 --cidr-block $new_cidr_1 \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${vpc_stack}-PrivateSubnet01},{Key=kubernetes.io/role/internal-elb,Value=1},{Key=provisioning,Value=manual}]" \
    --query Subnet.SubnetId --output text)
new_subnet_id_2=$(aws ec2 create-subnet --vpc-id $vpc_id --availability-zone $az_2 --cidr-block $new_cidr_2 \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${vpc_stack}-PrivateSubnet02},{Key=kubernetes.io/role/internal-elb,Value=1},{Key=provisioning,Value=manual}]" \
    --query Subnet.SubnetId --output text)

aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" \
    --query 'Subnets[*].{SubnetId: SubnetId,AvailabilityZone: AvailabilityZone,CidrBlock: CidrBlock}' \
    --output table

aws ec2 describe-vpcs --vpc-ids $vpc_id --query 'Vpcs[*].CidrBlockAssociationSet[*].{CIDRBlock: CidrBlock, State: CidrBlockState.State}' --out table

aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" \
    --query 'Subnets[*].{SubnetId: SubnetId,AvailabilityZone: AvailabilityZone,CidrBlock: CidrBlock}' \
    --output table

aws ec2 describe-vpcs --vpc-ids $vpc_id --query 'Vpcs[*].CidrBlockAssociationSet[*].{CIDRBlock: CidrBlock, State: CidrBlockState.State}' --out table

cat > eni_resources.yaml <<EOF
---
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: $az_1
spec:
  securityGroups:
    - $cluster_security_group_id
  subnet: $new_subnet_id_1
---
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: $az_2
spec:
  securityGroups:
    - $cluster_security_group_id
  subnet: $new_subnet_id_2
EOF


kubectl apply -f eni_resources.yaml

kubectl get ENIConfigs

kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=topology.kubernetes.io/zone

cat <<EOF > new_ng.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: $cluster_name
  region: $AWS_REGION

managedNodeGroups:
  - name: managed-ng-new
    availabilityZones: [$az_1, $az_2]
    # securityGroups:
    #  attachIDs: ["sg-1", "sg-2"]
    # ssh:
    #   allow: true
    #   publicKeyPath: ~/.ssh/ec2_id_rsa.pub
    #   sourceSecurityGroupIds: ["sg-00241fbb12c607007"]
    labels: {role: worker}
    instanceTypes: ["t3.small", "t3.medium"]
    spot: true
EOF

eksctl create nodegroup --config-file=new_ng.yaml

