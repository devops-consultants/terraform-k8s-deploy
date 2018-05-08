data "template_file" "master_config" {
  template = "${file("files/init.tpl")}"
  count    = "${var.k8s_masters}"

  vars {
    hostname  = "${format("master%02d", count.index + 1)}"
    fqdn      = "${format("master%02d", count.index + 1)}.${var.domain_name}"
    root_size = "40G"
  }
}

data "template_file" "node_config" {
  template = "${file("files/init.tpl")}"
  count    = "${var.k8s_nodes}"

  vars {
    hostname  = "${format("node%02d", count.index + 1)}"
    fqdn      = "${format("node%02d", count.index + 1)}.${var.domain_name}"
    root_size = "20G"
  }
}

resource "openstack_compute_instance_v2" "master" {
  name        = "${format("master%02d", count.index + 1)}.${var.domain_name}"
  flavor_name = "${var.master_type}"
  key_pair    = "${openstack_compute_keypair_v2.ssh-keypair.name}"
  user_data   = "${element(data.template_file.master_config.*.rendered, count.index)}"
  count       = "${var.k8s_masters}"

  block_device {
    uuid                  = "${element(openstack_blockstorage_volume_v2.master.*.id, count.index)}"
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = false
  }

  network {
    name = "${var.network_name}"
  }

  security_groups = [
    "${var.local_ssh_sec_group}",
    "${var.local_consul_sec_group}",
    "${openstack_networking_secgroup_v2.k8s.name}",
  ]

  connection {
    user        = "centos"
    private_key = "${file(var.private_key_file)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rpm-ostree install unzip",
      "sudo systemctl reboot",
    ]
  }

  #   provisioner "file" {
  #     content     = "${data.template_file.setup_consul.rendered}"
  #     destination = "/tmp/install_consul.sh"
  #   }

  #  provisioner "file" {
  #    source      = "files/attach_data_vol.sh"
  #    destination = "/tmp/attach_data_vol.sh"
  #  }

  #   provisioner "remote-exec" {
  #     inline = [
  # 	"sudo chmod a+x /tmp/install_consul.sh",
  # 	"sudo /tmp/install_consul.sh"
  #     ]
  #   }
}
