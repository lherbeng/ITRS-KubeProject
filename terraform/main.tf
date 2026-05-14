provider "kubernetes" {
  config_path = "~/.kube/config"  # Path sa kubeconfig file ng iyong cluster
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"  # Path sa kubeconfig file ng iyong cluster
  }
}

resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/latest"
  chart      = "rancher"
  namespace  = "cattle-system"

  set {
    name  = "hostname"
    value = "<RANCHER_HOSTNAME>"  # Palitan ng iyong domain o IP address
  }

  set {
    name  = "bootstrapPassword"
    value = "<ADMIN_PASSWORD>"  # Palitan ng iyong gustong admin password
  }

  set {
    name  = "ingress.tls.source"
    value = "letsEncrypt"  # Gamitin ang Let's Encrypt para sa auto-generated TLS
  }

  set {
    name  = "letsEncrypt.email"
    value = "<YOUR_EMAIL>"  # Palitan ng iyong email address
  }
}