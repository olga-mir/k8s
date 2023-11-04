include Makefile.preflight

AWS_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
KOPS_JSONNETFILES_DIR=$(wildcard aws/kops/*/*.*sonnet)
NODES_IPS_FILE=$(AWS_DIR)/nodes-ips.json
KOPS_CLUSTER_CONFIG_FILE=$(AWS_DIR)/kops/cluster.yaml

# Generates cluster.yaml from jsonnet files found in `aws/kops/`.
# (this target will not refresh if IP of local machine has changed.
# IP is used to restrict SSH and API server access)
$(KOPS_CLUSTER_CONFIG_FILE): $(KOPS_JSONNETFILES_DIR)
	envsubst < $(AWS_DIR)/kops/overlays/template.libsonnet > $(AWS_DIR)/kops/overlays/dev-cluster.libsonnet
	$(AWS_DIR)/kops/generate-cluster-config.sh > "$@"


# Always rebuild cluster.yaml file even if input files did not change
# there are dynamic inputs that may be different between the runs and Make can't detect
# https://stackoverflow.com/questions/816370/how-do-you-force-a-makefile-to-rebuild-a-target
.FORCE:
$(KOPS_CLUSTER_CONFIG_FILE): .FORCE


# One step target to install cluster complete with kubeconfig setup
.PHONY: kops-create-cluster
kops-create-cluster: kops-init-cluster kops-update-cluster kops-get-admin


# Delete cluster and supporting files that contain IPs that can change
.PHONY: kops-delete-cluster-yes
kops-delete-cluster-yes:
	rm -f $(NODES_IPS_FILE)
	rm -f $(KOPS_CLUSTER_CONFIG_FILE)
	kops delete cluster --name $(KOPS_CLUSTER_NAME) --yes
	aws s3 rm $(KOPS_STATE_STORE)/$(KOPS_CLUSTER_NAME) --recursive

# kops will try to validate a cluster pointed to by kubectl current config
# this is undesirable when there are clusters in kubeconfig that are not managed by kops
# the `-` at the beginning of the line tells Make to not fail if the command fails
.PHONY: kops-init-cluster
kops-init-cluster: $(KOPS_CLUSTER_CONFIG_FILE)
	-kubectl --kubeconfig=~/.kube/config config delete-user $(KOPS_CLUSTER_NAME)
	-kubectl --kubeconfig=~/.kube/config config delete-cluster $(KOPS_CLUSTER_NAME)
	-kubectl --kubeconfig=~/.kube/config config delete-context $(KOPS_CLUSTER_NAME)
	kops create -f $(KOPS_CLUSTER_CONFIG_FILE)


.PHONY: kops-update-cluster
kops-update-cluster:
	kops update cluster --name $(KOPS_CLUSTER_NAME) --yes


.PHONY: kops-get-admin
kops-get-admin:
	kops export kubecfg --admin --name $(KOPS_CLUSTER_NAME)


##### Helper functions

.PHONY: kops-check-cluster-ready
kops-check-cluster-ready:
	kops validate cluster --name $(KOPS_CLUSTER_NAME)

.PHONY: get-ips
get-ips:
	kubectl get nodes -o json | jq -r '.items[] | {role: .metadata.labels["kubernetes.io/role"], address0: .status.addresses[0].address, address1: .status.addresses[1].address}' | tee $(NODES_IPS_FILE)

.PHONY: get-ec2-ips
get-ec2-ips:
	aws ec2 describe-instances \
       --filters "Name=instance-state-name,Values=running" \
       --region=${AWS_REGION} \
       --query 'Reservations[*].Instances[*].[PrivateIpAddress, PublicIpAddress]' \
       --output text
