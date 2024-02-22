data "aws_caller_identity" "current" {}

resource "kubernetes_namespace" "this" {
  metadata {
    name = "linkerd-viz"

    annotations = {
      "linkerd.io/inject"             = "enabled" # extracted from helm chart linkerd2
      "config.linkerd.io/proxy-await" = "enabled" # extracted from helm chart linkerd2
    }
    labels = {
      role                                 = "linkerd-viz"
      "linkerd.io/extension"               = "viz"      # extracted from helm chart linkerd2
      "pod-security.kubernetes.io/enforce" = "baseline" # restrict namespace to pod-security-standard baseline
      "pod-security.kubernetes.io/audit"   = "baseline" # audit namespace to pod-security-standard baseline
      "pod-security.kubernetes.io/warn"    = "baseline" # warn namespace to pod-security-standard baseline
    }
  }
}

resource "kubernetes_default_service_account_v1" "default" {
  metadata {
    namespace = kubernetes_namespace.this.metadata.0.name
  }
  automount_service_account_token = false
}

# rolebinding is created as preinstalled clusterrolebinding for "eks:podsecuritypolicy:privileged" is deleted
resource "kubernetes_role_binding" "eks_podsecuritypolicy_authenticated" {
  metadata {
    name      = "eks_podsecuritypolicy_authenticated"
    namespace = kubernetes_namespace.this.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "eks:podsecuritypolicy:privileged"
  }
  subject {
    kind      = "Group"
    name      = "system:serviceaccounts:${kubernetes_namespace.this.metadata.0.name}"
    api_group = "rbac.authorization.k8s.io"
    namespace = kubernetes_namespace.this.metadata.0.name
  }
  subject {
    kind      = "Group"
    name      = "system:authenticated"
    api_group = "rbac.authorization.k8s.io"
    namespace = kubernetes_namespace.this.metadata.0.name
  }
}
