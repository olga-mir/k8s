
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
TF_PLAN_FILE=$(ROOT_DIR)/tfplan

.PHONY: tf-plan
tf-plan: $(ROOT_DIR)/*.tfvars $(ROOT_DIR)/*.tf
	terraform plan -var-file=dev.tfvars -out=$(TF_PLAN_FILE)


.PHONY: $(TF_PLAN_FILE)
$(TF_PLAN_FILE): tf-plan


.PHONY: tf-apply
tf-apply: $(TF_PLAN_FILE)
	terraform apply -input=false -auto-approve $(TF_PLAN_FILE)


.PHONY: cleanup
cleanup:
	terraform plan -destroy -input=false -out=$(TF_PLAN_FILE) -var-file=dev.tfvars
	terraform apply -destroy -input=false -auto-approve $(TF_PLAN_FILE)
