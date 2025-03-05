export GCP_PROJECT_ID ?= 
export environment ?= sample
export GCP_REGION ?= us-central1
export GCP_ZONE ?= us-central1-a

gcloud-login:
	gcloud auth application-default login 

gcp-enable-apis:
	gcloud services enable compute.googleapis.com
	gcloud services enable container.googleapis.com
	gcloud services enable cloudkms.googleapis.com

# GKE Cluster
tf-init:
	terraform -chdir=$(PWD)/terraform init -upgrade

tf-plan:
	terraform -chdir=$(PWD)/terraform plan \
		-var gcp_project_id=$(GCP_PROJECT_ID) \
		-var gcp_region=$(GCP_REGION) \
		-var environment=$(environment)


tf-apply:
	terraform -chdir=$(PWD)/terraform apply -auto-approve \
		-var gcp_project_id=$(GCP_PROJECT_ID) \
		-var gcp_region=$(GCP_REGION) \
		-var environment=$(environment)

tf-destroy:
	terraform -chdir=$(PWD)/terraform destroy -auto-approve -lock=false \
		-var gcp_project_id=$(GCP_PROJECT_ID) \
		-var gcp_region=$(GCP_REGION) \
		-var environment=$(environment)

tf-fmt:
	terraform fmt terraform/