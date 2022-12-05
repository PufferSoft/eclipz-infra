locals {
  namespace = "jenkins"
}

resource "kubernetes_secret" "jenkins_repo" {
  metadata {
    name      = "jenkins-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    name = "jenkinsci"
    url  = "https://charts.jenkins.io"
    type = "helm"
  }
}

resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = local.namespace
  }
}

resource "kubernetes_manifest" "jenkins_argocd" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "jenkins"
      "namespace" = "argocd"
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "chart"          = "jenkins"
        "repoURL"        = "https://charts.jenkins.io"
        "targetRevision" = "4.1.9"
        "helm" = {
          "releaseName" = "jenkins"
          "values" = yamlencode({
            "controller" : {
              "installPlugins" : [
                "kubernetes:3600.v144b_cd192ca_a_",
                "workflow-aggregator:581.v0c46fa_697ffd",
                "git:4.11.3",
                "configuration-as-code:1429.v09b_044a_c93de",
                "blueocean:1.25.5",
                "pipeline-aws:1.43",
                "aws-credentials:191.vcb_f183ce58b_9",
                "docker-workflow:1.29",
                "amazon-ecr:1.73.v741d474abe74",
                "pipeline-utility-steps:2.13.0",
                "pipeline-stage-view:2.24"
              ]
            }
          })
        }
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = local.namespace
      }
      "syncPolicy" = {
        "automated" = {
          "selfHeal" = true
        }
      }
    }
  }
}
