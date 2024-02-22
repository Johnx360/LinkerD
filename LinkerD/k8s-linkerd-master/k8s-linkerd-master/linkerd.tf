locals {
  linkerd_image_repository_base    = "registry.infrastructure.netzda-mig.org/development/devops/dockerfiles/external"
  linkerd_image_tag                = "stable-2.13.4"
  linkerd_proxy_init_image_version = "v2.2.1"
}

resource "helm_release" "linkerd_crds" {
  name             = "linkerd-crds"
  namespace        = kubernetes_namespace.this.metadata.0.name
  repository       = "https://helm.linkerd.io/stable"
  chart            = "linkerd-crds"
  version          = "1.6.1"
  create_namespace = false

}

resource "helm_release" "linkerd_controle_plane" {
  name             = "linkerd-control-plane"
  namespace        = kubernetes_namespace.this.metadata.0.name
  repository       = "https://helm.linkerd.io/stable"
  chart            = "linkerd-control-plane"
  version          = "1.12.4"
  create_namespace = false

  values = [jsonencode({
    cniEnabled              = true
    identityTrustAnchorsPEM = tls_locally_signed_cert.issuer.ca_cert_pem
    identity = {
      issuer = {
        tls = {
          crtPEM = tls_locally_signed_cert.issuer.cert_pem
          keyPEM = tls_private_key.issuer.private_key_pem
        }
      }
    }
    policyController = {
      image = {
        name    = "${local.linkerd_image_repository_base}/linkerd_policy-controller"
        version = local.linkerd_image_tag
      }
    }
    proxy = {
      image = {
        name    = "${local.linkerd_image_repository_base}/linkerd_proxy"
        version = local.linkerd_image_tag
      }
    }
    proxyInit = {
      name    = "${local.linkerd_image_repository_base}/linkerd_proxy-init"
      version = local.linkerd_proxy_init_image_version
      ignoreOutboundPorts : "4567,4568,443"
    }
    controllerImage = "${local.linkerd_image_repository_base}/linkerd_controller"
    debugContainer = {
      image = {
        name    = "${local.linkerd_image_repository_base}/linkerd_debug"
        version = local.linkerd_image_tag
      }
    }
  })]
  depends_on = [helm_release.linkerd_crds]
}
