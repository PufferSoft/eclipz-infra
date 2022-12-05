################################
# ECR secrets
################################
data "aws_caller_identity" "current" {}
data "aws_ecr_authorization_token" "token" {}

resource "kubernetes_secret" "ecr" {
  metadata {
    name = "ecr-cfg"
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${data.aws_ecr_authorization_token.token.proxy_endpoint}" = {
          auth = "${data.aws_ecr_authorization_token.token.authorization_token}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

#################################
# Github secret
#################################
data "aws_secretsmanager_secret" "github" {
  arn = var.github_secret_arn
}

data "aws_secretsmanager_secret_version" "github" {
  secret_id = data.aws_secretsmanager_secret.github.id
}

resource "kubernetes_secret" "github" {
  metadata {
    name      = "github-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    url      = var.repo_url
    #password = jsondecode(data.aws_secretsmanager_secret_version.github.secret_string)["token"]
    password = data.aws_secretsmanager_secret_version.github.secret_string
    username = "not-used"
  }
}



################################
# Namespace
################################
resource "kubernetes_namespace" "admingui" {
  metadata {
    name = var.namespace
  }
}

################################
# Admingui application
################################
resource "kubernetes_manifest" "argocd_frontend" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"       = "admingui-frontend"
      "namespace"  = "argocd"
      "finalizers" = ["resources-finalizer.argocd.argoproj.io"]
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = var.repo_url
        "targetRevision" = "HEAD"
        # might need to change this
        "path" = var.frontend_repo_path
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = var.namespace
      }
      "syncPolicy" = {
        "automated" = {
          "selfHeal" = true
        }
      }
    }
  }
}

resource "kubernetes_manifest" "argocd_backend" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"       = "admingui-backend"
      "namespace"  = "argocd"
      "finalizers" = ["resources-finalizer.argocd.argoproj.io"]
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = var.repo_url
        "targetRevision" = "HEAD"
        # TODO: Make this dynamic
        "path" = var.backend_repo_path
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = var.namespace
      }
      "syncPolicy" = {
        "automated" = {
          "selfHeal" = true
        }
      }
    }
  }
}

resource "kubernetes_manifest" "argocd_controller" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"       = "admingui-controller"
      "namespace"  = "argocd"
      "finalizers" = ["resources-finalizer.argocd.argoproj.io"]
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = var.repo_url
        "targetRevision" = "HEAD"
        "path"           = var.controller_repo_path
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = var.namespace
      }
      "syncPolicy" = {
        "automated" = {
          "selfHeal" = true
        }
      }
    }
  }
}

#################################
# ALB Ingress
#################################
resource "kubernetes_ingress_v1" "admingui" {
  metadata {
    name      = "admingui-ingress"
    namespace = var.namespace

    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      # SSL certificate + redirect
      "alb.ingress.kubernetes.io/certificate-arn"      = var.ssl_certificate_arn
      "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
      
      # internal routing
      "alb.ingress.kubernetes.io/backend-protocol"     = "HTTP"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"          = "ip"
    }

  }
  spec {
    rule {
      http {
        path {
          path = "/api/*"
          backend {
            service {
              name = "admingui-backend"
              port {
                number = 80
              }
            }
          }
        }
        path {
          path = "/controller/*"
          backend {
            service {
              name = "admingui-controller"
              port {
                number = 80
              }
            }
          }
        }

        path {
          path = "/*"
          backend {
            service {
              name = "admingui-frontend"
              port {
                number = 80
              }
            }
          }
        }

      }
    }
  }
}

#################################
# Database secrets
#################################
resource "kubernetes_secret" "admingui" {
  metadata {
    name      = "admingui-secrets"
    namespace = var.namespace
  }

  depends_on = [kubernetes_namespace.admingui]

  data = {
    database    = data.terraform_remote_state.eks.outputs.db_name
    db_password = data.terraform_remote_state.eks.outputs.db_password
    db_user     = data.terraform_remote_state.eks.outputs.db_username
    db_host     = data.terraform_remote_state.eks.outputs.db_endpoint
    db_port     = data.terraform_remote_state.eks.outputs.db_port
  }
}

