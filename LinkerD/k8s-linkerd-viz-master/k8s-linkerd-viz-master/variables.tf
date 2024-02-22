# from ../../common.hcl
variable "aws_region" {}

# from ../cluster
variable "eks_cluster_id" {
  type        = string
  description = "EKS cluster ID"
}

variable "eks_cluster_cluster_oidc_issuer_url" {
  type        = string
  description = "EKS cluster OIDC issuer url"
}

variable "certificate_arn" {
  type        = string
  description = "arn of the aws certificate"
}
variable "certificate_domainname" {
  description = "domain name of the certificate"
}
