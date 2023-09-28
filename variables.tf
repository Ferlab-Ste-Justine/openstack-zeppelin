variable "name" {
  description = "Name to give to the vm, its port and the prefix of security groups"
  type = string
  default = ""
}

variable "image_source" {
  description = "Source of the vm's image"
  type = object({
    image_id = string
    volume_id = string
  })
}

variable "flavor_id" {
  description = "ID of the VM flavor for the node"
  type = string
}

variable "kubernetes_workers_security_group_id" {
  description = "Id of the security group for the kubernetes workers zeppelin will interact with"
  type = string
}

variable "additional_security_group_ids" {
  description = "Additional security groups of the node"
  type = list(string)
  default = []
}

variable "network_id" {
  description = "Id of the network the node will be attached to"
  type = string
}

variable "keypair_name" {
  description = "Name of the keypair that will be used to ssh to the node"
  type = string
}

variable "bastion_security_group_id" {
  description = "Id of pre-existing security group to add bastion rules to"
  type = string
  default = ""
}

variable "nameserver_ips" {
  description = "Ips of the nameservers"
  type = list(string)
  default = []
}

variable "zeppelin_version" {
  description = "Version of zeppelin"
  type = string
  default = "0.10.1"
}

variable "zeppelin_mirror" {
  description = "Mirror from which to download zeppelin"
  type = string
  default = "https://mirror.csclub.uwaterloo.ca"
}

variable "k8_executor_image" {
  description = "Image to launch k8 executor from"
  type = string
  default = "chusj/spark:7508c20ef44952f1ee2af91a26822b6efc10998f"
}

variable "k8_api_endpoint" {
  description = "Endpoint to access the k8 masters"
  type = string
}

variable "k8_ca_certificate" {
  description = "CA certicate of kubernetes api"
  type = string
}

variable "k8_client_certificate" {
  description = "Client certicate to access kubernetes api"
  type = string
}

variable "k8_client_private_key" {
  description = "Client private key to access kubernetes api"
  type = string
}

variable "s3_access" {
  description = "S3 access key"
  type = string
}

variable "s3_secret" {
  description = "S3 secret key"
  type = string
}

variable "s3_url" {
  description = "url of the S3 store"
  type = string
}

variable "hive_metastore_port" {
  description = "Port of the hive metastore on the kubernetes cluster"
  type = number
}

variable "hive_metastore_url" {
  description = "Url of the hive metastore"
  type = string
}

variable "spark_sql_warehouse_dir" {
  description = "S3 path of the spark sql warehouse"
  type = string
}

variable "notebook_s3_bucket" {
  description = "S3 bucket to store notebooks under"
  type = string
}

variable "keycloak" {
  description = "Keycloak configuration for user authentication"
  type        = object({
    enabled       = bool
    url           = string
    realm         = string
    client_id     = string
    client_secret = string
    zeppelin_url  = string
  })
  default = {
    enabled       = false
    url           = ""
    realm         = ""
    client_id     = ""
    client_secret = ""
    zeppelin_url  = ""
  }
}
