resource "helm_release" "grafana" {
  name             = "grafana"
  namespace        = kubernetes_namespace.this.metadata.0.name
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  version          = "6.57.0"
  create_namespace = false

  values = ["${file("grafana-values.yaml")}"]
}
