module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${var.addon_context.eks_cluster_id}-lb-irsa"
  description = "Allows lb controller to manage ALB and NLB"
  policy      = data.aws_iam_policy_document.aws_lb.json
  tags        = var.addon_context.tags
}

#################################
# ALB Ingress
#################################

  resource "kubernetes_ingress_v1" "addons_ingress2" {
    metadata {
      name      = "apps-ingress2"
      namespace = "argocd"

      annotations = {
        "kubernetes.io/ingress.class" = "alb"
        # SSL certificate + redirect
      //  "alb.ingress.kubernetes.io/certificate-arn"      = var.ssl_certificate_arn
      //  "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTPS\":443}]"
      //  "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"

        # internal routing
        "alb.ingress.kubernetes.io/backend-protocol"     = "HTTP"
        "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"          = "ip"
        "alb.ingress.kubernetes.io/group.name"           = "myingresses"
        "alb.ingress.kubernetes.io/group.order"           = "2"
      }

    }


      spec {
        rule {
          host = "grafana.awssolutionsprovider.com"
          http {
            path {
              backend {
                service {
                  name = "vault-ui"
                  port {
                    number = 8200
                  }
                }
              }
              path = "/"
              path_type = "Prefix"
            }
          }
         }

        tls {
          secret_name = "tls-secret"
        }
      }
    }

    resource "kubernetes_ingress_v1" "addons_ingress" {
      metadata {
        name      = "apps-ingress"
        namespace = "prometheus"

        annotations = {
          "kubernetes.io/ingress.class" = "alb"
          # SSL certificate + redirect
        //  "alb.ingress.kubernetes.io/certificate-arn"      = var.ssl_certificate_arn
        //  "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTPS\":443}]"
        //  "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"

          # internal routing
          "alb.ingress.kubernetes.io/backend-protocol"     = "HTTP"
          "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
          "alb.ingress.kubernetes.io/target-type"          = "ip"
          "alb.ingress.kubernetes.io/group.name"           = "myingresses"
          "alb.ingress.kubernetes.io/group.order"           = "1"
        }

      }


        spec {
          rule {
            host = "prom.awssolutionsprovider.com"
            http {
              path {
                backend {
                  service {
                    name = "prometheus-server"
                    port {
                      number = 80
                    }
                  }
                }
                path = "/"
                path_type = "Prefix"
              }
            }
           }

          tls {
            secret_name = "tls-secret"
          }
        }
      }


      resource "kubernetes_ingress_v1" "addons_ingress3" {
        metadata {
          name      = "apps-ingress3"
          namespace = "grafana"

          annotations = {
            "kubernetes.io/ingress.class" = "alb"
            # SSL certificate + redirect
          //  "alb.ingress.kubernetes.io/certificate-arn"      = var.ssl_certificate_arn
          //  "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTPS\":443}]"
          //  "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"

            # internal routing
            "alb.ingress.kubernetes.io/backend-protocol"     = "HTTP"
            "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
            "alb.ingress.kubernetes.io/target-type"          = "ip"
            "alb.ingress.kubernetes.io/group.name"           = "myingresses"
            "alb.ingress.kubernetes.io/group.order"           = "3"
          }

        }


          spec {
            rule {
              host = "graf.awssolutionsprovider.com"
              http {
                path {
                  backend {
                    service {
                      name = "grafana"
                      port {
                        number = 80
                      }
                    }
                  }
                  path = "/"
                  path_type = "Prefix"
                }
              }
             }

            tls {
              secret_name = "tls-secret"
            }
          }
        }
