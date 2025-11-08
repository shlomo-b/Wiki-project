# role for external-secrets

module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "external-secrets-role"
  version = "5.28.0"
  
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


# data "aws_iam_policy_document" "alb_extra" {
#   statement {
#     sid     = "AllowDescribeListenerAttributes"
#     effect  = "Allow"
#     actions = [
#       "elasticloadbalancing:DescribeListenerAttributes"
#     ]
#     resources = ["*"]
#   }
# }

# resource "aws_iam_policy" "alb_extra" {
#   name   = "AWSLoadBalancerControllerExtra"
#   policy = data.aws_iam_policy_document.alb_extra.json
# }

module "iam_eks_role_alb_controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.28.0"

  role_name                              = "aws-load-balancer-controller-role"
  attach_load_balancer_controller_policy = true

  # role_policy_arns = {
  #   extra = aws_iam_policy.alb_extra.arn
  # }

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["aws-alb-controller:aws-load-balancer-controller"]
    }
  }

  depends_on = [
    module.eks
  ]
}
