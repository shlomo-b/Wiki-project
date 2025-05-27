module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr
  cluster_endpoint_public_access  = true

  # Disable creation of security groups
  create_cluster_security_group = false
  create_node_security_group    = false
  cluster_security_group_id = module.sgs["vpc-one"].security_group_id
  
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    aws-ebs-csi-driver     = {}
  }

    vpc_id                   =  module.vpc["vpc-one"].vpc_id
    subnet_ids               = [
        module.vpc["vpc-one"].public_subnets[0],
        module.vpc["vpc-one"].public_subnets[1]
    ]
    control_plane_subnet_ids = [
        module.vpc["vpc-one"].private_subnets[0],
        module.vpc["vpc-one"].private_subnets[1]
    ]
    
  # EKS Managed Node Group(s) 
  eks_managed_node_group_defaults = {
    instance_types = var.instance_types

    # create self iam role and give access to node group
    create_iam_role = false
    iam_role_name =  aws_iam_role.eks_cluster_role.name
    iam_role_arn  =  aws_iam_role.eks_cluster_role.arn
  }

  eks_managed_node_groups = {
    prod-k8s-nodes = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.instance_types

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size
      vpc_security_group_ids = [module.sgs["vpc-one"].security_group_id]
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    permissions = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::148088962203:user/shlomob" # add user to access to my cluster

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy" # give the user shlomob access to the cluster
          access_scope = {
            namespaces = []
            type       = "cluster"
          }
        }
      }
    }
  }

  tags = { 
    Environment = "dev"
    Terraform   = "true"
  }
}
