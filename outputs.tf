output "datachain_aws_region" {
  value = var.aws_region
}

output "datachain_oidc_compute_role_arn" {
  value = aws_iam_role.datachain_oidc_compute.arn
}

output "datachain_oidc_storage_role_arn" {
  value = aws_iam_role.datachain_oidc_storage.arn
}

output "datachain_cluster_role_arn" {
  value = aws_iam_role.datachain_cluster.arn
}

output "datachain_cluster_node_role_arn" {
  value = aws_iam_role.datachain_cluster_node.arn
}

output "datachain_cluster_vpc_id" {
  value = aws_vpc.datachain_cluster.id
}

output "datachain_cluster_subnet_ids" {
  value = slice(values(aws_subnet.datachain_cluster)[*].id, 0, 2)
}

output "datachain_cluster_security_group_ids" {
  value = [aws_security_group.datachain_cluster.id]
}
