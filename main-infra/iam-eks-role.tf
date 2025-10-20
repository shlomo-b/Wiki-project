# role for external-secrets

module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "external-secrets-role"
  version   = "5.39.1"
  
  role_policy_arns = {
    policy = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  }
  
  oidc_providers = {
    one = {
      provider_arn               =  module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }
  depends_on = [ 
    module.eks
   ]
}

# # role for aws load balancer controller ingress

# module "iam_eks_role_alb" {
#   source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   role_name = "aws-alb-controller-ingress-role"
  
#   role_policy_arns = {
#     policy = "arn:aws:iam::148088962203:policy/AWSLoadBalancerControllerIAMPolicy"
#   }
  
#   oidc_providers = {
#     one = {
#       provider_arn               =  module.eks.oidc_provider_arn
#       namespace_service_accounts = ["aws-alb-controller:aws-alb-controller"]
#     }
#   }
#   depends_on = [ 
#     module.eks
#    ]
# }