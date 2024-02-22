# from ../../common.hcl
variable "aws_region" {
  default = "eu-north-1"
}

# from ../cluster
variable "eks_cluster_id" {
  type        = string
  default = "B4-EKS-cluster"
}

variable "eks_cluster_cluster_oidc_issuer_url" {
  type        = string
  default = "https://oidc.eks.eu-north-1.amazonaws.com/id/E10D8BD46F0EFE7DDE02205080F8C791"
}
