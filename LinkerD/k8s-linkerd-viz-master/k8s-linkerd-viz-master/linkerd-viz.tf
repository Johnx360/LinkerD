locals {
  linkerd_image_repository_base = "registry.infrastructure.netzda-mig.org/development/devops/dockerfiles/external"
  linkerd_image_tag             = "stable-2.13.4"
  prometheus_image_tag          = "v2.43.0" # from linkerd-viz helm chart
}

resource "helm_release" "linkerd-viz" {
  name             = "linkerd-viz"
  namespace        = kubernetes_namespace.this.metadata.0.name
  repository       = "https://helm.linkerd.io/stable"
  chart            = "linkerd-viz"
  version          = "30.8.4"
  create_namespace = false

  values = [jsonencode({
    grafana = {
      url = "grafana:80"
    }
    dashboard = {
      # allow this hostname to be used as ingress
      enforcedHostRegexp = "linkerd.${var.certificate_domainname}"
      image = {
        registry = "${local.linkerd_image_repository_base}"
        name     = "linkerd_web"
        tag      = local.linkerd_image_tag
      }
    }
    metricsAPI = {
      image = {
        registry = "${local.linkerd_image_repository_base}"
        name     = "linkerd_metrics-api"
        tag      = local.linkerd_image_tag
      }
    }
    tap = {
      image = {
        registry = "${local.linkerd_image_repository_base}"
        name     = "linkerd_tap"
        tag      = local.linkerd_image_tag
      }
    }
    tapInjector = {
      image = {
        registry = "${local.linkerd_image_repository_base}"
        name     = "linkerd_tap"
        tag      = local.linkerd_image_tag
      }
    }
    prometheus = {
      image = {
        registry = "${local.linkerd_image_repository_base}"
        name     = "linkerd_prometheus"
        tag      = local.prometheus_image_tag
      }
    }
  })]
}

resource "kubernetes_ingress_v1" "linkerd_viz" {
  metadata {
    name      = "linkerd-viz"
    namespace = kubernetes_namespace.this.metadata.0.name
    annotations = {
      "alb.ingress.kubernetes.io/certificate-arn"  = var.certificate_arn
      "alb.ingress.kubernetes.io/ssl-policy"       = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/ready"
      "alb.ingress.kubernetes.io/healthcheck-port" = "9994"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/inbound-cidrs"    = "10.0.0.0/8"
    }
  }

  spec {

    ingress_class_name = "alb"
    rule {
      host = "linkerd.${var.certificate_domainname}"
      http {
        path {
          backend {
            service {
              name = "web"
              port {
                number = 8084
              }
            }
          }
          path = "/*"
        }
      }
    }
    tls {
      hosts = ["linkerd.${var.certificate_domainname}"]
    }
  }
}
