variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "ssh_key_name" {}
#variable "ssh_fingerprint" {}

provider "digitalocean" {
  token = var.do_token
}
