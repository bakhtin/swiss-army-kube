# Create namespace logging
resource "kubernetes_namespace" "logging" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = "logging"
  }
}

resource "helm_release" "elastic-stack" {
  depends_on = [
    var.module_depends_on
  ]

  name       = "elastic"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "elastic-stack"
  namespace  = "logging"

  values = [
    file("${path.module}/values/elastic-stack.yaml"),
  ]

  set {
    name  = "kibana.ingress.hosts[0]"
    value = "kibana.${var.domain}"
  }

  set {
    name  = "kibana.ingress.tls[0].hosts[0]"
    value = "kibana.${var.domain}"
  }

  set {
    name  = "kibana.ingress.annotations.ingress.kubernetes.io/auth-url"
    value = "https://oauth2.${var.domain}/oauth2/auth"
  }

  set {
    name  = "kibana.ingress.annotations.ingress.kubernetes.io/auth-signin"
    value = "https://oauth2.${var.domain}/oauth2/start?rd=https://$host$request_uri$is_args$args"
  }

  set {
    name  = "logstash.enabled"
    value = "${var.logstash}"
  }

  set {
    name  = "filebeat.enabled"
    value = "${var.filebeat}"
  }

  set {
    name  = "elasticsearch-curator"
    value = "${var.elasticsearch-curator}"
  }

  set {
    name  = "elasticsearch.data.persistence.size"
    value = "${var.elasticDataSize}"
  }
}
