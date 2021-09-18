include Makefile.preflight
DATESTR=$(date +%F_%H_%M_%S)
JSONNETFILES=$(wildcard clusterConfig/*.*sonnet)

# Generates cluster.yaml from jsonnet files found in `clusterConfig`.
# (this target will not re-fresh if IP of local machine has changed.
# IP is used to restrict SSH access)
cluster.yaml: $(JSONNETFILES)
	scripts/generate-cluster-config.sh > "$@"


# One step target to install cluster complete with kubeconfig setup
.PHONY: create-cluster
create-cluster: init-cluster update-cluster get-admin
	@echo "*** Your chariot awaits ***"


# Delete cluster
.PHONY: delete-cluster-yes
delete-cluster-yes: check-setup
	kops delete cluster --yes


.PHONY: init-cluster
init-cluster: check-setup cluster.yaml
	kops create -f cluster.yaml


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
	kubectl get nodes -o json | jq '[.items[] | {role: .metadata.labels["kubernetes.io/role"], addresses: .status.addresses | map(select(.type=="InternalIP" or .type=="ExternalIP"))}]' > nodes-ips.json
	jq '.[]|.addresses|map(select(.type=="ExternalIP"))|.[].address' nodes-ips.json > public-ips-nodes.txt && cat public-ips-nodes.txt

.PHONY: get-ec2-ips
get-ec2-ips: check-setup
	aws ec2 describe-instances \
       --filters "Name=instance-state-name,Values=running" \
       --region=${AWS_REGION} \
       --query 'Reservations[*].Instances[*].[PrivateIpAddress, PublicIpAddress]' \
       --output text
