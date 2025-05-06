resource "aws_key_pair" "eks" {
  key_name   = "expense-eks"
  public_key = file("~/.ssh/eks.pub") # Using home dir shortcut for portability
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                    = local.name
  cluster_version                 = "1.27"
  create_node_security_group      = false
  create_cluster_security_group   = false
  cluster_security_group_id       = local.eks_control_plane_sg_id
  node_security_group_id          = local.eks_node_sg_id

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    metrics-server         = {}
  }

  cluster_endpoint_public_access = false
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    blue = {
      instance_types = ["m5.xlarge"]
      key_name       = aws_key_pair.eks.key_name

      min_size       = 2
      max_size       = 10
      desired_size   = 2

      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy      = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy      = "arn:aws:iam::aws:policy/AmazonEFSCSIDriverPolicy"
        AmazonEKSLoadBalancingPolicy  = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = local.name
    }
  )
}
