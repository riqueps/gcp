export GCP_PROJECT_ID ?= 

gcloud-login:
	gcloud auth application-default login 

tf-init:
	terraform -chdir=$(PWD)/terraform init -upgrade

tf-apply:
	terraform -chdir=$(PWD)/terraform apply -auto-approve

tf-destroy:
	terraform -chdir=$(PWD)/terraform destroy -auto-approve

gcp-enable-apis:
	gcloud services enable compute.googleapis.com
