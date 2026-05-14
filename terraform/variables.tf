variable "rancher_hostname" {
  description = "The hostname for Rancher UI (e.g., rancher.example.com)"
  type        = string
}

variable "rancher_password" {
  description = "The bootstrap password for the Rancher admin account"
  type        = string
  sensitive   = true  # Mark as sensitive to hide in logs
}

variable "letsencrypt_email" {
  description = "The email address for Let's Encrypt"
  type        = string
}