# Makefile for Terraform deployment

# Terraform backend configuration
SHELL := /bin/bash

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


# get auth token for FunctionGraph API calls
get_auth_token:
	mkdir -p temp
	$(eval OTC_X_AUTH_TOKEN := $(shell ./tokenFromUsername.sh))

FGS_QueryDependencies: get_auth_token
	
	@curl -X GET \
	 -H "Content-Type: application/json" \
	 -H "x-auth-token: $(OTC_X_AUTH_TOKEN)" \
	 https://functiongraph.eu-de.otc.t-systems.com/v2/${OTC_SDK_PROJECTID}/fgs/dependencies?runtime=Node.js20.15 \
	 -o ./temp/QueryDependencies_response.json
	 cat ./temp/QueryDependencies_response.json | jq .
	@echo "" 
	# finished

FGS_CreateDependencyVersion: get_auth_token
		
	jq --rawfile data <(base64 -w 0 ./dependency-postgres/postgres-dependency-8.20.0.zip) '.depend_file = $$data' ./data/createDependencyVersion.json > ./temp/createDependencyVersion1.json

	@curl -X POST \
	 -H "Content-Type: application/json" \
	 -H "x-auth-token: $(OTC_X_AUTH_TOKEN)" \
	 -d @./temp/createDependencyVersion1.json \
	 https://functiongraph.eu-de.otc.t-systems.com/v2/${OTC_SDK_PROJECTID}/fgs/dependencies/version \
	 -o ./temp/createDependencyVersion_response.json
	 cat ./temp/createDependencyVersion_response.json | jq .
	@echo "" 
	# finished

FGS_CreateFunction: get_auth_token
		
	jq --rawfile data <(base64 -w 0 ./function/src/index.js) '.func_code.file = $$data' ./data/createFunction.json > ./temp/createFunction1.json

	@curl -X POST \
	 -H "Content-Type: application/json" \
	 -H "x-auth-token: $(OTC_X_AUTH_TOKEN)" \
	 -d @./temp/createFunction1.json \
	 https://functiongraph.eu-de.otc.t-systems.com/v2/${OTC_SDK_PROJECTID}/fgs/functions \
	 -o ./temp/createFunction_response.json
	 cat ./temp/createFunction_response.json | jq .
	@echo "" 
	# finished


FGS_FunctionDependencyAdd: get_auth_token
	
	jq --rawfile data <(base64 -w 0 ./function/src/index.js) '.func_code.file = $$data' ./data/FunctionDependency_add.json > ./temp/FunctionDependency_add.json

	@curl -X PUT \
	 -H "Content-Type: application/json" \
	 -H "x-auth-token: $(OTC_X_AUTH_TOKEN)" \
	 -d @./temp/FunctionDependency_add.json \
	 https://functiongraph.eu-de.otc.t-systems.com/v2/${OTC_SDK_PROJECTID}/fgs/functions/urn:fss:eu-de:d52e41d2434941b194ce3f91b1b12f8a:function:default:test-function/code \
	 -o ./temp/FunctionDependencyAdd_response.json
	 cat ./temp/FunctionDependencyAdd_response.json | jq .
	@echo "" 
	# finished

FGS_FunctionDependencyRemove: get_auth_token
	
	mkdir -p temp
	jq --rawfile data <(base64 -w 0 ./function/src/index.js) '.func_code.file = $$data' ./data/FunctionDependency_remove.json > ./temp/FunctionDependency_remove.json

	@curl -X PUT \
	 -H "Content-Type: application/json" \
	 -H "x-auth-token: $(OTC_X_AUTH_TOKEN)" \
	 -d @./temp/FunctionDependency_remove.json \
	 https://functiongraph.eu-de.otc.t-systems.com/v2/${OTC_SDK_PROJECTID}/fgs/functions/urn:fss:eu-de:d52e41d2434941b194ce3f91b1b12f8a:function:default:test-function/code \
	 -o ./temp/FunctionDependencyRemove_response.json
	 cat ./temp/FunctionDependencyRemove_response.json | jq .
	@echo "" 
	# finished


FGS_DeleteFunction: get_auth_token
	
	@curl -X DELETE \
	 -H "Content-Type: application/json" \
	 -H "x-auth-token: $(OTC_X_AUTH_TOKEN)" \
	 https://functiongraph.eu-de.otc.t-systems.com/v2/${OTC_SDK_PROJECTID}/fgs/functions/urn:fss:eu-de:d52e41d2434941b194ce3f91b1b12f8a:function:default:test-function
	@echo "" 
	# finished


.PHONY: tf_init tf_plan tf_apply tf_destroy FGS_QueryDependencies FGS_CreateDependencyVersion FGS_CreateFunction FGS_FunctionDependencyAdd FGS_FunctionDependencyRemove FGS_DeleteFunction
