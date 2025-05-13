data "aws_iam_policy_document" "datachain_cluster_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    principals {
      type = "Service"
      identifiers = [
        "eks.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "datachain_cluster_node_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "datachain_cluster_pod_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    principals {
      type = "Service"
      identifiers = [
        "pods.eks.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "datachain_cluster" {
  name               = "datachain-cluster"
  assume_role_policy = data.aws_iam_policy_document.datachain_cluster_assume_role.json
}

resource "aws_iam_role" "datachain_cluster_node" {
  name               = "datachain-cluster-node"
  assume_role_policy = data.aws_iam_policy_document.datachain_cluster_node_assume_role.json
}

resource "aws_iam_role" "datachain_cluster_pod" {
  name               = "datachain-cluster-pod"
  assume_role_policy = data.aws_iam_policy_document.datachain_cluster_pod_assume_role.json
}

resource "aws_iam_role_policy_attachment" "datachain_cluster" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSComputePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy",
  ])
  role       = aws_iam_role.datachain_cluster.name
  policy_arn = each.key
}

resource "aws_iam_role_policy_attachment" "datachain_cluster_node" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
  ])
  role       = aws_iam_role.datachain_cluster.name
  policy_arn = each.key
}
