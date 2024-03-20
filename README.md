# About

This Terraform module provisions a Zeppelin VM in OpenStack. The Zeppelin server provisioned has the following characteristics:
- Provisions executors in a Kubernetes cluster.
- Uses S3 for storage.
- Utilizes an Hive metastore.
- Operates with Spark 3 in Scala.
- Saves its notebooks in S3.
- Expects to communicate with a group of Kubernetes workers to access the Hive metastore, with client traffic originating from the Kubernetes cluster's workers.
- Can use Keycloak for user authentication (with Shiro).

# Motivation

We experimented with orchestrating Zeppelin directly in Kubernetes using its built-in support for Kubernetes but found it too bleeding edge for current needs. It didn't work well out of the box, and while tweaking it towards a working solution, we realized the end result would be challenging to maintain. Therefore, we opted for a more manageable Zeppelin deployment outside of Kubernetes, with executors still running in Kubernetes.

# Input Variables

- **`name`**: Name to give to the VM, its port, and the prefix of security groups. It is a required variable with no default value.

- **`image_source`**: Source of the VM's image. This object has two keys, `image_id` for an image to associate with a VM that has local storage, and `volume_id` for a volume containing the OS to associate with the VM. Only one of the two fields should be used, with the other set to an empty string.

- **`flavor_id`**: ID of the VM flavor used to provision the Zeppelin server.

- **`kubernetes_workers_security_group_id`**: ID of the security group for the Kubernetes workers Zeppelin will interact with. Zeppelin will be given access on the `hive_metastore_port` port and will give access to the workers on its port `8080`.

- **`kubernetes_lb_security_group_id`**: Security group ID for Kubernetes load balancers.

- **`additional_security_group_ids`**: Array of additional security group IDs to assign to the Zeppelin server in addition to the server security group already assigned by the module.

- **`fluentd_security_group`**: Optional Fluentd security group configuration. It includes an `id` for the security group to add Fluentd rules to and a `port` the remote Fluentd node listens on.

- **`network_id`**: ID of the network to attach the Zeppelin server to.

- **`keypair_name`**: Name of the keypair that can be used to SSH to the server.

- **`client_group_ids`**: List of IDs of security groups that should have client access to the Zeppelin server.

- **`bastion_group_ids`**: List of IDs of security groups that should have bastion access to the Zeppelin server.

- **`metrics_server_group_ids`**: List of IDs of security groups that should have metrics server access to the Zeppelin server.

- **`nameserver_ips`**: IPs of nameservers that will be added to the list of nameservers the Zeppelin server refers to resolve domain names.

- **`zeppelin_version`**: Version of Zeppelin. Defaults to `0.11.0`.

- **`zeppelin_mirror`**: Mirror from which to download Zeppelin. Defaults to `https://mirror.csclub.uwaterloo.ca/apache`.

- **`k8_executor_image`**: Image to use to launch executor containers in Kubernetes. Defaults to `apache/spark:3.5.1`.

- **`k8_service_account_name`**, **`k8_namespace`**, **`k8_api_endpoint`**, **`k8_ca_certificate`**, **`k8_client_certificate`**, **`k8_client_private_key`**, **`s3_access`**, **`s3_secret`**, **`s3_url`**, **`hive_metastore_port`**, **`hive_metastore_url`**, **`spark_sql_warehouse_dir`**, **`notebook_s3_bucket`**, **`keycloak`**, and **`fluentbit`**: Additional configurations for Kubernetes service account, namespace, API endpoint, certificates, S3 credentials, Hive metastore settings, Spark SQL warehouse directory, notebook storage, Keycloak authentication, and Fluent-bit logging.

# Output Variables

- **`id`**: ID of the generated Zeppelin server compute instance.

- **`ip`**: IP of the generated Zeppelin server compute instance on the network it was attached to.

- **`groups`**: The security groups giving access to the Zeppelin server. The exported security groups (resources of type `openstack_networking_secgroup_v2`) include:
  - **`bastion`**: Servers able to access the Zeppelin
