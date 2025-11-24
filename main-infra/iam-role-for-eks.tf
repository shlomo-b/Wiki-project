# Create an IAM role for the EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {

        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the AmazonEKS_CNI_Policy policy to the EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_eks_cni" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

}

# Attach the AmazonEKSWorkerNodePolicy policy to the EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_eks_worker" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

}

# Attach the AmazonEC2ContainerRegistryReadOnly policy to the EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_ecr" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

}

resource "aws_iam_role_policy" "eks_node_volume_access" {
  name = "eks-node-volume-access"
  role = aws_iam_role.eks_cluster_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVolume",
          "ec2:AttachVolume",
          "ec2:DeleteVolume",
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeAvailabilityZones",
          "ec2:CreateTags"
        ]
        Resource = "*"
      }
    ]
  })
}
