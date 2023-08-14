resource "openstack_networking_port_v2" "zeppelin" {
  name           = var.namespace == "" ? "zeppelin" : "zeppelin-${var.namespace}"
  network_id     = var.network_id
  security_group_ids = concat(
    var.additional_security_group_ids,
    [openstack_networking_secgroup_v2.zeppelin_server.id]
  )
  admin_state_up = true
}

data "template_cloudinit_config" "zeppelin" {
  gzip = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/templates/cloud_config.yaml", 
      {
        nameserver_ips  = var.nameserver_ips
        zeppelin_version = var.zeppelin_version
        zeppelin_mirror = var.zeppelin_mirror
        k8_executor_image = var.k8_executor_image
        k8_api_endpoint = var.k8_api_endpoint
        s3_access = var.s3_access
        s3_secret = var.s3_secret
        s3_url = var.s3_url
        hive_metastore_url = var.hive_metastore_url
        spark_sql_warehouse_dir = var.spark_sql_warehouse_dir
        k8_ca_certificate = var.k8_ca_certificate
        k8_client_certificate = var.k8_client_certificate
        k8_client_private_key = var.k8_client_private_key
        notebook_s3_bucket = var.notebook_s3_bucket
        keycloak = var.keycloak
      }
    )
  }
}

resource "openstack_compute_instance_v2" "zeppelin" {
  name            = var.namespace == "" ? "zeppelin" : "zeppelin-${var.namespace}"
  image_id        = var.image_id
  flavor_id       = var.flavor_id
  key_pair        = var.keypair_name
  user_data       = data.template_cloudinit_config.zeppelin.rendered

  network {
    port = openstack_networking_port_v2.zeppelin.id
  }
}