export GCP_PROJECT_ID := $(shell gcloud config get-value project)
export ENVIRONMENT ?= dev
export TF_WORKSPACE := $(ENVIRONMENT)
export GCP_REGION ?= us-central1
export GCP_ZONE ?= us-central1-a
export TF_ACTION ?= 

gcloud-login:
	gcloud auth application-default login 

gcp-enable-apis:
	gcloud services enable compute.googleapis.com
	gcloud services enable container.googleapis.com
	gcloud services enable cloudkms.googleapis.com

tf-fmt:
	terraform fmt -recursive

tf-workspace:
	./makefile.sh tf-workspace

# GKE Cluster

tf-gke: tf-workspace
	./gke/tf.sh $(TF_ACTION)

##################

# GKE APP
tf-app-init:
	terraform -chdir=$(PWD)/gke-app init -upgrade -migrate-state

bastion-ssh-tunnel:
	gcloud compute ssh $(ENVIRONMENT)-bastion \
    	--tunnel-through-iap \
    	--project=$(GCP_PROJECT_ID) \
    	--zone=$(GCP_ZONE) \
    	--ssh-flag="-4 -L8888:localhost:8888 -N -q -f"

tf-app-apply: bastion-ssh-tunnel
	@HTTPS_PROXY=localhost:8888 terraform -chdir=$(PWD)/gke-app apply -auto-approve \
									-var gcp_project_id=$(GCP_PROJECT_ID) \
									-var gcp_region=$(GCP_REGION) \
									-var environment=$(ENVIRONMENT)

tf-app-destroy: bastion-ssh-tunnel
	@HTTPS_PROXY=localhost:8888 terraform -chdir=$(PWD)/gke-app destroy -auto-approve -lock=false \
									-var gcp_project_id=$(GCP_PROJECT_ID) \
									-var gcp_region=$(GCP_REGION) \
									-var environment=$(ENVIRONMENT)
##################

gke-credentials:
	gcloud container clusters get-credentials $(ENVIRONMENT)-gke-cluster \
    --region=$(GCP_REGION) \
    --project=$(GCP_PROJECT_ID)