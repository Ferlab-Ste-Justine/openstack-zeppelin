variable "namespace" {
  description = "Namespace to create the resources under"
  type = string
  default = ""
}

variable "image_id" {
    description = "ID of the vm image used to provision the node"
    type = string
}

variable "flavor_id" {
  description = "ID of the VM flavor for the node"
  type = string
}

variable "security_group_ids" {
  description = "Security groups of the node"
  type = list(string)
  default = ["default"]
}

variable "network_id" {
  description = "Id of the network the node will be attached to"
  type = string
}

variable "keypair_name" {
  description = "Name of the keypair that will be used to ssh to the node"
  type = string
}

variable "nameserver_ips" {
  description = "Ips of the nameservers"
  type = list(string)
  default = []
}

variable "zeppelin_mirror" {
  description = "Mirror from which to download zeppelin"
  type = string
  default = "https://mirror.csclub.uwaterloo.ca"
}

variable "spark_mirror" {
  description = "Mirror from which to download spark"
  type = string
  default = "https://mirror.dsrg.utoronto.ca"
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