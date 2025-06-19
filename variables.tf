variable "aws_region" {
  default = "eu-north-1"
}

variable "oidc_provider" {
  default = "studio.datachain.ai/api"
}

variable "oidc_condition_compute" {
  default = "credentials:example-team/datachain-compute"
}

variable "oidc_condition_storage" {
  default = "credentials:example-team/datachain-storage"
}

variable "storage_buckets" {
  default = [
    "example-bucket",
  ]
}

variable "secrets" {
  default = [
    "arn:aws:secretsmanager:us-east-1:000000000000:secret:example-secret/test-abcdef",
  ]
}
