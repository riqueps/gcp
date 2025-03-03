data "google_client_config" "default" {}

data "google_container_cluster" "gke_cluster" {
  name     = "${var.env_name}-gke-cluster"
  location = var.gcp_region
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.gke_cluster.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
}

# Workload identity for gke workloads
# https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/11.0.0/submodules/workload-identity
module "workload_identity_hello_app" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version             = "11.0.0"
  project_id          = var.gcp_project_id
  name                = "example-hello-app-sa"
  namespace           = "default"
}

# Grant storage admin permission to the SA
resource "google_project_iam_member" "sa_binding" {
  project = var.gcp_project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${module.workload_identity_hello_app.gcp_service_account_email}"
}

# K8S objects
resource "kubernetes_deployment_v1" "default" {
  metadata {
    name = "example-hello-app-deployment"
  }

  spec {
    selector {
      match_labels = {
        app = "hello-app"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "hello-app"
        }
      }

      spec {
        service_account_name = "example-hello-app-sa"
        container {
          image = "us-docker.pkg.dev/google-samples/containers/gke/hello-app:2.0"
          name  = "hello-app-container"

          port {
            container_port = 8080
            name           = "hello-app-svc"
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false

            capabilities {
              add  = []
              drop = ["NET_RAW"]
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "hello-app-svc"

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }

        security_context {
          run_as_non_root = true

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        # Toleration is currently required to prevent perpetual diff:
        # https://github.com/hashicorp/terraform-provider-kubernetes/pull/2380
        toleration {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "amd64"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "default" {
  metadata {
    name = "example-hello-app-service"
    annotations = {
      "cloud.google.com/neg" = "{\"ingress\": true}"
      "cloud.google.com/backend-config"= "{\"ports\": {\"80\":\"example-hello-app-backendconfig\"}}"
    }
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.default.spec[0].selector[0].match_labels.app
    }

    ip_family_policy = "SingleStack"

    port {
      port        = 80
      target_port = kubernetes_deployment_v1.default.spec[0].template[0].spec[0].container[0].port[0].name
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name = "example-hello-app-ingress"
  }

  spec {
    default_backend {
      service {
        name = "example-hello-app-service"
        port {
          number = 80
        }
      } 
      
    }
  }
}

resource "kubernetes_manifest" "backendconfig" {
  manifest = {
    "apiVersion" = "cloud.google.com/v1"
    "kind"       = "BackendConfig"
    "metadata" = {
      "name"      = "example-hello-app-backendconfig"
      "namespace" = "default"
    }
    "spec" = {
      "securityPolicy" = {
        "name" = "${var.env_name}-ca-policy"
      }
    }
  }
}
