locals {
  linkerd_image_repository_base = "registry.infrastructure.netzda-mig.org/development/devops/dockerfiles/external"
  linkerd_image_tag             = "v1.1.1"
}
resource "helm_release" "linkerd2-cni" {
  name             = "linkerd2-cni"
  namespace        = kubernetes_namespace.this.metadata.0.name
  repository       = "https://helm.linkerd.io/stable"
  chart            = "linkerd2-cni"
  version          = "30.8.3"
  create_namespace = false

  values = [jsonencode({
    cniPluginImage   = "${local.linkerd_image_repository_base}/linkerd_cni-plugin"
    cniPluginVersion = "${local.linkerd_image_tag}"
  })]
}
