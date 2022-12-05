locals {
  name = "vault"
  default_helm_config = {
    name       = "vault"                                          # (Required) Release name.
    chart      = "vault"                                          # (Required) Chart name to be installed.
    repository = "https://helm.releases.hashicorp.com"            # (Optional) Repository URL where to locate the requested chart.
    version    = "v0.19.0"                                        # (Optional) Specify the exact chart version to install.
    values     = []
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}
