resource "openstack_blockstorage_volume_v2" "master" {
  region      = "RegionOne"
  name        = "${format("master%02d", count.index + 1)}"
  image_id    = "${data.openstack_images_image_v2.centos7.id}"
  description = "K8s Master volume"
  size        = 50
  count       = "${var.k8s_masters}"

  timeouts {
    create = "60m"
    delete = "2h"
  }
}

resource "openstack_blockstorage_volume_v2" "node" {
  region      = "RegionOne"
  name        = "${format("node%02d", count.index + 1)}"
  image_id    = "${data.openstack_images_image_v2.centos7.id}"
  description = "K8s Node Volume"
  size        = 35
  count       = "${var.k8s_nodes}"

  timeouts {
    create = "60m"
    delete = "2h"
  }
}
