
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
TF_PLAN_FILE=$(ROOT_DIR)/tfplan

####
#### Foundation
####

.PHONY: create-vpc
create-vpc:
	$(MAKE) -C $(ROOT_DIR)/foundation tf-apply


.PHONY: delete-vpc
delete-vpc:
	$(MAKE) -C $(ROOT_DIR)/foundation cleanup


####
#### GKE
####

.PHONY: tf-init
tf-init:
	terraform init


.PHONY: tf-plan-gke
tf-plan-gke: $(ROOT_DIR)/*.tfvars $(ROOT_DIR)/*.tf
	terraform fmt
	terraform plan -var-file=dev.tfvars -out=$(TF_PLAN_FILE)


.PHONY: $(TF_PLAN_FILE)
$(TF_PLAN_FILE): tf-plan-gke


.PHONY: create-gke
create-gke: $(TF_PLAN_FILE)
	terraform apply -input=false -auto-approve $(TF_PLAN_FILE)
	gcloud container clusters get-credentials $${CLUSTER_NAME} --region $${GCP_REGION} --project $${GCP_PROJECT}


.PHONY: delete-gke
delete-gke:
	terraform plan -destroy -input=false -out=$(TF_PLAN_FILE) -var-file=dev.tfvars
	terraform apply -destroy -input=false -auto-approve $(TF_PLAN_FILE)
	-kubectx -d gke_$${GCP_PROJECT}_$${GCP_REGION}_$${CLUSTER_NAME}


# Complete teardown - delete cluster and all resources in foundation.
.PHONY: delete-all
delete-all: delete-gke
	$(MAKE) -C $(ROOT_DIR)/foundation cleanup
