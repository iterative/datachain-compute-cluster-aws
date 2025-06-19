data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "datachain_oidc_compute" {
  statement {
    actions = [
      "eks:CreateCluster",
      "eks:CreateAddon",
      "eks:CreateAccessEntry",
      "eks:CreatePodIdentityAssociation",
      "eks:DeleteCluster",
      "eks:DeleteAddon",
      "eks:DeleteAccessEntry",
      "eks:DeletePodIdentityAssociation",
      "eks:DescribeCluster",
      "eks:DescribeAddon",
      "eks:DescribeAccessEntry",
      "eks:DescribePodIdentityAssociation",
    ]
    resources = [
      "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/datachain-*",
      "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:addon/datachain-*",
      "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:access-entry/datachain-*",
      "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:podidentityassociation/datachain-*",
    ]
  }

  statement {
    actions = [
      "iam:GetRole",
      "iam:ListAttachedRolePolicies"
    ]
    resources = [
      aws_iam_role.datachain_cluster.arn,
      aws_iam_role.datachain_cluster_node.arn,
      aws_iam_role.datachain_cluster_pod.arn,
    ]
  }

  statement {
    actions = ["iam:PassRole"]
    resources = [
      aws_iam_role.datachain_cluster.arn,
      aws_iam_role.datachain_cluster_node.arn,
      aws_iam_role.datachain_cluster_pod.arn,
    ]
  }

  # Needed for EKS to create service linked roles
  # the first time a cluster is created in the account
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values = [
        "autoscaling.amazonaws.com",
        "ec2scheduled.amazonaws.com",
        "elasticloadbalancing.amazonaws.com",
        "eks.amazonaws.com",
        "eks-fargate-pods.amazonaws.com",
        "eks-nodegroup.amazonaws.com",
        "spot.amazonaws.com",
        "spotfleet.amazonaws.com",
        "transitgateway.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "datachain_oidc_storage" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = flatten([
      for bucket in var.storage_buckets : [
        "arn:aws:s3:::${bucket}",
        "arn:aws:s3:::${bucket}/*"
      ]
    ])
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = var.secrets
  }
}

data "aws_iam_policy_document" "datachain_oidc_compute_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.datachain_oidc.arn]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "${aws_iam_openid_connect_provider.datachain_oidc.url}:sub"
      values   = [var.oidc_condition_compute]
    }
  }
}

data "aws_iam_policy_document" "datachain_oidc_storage_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.datachain_oidc.arn]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "${aws_iam_openid_connect_provider.datachain_oidc.url}:sub"
      values   = [var.oidc_condition_storage]
    }
  }
}

data "tls_certificate" "datachain_oidc" {
  url = "https://${var.oidc_provider}"
}

resource "aws_iam_openid_connect_provider" "datachain_oidc" {
  url             = data.tls_certificate.datachain_oidc.url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.datachain_oidc.certificates.0.sha1_fingerprint]
}

resource "aws_iam_role" "datachain_oidc_compute" {
  name                 = "datachain-oidc-compute"
  assume_role_policy   = data.aws_iam_policy_document.datachain_oidc_compute_assume_role.json
  max_session_duration = 12 * 60 * 60
}

resource "aws_iam_role" "datachain_oidc_storage" {
  name                 = "datachain-oidc-storage"
  assume_role_policy   = data.aws_iam_policy_document.datachain_oidc_storage_assume_role.json
  max_session_duration = 12 * 60 * 60
}

resource "aws_iam_role_policy" "datachain_oidc_compute" {
  name   = aws_iam_role.datachain_oidc_compute.name
  role   = aws_iam_role.datachain_oidc_compute.id
  policy = data.aws_iam_policy_document.datachain_oidc_compute.json
}

resource "aws_iam_role_policy" "datachain_oidc_storage" {
  name   = aws_iam_role.datachain_oidc_storage.name
  role   = aws_iam_role.datachain_oidc_storage.id
  policy = data.aws_iam_policy_document.datachain_oidc_storage.json
}
