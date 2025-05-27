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


# Attach the AdministratorAccess policy to the EKS cluster roles
resource "aws_iam_role_policy_attachment" "eks_cluster_admin" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn =  "arn:aws:iam::aws:policy/AdministratorAccess"

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
