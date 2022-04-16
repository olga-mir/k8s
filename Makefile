include Makefile.preflight

JSONNETFILES=$(wildcard clusterConfig/mgmt/*.*sonnet)
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
NODES_IPS_FILE=$(ROOT_DIR)/nodes-ips.json
MGMT_CLUSTER_KOPS_CONFIG_FILE=mgmt-cluster.yaml

# Generates cluster.yaml from jsonnet files found in `clusterConfig`.
# (this target will not refresh if IP of local machine has changed.
# IP is used to restrict SSH and API server access)
mgmt-cluster.yaml: $(JSONNETFILES)
	scripts/generate-cluster-config.sh > "$@"


# One step target to install cluster complete with kubeconfig setup
.PHONY: create-cluster
create-cluster: init-cluster update-cluster get-admin


# Delete cluster and supporting files that contain IPs that can change
.PHONY: delete-cluster-yes
delete-cluster-yes: check-setup
	rm -f $(NODES_IPS_FILE)
	rm -f $(MGMT_CLUSTER_KOPS_CONFIG_FILE)
	kops delete cluster --yes


.PHONY: init-cluster
init-cluster: check-setup cluster.yaml
	kops create -f $(MGMT_CLUSTER_KOPS_CONFIG_FILE)


.PHONY: update-cluster
update-cluster: check-setup
	kops update cluster --yes


.PHONY: get-admin
get-admin: check-setup
	kops export kubecfg --admin


##### Helper functions

.PHONY: debug
debug:
	@echo debug

.PHONY: check-cluster-ready
check-cluster-ready: check-setup
	kops validate cluster

.PHONY: get-ips
get-ips:
	kubectl get nodes -o json | jq -r '.items[] | {role: .metadata.labels["kubernetes.io/role"], address0: .status.addresses[0].address, address1: .status.addresses[1].address}' | tee $(NODES_IPS_FILE)

.PHONY: get-ec2-ips
get-ec2-ips: check-setup
	aws ec2 describe-instances \
       --filters "Name=instance-state-name,Values=running" \
       --region=${AWS_REGION} \
       --query 'Reservations[*].Instances[*].[PrivateIpAddress, PublicIpAddress]' \
       --output text
