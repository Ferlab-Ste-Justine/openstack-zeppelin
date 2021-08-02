output id {
  value = openstack_compute_instance_v2.zeppelin.id
}

output ip {
  value = openstack_compute_instance_v2.zeppelin.network.0.fixed_ip_v4
}

output "groups" {
  value = {
    bastion = openstack_networking_secgroup_v2.zeppelin_bastion
  }
}