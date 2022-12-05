locals {
  name = "promtail"
  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://grafana.github.io/helm-charts"
    version          = "6.3.0"
    namespace        = local.name
    values           = []
    create_namespace = true
    description      = "Promtail helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.name
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.promtail.arn], var.irsa_policies)
  }

  argocd_gitops_config = {
    enable = true
  }
}
