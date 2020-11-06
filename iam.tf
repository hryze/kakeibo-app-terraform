resource "aws_iam_role" "eks_master" {
  name               = "eks-master-role"
  assume_role_policy = data.aws_iam_policy_document.eks_master_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_master_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_master.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_master.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role" "eks_node" {
  name               = "eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_node_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_ro_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_openid_connect_provider" "openid" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = aws_eks_cluster.kakeibo_eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "cluster_autoscaler" {
  name               = "cluster-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role_policy.json
}

data "aws_iam_policy_document" "cluster_autoscaler_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.openid.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.openid.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
  }
}

resource "aws_iam_role_policy" "cluster_autoscaler_role_policy" {
  name   = "cluster-autoscaler-role-policy"
  role   = aws_iam_role.cluster_autoscaler.id
  policy = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "external_secrets" {
  name               = "external-secrets"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume_role_policy.json
}

data "aws_iam_policy_document" "external_secrets_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.openid.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.openid.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:external-secrets"]
    }
  }
}

resource "aws_iam_role_policy" "external_secrets_role_policy" {
  name   = "external-secrets-role-policy"
  role   = aws_iam_role.external_secrets.id
  policy = data.aws_iam_policy_document.external_secrets.json
}

data "aws_iam_policy_document" "external_secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      aws_secretsmanager_secret.rds_secret.arn,
      aws_secretsmanager_secret.user_db_dsn.arn,
      aws_secretsmanager_secret.account_db_dsn.arn,
      aws_secretsmanager_secret.todo_db_dsn.arn
    ]
  }
}

resource "aws_iam_role" "external_dns" {
  name               = "external-dns"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role_policy.json
}

data "aws_iam_policy_document" "external_dns_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.openid.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.openid.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:external-dns"]
    }
  }
}

resource "aws_iam_role_policy" "external_dns_role_policy" {
  name   = "external-dns-role-policy"
  role   = aws_iam_role.external_dns.id
  policy = data.aws_iam_policy_document.external_dns.json
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
    resources = [
      "arn:aws:route53:::hostedzone/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  name               = "aws-load-balancer-controller"
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role_policy.json
}

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.openid.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.openid.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role_policy" "aws_load_balancer_controller_role_policy" {
  name   = "aws-load-balancer-controller-role-policy"
  role   = aws_iam_role.aws_load_balancer_controller.id
  policy = data.aws_iam_policy_document.aws_load_balancer_controller.json
}

data "aws_iam_policy_document" "aws_load_balancer_controller" {
  statement {
    effect = "Allow"
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:SetWebAcl",
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates",
      "cognito-idp:DescribeUserPoolClient",
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "tag:GetResources",
      "tag:TagResources",
      "waf:GetWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "shield:DescribeProtection",
      "shield:GetSubscriptionState",
      "shield:DeleteProtection",
      "shield:CreateProtection",
      "shield:DescribeSubscription",
      "shield:ListProtections"
    ]
    resources = ["*"]
  }
}

resource "aws_s3_bucket_policy" "kakeibo_s3_bucket_policy" {
  bucket = aws_s3_bucket.kakeibo_s3.id
  policy = data.aws_iam_policy_document.kakeibo_s3_policy_document.json
}

data "aws_iam_policy_document" "kakeibo_s3_policy_document" {
  statement {
    sid = "s3 external access policy"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.website.iam_arn]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.kakeibo_s3.arn}/*"
    ]
  }
}

resource "aws_ecr_repository_policy" "user_rest_service_policy" {
  repository = aws_ecr_repository.user_rest_service_ecr_repository.name
  policy     = data.aws_iam_policy_document.kakeibo_ecr_policy_document.json
}

resource "aws_ecr_repository_policy" "account_rest_service_policy" {
  repository = aws_ecr_repository.account_rest_service_ecr_repository.name
  policy     = data.aws_iam_policy_document.kakeibo_ecr_policy_document.json
}

resource "aws_ecr_repository_policy" "todo_rest_service_policy" {
  repository = aws_ecr_repository.todo_rest_service_ecr_repository.name
  policy     = data.aws_iam_policy_document.kakeibo_ecr_policy_document.json
}

data "aws_iam_policy_document" "kakeibo_ecr_policy_document" {
  statement {
    sid = "kakeibo ecr policy"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:DescribeImages",
      "ecr:PutImage",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:BatchDeleteImage",
    ]
  }
}
