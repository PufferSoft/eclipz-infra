##########################
# Settings
##########################


# tenant      = "eclipz"
# environment = "stage"
# zone        = "devops"
region    = "us-west-2"
# #profile     = chielvis1

# backends
tf_state_eks_s3_bucket = "s3-eclipz-eks-test-uw2-38"
tf_state_eks_s3_key    = "0621aa21-0a56-419e-b53c-55f9e6fd444d"

# k8s variables
namespace = "admingui"

############################
# ArgoCD locations
############################

repo_url = "https://github.com/Eclipz-Git/eclipz-infra.git"
frontend_repo_path = "deploy/e2e/k8s/yaml/frontend"
backend_repo_path = "deploy/e2e/k8s/yaml/backend"
controller_repo_path = "deploy/e2e/k8s/yaml/controller"

github_secret_arn = "arn:aws:secretsmanager:us-west-2:516256549202:secret:github-token-2fGNoV"
ssl_certificate_arn = "arn:aws:acm:us-west-2:516256549202:certificate/71ba69b0-d2fb-44d4-a03e-5b5f98d3da3b"
