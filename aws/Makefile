include Makefile.preflight

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
KOPS_JSONNETFILES_DIR=$(wildcard aws/kops/*/*.*sonnet)
NODES_IPS_FILE=$(ROOT_DIR)/nodes-ips.json
KOPS_CLUSTER_CONFIG_FILE=cluster.yaml

# Generates cluster.yaml from jsonnet files found in `aws/kops/`.
# (this target will not refresh if IP of local machine has changed.
# IP is used to restrict SSH and API server access)
cluster.yaml: $(KOPS_JSONNETFILES_DIR)
	scripts/generate-cluster-config.sh > "$@"


# Always rebuild cluster.yaml file even if input files did not change
# there are dynamic inputs that may be different between the runs and Make can't detect
# https://stackoverflow.com/questions/816370/how-do-you-force-a-makefile-to-rebuild-a-target
.FORCE:
$(KOPS_CLUSTER_CONFIG_FILE): .FORCE


# One step target to install cluster complete with kubeconfig setup
.PHONY: create-cluster
create-cluster: init-cluster update-cluster get-admin


# Delete cluster and supporting files that contain IPs that can change
.PHONY: delete-cluster-yes
delete-cluster-yes:
	rm -f $(NODES_IPS_FILE)
	rm -f $(KOPS_CLUSTER_CONFIG_FILE)
	kops delete cluster --yes


# kops will try to validate a cluster pointed to by kubectl current config
# this is undesirable when there are clusters in kubeconfig that are not managed by kops
# the `-` at the beginning of the line tells Make to not fail if the command fails
# this can happen when current-context doesn't exist
.PHONY: init-cluster
init-cluster: $(KOPS_CLUSTER_CONFIG_FILE)
	-kubectx -d $(shell kubectx -c)
	kops create -f $(KOPS_CLUSTER_CONFIG_FILE)


.PHONY: update-cluster
update-cluster:
	kops update cluster --yes


.PHONY: get-admin
get-admin:
	kops export kubecfg --admin


##### Helper functions

.PHONY: debug
debug:
	@echo debug

.PHONY: check-cluster-ready
check-cluster-ready:
	kops validate cluster

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
