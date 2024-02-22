output "namespace_name" {
  value = kubernetes_namespace.this.metadata.0.name
}
output "url" {
  value = "https://${kubernetes_ingress_v1.linkerd_viz.spec.0.rule.0.host}/"
}
