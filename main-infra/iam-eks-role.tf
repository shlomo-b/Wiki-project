# role for external-secrets

module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "external-secrets-role"
  version   = "5.28.0"

  role_policy_arns = {
    policy = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  }

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }
  depends_on = [
    module.eks
  ]
}

# # role for aws load balancer controller ingress

# Small managed policy: grants permission to DescribeListenerAttributes for ALB
resource "aws_iam_policy" "alb_extra" {
  name = "AWSLoadBalancerControllerExtra"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid      = "AllowDescribeListenerAttributes",
      Effect   = "Allow",
      Action   = ["elasticloadbalancing:DescribeListenerAttributes"],
      Resource = ["*"]
    }]
  })
}

# IAM Role for the AWS Load Balancer Controller with built-in and extra policies
module "iam_eks_role_alb_controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.28.0"

  role_name                                                       = "aws-load-balancer-controller-role"
  attach_load_balancer_controller_policy                          = true
  attach_load_balancer_controller_targetgroup_binding_only_policy = true


  role_policy_arns = {
    extra = aws_iam_policy.alb_extra.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["aws-alb-controller:aws-load-balancer-controller"]
    }
  }

  depends_on = [module.eks]
}


# IAM Role for external-dns
module "iam_eks_role_external-dns" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.28.0"

  role_name                  = "external-dns-role"
  attach_external_dns_policy = true

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }

  depends_on = [module.eks]
}
