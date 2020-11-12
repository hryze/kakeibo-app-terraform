resource "aws_security_group" "cluster_master_sg" {
  name        = "cluster-master-sg"
  description = "EKS cluster master security group"
  vpc_id      = aws_vpc.kakeibo_vpc.id
  tags        = merge(local.default_tags, local.eks_tag, map("Name", "eks-master-sg"))

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
