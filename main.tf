# terraform {
#   backend "consul" {
#     path    = "openshift/terraform_state"
#   }
# }

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "${var.OS_USERNAME}"
  tenant_name = "${var.OS_TENANT_NAME}"
  password    = "${var.OS_PASSWORD}"
  auth_url    = "${var.OS_AUTH_URL}"
  insecure    = "false"
}

resource "openstack_compute_keypair_v2" "ssh-keypair" {
  name       = "k8s-keypair"
  public_key = "${file(var.public_key_file)}"
}

data "template_file" "setup_consul" {
  template = "${file("files/setup_consul.sh")}"

  vars {
    join_server_ip      = "${var.consul_join_ip}"
    datacenter          = "${var.consul_datacenter}"
    encrypt_key         = "${var.consul_encrypt_key}"
    consul_download_url = "${var.consul_download_url}"
  }
}

data "openstack_images_image_v2" "centos7" {
  name        = "CentOS 7"
  most_recent = true
}
