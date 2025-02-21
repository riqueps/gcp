export GCP_PROJECT_ID ?= 

gcloud-login:
	gcloud auth application-default login 

tf-init:
	terraform -chdir=$(PWD)/terraform init -upgrade

tf-plan:
	terraform -chdir=$(PWD)/terraform plan

tf-apply:
	terraform -chdir=$(PWD)/terraform apply -auto-approve

tf-destroy:
	terraform -chdir=$(PWD)/terraform destroy -auto-approve

gcp-enable-apis:
	gcloud services enable compute.googleapis.com
	gcloud services enable container.googleapis.com
	gcloud services enable cloudkms.googleapis.com
