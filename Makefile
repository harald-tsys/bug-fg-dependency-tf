# Makefile for Terraform deployment

# Terraform backend configuration


CURRENT_MAKEFILE := $(firstword $(MAKEFILE_LIST))

zip:
	cd dependency-postgres && npm pack
	cd function && npm pack

tf_init:
	terraform -chdir=terraform init

tf_plan: 
	if [ ! -f "terraform/.terraform.lock.hcl" ]; then \
		$(MAKE) -f $(CURRENT_MAKEFILE) tf_init; \
	fi
	terraform -chdir=terraform \
	  plan \
		-var-file="variables.tfvars" 

tf_apply: zip
	if [ ! -f "terraform/.terraform.lock.hcl" ]; then \
		$(MAKE) -f $(CURRENT_MAKEFILE) tf_init; \
	fi
	terraform -chdir=terraform \
	  apply -auto-approve \
	  -var-file="variables.tfvars"

tf_destroy:
	terraform -chdir=terraform \
	  destroy -auto-approve \
		-var-file="variables.tfvars"


FGS_QueryDependencies:
	# getting Token for authentication from Username/Password...
	$(eval OTC_X_AUTH_TOKEN := $(shell ./tokenFromUsername.sh))

	@curl -X GET \
	 -H "Content-Type: application/json" \
	 -H "x-auth-token: $(OTC_X_AUTH_TOKEN)" \
	 https://functiongraph.eu-de.otc.t-systems.com/v2/${OTC_SDK_PROJECTID}/fgs/dependencies?name=fg-tf-bug-postgres-dependency-8.20.0
	@echo "" 
	# finished
	
.PHONY: tf_init tf_plan tf_apply tf_destroy FGS_QueryDependencies
