variable "module_depends_on" {
  default = []
}

variable autoscaler_conf {
  default = {}
}

variable namespace {
  default = "kube-system"
}

variable cluster_name {
  type = string
}
