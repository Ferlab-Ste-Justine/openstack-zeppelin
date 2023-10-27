resource "openstack_networking_secgroup_v2" "zeppelin_server" {
  name                 = "${var.name}-server"
  description          = "Security group for zeppelin server"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "zeppelin_bastion" {
  name                 = "${var.name}-bastion"
  description          = "Security group for the bastion connecting to zeppelin server"
  delete_default_rules = true
}

locals {
  bastion_group_ids = concat(var.bastion_group_ids, [openstack_networking_secgroup_v2.zeppelin_bastion.id])
}

//Allow all outbound traffic for server and bastion
resource "openstack_networking_secgroup_rule_v2" "zeppelin_server_outgoing_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.zeppelin_server.id
}

resource "openstack_networking_secgroup_rule_v2" "zeppelin_server_outgoing_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.zeppelin_server.id
}

resource "openstack_networking_secgroup_rule_v2" "zeppelin_bastion_outgoing_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.zeppelin_bastion.id
}

resource "openstack_networking_secgroup_rule_v2" "zeppelin_bastion_outgoing_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.zeppelin_bastion.id
}

//Allow port 22 traffic from the bastion
resource "openstack_networking_secgroup_rule_v2" "internal_ssh_access" {
  for_each          = { for idx, id in local.bastion_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.zeppelin_server.id
}

//Allow port 22 traffic on the bastion
resource "openstack_networking_secgroup_rule_v2" "external_ssh_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.zeppelin_bastion.id
}

//Allow zeppelin port and icmp for client
resource "openstack_networking_secgroup_rule_v2" "client_zeppelin_access" {
  for_each          = { for idx, id in var.client_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 8080
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.zeppelin_server.id
}

resource "openstack_networking_secgroup_rule_v2" "client_icmp_access_v4" {
  for_each          = { for idx, id in var.client_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.zeppelin_server.id
}

resource "openstack_networking_secgroup_rule_v2" "client_icmp_access_v6" {
  for_each          = { for idx, id in var.client_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.zeppelin_server.id
}

//Allow bastion to use icmp
resource "openstack_networking_secgroup_rule_v2" "bastion_icmp_access_v4" {
  for_each          = { for idx, id in local.bastion_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.zeppelin_server.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_icmp_access_v6" {
  for_each          = { for idx, id in local.bastion_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.zeppelin_server.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_external_icmp_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.zeppelin_bastion.id
}

//Grant the zeppelin server access to the hive metastore port and icmp on the k8 workers
resource "openstack_networking_secgroup_rule_v2" "zeppelin_tcp_access_hive" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.hive_metastore_port
  port_range_max    = var.hive_metastore_port
  remote_group_id   = openstack_networking_secgroup_v2.zeppelin_server.id
  security_group_id = var.kubernetes_workers_security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "zeppelin_icmp_access_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = openstack_networking_secgroup_v2.zeppelin_server.id
  security_group_id = var.kubernetes_workers_security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "zeppelin_icmp_access_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = openstack_networking_secgroup_v2.zeppelin_server.id
  security_group_id = var.kubernetes_workers_security_group_id
}

//Allow port 9100 and icmp traffic from metrics server
resource "openstack_networking_secgroup_rule_v2" "metrics_server_node_exporter_access" {
  for_each          = { for idx, id in var.metrics_server_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9100
  port_range_max    = 9100
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.zeppelin_server.id
}

resource "openstack_networking_secgroup_rule_v2" "metrics_server_icmp_access_v4" {
  for_each          = { for idx, id in var.metrics_server_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.zeppelin_server.id
}

resource "openstack_networking_secgroup_rule_v2" "metrics_server_icmp_access_v6" {
  for_each          = { for idx, id in var.metrics_server_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.zeppelin_server.id
}
