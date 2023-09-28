# About

This terraform module will provision a zeppelin vm in openstack.

The zeppelin server provisioned has the following characteristics:
- It provisions executors in a kubernetes cluster
- It uses s3
- It uses an hive metastore
- It uses spark 3 in scala
- It saves its notebooks in s3
- It expects to communite to a group of kubernetes workers to access the hive metastore and it expects its client traffic to originate from the kubernetes cluster's workers
- It can use keycloak for user authentication (with shiro)

# Motivation

We experimented orchestrating zeppelin directly in kubernetes using its built-in support for kubernetes, but we felt it was too bleeding edge at the current time.

It didn't work well out of the box and while we were approaching a working solution tweaking it, we came to the realisation that the end result would not be easy to maintain in the future.

So instead, we made the tradeof of having a saner zeppelin deployment that runs outside of kubernetes while still having the executor that it spawns still run in kubernetes (which is what we care most about).

# Input Variables

- **name**: Name to give to the vm, its port and the prefix of security groups

- **image_source**: Source of the image to provision the zeppelin server on. It takes the following keys (only one of the two fields should be used, the other one should be empty):
  - **image_id**: Id of the image to associate with a vm that has local storage
  - **volume_id**: Id of a volume containing the os to associate with the vm

- **flavor_id**: ID of the vm flavor used to provision the zeppelin server.

- **kubernetes_workers_security_group_id**: Id of the kubernetes workers security group. The zeppelin will be given access on the **hive_metastore_port** port and will give access to the workers on its port **8080**.

- **additional_security_group_ids**: Array of security group ids to assign to the zeppelin server in additional to the server security group already assigned by the module.

- **network_id**: ID of the network to attach the zeppelin server to

- **keypair_name**: Name of the keypair that can be used to ssh to the server

- **bastion_security_group_id**: Id of pre-existing security group to add bastion rules to (defaults to "")

- **nameserver_ips**: Ips of nameservers that will be added to the list of nameservers the zeppelin server refers to to resolve domain names.

- **zeppelin_version**: Version of zeppelin. Defaults to **0.10.1**

- **zeppelin_mirror**: Mirror to download zeppelin from. Defaults to the university of Waterloo.

- **k8_executor_image**: Image to use to launch executor containers in kubernetes. Defaults to **chusj/spark:7508c20ef44952f1ee2af91a26822b6efc10998f**

- **k8_api_endpoint**: Kubernetes api endpoint that zeppelin will use to provision executors on kubernetes.

- **k8_ca_certificate**: Kubernetes ca certificate that zeppelin will use to authentify the api server.

- **k8_client_certificate**: Kubernetes client certificate that zeppelin will use to authentify itself to the api server.

- **k8_client_private_key**: Kubernetes private key that zeppelin will use to authentify itself to the api server.

- **s3_access**: S3 access key that zeppelin will use to identify itself to the s3 provider.

- **s3_secret**: S3 access key that zeppelin will use to authentify itself to the S3 provider.

- **s3_url**: url of the S3 provider that zeppelin will use.

- **hive_metastore_port**: Port that zeppelin will talk to on the k8 workers to access the hive metastore. Note that you still need to specify this port in the url argument below. This argument is simply to insure that the security groups on the k8 workers grant access to zeppelin on the given port.

- **hive_metastore_url**: Url of the hive metastore that zeppelin will use.

- **spark_sql_warehouse_dir**: S3 path of the spark sql warehouse.

- **notebook_s3_bucket**: S3 bucket under which zeppelin will store its notebooks.

- **keycloak**: Keycloak configuration for user authentication.
  - **enabled**: If set to false (the default), no user authentication will be in place.
  - **url**: Url of keycloak server.
  - **realm**: Name of keycloak realm.
  - **client_id**: Id of keycloak client.
  - **client_secret**: Secret of keycloak client.
  - **zeppelin_url**: Url of zeppelin.

# Output Variables

- id: ID of the generated zeppelin server compute instance

- ip: IP of the generated zeppelin server compute instance on the network it was attached to

- groups: The security groups giving access to the zeppeling server. The exported security groups (resources of type **openstack_networking_secgroup_v2**) are:
  - bastion: Servers able to access the zeppelin server with ssh traffic over port 22

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
  name = var.name
  image_source = {
    image_id = var.image_id
    volume_id = ""
  }
  flavor_id = var.flavors.small.id
  network_id = var.network.id
  kubernetes_workers_security_group_id = module.my_k8_cluster.groups.worker
  keypair_name = var.bastion_internal_keypair.name
  nameserver_ips = var.nameserver_ips
  k8_api_endpoint = "https://mykubernetesapi:6443"
  k8_ca_certificate = module.certificates.ca_certificate
  k8_client_certificate = module.certificates.client_certificate
  k8_client_private_key = tls_private_key.client.private_key_pem
  s3_access = local.my_zeppelin_bucket.access
  s3_secret = local.my_zeppelin_bucket.secret
  s3_url = "mys3server"
  hive_metastore_port = 9083
  hive_metastore_url = "myhivemetastore:9083"
  spark_sql_warehouse_dir = spark/mywharehouse
  notebook_s3_bucket = notebooks
}
```
