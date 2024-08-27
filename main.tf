locals {
  block_devices = var.image_source.volume_id != "" ? [{
    uuid                  = var.image_source.volume_id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = false
  }] : []
  cloudinit_templates = concat([
    {
      filename     = "zeppelin.cfg"
      content_type = "text/cloud-config"
      content = templatefile(
        "${path.module}/templates/cloud_config.yaml",
        {
          nameserver_ips                   = var.nameserver_ips
          zeppelin_version                 = var.zeppelin_version
          zeppelin_mirror                  = var.zeppelin_mirror
          k8_executor_image                = var.k8_executor_image
          k8_api_endpoint                  = var.k8_api_endpoint
          s3_access                        = var.s3_access
          s3_secret                        = var.s3_secret
          s3_url                           = var.s3_url
          hive_metastore_url               = var.hive_metastore_url
          spark_sql_warehouse_dir          = var.spark_sql_warehouse_dir
          k8_ca_certificate                = var.k8_ca_certificate
          k8_client_certificate            = var.k8_client_certificate
          k8_client_private_key            = var.k8_client_private_key
          notebook_s3_bucket               = var.notebook_s3_bucket
          keycloak                         = var.keycloak
          k8_service_account_name          = var.k8_service_account_name
          k8_namespace                     = var.k8_namespace
          k8_secret_s3                     = var.k8_secret_s3
          k8_secret_s3_access_key          = var.k8_secret_s3_access_key
          k8_secret_s3_secret_key          = var.k8_secret_s3_secret_key
          spark_dynamic_allocation_enabled = var.spark_dynamic_allocation_enabled
          spark_max_executors              = var.spark_max_executors
          spark_min_executors              = var.spark_min_executors
          spark_version                    = var.spark_version
          spark_mirror                     = var.spark_mirror
        }
      )
    },
    {
      filename     = "node_exporter.cfg"
      content_type = "text/cloud-config"
      content      = module.prometheus_node_exporter_configs.configuration
    }
    ],
    var.fluentbit.enabled ? [{
      filename     = "fluent_bit.cfg"
      content_type = "text/cloud-config"
      content      = module.fluentbit_configs.configuration
    }] : []
  )
}

module "prometheus_node_exporter_configs" {
  source               = "git::https://github.com/Ferlab-Ste-Justine/terraform-cloudinit-templates.git//prometheus-node-exporter?ref=v0.14.2"
  install_dependencies = true
}

module "fluentbit_configs" {
  source               = "git::https://github.com/Ferlab-Ste-Justine/terraform-cloudinit-templates.git//fluent-bit?ref=v0.14.2"
  install_dependencies = true
  fluentbit = {
    metrics = var.fluentbit.metrics
    systemd_services = [
      {
        tag     = var.fluentbit.zeppelin_tag
        service = "zeppelin.service"
      },
      {
        tag     = var.fluentbit.node_exporter_tag
        service = "node-exporter.service"
      }
    ]
    forward = var.fluentbit.forward
  }
}

data "template_cloudinit_config" "zeppelin" {
  gzip          = true
  base64_encode = true
  dynamic "part" {
    for_each = local.cloudinit_templates
    content {
      filename     = part.value["filename"]
      content_type = part.value["content_type"]
      content      = part.value["content"]
    }
  }
}

resource "openstack_networking_port_v2" "zeppelin" {
  name       = var.name
  network_id = var.network_id
  security_group_ids = concat(
    var.additional_security_group_ids,
    [openstack_networking_secgroup_v2.zeppelin_server.id]
  )
  admin_state_up = true
}

resource "openstack_compute_instance_v2" "zeppelin" {
  name      = var.name
  image_id  = var.image_source.image_id != "" ? var.image_source.image_id : null
  flavor_id = var.flavor_id
  key_pair  = var.keypair_name
  user_data = data.template_cloudinit_config.zeppelin.rendered

  network {
    port = openstack_networking_port_v2.zeppelin.id
  }

  dynamic "block_device" {
    for_each = local.block_devices
    content {
      uuid                  = block_device.value["uuid"]
      source_type           = block_device.value["source_type"]
      boot_index            = block_device.value["boot_index"]
      destination_type      = block_device.value["destination_type"]
      delete_on_termination = block_device.value["delete_on_termination"]
    }
  }
}