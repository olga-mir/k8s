# https://github.com/kubernetes/kops/blob/master/docs/operations/images.md

# us-east-1
AWS_REGION=ap-southeast-2

echo AL2

aws ec2 describe-images --region $AWS_REGION --output table \
  --owners 137112412989 \
  --query "sort_by(Images, &CreationDate)[*].[CreationDate,Name,ImageId]" \
  --filters "Name=name,Values=amzn2-ami-kernel-5.10-hvm-2*-x86_64-gp2"

echo UBUNTU 22.04

aws ec2 describe-images --region $AWS_REGION --output table \
  --owners 099720109477 \
  --query "sort_by(Images, &CreationDate)[*].[CreationDate,Name,ImageId]" \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"
