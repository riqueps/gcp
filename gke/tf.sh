#/bin/bash

apply () {
    terraform -chdir=${PWD}/gke/base init -reconfigure
    terraform -chdir=${PWD}/gke/base apply -auto-approve \
		  -var gcp_project_id=${GCP_PROJECT_ID} \
		  -var gcp_region=${GCP_REGION} \
		  -var environment=${ENVIRONMENT}
    
    terraform -chdir=${PWD}/gke/cluster init -reconfigure
    terraform -chdir=${PWD}/gke/cluster apply -auto-approve \
		  -var gcp_project_id=${GCP_PROJECT_ID} \
		  -var gcp_region=${GCP_REGION} \
		  -var environment=${ENVIRONMENT}
}

destroy () {
    terraform -chdir=${PWD}/gke/cluster init
    terraform -chdir=${PWD}/gke/cluster destroy -auto-approve \
		  -var gcp_project_id=${GCP_PROJECT_ID} \
		  -var gcp_region=${GCP_REGION} \
		  -var environment=${ENVIRONMENT}

    terraform -chdir=${PWD}/gke/base init
    terraform -chdir=${PWD}/gke/base destroy -auto-approve \
		  -var gcp_project_id=${GCP_PROJECT_ID} \
		  -var gcp_region=${GCP_REGION} \
		  -var environment=${ENVIRONMENT}
}

plan () {    
    terraform -chdir=${PWD}/gke/base init -reconfigure
    terraform -chdir=${PWD}/gke/base plan \
		  -var gcp_project_id=${GCP_PROJECT_ID} \
		  -var gcp_region=${GCP_REGION} \
		  -var environment=${ENVIRONMENT}
    
    terraform -chdir=${PWD}/gke/cluster init -reconfigure
    terraform -chdir=${PWD}/gke/cluster plan \
		  -var gcp_project_id=${GCP_PROJECT_ID} \
		  -var gcp_region=${GCP_REGION} \
		  -var environment=${ENVIRONMENT}
}

case "$1" in
    "apply") apply
    ;;
    "destroy") destroy
    ;;
    "plan") plan
    ;;
esac