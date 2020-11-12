resource "aws_eks_cluster" "kakeibo_eks_cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_master.arn
  version  = local.cluster_version
  tags     = merge(local.default_tags, map("Name", "kakeibo-eks-cluster"))

  vpc_config {
    security_group_ids = [aws_security_group.cluster_master_sg.id]
    subnet_ids         = local.private_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
  ]
}

resource "aws_eks_node_group" "kakeibo_eks_node_group" {
  cluster_name    = aws_eks_cluster.kakeibo_eks_cluster.name
  node_group_name = "kakeibo-dev-node-group"
  node_role_arn   = aws_iam_role.eks_node.arn
  instance_types  = ["r5.large"]
  subnet_ids      = local.private_subnet_ids
  version         = local.cluster_version
  tags            = merge(local.default_tags, map("Name", "kakeibo-eks-node-group"))

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 3
  }

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_ro_policy,
  ]
}

