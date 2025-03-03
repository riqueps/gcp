export GCP_PROJECT_ID ?= 
export ENV_NAME ?= sample
export GCP_REGION ?= us-central1
export GCP_ZONE ?= us-central1-a
export PRIVATE_SUBNET_NAME = "private"
export PUBLIC_SUBNET_NAME = "public"

gcloud-login:
	gcloud auth application-default login 

gcp-enable-apis:
	gcloud services enable compute.googleapis.com
	gcloud services enable container.googleapis.com
	gcloud services enable cloudkms.googleapis.com

# GKE Cluster
tf-gke-init:
	terraform -chdir=$(PWD)/gke init -upgrade

tf-gke-plan:
	terraform -chdir=$(PWD)/gke plan \
		-var gcp_project_id=$(GCP_PROJECT_ID) \
		-var gcp_region=$(GCP_REGION) \
		-var env_name=$(ENV_NAME)


tf-gke-apply:
	terraform -chdir=$(PWD)/gke apply -auto-approve \
		-var gcp_project_id=$(GCP_PROJECT_ID) \
		-var gcp_region=$(GCP_REGION) \
		-var env_name=$(ENV_NAME)

tf-gke-destroy:
	terraform -chdir=$(PWD)/gke destroy -auto-approve -lock=false \
		-var gcp_project_id=$(GCP_PROJECT_ID) \
		-var gcp_region=$(GCP_REGION) \
		-var env_name=$(ENV_NAME)

##################

# GKE APP
tf-app-init:
	terraform -chdir=$(PWD)/gke-app init -upgrade -migrate-state

bastion-ssh-tunnel:
	gcloud compute ssh $(ENV_NAME)-bastion \
    	--tunnel-through-iap \
    	--project=$(GCP_PROJECT_ID) \
    	--zone=$(GCP_ZONE) \
    	--ssh-flag="-4 -L8888:localhost:8888 -N -q -f"

tf-app-apply: bastion-ssh-tunnel
	@HTTPS_PROXY=localhost:8888 terraform -chdir=$(PWD)/gke-app apply -auto-approve \
									-var gcp_project_id=$(GCP_PROJECT_ID) \
									-var gcp_region=$(GCP_REGION) \
									-var env_name=$(ENV_NAME)

tf-app-destroy: bastion-ssh-tunnel
	@HTTPS_PROXY=localhost:8888 terraform -chdir=$(PWD)/gke-app destroy -auto-approve -lock=false \
									-var gcp_project_id=$(GCP_PROJECT_ID) \
									-var gcp_region=$(GCP_REGION) \
									-var env_name=$(ENV_NAME)
##################

gke-credentials:
	gcloud container clusters get-credentials $(ENV_NAME)-gke-cluster \
    --region=$(GCP_REGION) \
    --project=$(GCP_PROJECT_ID)