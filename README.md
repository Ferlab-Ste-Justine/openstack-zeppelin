# About

This terraform module will provision a zeppelin vm in openstack.

The zeppelin server provisioned has the following characteristics:
- It provisions executors in a kubernetes cluster
- It uses s3
- It uses an hive metastore
- It uses spark 3 in scala

# Motivation

We experimented orchestrating zeppelin directly in kubernetes using its built-in support for kubernetes, but we felt it was too bleeding edge at the current time.

It didn't work well out of the box and while we were approaching a working solution tweaking it, we came to the realisation that the end result would not be easy to maintain in the future.

So instead, we made the tradeof of having a saner zeppelin deployment that runs outside of kubernetes while still having the executor that it spawns still run in kubernetes (which is what we care most about).

# Input Variables

- namespace: Namespace tag to append to created openstack resources names

- image_id: ID of the vm image used to provision the zeppelin server

- flavor_id: ID of the vm flavor used to provision the zeppelin server.

- security_group_ids: Array of security group ids to assign to the zeppelin server

- network_id: ID of the network to attach the zeppelin server to

- keypair_name: Name of the keypair that can be used to ssh to the server

- nameserver_ips: Ips of nameservers that will be added to the list of nameservers the zeppelin server refers to to resolve domain names.

- zeppelin_mirror: Mirror to download zeppelin from. Defaults to the university of Waterloo.

- spark_mirror: Mirror to download spark from. Defaults to the university of Toronto.

- k8_executor_image: Image to use to launch executor containers in kubernetes. Defaults to **chusj/spark:7508c20ef44952f1ee2af91a26822b6efc10998f**

- k8_api_endpoint: Kubernetes api endpoint that zeppelin will use to provision executors on kubernetes.

- k8_ca_certificate: Kubernetes ca certificate that zeppelin will use to authentify the api server.

- k8_client_certificate: Kubernetes client certificate that zeppelin will use to authentify itself to the api server.

- k8_client_private_key: Kubernetes private key that zeppelin will use to authentify itself to the api server.

- s3_access: S3 access key that zeppelin will use to identify itself to the s3 provider.

- s3_secret: S3 access key that zeppelin will use to authentify itself to the S3 provider.

- s3_endpoint: The api endpoint of the S3 provider that zeppelin will use.

- hive_metastore_url: Url of the hive metastore that zeppelin will use.

# Output Variables

- id: ID of the generated zeppelin server compute instance

- ip: IP of the generated zeppelin server compute instance on the network it was attached to

# Usage Example

```
...

module "certificates" {
  source = "git::https://github.com/Ferlab-Ste-Justine/kubernetes-certificates.git"
  ca_key = tls_private_key.ca.private_key_pem
  etcd_ca_key = tls_private_key.etcd_ca.private_key_pem
  front_proxy_ca_key = tls_private_key.front_proxy_ca.private_key_pem
  client_key = tls_private_key.client.private_key_pem
}

...

module "zeppelin" {
  source = "git::https://github.com/Ferlab-Ste-Justine/openstack-zeppelin.git"
  namespace = var.namespace
  image_id = var.image_id
  flavor_id = var.flavors.small.id
  network_id = var.network.id
  security_group_ids = [
    var.reference_security_groups.default.id
  ]
  keypair_name = var.bastion_internal_keypair.name
  nameserver_ips = var.nameserver_ips
  k8_api_endpoint = "https://mykubernetesapi:6443"
  k8_ca_certificate = module.certificates.ca_certificate
  k8_client_certificate = module.certificates.client_certificate
  k8_client_private_key = tls_private_key.client.private_key_pem
  s3_access = openstack_identity_ec2_credential_v3.s3_key.access
  s3_secret = openstack_identity_ec2_credential_v3.s3_key.secret
  s3_endpoint = "https://mys3server"
  hive_metastore_url = "myhivemetastore:9083"
}
```

